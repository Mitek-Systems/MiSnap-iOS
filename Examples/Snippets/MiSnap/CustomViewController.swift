//
//  CustomViewController.swift
//
//  Created by Mitek Engineering on 2/25/21.
//

import UIKit
import MiSnap
import MiSnapScience
import MiSnapCore

/**
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures an analyzer and a camera and connects them together.
 It's your responsibility to implement UX and UI
 
 All MVP UI functions are in the extension at the very bottom of this file.
 Delete this extension with all its content and implement your UI instead.
 */
@objc public class CustomViewController: UIViewController {
    private var camera: MiSnapCamera?
    private var analyzer: MiSnapAnalyzer?
    
    private var parameters: MiSnapParameters
    
    private var orientation: UIInterfaceOrientation = .unknown {
        didSet {
            if let analyzer = analyzer {
                analyzer.update(orientation)
            }
            if let camera = camera {
                if parameters.science.orientationMode != .deviceLandscapeGuideLandscape {
                    camera.orientation = orientation
                }
                camera.updatePreviewLayer(orientation)
            }
        }
    }
    
    private var shouldProcessFrames = true
    /**
     `hintLabel` is added for making this custom view controller an MVP.
     Delete and add your UI
     */
    private var hintLabel = UILabel()
            
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Use this initializer.
     Make sure to call `MiSnapParameters(for:)` to set an appropriate document type
     */
    public init(with parameters: MiSnapParameters) {
        self.parameters = parameters
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        orientation = preferredInterfaceOrientationForPresentation
        start()
        
        /**
         Uncomment to simulate a timeout for debugging purposes.
         Delete sample function below when implementing your UX and UI.
         */
        //simulateTimeoutAndRetry()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { [weak self] _ in
            guard let self = self else { return }
            self.orientation = UIApplication.shared.statusBarOrientation
        }
    }
    
    public override var shouldAutorotate: Bool {
        if parameters.camera.recordVideo {
            return false
        }
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if parameters.science.orientationMode != .deviceLandscapeGuideLandscape {
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
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("\(String(describing: type(of: self))) is deinitialized")
    }
}

// MARK: Public functions
extension CustomViewController {
    /**
     Query MiSnap version
     */
    public static func version() -> String {
        return MiSnap.version()
    }
    /**
     Call this function to check camera permission before presenting this view controller
     */
    public func checkCameraPermission(handler: @escaping (Bool) -> Void) {
        MiSnapCamera.checkPermission(handler)
    }
    /**
     Call this function to check microphone permission (if required) before presenting this view controller
     */
    public func checkMicrophonePermission(handler: @escaping (Bool) -> Void) {
        MiSnapCamera.checkMicrophonePermission(handler)
    }
}

// MARK: Private functions
extension CustomViewController {
    private func start() {
        configureUI()
        configureAnalyzer(with: parameters, orientation: orientation)
        configureCamera(with: parameters, orientation: orientation)
    }
    
    private func configureAnalyzer(with parameters: MiSnapParameters, orientation: UIInterfaceOrientation) {
        if let _ = analyzer { return }
        analyzer = MiSnapAnalyzer(parameters: parameters, delegate: self, orientation: orientation)
    }
    
    private func configureCamera(with parameters: MiSnapParameters, orientation: UIInterfaceOrientation) {
        if let camera = camera, camera.isConfigured {
            didFinishConfiguringSession()
        } else {
            camera = MiSnapCamera(parameters.camera, orientation: orientation, delegate: self, frame: view.frame)
            guard let camera = camera else { fatalError("MiSnap Camera wasn't initialized") }
            camera.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(camera, at: 0)
            
            NSLayoutConstraint.activate([
                camera.topAnchor.constraint(equalTo: view.topAnchor),
                camera.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                camera.leftAnchor.constraint(equalTo: view.leftAnchor),
                camera.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        }
    }
    
    private func configureUI() {
        /**
         Delete sample functions below and add your UI here
         */
        configureHintLabel()
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
            analyzer.shutdown()
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
     Use this function as selector for Torch button action
     */
    @objc private func toggleTorch(_ button: UIButton) {
        guard let camera = camera, let analyzer = analyzer else { return }
        if camera.isTorchOn {
            camera.turnTorchOff()
            analyzer.turnTorchOff()
        } else {
            camera.turnTorchOn()
            analyzer.turnTorchOn()
        }
    }
    /**
     Use this function as selector for Manual button action
     */
    @objc private func manualSelectionButtonAction(_ button: UIButton) {
        analyzer?.selectCurrentFrame()
    }
    /**
     Use this to update mode (e.g. from `Auto` to `Manual`)
     */
    private func set(mode: MiSnapMode) {
        parameters.mode = mode
        analyzer?.update(mode)
    }
}

// MARK: MiSnapCameraDelegate callbacks
extension CustomViewController: MiSnapCameraDelegate {
    public func didReceive(_ sampleBuffer: CMSampleBuffer) {
        guard shouldProcessFrames else { return }
        analyzer?.didReceive(sampleBuffer)
    }
    
    public func didFinishRecordingVideo(_ videoData: Data?) {
        /**
         Handle video data here when `parameters.camera.recordVideo` is set to `true`
         */
    }
    
    public func didFinishConfiguringSession() {
        guard let camera = camera else { fatalError("One of the objects wasn't initialized") }
        
        shouldProcessFrames = true
        
        camera.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 0.3, options: .curveLinear, animations: {
            camera.alpha = 1.0
        }, completion: nil)
        
        analyzer?.resume()
        
        camera.start()
    }
}

// MARK: MiSnapAnalyzerDelegate callbacks
extension CustomViewController: MiSnapAnalyzerDelegate {
    /**
     Called when license status is anything but valid or expired
     */
    public func miSnapAnalyzerLicenseStatus(_ status: MiSnapLicenseStatus) {
        /**
         Hanlde invalid license status here
         */
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            /**
             Delete sample function below
             */
            self.updateUIForInvalidLicense(status: status)
        }
    }
    /**
     Called when a frame passed all IQA checks
     */
    public func miSnapAnalyzerSuccess(_ result: MiSnapResult) {
        /**
         Set camera alpha to 0 so that the last preview frame is not visible if a user rotates a device after an image is selected
         */
        camera?.alpha = 0.0
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
    public func miSnapAnalyzerFrameResult(_ result: MiSnapResult) {
        guard shouldProcessFrames else { return }
        
        /**
         Delete sample function below when implementing your UX and UI
         */
        updateHintLabel(withText: MiSnapResult.code(from: result.highestPriorityStatus))
    }
    
    public func miSnapAnalyzerCancelled(_ result: MiSnapResult) {
        /**
         A user cancelled a session:
         - Return `result` to your application if needed
         - Make sure to call `shutdown` to prevent memory leaks
         - Dismiss or notify a parent that it's ready to be dismissed
         */
        
        dismiss()
    }
    
    public func miSnapAnalyzerException(_ exception: NSException) {
        /**
         Handle an exception thrown by OS that was caught by the SDK
         */
    }
}

// MARK: MVP UI and UX. Delete this extension with all functions in it and implement your UX and UI instead
extension CustomViewController {
    private func configureHintLabel() {
        guard hintLabel.frame == .zero else { return }
        
        hintLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        hintLabel.font = .systemFont(ofSize: 20)
        hintLabel.textAlignment = .center
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
