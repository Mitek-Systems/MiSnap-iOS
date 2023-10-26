//
//  ViewController.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Mitek Engineering on 3/23/22.
//

import UIKit
import MiSnapCore
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

class ViewController: UIViewController {
    private var misnapFacialCaptureVC: MiSnapFacialCaptureViewController?
    private var result: MiSnapFacialCaptureResult?
    
    private var resultVC: ResultViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        misnapFacialCaptureVC = nil
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

// MARK: Invoking MiSnapFacialCapture
extension ViewController {
    @objc private func takeSelfieButtonAction() {
        let configuration = MiSnapFacialCaptureConfiguration()
        misnapFacialCaptureVC = MiSnapFacialCaptureViewController(with: configuration, delegate: self)
        
        presentMiSnapFacialCapture(misnapFacialCaptureVC)
    }
}

// MARK: MiSnapFacialCaptureViewControllerDelegate callbacks
extension ViewController: MiSnapFacialCaptureViewControllerDelegate {
    // Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
    func miSnapFacialCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle a license status here
    }

    func miSnapFacialCaptureSuccess(_ result: MiSnapFacialCaptureResult) {
        // Handle successful session results here
        self.result = result
    }

    func miSnapFacialCaptureCancelled(_ result: MiSnapFacialCaptureResult) {
        // Handle cancelled session results here
    }
}

// MARK: Views configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) { return }
        
        let takeSelfieButton = configureButton(withTitle: "Take Selfie", selector: #selector(takeSelfieButtonAction))
        takeSelfieButton.tag = 1
        
        view.addSubview(takeSelfieButton)
                
        let appNameLabel = configureLabel(withText: "MiSnapFacialCapture\nSampleApp", numberOfLines: 2)
        let misnapUxVersionLabel = configureLabel(withText: "MiSnapFacialCaptureUX \(MiSnapFacialCaptureUX.version())", fontSize: 17)
        let misnapVersionLabel = configureLabel(withText: "MiSnapFacialCapture \(MiSnapFacialCapture.version())", fontSize: 17)
        
        view.addSubview(appNameLabel)
        view.addSubview(misnapUxVersionLabel)
        view.addSubview(misnapVersionLabel)
        
        NSLayoutConstraint.activate([
            takeSelfieButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takeSelfieButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
    
    private func presentMiSnapFacialCapture(_ misnapFacialCaptureVC: MiSnapFacialCaptureViewController?) {
        guard let misnapFacialCaptureVC = misnapFacialCaptureVC else { return }
                                
        let minDiskSpace: Int = 20
        if misnapFacialCaptureVC.configuration.parameters.camera.recordVideo && !MiSnapFacialCaptureViewController.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }

        MiSnapFacialCaptureViewController.checkCameraPermission { granted in
            if !granted {
                var message = "Camera permission is required to capture your documents."
                if misnapFacialCaptureVC.configuration.parameters.camera.recordVideo {
                    message = "Camera permission is required to capture your documents and record videos of the entire process as required by a country regulation."
                }

                self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: message)
                return
            }

            if misnapFacialCaptureVC.configuration.parameters.camera.recordVideo && misnapFacialCaptureVC.configuration.parameters.camera.recordAudio {
                MiSnapFacialCaptureViewController.checkMicrophonePermission { granted in
                    if !granted {
                        let message = "Microphone permission is required to record audio as required by a country regulation."
                        self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: message)
                        return
                    }

                    DispatchQueue.main.async {
                        self.present(misnapFacialCaptureVC, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.present(misnapFacialCaptureVC, animated: true)
                }
            }
        }
    }
}
