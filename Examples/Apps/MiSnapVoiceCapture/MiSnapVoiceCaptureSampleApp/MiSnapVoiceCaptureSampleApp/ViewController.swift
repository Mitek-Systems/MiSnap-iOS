//
//  ViewController.swift
//  MiSnapVoiceCaptureSampleApp
//
//  Created by Stas Tsuprenko on 9/14/22.
//

import UIKit
import MiSnapVoiceCaptureUX
import MiSnapVoiceCapture
import MiSnapLicenseManager

class ViewController: UIViewController {
    private var misnapVoiceCaptureVC: MiSnapVoiceCaptureViewController?
    private var result: MiSnapVoiceCaptureResult?
    
    private var resultVC: ResultViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        misnapVoiceCaptureVC = nil
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

// MARK: Invoking MiSnapVoiceCapture
extension ViewController {
    @objc private func enrollmentButtonAction() {
        let configuration = MiSnapVoiceCaptureConfiguration(for: .enrollment)
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
        // Handle a phrase selected by a user
        // It's highly recommended not only store the phrase in UserDefaults but also in a database on a server side
        // to be able to retrieve it if a user switches a device or re-installs the app
        // Note, this exact phrase will need to be passed in  a configuration for a Verification session
    }

    func miSnapVoiceCaptureSuccess(_ results: [MiSnapVoiceCaptureResult], for type: MiSnapVoiceCaptureActivity) {
        // Handle successful session results here for a configured activity type (Enrollment, Verification)
        // For Enrollment, `results` will always contain 3 `MiSnapVoiceCaptureResult`s
        // For Verification, `results` will always contain 1 `MiSnapVoiceCaptureResult`
    }

    func miSnapVoiceCaptureCancelled(_ result: MiSnapVoiceCaptureResult) {
        // Handle cancelled session results here
    }

    func miSnapVoiceCaptureError(_ result: MiSnapVoiceCaptureResult) {
        // Handle an SDK error here
    }
    
    func miSnapVoiceCaptureShouldBeDismissed() {}
}

// MARK: Views configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) { return }
        
        let enrollmentButton = configureButton(withTitle: "Enroll", selector: #selector(enrollmentButtonAction))
        enrollmentButton.tag = 1
        
        view.addSubview(enrollmentButton)
                
        let appNameLabel = configureLabel(withText: "MiSnapVoiceCapture\nSampleApp", numberOfLines: 2)
        let misnapUxVersionLabel = configureLabel(withText: "MiSnapVoiceCaptureUX \(MiSnapVoiceCaptureUX.version())", fontSize: 17)
        let misnapVersionLabel = configureLabel(withText: "MiSnapVoiceCapture \(MiSnapVoiceCapture.version())", fontSize: 17)
        
        view.addSubview(appNameLabel)
        view.addSubview(misnapUxVersionLabel)
        view.addSubview(misnapVersionLabel)
        
        NSLayoutConstraint.activate([
            enrollmentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enrollmentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
    
    private func presentMiSnapVoiceCapture(_ misnapVoiceCaptureVC: MiSnapVoiceCaptureViewController?) {
        guard let misnapVoiceCaptureVC = misnapVoiceCaptureVC else { return }
                                
        let minDiskSpace: Int = 20
        if !misnapVoiceCaptureVC.hasMinDiskSpace(minDiskSpace) {
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
