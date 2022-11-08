//
//  ViewController.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 11/25/19.
//  Copyright © 2019 Mitek Systems Inc. All rights reserved.
//

import UIKit
import CoreNFC
import MiSnap
import MiSnapFacialCapture
import MiSnapVoiceCapture
import MiSnapNFC

class ViewController: UIViewController, CustomSegmentedControlDelegate {
    var resultVC: UIViewController?
    var result: MiSnapWorkflowResult?
    
    private var passportButton = UIButton()
    private var idCardButton = UIButton()
    
    private var enrollButton = UIButton()
    private var verifyButton = UIButton()
    private var enrollmentSegmentedControl = CustomSegmentedControl()
    private var verificationTypeLabel = UILabel()
    private var enrollView = UIView()
    private var verifyView = UIView()
    private var enrollmentInput = MiPassEnrollmentInput()
    private var enrollmentModification: MiPassEnrollmentModification = .newOrUpdateExisting
    private var phrase: String?
    
    private var containerView = UIView()
    private var versionLabel = UILabel()
    private var product: Product = .mobileVerify
    private var licenseStatus: MiSnapLicenseStatus?
    private var error: NSError?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSubviews()
        checkLicenseIfNeeded()
        checkErrorIfNeeded()
        presentResultVCIfNeeded()
    }
    
    // MARK: MobileVerify
    
    @objc func passportButtonAction(_ button: UIButton) {
        let miSnapWorkflowVC = MiSnapWorkflowViewController(with: [.passport, .face], delegate: self)
        presentWorkflowVC(miSnapWorkflowVC)
    }
    
    @objc func idCardButtonAction(_ button: UIButton) {
        let miSnapWorkflowVC = MiSnapWorkflowViewController(with: [.idFront, .idBack, .face], delegate: self)
        presentWorkflowVC(miSnapWorkflowVC)
    }
    
    // MARK: MiPass
    
    @objc private func enrollButtonAction() {
        handleEnrollmentReset { [weak self] enrollmentModification in
            guard enrollmentModification != .cancelled, let self = self else { return }
            self.enrollmentModification = enrollmentModification
            
            let miSnapWorkflowVC: MiSnapWorkflowViewController
            switch MiPassWorkflowType.from(self.enrollmentSegmentedControl.selectedIndex) {
            case .faceAndVoice:
                miSnapWorkflowVC = MiSnapWorkflowViewController(for: .enrollment, with: [.face, .voice], delegate: self)
            case .faceOnly:
                miSnapWorkflowVC = MiSnapWorkflowViewController(for: .enrollment, with: [.face], delegate: self)
            case .voiceOnly:
                miSnapWorkflowVC = MiSnapWorkflowViewController(for: .enrollment, with: [.voice], delegate: self)
            }
            self.presentWorkflowVC(miSnapWorkflowVC)
        }
    }
    
    @objc private func verifyButtonAction() {
        let miSnapWorkflowVC: MiSnapWorkflowViewController
        switch enrollmentInput.status {
        case .faceAndVoice:
            miSnapWorkflowVC = MiSnapWorkflowViewController(for: .verification, with: [.face, .voice], delegate: self, phrase: enrollmentInput.phrase)
        case .faceOnly:
            miSnapWorkflowVC = MiSnapWorkflowViewController(for: .verification, with: [.face], delegate: self, phrase: enrollmentInput.phrase)
        case .voiceOnly:
            miSnapWorkflowVC = MiSnapWorkflowViewController(for: .verification, with: [.voice], delegate: self, phrase: enrollmentInput.phrase)
        default:
            fatalError("Unhandled enrollment status")
        }
        presentWorkflowVC(miSnapWorkflowVC)
    }
    
    // MARK: Pre-check before presenting MiSnapWorkflowViewController
    
    private func presentWorkflowVC(_ vc: MiSnapWorkflowViewController) {
        let minDiskSpace: Int = 10 // Min disk spece in MB required to invoke MiSnapVoiceCaptureViewController
        if !MiSnapWorkflowViewController.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }

        MiSnapWorkflowViewController.checkMicrophonePermission { granted in
            if !granted {
                let message = "Microphone permission is required to record your voice samples that will be used for your enrollement and verification"
                self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: message)
                return
            }

            MiSnapWorkflowViewController.checkCameraPermission { granted in
                if !granted {
                    let message = "Camera permission is required to take your selfie that will be used for your enrollement and verification"
                    self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: message)
                    return
                }

                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: MiSnapWorkflowViewControllerDelegate callbacks
extension ViewController: MiSnapWorkflowViewControllerDelegate {
    func miSnapWorkflowLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle an invalid license status here
        licenseStatus = status
    }
    
    func miSnapWorkflowDidSelectPhrase(_ phrase: String) {
        // Handle a phrase selected by a user here when workflow is configured for Voice enrollment
        self.phrase = phrase
    }
    
    func miSnapWorkflowSuccess(_ result: MiSnapWorkflowResult) {
        // Uncomment code block below to access result
        //if let idFront = result.idFront {
        //    // Handle `idFront` result here
        //    if let encodedImage = idFront.encodedImage {
        //        // Send base64 encoded image to a back end
        //    }
        //    if let originalImage = idFront.image {
        //        // Display UIImage if needed
        //    }
        //    // Handle other `idFront` result here
        //}
        //
        //if let idBack = result.idBack {
        //    // Handle `idBack` result here
        //    if let encodedImage = idBack.encodedImage {
        //        // Send base64 encoded image to a back end
        //    }
        //    if let originalImage = idBack.image {
        //        // Display UIImage if needed
        //    }
        //    if let extraction = idBack.extraction, let pdf417 = extraction.barcodeString {
        //        // Send extracted barcode to a back end
        //    }
        //    // Handle other `idBack` result here
        //}
        //
        //if let passport = result.passport {
        //    // Handle `passport` result here
        //    if let encodedImage = passport.encodedImage {
        //        // Send base64 encoded image to a back end
        //    }
        //    if let originalImage = passport.image {
        //        // Display UIImage if needed
        //    }
        //    // Handle other `passport` result here
        //}
        //
        //if let passportQr = result.passportQr {
        //    // Handle `passportQr` result here
        //    if let originalImage = passportQr.image {
        //        // Send base64 encoded image to a back end
        //    }
        //    if let extraction = passportQr.extraction, let qrCode = extraction.personalNumber {
        //        // Send extracted QR code to a back end
        //    }
        //    // Handle other `passportQr` result here
        //}
        //
        //if let nfc = result.nfc {
        //    // Handle `nfc` result here
        //}
        //
        //if let face = result.face {
        //    // Handle `face` result here
        //    if let encodedImage = face.encodedImage {
        //        // Send base64 encoded image to a back end
        //    }
        //    if let originalImage = face.image {
        //        // Display UIImage if needed
        //    }
        //    // Handle other `face` result here
        //}
        //
        //if let voices = result.voice {
        //    // Handle `face` results here
        //    for voice in voices {
        //        if let data = voice.data {
        //            // Handle Data representation of a recorded .wav sample
        //        }
        //    }
        //}
        
        self.result = result
    }
    
    func miSnapWorkflowError(_ result: MiSnapWorkflowResult) {
        // Handle an SDK error here
        if let voice = result.voice, !voice.isEmpty {
            self.error = voice[0].error
        }
    }
    
    func miSnapWorkflowCancelled(_ result: MiSnapWorkflowResult) {
        // Handle a MiSnapWorkflow cancelled by a user event here
    }
            
    // Uncomment an optional callback below to get result for a step as it's completed
    //func miSnapWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep) {
    //    switch step {
    //    case .idFront:
    //        if let idFrontResult = result as? MiSnapResult {
    //            // Handle `idFront` result here if needed
    //        }
    //    case .idBack:
    //        if let idBackResult = result as? MiSnapResult {
    //            // Handle `idBack` result here if needed
    //        }
    //    case .passport:
    //        if let passport = result as? MiSnapResult {
    //            // Handle `passport` result here if needed
    //        }
    //    case .passportQr:
    //        if let passportQr = result as? MiSnapResult {
    //            // Handle `passportQr` result here if needed
    //        }
    //    case .nfc:
    //        if let nfc = result as? [String : Any] {
    //            // Handle `nfc` result here if needed
    //        }
    //    case .face:
    //        if let face = result as? MiSnapFacialCaptureResult {
    //            // Handle `face` result here if needed
    //        }
    //    case .voice:
    //        if let voice = result as? [MiSnapVoiceCaptureResult] {
    //            // Handle `voice` results here if needed
    //        }
    //    default:
    //        break
    //    }
    //}
}

// !!! ============= !!! ============= !!! ============= !!! ============= !!! ============= !!!
// MARK: Code below is for sample app's UI. Ignore it since it's not applicable to your app.
// !!! ============= !!! ============= !!! ============= !!! ============= !!! ============= !!!

// MARK: Private view configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) {
            if product == .miPass {
                manageEnrollment()
                manageVerification()
            }
            return
        }
        
        setGradientBackground()
        
        let segmentedControl = UISegmentedControl(items: Product.allCases.map { $0.rawValue })
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlAction(_ :)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "SelectedSegmentedControl")
        segmentedControl.tag = 1
        view.addSubview(segmentedControl)
        
        containerView = UIView(frame: view.frame)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        versionLabel = configureVersionLabel()
        view.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            segmentedControl.heightAnchor.constraint(equalToConstant: 35),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            versionLabel.widthAnchor.constraint(equalToConstant: versionLabel.frame.width),
            versionLabel.heightAnchor.constraint(equalToConstant: versionLabel.frame.height),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        configure(for: Product.from(segmentedControl.selectedSegmentIndex))
    }
    
    private func configure(for product: Product) {
        self.product = product
        
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        
        switch product {
        case .mobileVerify:     configureForMobileVerify()
        case .miPass:           configureForMiPass()
        }
    }
    
    @objc private func segmentedControlAction(_ segmentedControl: UISegmentedControl) {
        UserDefaults.standard.set(segmentedControl.selectedSegmentIndex, forKey: "SelectedSegmentedControl")
        UserDefaults.standard.synchronize()
        
        configure(for: Product.from(segmentedControl.selectedSegmentIndex))
    }
    
    private func checkLicenseIfNeeded() {
        guard let status = licenseStatus else { return }
        licenseValid(status)
        licenseStatus = nil
    }
    
    private func checkErrorIfNeeded() {
        guard let error = error else { return }
        presentAlert(withTitle: error.domain, message: error.localizedDescription)
        self.error = nil
    }
    
    private func presentResultVCIfNeeded() {
        guard let result = result else {
            resultVC = nil
            return
        }
        switch product {
        case .mobileVerify:
            resultVC = MobileVerifyResultViewController(with: result)
        case .miPass:
            resultVC = MiPassResultViewController(with: result, enrollmentInput: enrollmentInput, enrollmentModification: enrollmentModification, phrase: phrase)
        }
        
        guard let resultVC = resultVC else { return }
        present(resultVC, animated: true)
        self.result = nil
    }
}

// MARK: Common UI configuration
extension ViewController {
    private func setGradientBackground() {
        let colorTop = #colorLiteral(red: 0.05935008079, green: 0.2641155422, blue: 0.3017097414, alpha: 1).cgColor
        let colorBottom = #colorLiteral(red: 0.05098039216, green: 0.06274509804, blue: 0.2392156863, alpha: 1).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.frame
        
        view.layer.addSublayer(gradientLayer)
    }
    
    private func configureActivityView(withTitle title: String, someView: UIView? = nil, buttons: [UIButton]) -> UIView {
        let activityView = UIView(frame: view.frame)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = configureActivityLabel(withTitle: title)
        activityView.addSubview(label)
        if let someView = someView {
            activityView.addSubview(someView)
        }
        for button in buttons {
            activityView.addSubview(button)
        }
        
        let smallScreen = UIScreen.main.bounds.size.width < 375
        let spacing: CGFloat = smallScreen ? 10 : 30
        
        var activityViewHeight = spacing + label.frame.height + spacing / 2
        if let someView = someView {
            activityViewHeight += someView.frame.height + spacing * 2
        } else {
            activityViewHeight += spacing
        }
        for button in buttons {
            activityViewHeight += button.frame.height
        }
        activityViewHeight += CGFloat(buttons.count - 1) * spacing
                        
        NSLayoutConstraint.activate([
            activityView.widthAnchor.constraint(equalToConstant: activityView.frame.width),
            activityView.heightAnchor.constraint(equalToConstant: activityViewHeight),
            
            label.topAnchor.constraint(equalTo: activityView.topAnchor, constant: spacing),
            label.centerXAnchor.constraint(equalTo: activityView.centerXAnchor)
        ])
        
        var topAnchor = label.bottomAnchor
        var offset = spacing
        if let someView = someView {
            NSLayoutConstraint.activate([
                someView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: spacing / 3),
                someView.centerXAnchor.constraint(equalTo: activityView.centerXAnchor)
            ])
            topAnchor = someView.bottomAnchor
            offset = spacing * 2
        }
        
        for button in buttons {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor, constant: offset),
                button.centerXAnchor.constraint(equalTo: activityView.centerXAnchor)
            ])
            topAnchor = button.bottomAnchor
            offset = spacing
        }
        
        return activityView
    }
    
    private func configureButton(withTitle title: String, textColor: UIColor = .white, backgroundColor: UIColor = .systemBlue, action: Selector) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.04969549924, green: 0.5109332204, blue: 0.8450021744, alpha: 1)
        
        var buttonWidth = button.frame.width
        var buttonHeight = button.frame.height
        if let titleLabel = button.titleLabel {
            titleLabel.font = .systemFont(ofSize: 26, weight: .light)
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
    
            buttonWidth = titleLabel.frame.width < 300 ? 300 : titleLabel.frame.width
            buttonHeight = titleLabel.frame.height * 2
            
            button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: buttonWidth, height: buttonHeight)
        }
        
        button.layer.cornerRadius = buttonHeight / 2
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        return button
    }
    
    private func configureActivityLabel(withTitle title: String) -> UILabel {
        let label = UILabel(frame: view.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.sizeToFit()
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: label.frame.width),
            label.heightAnchor.constraint(equalToConstant: label.frame.height)
        ])
        
        return label
    }
    
    private func presentPermissionAlert(withTitle title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let openSettings = UIAlertAction(title: "Open Settings", style: .cancel) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(cancel)
            alert.addAction(openSettings)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func configureVersionLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: 40))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(MiSnap.version())"
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.6041179916, green: 0.6041179916, blue: 0.6041179916, alpha: 1)
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 19, weight: .regular)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: label.frame.width),
            label.heightAnchor.constraint(equalToConstant: label.frame.height)
        ])
        label.isUserInteractionEnabled = true
        
        return label
    }
    
    @discardableResult private func licenseValid(_ status: MiSnapLicenseStatus) -> Bool {
        if status != .valid && status != .expired {
            switch MiSnapLicenseManager.shared().status {
            case .none:                     presentAlert(withTitle: "License key is none", message: nil)
            case .notValid:                 presentAlert(withTitle: "License key is not valid", message: nil)
            case .disabled:                 presentAlert(withTitle: "License key is disabled", message: nil)
            case .notValidAppId:            presentAlert(withTitle: "Not valid application bundle identifier", message: nil)
            case .platformNotSupported:     presentAlert(withTitle: "iOS platform is not licensed", message: nil)
            case .featureNotSupported:      presentAlert(withTitle: "Feature is not licensed", message: nil)
            default:                        break
            }
            return false
        }
        
        if !MiSnapLicenseManager.shared().featureSupported(.voice) {
            presentAlert(withTitle: "Voice capture is not licensed", message: nil)
            return false
        }
        if !MiSnapLicenseManager.shared().featureSupported(.face) {
            presentAlert(withTitle: "Face capture is not licensed", message: nil)
            return false
        }
        return true
    }
}

// MARK: MobileVerify product configuration
extension ViewController {
    private func configureForMobileVerify() {
        passportButton = configureButton(withTitle: "Passport", action: #selector(passportButtonAction(_:)))
        idCardButton = configureButton(withTitle: "ID/DL/RP Front then Back", action: #selector(idCardButtonAction(_:)))
        
        let authenticationView = configureActivityView(withTitle: "Authentication", buttons: [passportButton, idCardButton])
        containerView.addSubview(authenticationView)
        
        NSLayoutConstraint.activate([
            authenticationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authenticationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        configureNfcStatusSubview()
    }
    
    private func configureNfcStatusSubview() {
        var iosSupported = false
        var nfcAntennaPresent = false
        
        if #available(iOS 13.0, *) {
            iosSupported = true
            if NFCTagReaderSession.readingAvailable {
                nfcAntennaPresent = true
            }
        }
        
        let supportLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        supportLabel.translatesAutoresizingMaskIntoConstraints = false
        supportLabel.text = "NFC reading support"
        supportLabel.font = .systemFont(ofSize: 15.0)
        supportLabel.textAlignment = .left
        
        let supportIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        supportIcon.translatesAutoresizingMaskIntoConstraints = false
        supportIcon.contentMode = .scaleAspectFit
        
        let horizontalStackView = UIStackView(arrangedSubviews: [supportLabel, supportIcon])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 2
        horizontalStackView.distribution = .fill
        
        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 3
        verticalStackView.distribution = .fill
                
        if iosSupported && nfcAntennaPresent {
            supportIcon.image = #imageLiteral(resourceName: "checkmark")
        } else {
            supportIcon.image = #imageLiteral(resourceName: "crossmark")
            
            if !iosSupported {
                add(message: "iOS >= 13.0 is required", to: verticalStackView)
            } else if !nfcAntennaPresent {
                add(message: "No NFC antenna", to: verticalStackView)
            }
        }
        
        containerView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            supportLabel.heightAnchor.constraint(equalToConstant: 30),
            
            supportIcon.widthAnchor.constraint(equalToConstant: 30),
            supportIcon.heightAnchor.constraint(equalToConstant: 30),
            
            verticalStackView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -20),
            verticalStackView.widthAnchor.constraint(equalToConstant: 175),
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func add(message: String, to stackView: UIStackView) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13.0)
        label.text = "\u{2022} " + message
        label.textAlignment = .left
        
        stackView.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
}

// MARK: MiPass product configuration
extension ViewController {
    private func configureForMiPass() {
        enrollButton = configureButton(withTitle: "Start enrollment", textColor: .white, backgroundColor: .systemBlue, action: #selector(enrollButtonAction))
        verifyButton = configureButton(withTitle: "Start verification", textColor: .white, backgroundColor: .systemBlue, action: #selector(verifyButtonAction))
        
        enrollmentSegmentedControl = CustomSegmentedControl(with: ["Face and Voice", "Face Only", "Voice Only"], delegate: self, frame: view.frame)
        enrollmentSegmentedControl.selectedIndex = 0
        
        verificationTypeLabel = configureVerificationTypeLabel(withTitle: enrollmentInput.status.stringValue)
        
        enrollView = configureActivityView(withTitle: "Enrollment", someView: enrollmentSegmentedControl, buttons: [enrollButton])
        verifyView = configureActivityView(withTitle: "Verification", someView: verificationTypeLabel, buttons: [verifyButton])
        
        let dividerView = configureDividerView()
        
        containerView.addSubview(enrollView)
        containerView.addSubview(dividerView)
        containerView.addSubview(verifyView)
                
        NSLayoutConstraint.activate([
            dividerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dividerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            enrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enrollView.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -20),
            
            verifyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verifyView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20)
        ])
        
        manageEnrollment()
        manageVerification()
    }
    
    private func handleEnrollmentReset(completed: @escaping (MiPassEnrollmentModification) -> Void) {
        if enrollmentInput.status == .notEnrolled {
            return completed(.newOrUpdateExisting)
        }
        let alert = UIAlertController(title: nil, message: "What kind of update do you want to do?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completed(.cancelled)
        }
        let updateExisting = UIAlertAction(title: "Update existing enrollment", style: .default) { _ in
            completed(.newOrUpdateExisting)
        }
        let reenroll = UIAlertAction(title: "Delete current enrollment and re-enroll", style: .default) { _ in
            completed(.deleteExistingAndReenroll)
        }
        alert.addAction(cancel)
        alert.addAction(updateExisting)
        alert.addAction(reenroll)
        
        present(alert, animated: true)
    }
    
    private func configureVerificationTypeLabel(withTitle title: String) -> UILabel {
        let label = UILabel(frame: view.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()
        
        if label.frame.width <= view.frame.width / 2 {
            label.frame = view.frame
            label.numberOfLines = 1
            label.sizeToFit()
        }
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: label.frame.width < 300 ? 300 : label.frame.width),
            label.heightAnchor.constraint(equalToConstant: label.frame.height)
        ])
        
        return label
    }
    
    private func configureDividerView() -> UIView {
        let dividerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width > 300 ? 300 : view.frame.width, height: 1))
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            dividerView.widthAnchor.constraint(equalToConstant: dividerView.frame.width),
            dividerView.heightAnchor.constraint(equalToConstant: dividerView.frame.height)
        ])
        
        return dividerView
    }
    
    private func manageEnrollment() {
        guard let _ = enrollmentInput.enrollmentId else { return }
        enrollButton.setTitle("Update enrollment", for: .normal)
    }
    
    private func manageVerification() {
        verifyView.alpha = enrollmentInput.status == .notEnrolled ? 0.2 : 1.0
        verifyView.isUserInteractionEnabled = enrollmentInput.status != .notEnrolled
        verificationTypeLabel.text = enrollmentInput.status.stringValue
    }
}
