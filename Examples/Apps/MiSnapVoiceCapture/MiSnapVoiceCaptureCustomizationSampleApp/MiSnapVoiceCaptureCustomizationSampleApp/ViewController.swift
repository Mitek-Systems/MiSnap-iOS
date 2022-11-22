//
//  ViewController.swift
//  MiSnapVoiceCaptureSampleApp
//
//  Created by Mitek Engineering on 9/14/22.
//

import UIKit
import MiSnapVoiceCaptureUX
import MiSnapVoiceCapture
import MiSnapLicenseManager

class ViewController: UIViewController {
    private var misnapVoiceCaptureVC: MiSnapVoiceCaptureViewController?
    private var results: [MiSnapVoiceCaptureResult]?
    
    private var resultVC: ResultViewController?
    
    private let template = MiSnapVoiceCaptureConfiguration()
        .withCustomUxParameters { uxParameters in
            uxParameters.autoDismiss = false
        }
        .withCustomPhraseSelection { phraseSelection in
            phraseSelection.message.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            phraseSelection.phrase.font = .systemFont(ofSize: 21.0, weight: .bold)
            
            phraseSelection.buttons.proceed.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        .withCustomIntroductoryInstruction { introductoryInstruction in
            introductoryInstruction.instruction.font = .systemFont(ofSize: 29, weight: .thin)
            
            introductoryInstruction.buttons.proceed.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        .withCustomRecording { recording in
            recording.success.color = .systemBlue
            recording.success.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            
            recording.neutral.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            recording.neutral.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            
            recording.failure.color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            recording.failure.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            
            recording.buttons.cancel.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            recording.buttons.cancel.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            recording.buttons.cancel.colorDarkMode = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            recording.buttons.cancel.backgroundColorDarkMode = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            recording.message.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            
            recording.phrase.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            recording.phrase.backgroundColorDarkMode = nil
            
            recording.failureMessage.font = .systemFont(ofSize: 22, weight: .bold)
            
            recording.buttons.failureAcknowledgment.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        .withCustomLocalization { localization in
            localization.bundle = Bundle.main
            localization.stringsName = "Localizable"
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        misnapVoiceCaptureVC = nil
        resultVC = nil
        
        configureSubviews()
        
        if let results = results {
            resultVC = ResultViewController(with: results)
            guard let resultVC = resultVC else { return }
            present(resultVC, animated: true)
            self.results = nil
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: Invoking MiSnapVoiceCapture
extension ViewController {
    @objc private func enrollmentButtonAction() {
        let configuration = MiSnapVoiceCaptureConfiguration(for: .enrollment)
            .withCustomParameters { parameters in
                parameters.snrMin = 7.1
            }
            .applying(template)
        misnapVoiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
        
        presentMiSnapVoiceCapture(misnapVoiceCaptureVC)
    }
    
    @objc private func verificationButtonAction() {
        guard let phrase = UserDefaults.standard.object(forKey: "phrase") as? String else { return }
        let configuration = MiSnapVoiceCaptureConfiguration(for: .verification, phrase: phrase)
            .withCustomParameters { parameters in
                parameters.snrMin = 3.1
            }
            .applying(template)
        misnapVoiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
        
        presentMiSnapVoiceCapture(misnapVoiceCaptureVC)
    }
}

// MARK: MiSnapVoiceCaptureViewControllerDelegate callbacks
extension ViewController: MiSnapVoiceCaptureViewControllerDelegate {
    // Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
    func miSnapVoiceCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle a license status here
    }

    func miSnapVoiceCaptureDidSelectPhrase(_ phrase: String) {
        /*
        Handle a phrase selected by a user in an Enrollment flow.
        
        It's highly recommended not only store the phrase in UserDefaults but also in a database on a server side to be able to retrieve it if a user switches a device or re-installs the app.
        
        For security purposes you might even cosider storing the phrase on a server side only and retrieve it for each verification.
        
        Note, this exact phrase will need to be passed in a configuration for a Verification flow.
        */
        
        UserDefaults.standard.set(phrase, forKey: "phrase")
        UserDefaults.standard.synchronize()
    }
    
    func miSnapVoiceCaptureSuccess(_ results: [MiSnapVoiceCaptureResult], for flow: MiSnapVoiceCaptureFlow) {
        /*
         Handle successful session results here for a configured flow (Enrollment, Verification)
         
         For Enrollment, `results` is always an array with 3 `MiSnapVoiceCaptureResult`s
         
         For Verification, `results` is always an array with one `MiSnapVoiceCaptureResult`
        */
        self.results = results
    }

    func miSnapVoiceCaptureCancelled(_ result: MiSnapVoiceCaptureResult) {
        // Handle cancelled session results here
    }

    func miSnapVoiceCaptureError(_ result: MiSnapVoiceCaptureResult) {
        // Handle an SDK error here
    }
    
    func miSnapVoiceCaptureShouldBeDismissed() {
        misnapVoiceCaptureVC?.dismiss(animated: true)
    }
}

// MARK: Views configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) { return manageVerifyButton() }
        
        let enrollmentButton = configureButton(withTitle: "Enroll", selector: #selector(enrollmentButtonAction))
        enrollmentButton.tag = 1
        
        view.addSubview(enrollmentButton)
        
        let verificationButton = configureButton(withTitle: "Verify", selector: #selector(verificationButtonAction))
        verificationButton.tag = 2
        
        view.addSubview(verificationButton)
        manageVerifyButton()
                
        let appNameLabel = configureLabel(withText: "MiSnapVoiceCapture\nSampleApp", numberOfLines: 2)
        let misnapUxVersionLabel = configureLabel(withText: "MiSnapVoiceCaptureUX \(MiSnapVoiceCaptureUX.version())", fontSize: 17)
        let misnapVersionLabel = configureLabel(withText: "MiSnapVoiceCapture \(MiSnapVoiceCapture.version())", fontSize: 17)
        
        view.addSubview(appNameLabel)
        view.addSubview(misnapUxVersionLabel)
        view.addSubview(misnapVersionLabel)
        
        NSLayoutConstraint.activate([
            enrollmentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enrollmentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            verificationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verificationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            misnapVersionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            misnapVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            misnapUxVersionLabel.bottomAnchor.constraint(equalTo: misnapVersionLabel.topAnchor, constant: -5),
            misnapUxVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func manageVerifyButton() {
        guard let verificationButton = view.viewWithTag(2) as? UIButton else { return }
        
        if let _ = UserDefaults.standard.object(forKey: "phrase") as? String {
            verificationButton.alpha = 1.0
            verificationButton.isEnabled = true
        } else {
            verificationButton.alpha = 0.4
            verificationButton.isEnabled = false
        }
    }
    
    private func configureButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemBlue.withAlphaComponent(0.4), for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 25.0, weight: .bold)
        
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
    
    private func presentMiSnapVoiceCapture(_ misnapVoiceCaptureVC: MiSnapVoiceCaptureViewController?) {
        guard let misnapVoiceCaptureVC = misnapVoiceCaptureVC else { return }
                                
        let minDiskSpace: Int = 20
        if !MiSnapVoiceCaptureViewController.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }

        MiSnapVoiceCaptureViewController.checkMicrophonePermission { granted in
            if !granted {
                let message = "Microphone permission is required to record audio as required by a country regulation."
                self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: message)
                return
            }

            DispatchQueue.main.async {
                self.present(misnapVoiceCaptureVC, animated: true)
            }
        }
    }
}
