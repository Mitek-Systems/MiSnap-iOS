//
//  CustomNFCViewController.swift
//
//  Created by Mitek Engineering on 11/26/19.
//

import UIKit
import MiSnapNFC
import MiSnapLicenseManager

/*
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures an NFC reader.
 It's your responsibility to implement and present Introductory instruction,
 Help or Timeout screens and control a timeout if required
 */
@available(iOS 13, *)
@objc public class CustomNFCViewController: UIViewController {
    @objc public var documentType: MiSnapNFCDocumentType = .none
    @objc public var chipLocation: MiSnapNFCChipLocation = .noChip
    @objc public var mrzString: String = ""
    @objc public var mrzDocNumber: String = ""
    @objc public var mrzDob: String = ""
    @objc public var mrzDoe: String = ""
    @objc public var timeout: TimeInterval = 15.0
    
    private var reader: MiSnapNFCReader? = MiSnapNFCReader()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_ :)), name: .DidInvalidateNFCTagReaderSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectTag), name: .DidDetectNFCTag, object: nil)
        
        reader?.set(documentType: documentType)
        reader?.set(timeout: timeout)
        
        let configuration = MiSnapNFCResourceLocatorConfiguration()
        configuration.localization.bundle = // Your bundle where localization files are located
        configuration.localization.stringsName = // Your localization file name
        
        MiSnapNFCResourceLocator.shared.set(configuration: configuration)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Call this function to start NFC reading session
    func startButtonAction() {
        reader?.read(documentNumber: mrzDocNumber,
                    dateOfBirth: mrzDob,
                    dateOfExpiry: mrzDoe,
                    mrz: mrzString) { (results, error) in
            DispatchQueue.main.async {
                if let results = results {
                    // Handle successful results
                } else if let error = error {
                    switch error {
                    case .authenticationFailed:
                        print("Authentication Failed")
                        // Handle authentication failed
                    case .invalidLicense(let miSnapLicenseStatus):
                        print("License status: \(miSnapLicenseStatus.rawValue)")
                        // Handle invalid license
                    default:
                        print("Other error")
                        // Handle any other error
                    }
                }
            }
        }
    }
    
    // Call this function to deinitialize all objects to avoid memory leaks
    private func shutdown() {
        reader?.stop()
        self.reader = nil
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let userInfoDict = notification.userInfo as? [String : Any] else { return }
            
            if let invalidationReason = userInfoDict[MiSnapNFCKey.invalidationReason] as? MiSnapNFCInvalidationReason {
                switch invalidationReason {
                case .cancelled:
                    print("Cancelled")
                    // Handle reader session was cancelled
                case .timeout:
                    print("Timeout")
                    // Handle timeout
                default:
                    break
                }
            }
            if let mibiDataString = userInfoDict[MiSnapNFCKey.mibi] as? String {
                print("Intermediate MIBI Data:\n\(mibiDataString)")
            }
        }
    }
    
    @objc private func didDetectTag() {
        DispatchQueue.main.async {
            // Handle a tag detected event here if needed
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(String(describing: type(of: self))) is deinitialized")
    }
}
