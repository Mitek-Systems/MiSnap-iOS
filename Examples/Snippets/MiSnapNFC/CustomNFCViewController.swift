//
//  CustomNFCViewController.swift
//
//  Created by Mitek Engineering on 11/26/19.
//

import UIKit
import CoreNFC
import MiSnapNFC
import MiSnapCore

/**
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures an NFC reader.
 It's your responsibility to implement UX and UI.
 
 All MVP UI functions are in the extension at the very bottom of this file.
 Delete this extension with all its content and implement your UI instead.
 */
@available(iOS 13, *)
public class CustomNFCViewController: UIViewController {
    private let inputs: MiSnapNFCInputs
    private let parameters: MiSnapNFCParameters
    
    private var reader: MiSnapNFCReader?
    
    /**
     Both `startButton` and `hintLabel` are added for making this custom view controller an MVP.
     Delete or modify if needed
     */
    private var startButton = UIButton()
    private var hintLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
     Use this initializer
     */
    public init(with inputs: MiSnapNFCInputs, parameters: MiSnapNFCParameters) {
        self.inputs = inputs
        self.parameters = parameters
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        configureReader(with: inputs, parameters: parameters)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_ :)), name: .DidInvalidateNFCTagReaderSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectTag), name: .DidDetectNFCTag, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureUI()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(String(describing: type(of: self))) is deinitialized")
    }
}

// MARK: Public functions
extension CustomNFCViewController {
    /**
     Query MiSnapNFC version
     */
    public static func version() -> String {
        return MiSnapNFC.version()
    }
    /**
     Call this function to check if a device has NFC antenna before presenting this view controller
     */
    public static func hasAntenna() -> Bool {
        return NFCNDEFReaderSession.readingAvailable
    }
}

// MARK: Private views/objects configuration functions
extension CustomNFCViewController {
    /**
     Configures reader
     */
    private func configureReader(with inputs: MiSnapNFCInputs, parameters: MiSnapNFCParameters) {
        reader = MiSnapNFCReader(with: inputs, parameters: parameters)
        let configuration = MiSnapNFCResourceLocatorConfiguration()
        /**
         Uncomment lines below if you need to override a default bundle (.main) or default strings file name (MiSnapNFCLocalizable)
         */
        //configuration.localization.bundle = // Your bundle where localization files are located
        //configuration.localization.stringsName = // Your localization file name
        MiSnapNFCResourceLocator.shared.set(configuration: configuration)
    }
    /**
     Configure your UI here
     */
    private func configureUI() {
        /**
         Delete sample functions below and add your UI here
         */
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        configureStartButton()
        configureHintLabel()
        updateHintLabel(withText: "Press start button when ready")
    }
    /**
     Call this function to start NFC reading session
     */
    @objc func startButtonAction(_ button: UIButton) {
        reader?.read { (results, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let results = results {
                    /**
                     Chip was successfully read:
                     - Update your UI here to reflect this if needed
                     - Make sure to call `shutdown` to prevent memory leaks
                     - Dismiss or notify a parent that it's ready to be dismissed
                     */
                    self.dismiss()
                } else if let error = error {
                    /**
                     A chip reading error occurred
                     */
                    switch error {
                    case .nfcNotSupported:
                        /**
                         Handle NFC not supported
                         Ideally, you should check whether a device has NFC antenna by calling `hasAntenna()`
                         before presenting this view controller so that this error is never returned here
                         */
                        updateHintLabel(withText: "This device doesn't have NFC antenna")
                    case .connectionLost:
                        /**
                         Handle connection lost (i.e. a device was moved during a chip reading)
                         Ask a user to retry
                         */
                        updateHintLabel(withText: "Connection lost.\nTry again and hold still when the chip is detected")
                    case .authenticationFailed:
                        /**
                         Handle authentication failed (i.e. MRZ-based unlcok key isn't correct)
                         Options to handle:
                         - Skip NFC step
                         - Present a screen where a user can manually edit required fields (document number, date of birth, and date of expiry)
                         - Make a user to re-take document
                         */
                        updateHintLabel(withText: "Authentication failed\nMRZ-based key isn't correct")
                    case .invalidLicense(let status):
                        /**
                         Handle invalid license
                         */
                        updateHintLabel(withText: "License status: " + status.stringValue)
                    case .systemResourceUnavailable:
                        /**
                         Handle system resource unavailable (i.e. NFC antenna isn't released yet after a previous session or is used by another application)
                         Typically, adding a delay of a few seconds is enough for antenna to become available again
                         */
                        updateHintLabel(withText: "NFC antenna is busy\nWait 3 seconds then try again")
                    case .systemError:
                        /**
                         Handle system error where a success is reported but not all data was read.
                         Ask a user to retry reading and reboot a device if error persists
                         */
                        updateHintLabel(withText: "System error\nTry again and reboot a device if this error persists")
                    case .responseError(let errorMessage):
                        /**
                         Handle catch-all case
                         */
                        updateHintLabel(withText: errorMessage)
                    default:
                        /**
                         Handle any other error
                         */
                        updateHintLabel(withText: "Other error")
                    }
                }
            }
        }
    }
    /**
     Called when a chip is detected
     */
    @objc private func didDetectTag() {
        /**
         Handle a tag detected event here if needed
         */
        updateHintLabel(withText: "Detected chip. Hold still")
    }
    /**
     Called when NFC session is invalidated
     */
    @objc private func handleNotification(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let userInfoDict = notification.userInfo as? [String : Any] else { return }
            
            if let invalidationReason = userInfoDict[MiSnapNFCKey.invalidationReason] as? MiSnapNFCInvalidationReason {
                switch invalidationReason {
                case .cancel:
                    /**
                     User cancelled a session
                     */
                    self.updateHintLabel(withText: "User cancelled a session")
                case .timeout:
                    /**
                     Session time out.
                     A chip wasn't detected which means:
                     - either a document doesn't have a chip
                     - or a user need better guidance on how to detect it
                     */
                    self.updateHintLabel(withText: "Session timeout out\nTry again")
                default:
                    break
                }
            }
            if let mibiDataString = userInfoDict[MiSnapNFCKey.mibi] as? String {
                print("Intermediate MIBI Data:\n\(mibiDataString)")
            }
        }
    }
    /**
     Call this function to deinitialize all objects to avoid memory leaks
     */
    private func shutdown() {
        MiSnapNFCResourceLocator.destroyShared()
        reader?.stop()
        self.reader = nil
    }
    /**
     Calls `shutdown` and dismisses this custom view controller
     */
    private func dismiss() {
        shutdown()
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: MVP UI and UX. Delete this extension with all functions in it and implement your UX and UI instead
extension CustomNFCViewController {
    private func configureStartButton() {
        guard startButton.frame == .zero else { return }
        
        startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.systemBlue, for: .normal)
        startButton.setTitleColor(.systemBlue.withAlphaComponent(0.4), for: .highlighted)
        startButton.titleLabel?.font = .systemFont(ofSize: 22)
        startButton.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)
        startButton.center = CGPoint(x: view.frame.width / 2, y: view.frame.height * 3 / 4)
        
        view.addSubview(startButton)
    }
    
    private func configureHintLabel() {
        guard hintLabel.frame == .zero else { return }
        
        hintLabel = UILabel(frame: view.frame)
        hintLabel.font = .systemFont(ofSize: 20)
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        
        view.addSubview(hintLabel)
    }
    
    private func updateHintLabel(withText text: String) {
        let maxSize = CGSize(width: view.frame.width * 0.9, height: view.frame.height)
        hintLabel.frame = CGRect(origin: .zero, size: maxSize)
        hintLabel.text = text
        hintLabel.sizeToFit()
        hintLabel.center = view.center
    }
}
