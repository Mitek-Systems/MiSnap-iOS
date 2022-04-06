//
//  CustomViewController.swift
//
//  Created by Mitek Engineering on 2/25/21.
//

import UIKit
import MiSnap
import MiSnapScience
import MiSnapLicenseManager

/*
 This view controller provided for your reference when building a custom UX.
 Note, that it only configures an analyzer and a camera and connects them together.
 It's your responsibility to implement and present Introductory instruction, Help, Timeout
 or Review screens and control a timeout if required
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
                if parameters.science.orientationMode == .deviceLandscapeGuideLandscape && orientation.isPortrait {
                    camera.orientation = .landscapeRight
                } else {
                    camera.orientation = orientation
                }
                camera.updatePreviewLayer(orientation)
            }
        }
    }
            
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use this initializer
    init(with parameters: MiSnapParameters) {
        self.parameters = parameters
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        orientation = UIApplication.shared.statusBarOrientation
        start()
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
    // Query MiSnap version
    public static func version() -> String {
        return MiSnap.version()
    }
    
    /*
     Call this function to check camera permission after an instance
     of this view controller is initialized but before it's presented
     */
    @objc public func checkCameraPermission(handler: @escaping (Bool) -> ()) {
        MiSnapCamera.checkPermission(handler)
    }
    
    /*
     Call this function to check microphone permission (if required) after an
     instance of this view controller is initialized but before it's presented
     */
    @objc public func checkMicrophonePermission(handler: @escaping (Bool) -> ()) {
        MiSnapCamera.checkMicrophonePermission(handler)
    }
}

// MARK: Private functions
extension CustomViewController {
    private func configureAnalyzer(with parameters: MiSnapParameters, orientation: UIInterfaceOrientation) {
        if let _ = analyzer { return }
        analyzer = MiSnapAnalyzer(parameters: parameters, delegate: self, orientation: orientation)
    }
    
    private func configureCamera() {
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
    
    private func start() {
        configureAnalyzer(with: parameters, orientation: orientation)
        
        if let camera = camera, camera.isConfigured {
            didFinishConfiguringSession()
        } else {
            configureCamera()
        }
    }
    
    // Call this function to deinitialize all objects to avoid memory leaks
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
    
    /*
     Call this function only when a user cancels a session
     On success `shutdown` is called
     */
    private func cancel() {
        camera?.discardRecording()
        analyzer?.cancel()
    }
    
    // Use this function as selector for Torch button action
    private func toggleTorch() {
        guard let camera = camera, let analyzer = analyzer else { return }
        if camera.isTorchOn {
            camera.turnTorchOff()
            analyzer.turnTorchOff()
        } else {
            camera.turnTorchOn()
            analyzer.turnTorchOn()
        }
    }
    
    // Use this function as selector for Manual button action
    private func manualSelectionButtonAction() {
        analyzer?.selectCurrentFrame()
    }
    
    // Use this to update mode (e.g. from `Auto` to `Manual`)
    private func set(mode: MiSnapMode) {
        parameters.mode = mode
        analyzer?.update(mode)
    }
}

// MARK: MiSnapCameraDelegate callbacks
extension CustomViewController: MiSnapCameraDelegate {
    public func didReceive(_ sampleBuffer: CMSampleBuffer) {
        analyzer?.didReceive(sampleBuffer)
    }
    
    public func didFinishRecordingVideo(_ videoData: Data?) {
        // Handle video data here when `parameters.camera.recordVideo` is set to `true`
    }
    
    public func didFinishConfiguringSession() {
        guard let camera = camera else { fatalError("One of the objects wasn't initialized") }
        
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
    public func miSnapAnalyzerLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Hanlde invalid license status here
    }

    public func miSnapAnalyzerSuccess(_ result: MiSnapResult!) {
        // Set camera alpha to 0 so that the last preview frame is not visible if a user rotates a device after an image is selected
        camera?.alpha = 0.0
        
        // Display success animation if needed here
        
        // Return result here
        
        shutdown()
        
        // Dismiss here
    }

    public func miSnapAnalyzerFrameResult(_ result: MiSnapResult!) {
        // Handle frame analysis results here
    }
    
    public func miSnapAnalyzerCancelled(_ result: MiSnapResult!) {
        // Return cancellation result here
        
        shutdown()
        
        // Dismiss here
    }
    
    public func miSnapAnalyzerException(_ exception: NSException!) {
        // Handle caught exception here
    }
}
