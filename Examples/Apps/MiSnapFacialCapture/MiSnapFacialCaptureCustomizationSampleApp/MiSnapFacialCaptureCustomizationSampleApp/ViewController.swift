//
//  ViewController.swift
//  MiSnapFacialCaptureCustomizationSampleApp
//
//  Created by Mitek Engineering on 3/24/22.
//

import UIKit
import MiSnapFacialCaptureUX
import MiSnapFacialCapture
import MiSnapLicenseManager

class ViewController: UIViewController {
    private var misnapFacialCaptureVC: MiSnapFacialCaptureViewController?
    private var result: MiSnapFacialCaptureResult?
    
    private var triggerSegmentedControl: UISegmentedControl!
    
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
            .withCustomGuide { guide in
                guide.vignette.style = .blur
                guide.vignette.alpha = 0.925
                
                guide.outline.colorGood = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                guide.outline.colorBad = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            }
            .withCustomHelp { help in
                help.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                help.size = help.size.scaled(by: 0.8)
            }
            .withCustomCancel { cancel in
                cancel.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cancel.size = cancel.size.scaled(by: 0.8)
            }
            .withCustomCameraShutter { cameraShutter in
                cameraShutter.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cameraShutter.size = cameraShutter.size.scaled(by: 1.15)
            }
            .withCustomCountdown { countdown in
                countdown.burnupColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                countdown.burnupLineWidth = 3
                countdown.fontSize = 35.0
            }
            .withCustomSuccessCheckmark { successCheckmark in
                successCheckmark.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                successCheckmark.cutoutFillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).withAlphaComponent(0.5)
            }
            .withCustomUxParameters { uxParameters in
                uxParameters.timeout = 25.0
                uxParameters.showHelpScreen = false
                uxParameters.showTimeoutScreen = false
            }
            .withCustomLocalization { localization in
                localization.bundle = Bundle.main
                localization.stringsName = "Localizable"
            }
            .withCustomParameters { parameters in
                parameters.selectOnSmile = triggerSegmentedControl.selectedSegmentIndex == 1
            }
        
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
    
    /*
     Implementing optional callbacks since `showHelpScreen` and `showTimeoutScreen`
     of `MiSnapFacialCaptureUxParameters`were overridden to `false` in configuration
     */
    func miSnapFacialCaptureHelpAction() {
        guard let misnapFacialCaptureVC = misnapFacialCaptureVC else { return }

        let helpVC = CustomFacialCaptureTutorialViewController(for: .help, delegate: misnapFacialCaptureVC)
        misnapFacialCaptureVC.presentVC(helpVC)
    }

    func miSnapFacialCaptureTimeoutAction() {
        guard let misnapFacialCaptureVC = misnapFacialCaptureVC else { return }

        let timeoutVC = CustomFacialCaptureTutorialViewController(for: .timeout, delegate: misnapFacialCaptureVC)
        misnapFacialCaptureVC.presentVC(timeoutVC)
    }
}

// MARK: Views configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) { return }
        
        let takeSelfieButton = configureButton(withTitle: "Take Selfie", selector: #selector(takeSelfieButtonAction))
        takeSelfieButton.tag = 1
        
        view.addSubview(takeSelfieButton)
        
        triggerSegmentedControl = UISegmentedControl(items: ["Countdown", "Smile"])
        triggerSegmentedControl.selectedSegmentIndex = 0
        triggerSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(triggerSegmentedControl)
                
        let appNameLabel = configureLabel(withText: "MiSnapFacialCapture\nCusomizationSampleApp", numberOfLines: 2)
        let misnapUxVersionLabel = configureLabel(withText: "MiSnapFacialCaptureUX \(MiSnapFacialCaptureUX.version())", fontSize: 17)
        let misnapVersionLabel = configureLabel(withText: "MiSnapFacialCapture \(MiSnapFacialCapture.version())", fontSize: 17)
        
        view.addSubview(appNameLabel)
        view.addSubview(misnapUxVersionLabel)
        view.addSubview(misnapVersionLabel)
        
        NSLayoutConstraint.activate([
            takeSelfieButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takeSelfieButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            triggerSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            triggerSegmentedControl.topAnchor.constraint(equalTo: takeSelfieButton.bottomAnchor, constant: 30),
            
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

