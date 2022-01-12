//
//  MiSnapViewController.swift
//  MiSnap UX
//
//  Created by Mitek Engineering on 2/25/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnap
import MiSnapScience

private enum MiSnapViewControllerDismissalReason: String, Equatable {
    case cancel, success
}

protocol MiSnapViewControllerDelegate {
    func miSnapSuccess(_ result: MiSnapResult)
    func miSnapCancelled(_ result: MiSnapResult)
    func miSnapException(_ exception: NSException)
    
    func miSnapDidStartSession()
    func miSnapDidFinishRecordingVideo(_ videoData: Data?)
    func miSnapDidFinishSuccessAnimation()
}

extension MiSnapViewControllerDelegate {
    func miSnapDidStartSession() {}
    func miSnapDidFinishRecordingVideo(_ videoData: Data?) {}
    func miSnapDidFinishSuccessAnimation() {}
}

class MiSnapViewController: UIViewController {
    private(set) var configuration: MiSnapConfiguration
    private var delegate: MiSnapViewControllerDelegate?
    
    private var camera: MiSnapCamera?
    private var overlay: MiSnapOverlayView?
    
    private var analyzer: MiSnapAnalyzer?
    
    private var tutorialViewController: MiSnapTutorialViewController?
    
    private var timer: Timer?
    private var timeoutOccurred: Bool = false
    private var cancelled: Bool = false
    private var shouldSkipFrames: Bool = false
    
    private var orientation: UIInterfaceOrientation = .unknown {
        didSet {
            if let analyzer = analyzer {
                analyzer.update(orientation)
            }
            if let overlay = overlay {
                overlay.update(orientation)
            }
            if let camera = camera {
                if configuration.parameters.orientationMode == .deviceLandscapeGuideLandscape && orientation.isPortrait {
                    camera.orientation = .landscapeRight
                } else {
                    camera.orientation = orientation
                }
                camera.updatePreviewLayer(orientation)
            }
        }
    }
    
    private var presentedInstruction: Bool = false
    private var shouldPresentTutorial: Bool {
        if presentedInstruction { return false }
        presentedInstruction = true
        
        let instructionKey = "instruction_for_\(configuration.parameters.documentType.rawValue)"
        
        guard let _ = UserDefaults.standard.object(forKey: instructionKey) else {
            UserDefaults.standard.set(configuration.parameters.documentCategory == .id, forKey: instructionKey)
            UserDefaults.standard.synchronize()
            return true
        }
        
        return UserDefaults.standard.bool(forKey: instructionKey)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with configuration: MiSnapConfiguration, delegate: MiSnapViewControllerDelegate) {
        self.configuration = configuration
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted(_:)), name: .AVCaptureSessionWasInterrupted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if cancelled { return }
        super.viewWillAppear(animated)
        
        orientation = MiSnapOrientation.current
        
        configureAnalyzer(with: configuration.parameters, orientation: orientation)
        
        if shouldPresentTutorial {
            presentTutorial(for: .instruction)
        } else {
            configureOverlay(with: configuration, orientation: orientation)
            start()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            self.orientation = MiSnapOrientation.current
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        MiSnapLocalizer.destroyShared()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        if configuration.parameters.camera.recordVideo {
            return false
        }
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if configuration.parameters.orientationMode != .deviceLandscapeGuideLandscape {
            guard let camera = camera, camera.parameters.recordVideo else {
                return .all
            }
            
            if orientation.isPortrait {
                return .portrait
            } else {
                return .landscape
            }
        }
        return .landscape
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: Public functions
extension MiSnapViewController {
    public func set(delegate: MiSnapViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    public func pauseAnalysis() {
        shouldSkipFrames = true
    }
    
    public func resumeAnalysis() {
        shouldSkipFrames = false
    }
    
    public static func miSnapVersion() -> String {
        return MiSnap.version()
    }
    
    public static func miSnapScienceVersion() -> String {
        return MiSnapScience.version()
    }
    
    public func checkCameraPermission(handler: @escaping (Bool) -> ()) {
        MiSnapCamera.checkPermission(handler)
    }
    
    public func checkMicrophonePermission(handler: @escaping (Bool) -> ()) {
        MiSnapCamera.checkMicrophonePermission(handler)
    }
    
    public func hasMinDiskSpace(_ minDiskSpace: Int) -> Bool {
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

// MARK: Private objects configuration functions
extension MiSnapViewController {
    private func configureOverlay(with configuration: MiSnapConfiguration, orientation: UIInterfaceOrientation) {
        if let _ = overlay { return }
        overlay = MiSnapOverlayView(with: configuration, delegate: self, orientation: orientation, frame: view.frame)
        guard let overlay = overlay else { fatalError("MiSnap Overlay wasn't initialized") }
        view.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leftAnchor.constraint(equalTo: view.leftAnchor),
            overlay.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        overlay.alpha = 0.0
    }
    
    private func configureAnalyzer(with parameters: MiSnapParameters, orientation: UIInterfaceOrientation) {
        if let _ = analyzer { return }
        analyzer = MiSnapAnalyzer(parameters: parameters, delegate: self, orientation: orientation)
    }
    
    private func configureCamera() {
        camera = MiSnapCamera(configuration.parameters.camera, orientation: orientation, delegate: self, frame: view.frame)
        guard let camera = camera else { fatalError("MiSnap Camera wasn't initialized") }
        camera.translatesAutoresizingMaskIntoConstraints = false
        guard let overlay = overlay else { fatalError("MiSnap Camera is initialized before MiSnap Overlay") }
        view.insertSubview(camera, belowSubview: overlay)
        
        NSLayoutConstraint.activate([
            camera.topAnchor.constraint(equalTo: view.topAnchor),
            camera.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            camera.leftAnchor.constraint(equalTo: view.leftAnchor),
            camera.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func configureCameraForSimulator() {
        camera = MiSnapCamera(frame: view.frame)
        guard let camera = camera, let imageName = configuration.parameters.injectImageName, let image = UIImage(named: imageName) else { return }
        camera.delegate = self
        camera.setImage(image, frameRate: 4)
    }
}

// MARK: Other private functions
extension MiSnapViewController {
    private func presentTutorial(for tutorialMode: MiSnapTutorialMode) {
        stopTimer()
        analyzer?.pause(for: tutorialMode)
        
        if let camera = camera {
            camera.turnTorchOff()
            camera.alpha = 0.0
        }
        
        if let overlay = overlay {
            overlay.alpha = 0.0
        }
        
        let messages = analyzer?.messages(for: tutorialMode) as! [String]
        
        tutorialViewController = MiSnapTutorialViewController(with: configuration.parameters, tutorialMode: tutorialMode, messages: messages, delegate: self, supportedOrientation: supportedInterfaceOrientations)
        guard let tutorialViewController = tutorialViewController else { fatalError("MiSnap Tutorial View Controller wasn't initialized") }
        
        // It is mandatory to set modalPresentationStyle to .fullScreen to avoid undefined behavior on devices running iOS 13.0 or newer
        tutorialViewController.modalPresentationStyle = .fullScreen
        tutorialViewController.modalTransitionStyle = .crossDissolve
        
        present(tutorialViewController, animated: true, completion: nil)
    }
    
    private func dismissTutorial(animated: Bool) {
        if let tutorialViewController = tutorialViewController {
            tutorialViewController.dismiss(animated: animated, completion: nil)
            tutorialViewController.shutdown()
            self.tutorialViewController = nil
        }
    }
    
    private func start() {
        #if !targetEnvironment(simulator)
        if let camera = camera, camera.isConfigured {
            didFinishConfiguringSession()
        } else {
            configureCamera()
        }
        #else
        configureCameraForSimulator()
        didFinishConfiguringSession()
        #endif
    }
    
    private func cancel() {
        cancelled = true
        camera?.discardRecording()
        analyzer?.cancel()
    }
    
    private func shutdown() {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
        
        if let camera = camera {
            camera.shutdown()
            camera.delegate = nil
            camera.removeFromSuperview()
            self.camera = nil
        }
        
        if let overlay = overlay {
            overlay.shutdown()
            overlay.removeFromSuperview()
            self.overlay = nil
        }
        
        if let analyzer = analyzer {
            analyzer.shutdown()
            analyzer.delegate = nil
            self.analyzer = nil
        }
    }
    
    private func dismiss(reason: MiSnapViewControllerDismissalReason, delay: Int = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) { [unowned self] in
            self.shutdown()
            if reason == .success {
                self.delegate?.miSnapDidFinishSuccessAnimation()
            }
            if self.configuration.uxParameters.shouldDismissOnSuccess || reason == .cancel {
                self.dismissTutorial(animated: false)
                if let navigationController = navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func startTimer() {
        if let _ = timer { return }
        
        timeoutOccurred = false
        
        if configuration.parameters.mode == .manual && configuration.parameters.camera.recordVideo {
            startTimer(with: 45)
        } else if configuration.parameters.mode == .auto {
            startTimer(with: TimeInterval(configuration.parameters.timeout) / 1000.0)
        }
    }
    
    @objc private func startTimer(with timeInterval: TimeInterval) {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timeoutDidOccur), userInfo: nil, repeats: false)
    }
    
    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc private func timeoutDidOccur() {
        stopTimer()
        camera?.discardRecording()
        timeoutOccurred = true
        shouldSkipFrames = true
        
        if configuration.parameters.seamlessFailover {
            presentSeamlessTimeoutTutorial()
        } else {
            presentTutorial(for: .timeout)
        }
    }
    
    private func presentSeamlessTimeoutTutorial() {
        let alert = UIAlertController(title: nil, message: MiSnapLocalizer.shared.localizedString(for: "help_seamless_failover"), preferredStyle: .alert)
        let retryAutoAction = UIAlertAction(title: MiSnapLocalizer.shared.localizedString(for: "misnap_tutorial_try_again"), style: .default) { [weak self] (action) in
            self?.didFinishConfiguringSession()
        }
        let retryManualAction = UIAlertAction(title: MiSnapLocalizer.shared.localizedString(for: "misnap_tutorial_capture_manually"), style: .default) { [weak self] (action) in
            self?.set(mode: .manual)
            self?.didFinishConfiguringSession()
        }
        alert.addAction(retryAutoAction)
        alert.addAction(retryManualAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func sessionWasInterrupted(_ notification: Notification) {
        stopTimer()
        analyzer?.pause()
        camera?.discardRecording()
        
        guard let dict = notification.userInfo, let reasonInt = dict[AVCaptureSessionInterruptionReasonKey] as? Int, let reason = AVCaptureSession.InterruptionReason(rawValue: reasonInt) else { return }
        
        switch reason {
        case .videoDeviceNotAvailableInBackground:
            overlay?.addInterruptionView(withMessage: MiSnapLocalizer.shared.localizedString(for: ""))
        case .audioDeviceInUseByAnotherClient:
            overlay?.addInterruptionView(withMessage: MiSnapLocalizer.shared.localizedString(for: "misnap_session_interruption_microphone_in_use"))
        case .videoDeviceInUseByAnotherClient:
            overlay?.addInterruptionView(withMessage: MiSnapLocalizer.shared.localizedString(for: "misnap_session_interruption_camera_in_use"))
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            overlay?.addInterruptionView(withMessage: MiSnapLocalizer.shared.localizedString(for: "misnap_session_interruption_multiple_foreground_apps"))
        default: break
        }
    }
    
    @objc private func sessionInterruptionEnded() {
        overlay?.removeInterruptionView()
        start()
    }
    
    private func playShutterSound() {
        AudioServicesPlaySystemSound(1108)
    }
    
    private func handleImageInjection() {
        if let injectImageName = configuration.parameters.injectImageName, let image = UIImage(named: injectImageName) {
            overlay?.setSelectedImage(image)
        }
    }
    
    private func toggleTorch() {
        guard let camera = camera, let analyzer = analyzer, let overlay = overlay else { return }
        if camera.isTorchOn {
            camera.turnTorchOff()
            analyzer.turnTorchOff()
            overlay.torchOn(false)
        } else {
            camera.turnTorchOn()
            analyzer.turnTorchOn()
            overlay.torchOn(true)
        }
    }
}

// MARK: MiSnapOverlayViewDelegate callbacks
extension MiSnapViewController: MiSnapOverlayViewDelegate {
    func cancelButtonAction() {
        cancel()
    }
    
    func helpButtonAction() {
        presentTutorial(for: .help)
    }
    
    func torchButtonAction() {
        toggleTorch()
    }
    
    func manualSelectionButtonAction() {
        analyzer?.selectCurrentFrame()
    }
}

// MARK: MiSnapTutorialViewControllerDelegate callbacks
extension MiSnapViewController: MiSnapTutorialViewControllerDelegate {
    func tutorialContinueButtonAction(for tutorialMode: MiSnapTutorialMode) {
        dismissTutorial(animated: true)
        if tutorialMode == .timeout {
            set(mode: .manual)
        }
    }
    
    func tutorialRetryButtonAction() {
        dismissTutorial(animated: true)
        overlay?.update(.auto)
    }
    
    func tutorialCancelButtonAction() {
        cancel()
    }
    
    private func set(mode: MiSnapMode) {
        configuration.parameters.mode = .manual
        overlay?.update(.manual)
        analyzer?.update(.manual)
    }
}

// MARK: MiSnapCameraDelegate callbacks
extension MiSnapViewController: MiSnapCameraDelegate {
    func didReceive(_ sampleBuffer: CMSampleBuffer) {
        if shouldSkipFrames { return }
        analyzer?.didReceive(sampleBuffer)
    }
    
    func didDecodeBarcode(_ decodedBarcodeString: String) {
        analyzer?.didReceiveDecodedBarcode(decodedBarcodeString)
    }
    
    func didFinishRecordingVideo(_ videoData: Data?) {
        camera?.delegate = nil
        delegate?.miSnapDidFinishRecordingVideo(videoData)
    }
    
    func didFinishConfiguringSession() {
        shouldSkipFrames = false
        delegate?.miSnapDidStartSession()

        guard let camera = camera, let overlay = overlay else { fatalError("One of the objects wasn't initialized") }
        
        if timeoutOccurred && configuration.parameters.seamlessFailover {
            camera.alpha = 1.0
            overlay.alpha = 1.0
        } else {
            camera.alpha = 0.0
            overlay.alpha = 0.0
            UIView.animate(withDuration: 1.0, delay: 0.3, options: .curveLinear, animations: {
                camera.alpha = 1.0
                overlay.alpha = 1.0
            }, completion: nil)
        }
        
        startTimer()
        analyzer?.resume()
        
        overlay.manageTorchButton(hasTorch: camera.hasTorch)
        camera.start()
        
        handleImageInjection()
    }
}

// MARK: MiSnapAnalyzerDelegate callbacks
extension MiSnapViewController: MiSnapAnalyzerDelegate {
    func miSnapAnalyzerSuccess(_ result: MiSnapResult!) {
        if timeoutOccurred { return }
        
        stopTimer()
        camera?.stop()
        // Set camera alpha to 0 so that the last preview frame is not visible if a user rotates a device after an image is selected
        camera?.alpha = 0.0
        
        playShutterSound()
        overlay?.successAnimation(with: result.image)
        
        delegate?.miSnapSuccess(result)
        
        dismiss(reason: .success, delay: configuration.parameters.terminationDelay)
    }
    
    func miSnapAnalyzerFrameResult(_ result: MiSnapResult!) {
        overlay?.update(for: result)
    }
    
    func miSnapAnalyzerCancelled(_ result: MiSnapResult!) {
        stopTimer()
        camera?.stop()
        
        delegate?.miSnapCancelled(result)
        
        dismiss(reason: .cancel)
    }
    
    func miSnapAnalyzerException(_ exception: NSException!) {
        delegate?.miSnapException(exception)
    }
}
