//
//  MiPassResultView.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 7/13/21.
//

import UIKit
import MiSnapVoiceCapture
import MiSnapFacialCapture

private enum ResultSection: String, CaseIterable, Equatable {
    case summary = "Summary"
    case details = "Details"
    
    static func section(from index: Int) -> ResultSection {
        switch index {
        case 0:     return .summary
        case 1:     return .details
        default:    fatalError("No result section with index \"\(index)\"")
        }
    }
}

class MiPassResultView: UIStackView {
    private let serverResult: MiPassResult?
    private let result: MiSnapWorkflowResult
    
    private var segmentedControl: UISegmentedControl!
    private var scrollView: UIScrollView!
    private var verticalStackView: UIStackView!
    
    private let heightConstant: CGFloat = 50
    private var widthConstant: CGFloat!
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var voiceClientInfo: [String]? {
        var info: [String] = []
        if let voiceResults = result.voice {
            if voiceResults.count > 1 {
                for (idx, result) in voiceResults.enumerated() {
                    info.append("Recording \(idx + 1)")
                    if let data = result.data {
                        info.append("\tData size:\(data.size(.useKB))")
                    }
                    info.append("\tSpeech Length:\(String(format: "%.0f", result.speechLength)) ms")
                    info.append("\tSignal-to-Noise Ratio:\(String(format: "%.2f", result.snr)) dB")
                }
            } else {
                if let data = voiceResults[0].data {
                    info.append("Data size:\(data.size(.useKB))")
                }
                info.append("Speech Length:\(String(format: "%.0f", voiceResults[0].speechLength)) ms")
                info.append("Signal-to-Noise Ratio:\(String(format: "%.2f", voiceResults[0].snr)) dB")
            }
        }
        
        if info.isEmpty {
            return nil
        }
        return info
    }
    
    public init(with serverResult: MiPassResult?, result: MiSnapWorkflowResult, frame: CGRect) {
        self.serverResult = serverResult
        self.result = result
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 5
        distribution = .fill
        
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        widthConstant = frame.width * 0.95
        configureInitialSubviews()
        configureScrollView(for: segmentedControl.selectedSegmentIndex)
    }
}

// MARK: Private views configuration functions
extension MiPassResultView {
    private func configureInitialSubviews() {
        let horizontalStackMultiplier = 0.25
        
        let horizontalStack = UIStackView()
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 2
        horizontalStack.alignment = .center
        
        if let faceResult = result.face, let image = faceResult.image {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.height * horizontalStackMultiplier * 9 / 16, height: frame.height * horizontalStackMultiplier))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            horizontalStack.addArrangedSubview(imageView)
        }
        
        if let voiceResults = result.voice {
            for (idx, voiceResult) in voiceResults.enumerated() {
                guard let data = voiceResult.data else { continue }
                let recordingPlaybackView = RecordingPlaybackView(with: data, index: idx + 1, frame: CGRect(x: 0,
                                                                                                            y: 0,
                                                                                                            width: frame.height * horizontalStackMultiplier * 9 / 16,
                                                                                                            height: frame.height * horizontalStackMultiplier))
                horizontalStack.addArrangedSubview(recordingPlaybackView)
            }
        }
        
        let items = ResultSection.allCases.map { $0.rawValue }
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        addArrangedSubview(horizontalStack)
        addArrangedSubview(segmentedControl)
        addArrangedSubview(scrollView)
        
        NSLayoutConstraint.activate([
            horizontalStack.heightAnchor.constraint(equalToConstant: frame.size.height * horizontalStackMultiplier),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        verticalStackView = UIStackView(frame: frame)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 5
        verticalStackView.distribution = .fill
    }
    
    private func finishConfiguring() {
        scrollView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            verticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            verticalStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    private func configureForSummary() {
        guard let serverResult = serverResult else {
            return addNotification(withText: "Summary is not available in offline mode")
        }
        
        addJudgement(withTitle: "Overall \(result.activity == .enrollment ? "Enrollment" : "Verification")", judgment: serverResult.judgement)
        if let voiceJudgement = serverResult.voiceJudgement {
            addJudgement(withTitle: "Voice", judgment: voiceJudgement)
        }
        
        if let faceJudgement = serverResult.faceJudgement {
            addJudgement(withTitle: "Face", judgment: faceJudgement)
        }
    }
    
    private func configureForDetails() {
        var addedVoiceHeader: Bool = false
        if let voiceClientInfo = voiceClientInfo {
            addHeader(withTitle: "Voice Result")
            addInfoSection(for: voiceClientInfo)
            addedVoiceHeader = true
        }
        if let serverResult = serverResult, let errors = serverResult.voiceErrors, !errors.isEmpty {
            if !addedVoiceHeader {
                addHeader(withTitle: "Voice Result")
            }
            addInfoView(for: errors)
        }
        
        if let serverResult = serverResult, let errors = serverResult.faceErrors, !errors.isEmpty {
            addHeader(withTitle: "Face Result")
            addInfoView(for: errors)
        }
    }
    
    private func addHeader(withTitle title: String) {
        let view = ResultLabel(with: title, frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: heightConstant)
        ])
        
        verticalStackView.addArrangedSubview(view)
    }
    
    private func addJudgement(withTitle title: String, judgment: MitekPlatformJudgement) {
        let view = JudgementView(with: title, judgementIcon: judgment.image, frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
        view.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.addArrangedSubview(view)
    }
    
    private func addNotification(withText text: String) {
        let view = ResultLabel(with: text, alignement: .left, bgColor: .clear, frame: CGRect(x: 0, y: 0, width: widthConstant, height: frame.height))
        view.sizeToFit()
        view.frame = CGRect(x: 0, y: 0, width: widthConstant, height: view.frame.height < heightConstant ? heightConstant : view.frame.height)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.frame.height)
        ])
        
        verticalStackView.addArrangedSubview(view)
    }
    
    private func addInfoSection(for infos: [String]) {
        for info in infos {
            let components = info.split(separator: ":")
            
            let title = String(components[0])
            
            var values: [String] = []
            
            if components.count == 2 {
                values.append(String(components[1]))
            } else if components.count == 3 {
                values.append(String(components[2]))
            }
            
            let info = InfoView(with: title,
                                values: values.isEmpty ? nil : values,
                                frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
            
            verticalStackView.addArrangedSubview(info)
        }
    }
    
    private func addInfoView(for infos: [String]) {
        for info in infos {
            let infoView = InfoView(with: info,
                                    values: nil,
                                    frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
            
            verticalStackView.addArrangedSubview(infoView)
        }
    }
    
    @objc private func segmentedControlAction() {
        configureScrollView(for: segmentedControl.selectedSegmentIndex)
    }
    
    private func configureScrollView(for index: Int) {
        let resultSection = ResultSection.section(from: index)
        configureScrollView(for: resultSection)
    }
    
    private func configureScrollView(for resultSection: ResultSection) {
        clearSubviews()
        switch resultSection {
        case .summary:          configureForSummary()
        case .details:          configureForDetails()
        }
        finishConfiguring()
    }
    
    private func clearSubviews() {
        for subview in scrollView.subviews {
            NSLayoutConstraint.deactivate(subview.constraints)
            subview.removeFromSuperview()
        }
        
        for subview in verticalStackView.subviews {
            NSLayoutConstraint.deactivate(subview.constraints)
            subview.removeFromSuperview()
        }
    }
}
