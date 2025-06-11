//
//  CustomFacialCaptureViewController.swift
//
//  Created by Mitek Engineering on 6/12/20.
//

import UIKit
import MiSnapFacialCapture

/**
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures an analyzer and a camera and connects them together.
 It's your responsibility to implement UX and UI
 
 All MVP UI functions are in the extension at the very bottom of this file.
 Delete this extension with all its content and implement your UI instead.
 */
@objc public class CustomFacialCaptureViewController: UIViewController {
    private let parameters: MiSnapFacialCaptureParameters
    
    private var analyzer: MiSnapFacialCaptureAnalyzer?
    private var camera: MiSnapFacialCaptureCamera?
    
    private var countdownTimer: Timer?
    private var countdownCounter: Int = 0 {
        didSet {
            countdownLabel.text = String(countdownCounter)
        }
    }
    
    private var shouldProcessFrames = true
    /**
     Both `hintLabel` and `countdownLabel` are added for making this custom view controller an MVP.
     Delete or modify them to your liking
     */
    private var hintLabel = UILabel()
    private var countdownLabel = UILabel()
            
    required init?(coder: NSCoder) {
        fatalError("MiSnapFacialCaptureViewController(coder:) has not been implemented")
    }
    
    /**
     Use this initializer
     */
    init(with parameters: MiSnapFacialCaptureParameters) {
        self.parameters = parameters
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
        
        /**
         Uncomment to simulate a timeout for debugging purposes.
         Delete sample function below when implementing your UX and UI.
         */
        //simulateTimeoutAndRetry()
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
extension CustomFacialCaptureViewController {
    /**
     Query MiSnapFacialCapture version
     */
    public static func version() -> String {
        return MiSnapFacialCapture.version()
    }
    /**
     Call this function to check camera permission before presenting this view controller
     */
    public func checkCameraPermission(handler: @escaping (Bool) -> Void) {
        MiSnapFacialCaptureCamera.checkPermission(handler)
    }
    /**
     Call this function to check microphone permission (if required) before presenting this view controller
     */
    public func checkMicrophonePermission(handler: @escaping (Bool) -> Void) {
        MiSnapFacialCaptureCamera.checkMicrophonePermission(handler)
    }
}

// MARK: Private configuration functions
extension CustomFacialCaptureViewController {
    private func start() {
        configureUI()
        configureAnalyzer()
        configureCameraView()
    }
    
    private func configureUI() {
        /**
         Delete sample functions below and add your UI here
         */
        configureHintLabel()
        configureCountdownLabel()
    }
    
    private func configureAnalyzer() {
        if let _ = analyzer { } else {
            analyzer = MiSnapFacialCaptureAnalyzer(parameters: parameters, delegate: self)
        }
        analyzer?.resume()
    }
    
    private func configureCameraView() {
        if let camera = camera, camera.isConfigured {
            didFinishConfiguringSession()
        } else {
            camera = MiSnapFacialCaptureCamera(preset: .hd1280x720, format: Int(kCVPixelFormatType_32BGRA), position: .front, frame: view.frame)
            guard let camera = camera else { fatalError("Couldn't initialize camera view") }
            camera.parameters = parameters.camera
            camera.delegate = self
            camera.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(camera, at: 0)
            
            NSLayoutConstraint.activate([
                camera.leftAnchor.constraint(equalTo: view.leftAnchor),
                camera.rightAnchor.constraint(equalTo: view.rightAnchor),
                camera.topAnchor.constraint(equalTo: view.topAnchor),
                camera.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    /**
     Call this function to deinitialize all objects to avoid memory leaks
     */
    private func shutdown() {
        if let camera = camera {
            camera.stop()
            camera.shutdown()
            camera.delegate = nil
            camera.removeFromSuperview()
            self.camera = nil
        }

        if let analyzer = analyzer {
            analyzer.stop()
            analyzer.delegate = nil
            self.analyzer = nil
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
    /**
     Call this function only when a user cancels a session
     On success `shutdown` is called
     */
    private func cancel() {
        camera?.discardRecording()
        analyzer?.cancel()
    }
    /**
     Use this function as selector for Manual button action
     */
    @objc private func manualSelectionButtonAction(_ button: UIButton) {
        analyzer?.selectFrame()
    }
    /**
     Call this function to update mode (e.g. from `Auto` to `Manual`)
     */
    private func set(mode: MiSnapFacialCaptureMode) {
        parameters.mode = mode
        analyzer?.update(parameters)
    }
    /**
     Starts a countdown timer and displays a countdown view if countdown hasn't started already
     */
    private func startCountdown() {
        /**
         For good UX It's recommended to invalidate your session timer when a countdown is started
         to prevent showing a timeout screen while 3-2-1 countdown is happenning
         */
        if let _ = countdownTimer { } else {
            countdownCounter = 3
            let countdownTime = TimeInterval(parameters.countdownTime) / TimeInterval(countdownCounter)
            countdownTimer = Timer.scheduledTimer(timeInterval: countdownTime, target: self, selector: #selector(countdownTimerAction(_:)), userInfo: nil, repeats: true)
            
            hideCountdownLabel(false)
        }
    }
    /**
     Invalidates a countdown timer and hides a countdown view
     */
    private func invalidateCountdown() {
        /**
         Do not forget to restart your session timer that you invalidated when started a countdown
         */
        if let timer = countdownTimer {
            timer.invalidate()
            countdownTimer = nil
            
            hideCountdownLabel(true)
        }
    }
    /**
     Called every `parameters.countdownTime / 3` seconds until counted to 0 at which point a selfie is taken
     */
    @objc private func countdownTimerAction(_ timer: Timer) {
        countdownCounter -= 1
        
        if countdownCounter == 0 {
            invalidateCountdown()
            analyzer?.selectFrame()
        }
    }
}

// MARK: MiSnapFacialCaptureAnalyzerDelegate callbacks
extension CustomFacialCaptureViewController: MiSnapFacialCaptureAnalyzerDelegate {
    /**
     Called when license status is anything but valid or expired
     */
    public func miSnapFacialCaptureAnalyzerLicenseStatus(_ status: MiSnapLicenseStatus) {
        /**
         Hanlde invalid license status here
         */
        
        /**
         Delete sample function below
         */
        updateUIForInvalidLicense(status: status)
    }
    /**
     Called when a frame passed all IQA checks
     */
    public func miSnapFacialCaptureAnalyzerSuccess(_ result: MiSnapFacialCaptureResult!) {
        /**
         A good image is returned:
         - Return `result` to your application
         - Update your UI here to reflect this (e.g. run success animation) if needed
         - Make sure to call `shutdown` to prevent memory leaks
         - Dismiss or notify a parent that it's ready to be dismissed
         */
        
        dismiss()
    }
    /**
     Called when a frame failed one or more IQA checks.
     This callback is returned on a main thread so it's safe to update UI here
     */
    public func miSnapFacialCaptureAnalyzerError(_ result: MiSnapFacialCaptureResult!) {
        guard shouldProcessFrames else { return }
        
        if result.highestPriorityStatus != .countdown {
            invalidateCountdown()
        }
        
        /**
         Delete sample function below when implementing your UX and UI
         */
        updateUIForFailedFrame(status: result.highestPriorityStatus)
    }
    /**
     Called when a user cancels a session
     This callback is returned on a main thread so it's safe to update UI here
     */
    public func miSnapFacialCaptureAnalyzerCancelled(_ result: MiSnapFacialCaptureResult!) {
        /**
         A user cancelled a session:
         - Return `result` to your application if needed
         - Make sure to call `shutdown` to prevent memory leaks
         - Dismiss or notify a parent that it's ready to be dismissed
         */
        
        dismiss()
    }
    /**
     Called when SDK runs on a device older than iOS 12.0
     Note, since min SDK version was increased to iOS 12.0 this callback will never be sent by the SDK
     */
    public func miSnapFacialCaptureAnalyzerManualOnly() {
        /**
         Devices running < iOS 12.0 support Manual only selfie acquistion
         without quality check.
         SDK returns this callback if such a device is detected
         */
    }
    /**
     Called when frame passed all IQA checks and `selectOnSmile` is `false` (default)
     so that integrator can present a countdown UI
     This callback is returned on a main thread so it's safe to update UI here
     */
    public func miSnapFacialCaptureAnalyzerStartCountdown() {
        /**
         Handle countdown start
         Note, this callback is returned only when `selectOnSmile` is `false` in `MiSnapFacialCaptureParameters` (default)
         */
        startCountdown()
    }
}

// MARK: MiSnapFacialCaptureCameraDelegate callbacks
extension CustomFacialCaptureViewController: MiSnapFacialCaptureCameraDelegate {
    public func didFinishConfiguringSession() {
        shouldProcessFrames = true
        camera?.start()
    }
    
    public func didReceive(_ sampleBuffer: CMSampleBuffer?) {
        guard shouldProcessFrames else { return }
        analyzer?.analyze(sampleBuffer)
    }
    
    public func didFinishRecordingVideo(_ videoData: Data?) {
        // Handle video data here when `parameters.cameraParameters.recordVideo` is set to `true`
    }
}

// MARK: MVP UI and UX. Delete this extension with all functions in it and implement your UX and UI instead
extension CustomFacialCaptureViewController {
    private func configureHintLabel() {
        guard hintLabel.frame == .zero else { return }
        hintLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        hintLabel.font = .systemFont(ofSize: 20)
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0
        hintLabel.textColor = .black
        hintLabel.backgroundColor = .white.withAlphaComponent(0.7)
        hintLabel.layer.cornerRadius = 15
        hintLabel.layer.masksToBounds = true
        hintLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        view.addSubview(hintLabel)
    }
    
    private func updateHintLabel(withText text: String) {
        let maxSize = CGSize(width: view.frame.width * 0.9, height: 50)
        hintLabel.frame = CGRect(origin: .zero, size: maxSize)
        hintLabel.text = text
        hintLabel.sizeToFit()
        hintLabel.frame = CGRect(origin: .zero, size: CGSize(width: hintLabel.frame.width + 20, height: maxSize.height))
        hintLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
    }
    
    private func updateUIForInvalidLicense(status: MiSnapLicenseStatus) {
        updateHintLabel(withText: "License status: " + status.stringValue)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            guard let self = self else { return }
            self.dismiss()
        }
    }
    
    private func updateUIForFailedFrame(status: MiSnapFacialCaptureStatus) {
        var text = MiSnapFacialCaptureResult.code(from: status)
        if status == .good, parameters.selectOnSmile {
            text = "Smile"
        } else if status == .countdown {
            text = "HoldStill"
        }
        updateHintLabel(withText: text)
    }
    
    private func configureCountdownLabel() {
        guard countdownLabel.frame == .zero else { return }
        countdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        countdownLabel.font = .systemFont(ofSize: 20)
        countdownLabel.textAlignment = .center
        countdownLabel.textColor = .black
        countdownLabel.backgroundColor = .white.withAlphaComponent(0.7)
        countdownLabel.layer.cornerRadius = 15
        countdownLabel.layer.masksToBounds = true
        countdownLabel.center = CGPoint(x: hintLabel.center.x, y: hintLabel.center.y + countdownLabel.frame.height + 20)
        hideCountdownLabel(true)
        
        view.addSubview(countdownLabel)
    }
    
    private func hideCountdownLabel(_ hide: Bool) {
        countdownLabel.isHidden = hide
        countdownLabel.isEnabled = !hide
    }
    
    /**
     This function simulates a timeout 5 seconds after a session is started and then resumes back in 3 seconds
     */
    private func simulateTimeoutAndRetry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self] in
            guard let self = self else { return }
            self.shouldProcessFrames = false
            self.analyzer?.pause(for: .timeout)
            
            /**
             Delete sample function below
             */
            self.updateHintLabel(withText: "Timeout")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) { [weak self] in
            guard let self = self else { return }
            self.start()
        }
    }
}
