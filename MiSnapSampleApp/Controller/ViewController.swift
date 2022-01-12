//
//  ViewController.swift
//  MiSnapSampleApp
//
//  Created by Panda Rajaram on 1/11/22.
//

import UIKit
import MiSnap
import MiSnapLicenseManager

class ViewController: UIViewController {

    private var vc: MiSnapViewController? = nil
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = vc {
            vc.set(delegate: nil)
            self.vc = nil
        }
        configureSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: Private functions
extension ViewController {
    private func configureSubviews() {
        button.center = view.center
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        self.view.addSubview(button)
    }
    @objc private func buttonClicked() {
        
        let configuration = MiSnapConfiguration(for: .anyId)
                
        if licenseKeyNotValid(for: configuration.parameters) { return }
        
        vc = MiSnapViewController(with: configuration, delegate: self)
        guard let vc = vc else { return }
        presentMiSnap(vc)
        print("Starting \"\(String(describing: configuration.parameters.documentTypeName))\" in Auto mode with default parameters")

    }
    
    private func presentMiSnap(_ vc: MiSnapViewController) {
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        let minDiskSpace: Int = 20
        
        //TODO: localize all strings
        if vc.configuration.parameters.camera.recordVideo && !vc.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }
        
        vc.checkCameraPermission { (granted) in
            if !granted {
                var message = "Camera permission is required to capture your documents."
                if vc.configuration.parameters.camera.recordVideo {
                    message = "Camera permission is required to capture your documents and record videos of the entire process as required by a country regulation."
                }
                
                self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: message)
                return
            }
            
            if vc.configuration.parameters.camera.recordVideo && vc.configuration.parameters.camera.recordAudio {
                vc.checkMicrophonePermission { (granted) in
                    if !granted {
                        let message = "Microphone permission is required to record audio as required by a country regulation."
                        self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: message)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
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
    
    private func presentAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func licenseKeyNotValid(for parameters: MiSnapParameters) -> Bool {
        if MiSnapLicenseManager.shared().status != .valid {
            switch MiSnapLicenseManager.shared().status {
            case .none:                     presentAlert(withTitle: "License key is none", message: nil)
            case .notValid:                 presentAlert(withTitle: "License key is not valid", message: nil)
            case .expired:                  presentAlert(withTitle: "License key has expired", message: nil)
            case .notValidAppId:            presentAlert(withTitle: "Not valid application bundle identifier", message: nil)
            case .platformNotSupported:     presentAlert(withTitle: "iOS platform is not licensed", message: nil)
            default:                        break
            }
            return true
        }
        
        if parameters.documentCategory == .deposit && !MiSnapLicenseManager.shared().featureSupported(.depositCapture) || parameters.documentCategory == .id && !MiSnapLicenseManager.shared().featureSupported(.idCapture) || parameters.documentType == .anyId && !MiSnapLicenseManager.shared().featureSupported(.ODC) {
            presentAlert(withTitle: "Feature is not licensed", message: nil)
            return true
        }
        return false
    }
    
}

// MARK: MiSnapViewControllerDelegate callback
extension ViewController: MiSnapViewControllerDelegate {
    func miSnapSuccess(_ results: MiSnapResult) {
        print("MiSnapSuccess")
    }
    
    func miSnapCancelled(_ results: MiSnapResult) {
        print("MiSnapCancelled")
    }
    
    func miSnapException(_ exception: NSException) {
        print("MiSnapException")
    }
    
    func miSnapDidStartSession() {
        print("MiSnapDidStartSession")
    }
    
    func miSnapDidFinishRecordingVideo(_ videoData: Data?) {
        print("MiSnapDidFinishRecordingVideo")
    }
    
    func miSnapDidFinishSuccessAnimation() {
        print("MiSnapDidFinishSuccessAnimation")
    }
}
