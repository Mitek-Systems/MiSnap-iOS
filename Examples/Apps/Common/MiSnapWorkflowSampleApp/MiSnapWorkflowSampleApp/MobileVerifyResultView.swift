//
//  MobileVerifyResultView.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 6/30/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapNFC

private enum ResultSection: String, CaseIterable, Equatable {
    case summary = "Summary"
    case details = "Details"
    case extractedData = "Extracted Data"
    
    static func section(from index: Int) -> ResultSection {
        switch index {
        case 0: return .summary
        case 1: return .details
        case 2: return .extractedData
        default: return .summary
        }
    }
}

class MobileVerifyResultView: UIStackView {
    private let serverResult: MobileVerifyResult?
    private let result: MiSnapWorkflowResult
    
    private var frontImage: UIImage? {
        if let idFront = result.idFront {
            return idFront.image
        } else if let passport = result.passport {
            return passport.image
        }
        return nil
    }
    private var backImage: UIImage? {
        if let idBack = result.idBack {
            return idBack.image
        } else if let passportQr = result.passportQr {
            return passportQr.image
        }
        return nil
    }
    private var nfcImage: UIImage? {
        if let nfc = result.nfc, let image = nfc[MiSnapNFCKey.faceImage] as? UIImage {
            return image
        }
        return nil
    }
    private var faceImage: UIImage? {
        return result.face?.image
    }
    private var images: [UIImage] {
        var images: [UIImage] = []
        if let frontImage = frontImage {
            images.append(frontImage)
        }
        if let backImage = backImage {
            images.append(backImage)
        }
        if let nfcImage = nfcImage {
            images.append(nfcImage)
        }
        if let faceImage = faceImage {
            images.append(faceImage)
        }
        return images
    }
    
    private var segmentedControl: UISegmentedControl!
    private var scrollView: UIScrollView!
    private var verticalStackView: UIStackView!
    
    private var heightConstant: CGFloat = 0
    private var widthConstant: CGFloat = 0
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(with result: MiSnapWorkflowResult, serverResult: MobileVerifyResult?, frame: CGRect) {
        self.result = result
        self.serverResult = serverResult
                
        super.init(frame: frame)
        self.frame = frame
        
        heightConstant = 50
        widthConstant = frame.size.width * 0.95
        axis = .vertical
        distribution = .fill
        spacing = 5
        translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 5
        verticalStackView.distribution = .equalSpacing
        
        configureInitialSubviews()
        configureScrollView(for: segmentedControl.selectedSegmentIndex)
    }
    
    public func configureInitialSubviews() {
        let horizontalStack = UIStackView()
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
    
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            horizontalStack.addArrangedSubview(imageView)
        }
        
        horizontalStack.isLayoutMarginsRelativeArrangement = true
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 2
        
        var items = [String]()
        for section in ResultSection.allCases {
            items.append(section.rawValue)
        }
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
            horizontalStack.heightAnchor.constraint(equalToConstant: frame.size.height * 0.25),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func addHeader(withTitle title: String) {
        let header = ResultLabel(with: title, frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
        header.translatesAutoresizingMaskIntoConstraints = false
        header.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        
        verticalStackView.addArrangedSubview(header)
    }
    
    private func addFinding(_ finding: MobileVerifyFinding) {
        let findingView = JudgementView(with: finding.name.summary,
                                        judgementIcon: finding.judgement.image,
                                        frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
        findingView.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView.addArrangedSubview(findingView)
    }
    
    private func addVerifications(_ verifications: [MobileVerifyVerification]) {
        for verification in verifications {
            let verificationView = JudgementView(with: verification.name,
                                                 judgementIcon: verification.judgement.image,
                                                 notifications: verification.notifications,
                                                 frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
            verificationView.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview(verificationView)
        }
    }
    
    private func addGenericInfo(withTitle title: String, value: String, split: CGFloat = 1) {
        let genericInfoView = InfoView(with: title, values: [value], split: split,
                                       frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant))
        genericInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView.addArrangedSubview(genericInfoView)
    }
    
    // TODO: is it the same as `addGenericInfo` above
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
    
    private func addExtractedDataSection(for infos: [String]) {
        for info in infos {
            let components = info.split(separator: ":")
            if components.count > 1 {
                let title = String(components[0])
                let value = String(components[1])
                
                var values: [String] = [value]
                if components.count == 3 {
                    values.append(String(components[2]))
                }
                
                let documentInfoView = InfoView(with: title, titleSize: 17,
                                                values: values, valueSize: 17,
                                                frame: CGRect(x: 0, y: 0, width: widthConstant, height: heightConstant * 0.9))
                documentInfoView.translatesAutoresizingMaskIntoConstraints = false
                
                verticalStackView.addArrangedSubview(documentInfoView)
            }
        }
    }
    
    private func finishConfiguring() {
        scrollView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            verticalStackView.widthAnchor.constraint(equalToConstant: widthConstant),
            verticalStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    private func configureForSummary() {
        guard let serverResult = serverResult else {
            return addNotification(withText: "Summary is not available in offline mode")
        }
        
        addFinding(serverResult.overallFinding)
        
        addHeader(withTitle: "Document Authentication")
        
        if let nfcFinding = serverResult.nfcFinding {
            addFinding(nfcFinding)
        }
        
        if let opticalFinding = serverResult.opticalFinding {
            addFinding(opticalFinding)
        }
        
        addHeader(withTitle: "Biometric Verification")
        
        if let faceComparisonFinding = serverResult.faceComparisonFinding {
            addFinding(faceComparisonFinding)
        }
        
        if let faceLivenessFinding = serverResult.faceLivenessFinding {
            addFinding(faceLivenessFinding)
        }
    }
    
    private func configureForDetails() {
        guard let serverResult = serverResult else {
            return addNotification(withText: "Details are not available in offline mode")
        }
        
        if let nfcFinding = serverResult.nfcFinding {
            addHeader(withTitle: "NFC Authenticators")
            addVerifications(nfcFinding.verifications)
        }
        
        if let opticalFinding = serverResult.opticalFinding {
            addHeader(withTitle: "Optical Authenticators")
            addVerifications(opticalFinding.verifications)
        }
        
        if let faceComparisonFinding = serverResult.faceComparisonFinding {
            addHeader(withTitle: "Biometric Authenticators")
            addVerifications(faceComparisonFinding.verifications)
        }
        
        if let faceLivenessFinding = serverResult.faceLivenessFinding {
            addVerifications(faceLivenessFinding.verifications)
        }
        
        addHeader(withTitle: "Performance")
        addGenericInfo(withTitle: "Total roundtrip time, ms", value: "\(serverResult.roundtripTime)", split: 9/3)
        addGenericInfo(withTitle: "Server processing time, ms", value: "\(serverResult.processingTime)", split: 9/3)
        
        if let dossierId = serverResult.dossierId {
            addHeader(withTitle: "Metadata")
            addGenericInfo(withTitle: "Dossier ID", value: dossierId, split: 3/10)
        }
    }
    
    private func configureForExtractedData() {
        guard let serverResult = serverResult else {
            return addNotification(withText: "Extracted data is not available in offline mode")
        }
        
        addHeader(withTitle: "Bio Info")
        addExtractedDataSection(for: serverResult.bioInfo)
        
        addHeader(withTitle: "Address")
        addExtractedDataSection(for: serverResult.address)
        
        addHeader(withTitle: "Document Info")
        addExtractedDataSection(for: serverResult.documentInfo)
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
        case .extractedData:    configureForExtractedData()
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
