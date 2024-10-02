//
//  ViewController.swift
//  MiSnapSampleApp
//
//  Created by Mitek Engineering on 1/10/22.
//

import UIKit
import MiSnapCore
import MiSnap
import MiSnapUX

class ViewController: UIViewController {
    private var misnapVC: MiSnapViewController?
    private var result: MiSnapResult?
    
    private var resultVC: ResultViewController?
        
    private let template = MiSnapConfiguration()
        // Customizes a guide view (a document outline + vignette)
        .withCustomGuide { guide in
            guide.vignette.style = .blur
            guide.vignette.alpha = 0.925
            // For all available Guide vignette view customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapVignetteConfiguration.html

            guide.outline.mainBorderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            // For all available Guide outline view customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapDocumentOutlineConfiguration.html
            
        }
        // Customizes a glare view that's presented when a glare is detected
        .withCustomGlare { glare in
            glare.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            glare.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).withAlphaComponent(0.35)
            // For all available Glare view customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapGlareViewConfiguration.html
        }
        // Customizes a real-time hint view
        .withCustomHint { hint in
            hint.size = hint.size.scaled(by: 0.8)
            hint.font = .systemFont(ofSize: 21.0, weight: .thin)
            hint.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).withAlphaComponent(0.7)
            // For all available Hint view customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapHintViewConfiguration.html
        }
        // Customizes a Document type label displayed at the top
        .withCustomDocumentLabel { documentLabel in
            documentLabel.font = .systemFont(ofSize: 18.0)
            // For all Document label customization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapLabelConfiguration.html
        }
        // Customizes the Cancel button
        .withCustomCancel { cancel in
            cancel.color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            cancel.style = .stroke
            cancel.size = cancel.size.scaled(by: 0.8)
            
            // For all available the Cancel button customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapCancelViewConfiguration.html
        }
        // Customizes the Help button
        .withCustomHelp { help in
            help.color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            help.style = .stroke
            help.size = help.size.scaled(by: 0.8)
            
            // For all available the Help button customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapHelpViewConfiguration.html
        }
        // Customizes the Torch button
        .withCustomTorch { torch in
            torch.colorEnabled = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            torch.colorDisabled = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            torch.style = .stroke
            torch.size = torch.size.scaled(by: 0.8)
            
            // For all available the Torch button customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapTorchViewConfiguration.html
        }
        // Customizes the Camera shutter button that's used to trigger an image acquisition in Manual mode
        .withCustomCameraShutter { cameraShutter in
            cameraShutter.color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            cameraShutter.style = .stroke
            cameraShutter.size = cameraShutter.size.scaled(by: 1.15)
            
            // For all available the Camera shutter button customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapCameraShutterViewConfiguration.html
        }
        // Customizes the Recording indicator that's displayed when Video Recording feature is enabled
        .withCustomRecordingIndicator { recordingIndicator in
            recordingIndicator.alpha = 0.8
            
            // For all available the Recording indicator customization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapRecordingIndicatorViewConfiguration.html
        }
        // Customizes the Success view at the end of a successful session
        .withCustomSuccess { success in
            success.checkmark.color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            success.checkmark.cutoutFillColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
            
            // For all available the Success checkmark customization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapSuccessCheckmarkViewConfiguration.html
            
            success.message.font = .systemFont(ofSize: 35.0, weight: .bold)
            
            // For all available the Success message customization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapLabelConfiguration.html
        }
        // Customizes UX parameters
        .withCustomUxParameters { uxParameters in
            uxParameters.timeout = 25.0
            uxParameters.useCustomTutorials = true
            uxParameters.instructionMode = .noInstruction
            uxParameters.reviewMode = .noReview
            
            // For all available UX parameters customization options see this API reference: https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapUxParameters.html
        }
        // Customizes localization
        .withCustomLocalization { localization in
            localization.bundle = .main
            localization.stringsName = "MiSnapLocalizable"
            
            // For all available Localization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapLocalizationConfiguration.html
        }
        // Customizes asset location
        .withCustomAssetLocation { assetLocation in
            assetLocation.bundle = .main
            
            // For all available Localization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapAssetLocationConfiguration.html
        }
        // Customizes tutorial (introductory instruction, help, timeout, review)
        .withCustomTutorial { tutorial in
            tutorial.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            
            // For all available Tutorial options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapTutorialConfiguration.html
            
            tutorial.buttons.barColor = #colorLiteral(red: 0.1454155445, green: 0.1572948992, blue: 0.1745085716, alpha: 1)
            
            // For all available Tutorial buttons customization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapTutorialButtonsConfiguration.html
            
            tutorial.instruction.message.font = .systemFont(ofSize: 22.0, weight: .thin)
            
            // For all available Tutorial instruction customization options see this API reference: https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapTutorialInstructionConfiguration.html#/c:@M@MiSnapUX@objc(cs)MiSnapTutorialInstructionConfiguration(py)message
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        misnapVC = nil
        resultVC = nil
        
        configureSubviews()
        
        if let result = result {
            resultVC = ResultViewController(with: result)
            guard let resultVC = resultVC else { return }
            present(resultVC, animated: true)
            self.result = nil
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: Invoking MiSnap document types
extension ViewController {
    @objc private func anyIdButtonAction() {
        let configuration = MiSnapConfiguration(for: .anyId)
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func passportButtonAction() {
        let configuration = MiSnapConfiguration(for: .passport)
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func idFrontButtonAction() {
        let configuration = MiSnapConfiguration(for: .idFront)
            .withCustomParameters { parameters in
                parameters.science.documentTypeName = "DL Front" // where `DL Front` is a key in `Localizable.strings` (custom localization)
            }
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func idBackButtonAction() {
        let configuration = MiSnapConfiguration(for: .idBack)
            .withCustomParameters { parameters in
                parameters.science.documentTypeName = "DL Back" // where `DL Back` is a key in `Localizable.strings` (custom localization)
            }
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func checkFrontButtonAction() {
        let configuration = MiSnapConfiguration(for: .checkFront)
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func checkBackButtonAction() {
        let configuration = MiSnapConfiguration(for: .checkBack)
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func genericButtonAction() {
        let configuration = MiSnapConfiguration(for: .generic)
            .applying(template)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
}

// MARK: MiSnapViewControllerDelegate callbacks
extension ViewController: MiSnapViewControllerDelegate {
    // Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
    func miSnapLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle a license status here
    }
    
    func miSnapSuccess(_ result: MiSnapResult) {
        // Handle successful session results here
        self.result = result
    }
    
    func miSnapCancelled(_ result: MiSnapResult) {
        // Handle cancelled session results here
    }
    
    func miSnapException(_ exception: NSException) {
        // Handle exception that was caught by the SDK here
    }
    
    /*
     Implementing optional callback since `useCustomTutorials` of `MiSnapUxParameters`
     was overridden to `true` in template configuration
     */
    func miSnapCustomTutorial(_ documentType: MiSnapScienceDocumentType, tutorialMode: MiSnapUxTutorialMode, mode: MiSnapMode, statuses: [NSNumber]?, image: UIImage?) {
        guard let misnapVC = misnapVC else { return }
        
        let helpVC = CustomTutorialViewController(for: documentType, tutorialMode: tutorialMode, mode: mode, statuses: statuses, image: image, delegate: misnapVC)
        misnapVC.present(helpVC, animated: true)
    }
}

// MARK: Views configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) { return }
        
        let anyIdButton = configureButton(withTitle: "Any ID", selector: #selector(anyIdButtonAction))
        let passportButton = configureButton(withTitle: "Passport", selector: #selector(passportButtonAction))
        let idFrontButton = configureButton(withTitle: "ID Front", selector: #selector(idFrontButtonAction))
        let idBackButton = configureButton(withTitle: "ID Back", selector: #selector(idBackButtonAction))
        let checkFrontButton = configureButton(withTitle: "Check Front", selector: #selector(checkFrontButtonAction))
        let checkBackButton = configureButton(withTitle: "Check Back", selector: #selector(checkBackButtonAction))
        let genericButton = configureButton(withTitle: "Generic", selector: #selector(genericButtonAction))
        
        let buttonsStackView = UIStackView(arrangedSubviews: [anyIdButton, passportButton, idFrontButton, idBackButton, checkFrontButton, checkBackButton, genericButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = view.frame.height > 667 ? 35 : view.frame.height < 665 ? 10 : 20
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.tag = 1
        
        view.addSubview(buttonsStackView)
        
        let buttonsStackViewHeight: CGFloat = CGFloat(buttonsStackView.arrangedSubviews.count) * 40 + CGFloat(buttonsStackView.arrangedSubviews.count - 1) * buttonsStackView.spacing
        
        let appNameLabel = configureLabel(withText: "MiSnapCustomizationSampleApp")
        let misnapUxVersionLabel = configureLabel(withText: "MiSnapUX \(MiSnapUX.version())", fontSize: 17)
        let misnapVersionLabel = configureLabel(withText: "MiSnap \(MiSnap.version())", fontSize: 17)
        
        view.addSubview(appNameLabel)
        view.addSubview(misnapUxVersionLabel)
        view.addSubview(misnapVersionLabel)
        
        NSLayoutConstraint.activate([
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: buttonsStackViewHeight),
            
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            misnapVersionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            misnapVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            misnapUxVersionLabel.bottomAnchor.constraint(equalTo: misnapVersionLabel.topAnchor, constant: -5),
            misnapUxVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemBlue.withAlphaComponent(0.4), for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 19.0, weight: .bold)
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: button.frame.width),
            button.heightAnchor.constraint(equalToConstant: button.frame.height)
        ])
        
        return button
    }
    
    private func configureLabel(withText text: String, numberOfLines: Int = 1, fontSize: CGFloat = 19.0) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: CGFloat(numberOfLines * 27)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: .thin)
        label.numberOfLines = numberOfLines
        label.textAlignment = .center
        
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
            let openSettings = UIAlertAction(title: "Open Settings", style: .cancel) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(cancel)
            alert.addAction(openSettings)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentAlert(withTitle title: String?, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentMiSnap(_ misnap: MiSnapViewController?) {
        guard let misnap = misnap else { return }
        
        let minDiskSpace: Int = 20
        if misnap.configuration.parameters.camera.recordVideo && !MiSnapViewController.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }
        
        MiSnapViewController.checkCameraPermission { granted in
            if !granted {
                var message = "Camera permission is required to capture your documents."
                if misnap.configuration.parameters.camera.recordVideo {
                    message = "Camera permission is required to capture your documents and record videos of the entire process as required by a country regulation."
                }
                
                self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: message)
                return
            }
            
            if misnap.configuration.parameters.camera.recordVideo && misnap.configuration.parameters.camera.recordAudio {
                MiSnapViewController.checkMicrophonePermission { granted in
                    if !granted {
                        let message = "Microphone permission is required to record audio as required by a country regulation."
                        self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: message)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.present(misnap, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.present(misnap, animated: true)
                }
            }
        }
    }
}
