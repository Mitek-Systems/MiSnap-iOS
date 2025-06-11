//
//  MiSnapVoiceCaptureViewController.swift
//  MiSnapBiometricsSampleApp
//
//  Created by Stas Tsuprenko on 7/8/21.
//

import UIKit
import MiSnapCore
import MiSnapVoiceCapture
import MiSnapAssetManager
/**
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures a voice recording controller.
 It's your responsibility to implement UX and UI.
 
 All MVP UI functions are in the extension at the very bottom of this file.
 Delete this extension with all its content and implement your UI instead.
 */
@objc public class CustomVoiceCaptureViewController: UIViewController {
    private let parameters: MiSnapVoiceCaptureParameters
    private let phrase: String
    
    private var controller: MiSnapVoiceCaptureController!
    
    private var results: [MiSnapVoiceCaptureResult] = []
    private var samplesCount: Int = 0
    private var attemptCounter: Int = 0
    
    private var interruptionReason: MiSnapVoiceCaptureControllerInterruptionReason = .none
    private var licenseStatus: MiSnapLicenseStatus = .none
    /**
     Both `phraseLabel` and `hintLabel` are added for making this custom view controller an MVP.
     Delete or modify them to your liking
     */
    private var phraseLabel = UILabel()
    private var hintLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
     Use this initializer.
     Make sure to call `MiSnapVoiceCaptureParameters(for:)` to set the correct flow (enrollment or verification).
     It is higly recommended to allow a user to select a phrase from multiple choices and than initialize this view controller
     with that selected phrase.
     */
    public init(with parameters: MiSnapVoiceCaptureParameters, phrase: String) {
        guard !phrase.isEmpty else { fatalError("Phrase cannot be an empty string") }
        self.parameters = parameters
        self.phrase = phrase
        
        if parameters.flow == .enrollment {
            samplesCount = 3
        } else {
            samplesCount = 1
        }
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        print("\(String(describing: type(of: self))) is deinitialized")
    }
}

// MARK: Public functions
extension CustomVoiceCaptureViewController {
    /**
     Query MiSnapVoiceCapture version
     */
    public static func version() -> String {
        return MiSnapVoiceCapture.version()
    }
    /**
     Call this function to check microphone permission before presenting this view controller
     */
    @objc public static func checkMicrophonePermission(handler: @escaping (Bool) -> Void) {
        MiSnapVoiceCapture.checkMicrophonePermission(handler)
    }
    /**
     Call this function to check if a device has enough space (in MB) for storing recordings before presenting this view controller
     */
    @objc public static func hasMinDiskSpace(_ minDiskSpace: Int) -> Bool {
        guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return false }
        
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: documentsDir)
            guard let totalFreeSpace = dict[.systemFreeSize] as? UInt64 else { return false }
            let totalFreeSpaceMb = totalFreeSpace / (1024 * 1024)
            return totalFreeSpaceMb >= minDiskSpace
        } catch {
            return false
        }
    }
}

// MARK: Private views/objects configuration functions
extension CustomVoiceCaptureViewController {
    /**
     Configures all necessary objects
     */
    private func start() {
        configureUI()
        configureController()
    }
    /**
     Configures and start a controller
     */
    private func configureController() {
        controller = MiSnapVoiceCaptureController(with: parameters, delegate: self)
        controller.start()
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
        configurePhraseLabel()
        configureHintLabel()
    }
    
    /**
     Call this function to deinitialize all objects to avoid memory leaks
     */
    private func shutdown() {
        /**
         Controller is going to be nil if licesne is not valid
         */
        if licenseStatus == .none {
            controller.shutdown()
        }
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

// MARK: MiSnapVoiceCaptureControllerDelegate callbacks
extension CustomVoiceCaptureViewController: MiSnapVoiceCaptureControllerDelegate {
    /**
     Called when license status is anything but valid or expired
     */
    public func miSnapVoiceCaptureControllerLicenseStatus(_ status: MiSnapLicenseStatus) {
        /**
         Handle invalid license status here
         */
        licenseStatus = status
        /**
         Delete sample function below
         */
        updateUIForInvalidLicense(status: status)
    }
    /**
     Called when a controller is started
     */
    public func miSnapVoiceCaptureControllerDidStart() {
        /**
         Handle controller started recording event
         */
        
        /**
         Delete sample function below
         */
        updateUIForRecordingStarted()
    }
    /**
     Called when a recording passes all quality checks
     */
    public func miSnapVoiceCaptureControllerSuccess(_ result: MiSnapVoiceCaptureResult) {
        results.append(result)
        attemptCounter += 1
        
        if attemptCounter < samplesCount {
            /**
             Successfully recorded one of multiple vocie samples:
             - Update your UI here to reflect this
             - Make sure to call `controller.start()` to start a new recording once UI is setup
             */
        } else {
            /**
             All samples were successfully collected:
             - Return `results` to your application
             - Update your UI here to reflect this (if needed)
             - Make sure to call `shutdown` to prevent memory leaks
             - Dismiss or notify a parent that it's ready to be dismissed
             */
        }
        
        /**
         Delete sample function below
         */
        updateUIForRecordingSucceeded(isFinal: attemptCounter >= samplesCount)
    }
    /**
     Called when a recording fails quality checks
     */
    public func miSnapVoiceCaptureControllerFailure(_ result: MiSnapVoiceCaptureResult) {
        /**
         Handle a quality issue detected in the recording (e.g. too short, too much noise):
         - Update your UI here to reflect this
         - Make sure to call `controller.start()` to start a new recording once UI is setup
         */
        
        /**
         Delete sample function below when implementing your UX and UI
         */
        updateUIForRecordingFailed(with: result)
    }
    /**
     Called when an SDK error occurs
     */
    public func miSnapVoiceCaptureControllerError(_ result: MiSnapVoiceCaptureResult) {
        /**
         Handle SDK error here
         */
        dismiss()
    }
    /**
     Called when a session is cancelled by a user
     */
    public func miSnapVoiceCaptureControllerCancel(_ result: MiSnapVoiceCaptureResult) {
        /**
         Handle user cancelled event here
         */
        dismiss()
    }
    /**
     Called when a controller is interrupted
     */
    public func miSnapVoiceCaptureControllerInterruptionStarted(_ reason: MiSnapVoiceCaptureControllerInterruptionReason) {
        interruptionReason = reason
        /**
         Handle interruption started for a specific reason here
         */
    }
    /**
     Called when a controller interruption has ended
     */
    public func miSnapVoiceCaptureControllerInterruptionEnded() {
        interruptionReason = .none
        /**
         Handle interruption ended here
         */
        controller.start()
    }
    /**
     Called every time a real-time voice data is processed with a speech length detected in the current recording
     */
    public func miSnapVoiceCaptureControllerSpeechLength(_ speechLength: Int) {
        /**
         (OPTIONAL) Handle speech length that's continuously updated
         */
    }
}

// MARK: MVP UI and UX. Delete this extension with all functions in it and implement your UX and UI instead
extension CustomVoiceCaptureViewController {
    private func configurePhraseLabel() {
        guard phraseLabel.frame == .zero else { return }
        
        let maxSize = CGSize(width: view.frame.width * 0.9, height: view.frame.height)
        phraseLabel = UILabel(frame: CGRect(origin: .zero, size: maxSize))
        phraseLabel.text = phrase
        phraseLabel.font = .systemFont(ofSize: 25)
        phraseLabel.sizeToFit()
        phraseLabel.center = CGPoint(x: view.center.x, y: view.center.y)
        
        view.addSubview(phraseLabel)
    }

    private func configureHintLabel() {
        guard hintLabel.frame == .zero else { return }
        
        hintLabel = UILabel(frame: view.frame)
        hintLabel.font = .systemFont(ofSize: 20)
        
        view.addSubview(hintLabel)
    }

    private func updateHintLabel(withText text: String, hidePhrase: Bool = false) {
        let maxSize = CGSize(width: view.frame.width * 0.9, height: view.frame.height)
        hintLabel.frame = CGRect(origin: .zero, size: maxSize)
        hintLabel.text = text
        hintLabel.sizeToFit()
        hintLabel.center = CGPoint(x: phraseLabel.center.x, y: phraseLabel.center.y - hintLabel.frame.height - 20)
        
        phraseLabel.isHidden = hidePhrase
        phraseLabel.isEnabled = !hidePhrase
    }
    
    private func updateUIForRecordingStarted() {
        updateHintLabel(withText: "Recording started. Say phrase:")
    }
    
    private func updateUIForRecordingSucceeded(isFinal: Bool = false) {
        updateHintLabel(withText: "Successfully recorded sample #" + String(attemptCounter), hidePhrase: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            guard let self = self else { return }
            if isFinal {
                self.dismiss()
            } else {
                self.updateHintLabel(withText: "Recording started. Say phrase:")
                self.controller.start()
            }
        }
    }
    
    private func updateUIForRecordingFailed(with result: MiSnapVoiceCaptureResult) {
        var message = "Failure: \(MiSnapVoiceCaptureResult.stringFromStatus(result.status))"
        if result.status == .tooShort {
            message += " | speech length: \(String(format: "%.2f ms", result.speechLength))"
        }
        if result.status == .tooNoisy {
            message += " | snr: \(String(format: "%.2f dB", result.snr))"
        }
        updateHintLabel(withText: message, hidePhrase: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) { [weak self] in
            guard let self = self else { return }
            self.updateHintLabel(withText: "Recording started. Say phrase:")
            self.controller.start()
        }
    }
    
    private func updateUIForInvalidLicense(status: MiSnapLicenseStatus) {
        updateHintLabel(withText: "License status: " + status.stringValue, hidePhrase: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            guard let self = self else { return }
            self.dismiss()
        }
    }
}
