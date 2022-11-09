//
//  ResultViewController.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Mitek Engineering on 3/23/22.
//

import UIKit
import MiSnapVoiceCapture

extension Data {
    func size(_ unit: ByteCountFormatter.Units) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [unit]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
    }
}

class ResultViewController: UIViewController {
    private var results: [MiSnapVoiceCaptureResult]?
    private var configured: Bool = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with results: [MiSnapVoiceCaptureResult]) {
        self.results = results
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var backgroundColor: UIColor = .white
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        }
        view.backgroundColor = backgroundColor
        
        configureSubviews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: Private views configurations functions
extension ResultViewController {
    private func configureSubviews() {
        guard let results = results, !configured else { return }
        configured = true
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(#colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
        backButton.backgroundColor = .clear
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        let audioPreviewView = configureAudioPreviewView(with: results)
        let audioInfoView = configureAudioInfoView(with: results)
        
        view.addSubview(backButton)
        view.addSubview(audioPreviewView)
        view.addSubview(audioInfoView)
        
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            backButton.topAnchor.constraint(equalTo: view.topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 60),
            
            audioPreviewView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            audioPreviewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            audioInfoView.topAnchor.constraint(equalTo: audioPreviewView.bottomAnchor, constant: 10),
            audioInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioInfoView.widthAnchor.constraint(equalToConstant: audioInfoView.frame.width),
            audioInfoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureAudioPreviewView(with results: [MiSnapVoiceCaptureResult]) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.95, height: view.frame.height * 0.20))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.tag = 1
        let spacing: CGFloat = 10
        
        var width: CGFloat = 0.0
        var currentView: UIView?
        
        for (idx, result) in results.enumerated() {
            guard let data = result.data else { continue }
            let recordingPlaybackView = RecordingPlaybackView(with: data, index: idx + 1, rect: CGRect(x: 0,
                                                                                                       y: 0,
                                                                                                       width: containerView.frame.width / CGFloat(results.count < 3 ? 3 : results.count),
                                                                                                       height: containerView.frame.height))
            containerView.addSubview(recordingPlaybackView)
            
            let xAnchor: NSLayoutXAxisAnchor
            var offset: CGFloat = 0.0
            if let currentView = currentView {
                xAnchor = currentView.rightAnchor
                offset = spacing
            } else {
                xAnchor = containerView.leftAnchor
            }
            
            NSLayoutConstraint.activate([
                recordingPlaybackView.leftAnchor.constraint(equalTo: xAnchor, constant: offset),
                recordingPlaybackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                recordingPlaybackView.widthAnchor.constraint(equalToConstant: recordingPlaybackView.frame.width - spacing),
                recordingPlaybackView.heightAnchor.constraint(equalToConstant: recordingPlaybackView.frame.height),
            ])
            
            currentView = recordingPlaybackView
            width += recordingPlaybackView.frame.width - spacing
        }
        
        width += CGFloat(results.count - 1) * spacing
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: width),
            containerView.heightAnchor.constraint(equalToConstant: containerView.frame.height),
        ])
        
        return containerView
    }
    
    private func configureAudioInfoView(with results: [MiSnapVoiceCaptureResult]) -> UIView {
        let containerView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.95, height: view.frame.height * 0.8))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.showsVerticalScrollIndicator = false
        containerView.bounces = false
        
        let spacing: CGFloat = 10
        
        var currentView: UIView?
        var height: CGFloat = 0.0
        
        for (idx, result) in results.enumerated() {
            let headerView = configureInfoView(withTitle: "Recording \(idx + 1)", fontWeight: .bold)
            containerView.addSubview(headerView)
            
            let dataSizeView = configureInfoView(withTitle: "Data size", value: (result.data ?? Data()).size(.useKB))
            containerView.addSubview(dataSizeView)
            
            let speechLengthView = configureInfoView(withTitle: "Speech Length", value: String(format: "%.0f ms", result.speechLength))
            containerView.addSubview(speechLengthView)
            
            let snrView = configureInfoView(withTitle: "Signal-to-Noise Ratio", value: String(format: "%.2f dB", result.snr))
            containerView.addSubview(snrView)
            
            let yAnchor: NSLayoutYAxisAnchor
            var offset = 0.0
            if let currentView = currentView {
                yAnchor = currentView.bottomAnchor
                offset = spacing * 3
            } else {
                yAnchor = containerView.topAnchor
            }
            
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: yAnchor, constant: offset),
                headerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                dataSizeView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: spacing),
                dataSizeView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                speechLengthView.topAnchor.constraint(equalTo: dataSizeView.bottomAnchor, constant: spacing),
                speechLengthView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                snrView.topAnchor.constraint(equalTo: speechLengthView.bottomAnchor, constant: spacing),
                snrView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            ])
            
            height += headerView.frame.height + dataSizeView.frame.height + speechLengthView.frame.height + snrView.frame.height + 3 * spacing
            currentView = snrView
        }
        
        height += CGFloat(results.count - 1) * spacing * 3
                
        containerView.contentSize = CGSize(width: containerView.frame.width, height: height)
        
        return containerView
    }
    
    private func configureInfoView(withTitle title: String, fontWeight: UIFont.Weight = .thin, value: String? = nil) -> UIView {
        let minHeight: CGFloat = 30.0
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.95, height: view.frame.height * 0.65))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTitle = UILabel(frame: containerView.frame)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.text = title
        labelTitle.textAlignment = .center
        labelTitle.font = .systemFont(ofSize: 17.0, weight: fontWeight)
        labelTitle.numberOfLines = 0
        if let value = value {
            labelTitle.textAlignment = .left
            labelTitle.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: view.frame.height * 0.65)
            
            let labelValue = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.2, height: view.frame.height * 0.65))
            labelValue.translatesAutoresizingMaskIntoConstraints = false
            labelValue.text = value
            labelValue.textAlignment = .right
            labelValue.font = .systemFont(ofSize: 17.0, weight: fontWeight)
            labelValue.sizeToFit()
            containerView.addSubview(labelValue)
            
            NSLayoutConstraint.activate([
                labelValue.widthAnchor.constraint(equalToConstant: labelValue.frame.width),
                labelValue.heightAnchor.constraint(equalToConstant: labelValue.frame.height > minHeight ? labelValue.frame.height : minHeight),
                labelValue.topAnchor.constraint(equalTo: containerView.topAnchor),
                labelValue.rightAnchor.constraint(equalTo: containerView.rightAnchor)
            ])
        }
        labelTitle.sizeToFit()
        containerView.addSubview(labelTitle)
        
        containerView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: labelTitle.frame.height > minHeight ? labelTitle.frame.height : minHeight)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: containerView.frame.width),
            containerView.heightAnchor.constraint(equalToConstant: containerView.frame.height),
            
            labelTitle.widthAnchor.constraint(equalToConstant: labelTitle.frame.width),
            labelTitle.heightAnchor.constraint(equalToConstant: labelTitle.frame.height > minHeight ? labelTitle.frame.height : minHeight),
            labelTitle.topAnchor.constraint(equalTo: containerView.topAnchor),
            labelTitle.leftAnchor.constraint(equalTo: containerView.leftAnchor)
        ])
        
        return containerView
    }
    
    @objc private func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}
