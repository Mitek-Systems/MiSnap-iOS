//
//  CustomFacialCaptureViewController.swift
//
//  Created by Mitek Engineering on 6/12/20.
//

import UIKit
import MiSnapFacialCapture

/*
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures an analyzer and a camera and connects them together.
 It's your responsibility to implement and present Introductory instruction, Help, Timeout
 or Review screens and control a timeout if required
 */
@objc public class CustomFacialCaptureViewController: UIViewController {
    private var analyzer: MiSnapFacialCaptureAnalyzer?
    private var camera: MiSnapFacialCaptureCamera?
    
    private var parameters: MiSnapFacialCaptureParameters
        
    required init?(coder: NSCoder) {
        fatalError("MiSnapFacialCaptureViewController.init(coder:) has not been implemented")
    }
    
    // Use this initializer
    init(with parameters: MiSnapFacialCaptureParameters) {
        self.parameters = parameters
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
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

// MARK: Private configuration functions
extension CustomFacialCaptureViewController {
    private func configureAnalyzer() {
        analyzer = MiSnapFacialCaptureAnalyzer(parameters: parameters)
        guard let analyzer = analyzer else { fatalError("Couldn't initialize analyzer") }
        analyzer.delegate = self
    }
    
    private func configureCameraView() {
        camera = MiSnapFacialCaptureCamera.init(preset: .hd1280x720, format: Int(kCVPixelFormatType_32BGRA), position: .front, frame: view.frame)
        guard let camera = camera else { fatalError("Couldn't initialize camera view") }
        camera.parameters = parameters.cameraParameters
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

extension CustomFacialCaptureViewController {
    private func start() {
        configureAnalyzer()
        
        if let camera = camera, camera.isConfigured {
            didFinishConfiguringSession()
        } else {
            configureCameraView()
        }
        analyzer?.resume()
    }
    
    // Call this function to deinitialize all objects to avoid memory leaks
    private func shutdown() {
        camera?.stop()
        camera?.delegate = nil
        camera?.removeFromSuperview()
        
        analyzer?.stop()
        analyzer?.delegate = nil
        analyzer = nil
    }
    
    /*
     Call this function only when a user cancels a session
     On success `shutdown` is called
     */
    private func cancel() {
        camera?.discardRecording()
        analyzer?.cancel()
    }
    
    // Use this function as selector for Manual button action
    func manualSelectionButtonAction() {
        analyzer?.selectFrame()
    }
    
    // Call this function to update mode (e.g. from `Auto` to `Manual`)
    private func set(mode: MiSnapFacialCaptureMode) {
        parameters.mode = mode
        analyzer?.update(parameters)
    }
}

// MARK: MiSnapFacialCaptureAnalyzerDelegate callbacks
extension CustomFacialCaptureViewController: MiSnapFacialCaptureAnalyzerDelegate {
    public func miSnapFacialCaptureAnalyzerLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Hanlde invalid license status here
    }
    
    public func miSnapFacialCaptureAnalyzerError(_ result: MiSnapFacialCaptureResults!) {
        // Handle frame analysis results here
    }
    
    public func miSnapFacialCaptureAnalyzerSuccess(_ result: MiSnapFacialCaptureResults!) {
        // Display success animation if needed here
        
        shutdown()
        
        // Dismiss here
    }
    
    public func miSnapFacialCaptureAnalyzerCancelled(_ result: MiSnapFacialCaptureResults!) {
        // Return cancellation result here
        
        shutdown()
        
        // Dismiss here
    }
    
    public func miSnapFacialCaptureAnalyzerManualOnly() {
        /*
         Devices running < iOS 12.0 support Manual only selfie acquistion
         without quality check.
         SDK returns this callback if such a device is detected
         */
    }
    
    public func miSnapFacialCaptureAnalyzerStartCountdown() {
        /*
         Handle countdown start
         Note, this callback is returned only when `selectOnSmile` is `false` in `MiSnapFacialCaptureParameters` (default)
         */
    }
}

// MARK: MiSnapFacialCaptureCameraDelegate callbacks
extension CustomFacialCaptureViewController: MiSnapFacialCaptureCameraDelegate {
    public func didFinishConfiguringSession() {
        camera?.start()
    }
    
    public func didReceive(_ sampleBuffer: CMSampleBuffer?) {
        analyzer?.analyze(sampleBuffer)
    }
    
    public func didFinishRecordingVideo(_ videoData: Data?) {
        // Handle video data here when `parameters.cameraParameters.recordVideo` is set to `true`
    }
}

// MARK: MiSnapFacialCaptureCamera permissions and other
extension CustomFacialCaptureViewController {
    // Query MiSnapFacialCapture version
    public static func version() -> String {
        return MiSnapFacialCapture.version()
    }
    
    /*
     Call this function to check camera permission after an instance
     of this view controller is initialized but before it's presented
     */
    public func checkCameraPermission(handler: @escaping (Bool) -> Void) {
        MiSnapFacialCaptureCamera.checkPermission(handler)
    }
    
    /*
     Call this function to check microphone permission (if required) after an
     instance of this view controller is initialized but before it's presented
     */
    public func checkMicrophonePermission(handler: @escaping (Bool) -> Void) {
        MiSnapFacialCaptureCamera.checkMicrophonePermission(handler)
    }
}
