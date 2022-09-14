//
//  ViewController.swift
//  MiSnapSampleApp
//
//  Created by Mitek Engineering on 1/10/22.
//

import UIKit
import MiSnap
import MiSnapUX
import MiSnapLicenseManager

class ViewController: UIViewController {
    private var misnapVC: MiSnapViewController?
    private var result: MiSnapResult?
    
    private var resultVC: ResultViewController?
    
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
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func passportButtonAction() {
        let configuration = MiSnapConfiguration(for: .passport)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func idFrontButtonAction() {
        let configuration = MiSnapConfiguration(for: .idFront)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func idBackButtonAction() {
        let configuration = MiSnapConfiguration(for: .idBack)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func checkFrontButtonAction() {
        let configuration = MiSnapConfiguration(for: .checkFront)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func checkBackButtonAction() {
        let configuration = MiSnapConfiguration(for: .checkBack)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
    
    @objc private func genericButtonAction() {
        let configuration = MiSnapConfiguration(for: .generic)
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
        
        let appNameLabel = configureLabel(withText: "MiSnapSampleApp")
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
        if misnap.configuration.parameters.camera.recordVideo && !misnap.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }
        
        misnap.checkCameraPermission { granted in
            if !granted {
                var message = "Camera permission is required to capture your documents."
                if misnap.configuration.parameters.camera.recordVideo {
                    message = "Camera permission is required to capture your documents and record videos of the entire process as required by a country regulation."
                }
                
                self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: message)
                return
            }
            
            if misnap.configuration.parameters.camera.recordVideo && misnap.configuration.parameters.camera.recordAudio {
                misnap.checkMicrophonePermission { granted in
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
