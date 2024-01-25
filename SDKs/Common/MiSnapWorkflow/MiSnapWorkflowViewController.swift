//
//  MiSnapWorkflowViewController.swift
//  MiSnapWorkflow
//
//  Created by Stas Tsuprenko on 11/25/19.
//  Copyright © 2019 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapCore
#if canImport(MiSnapUX) && canImport(MiSnap)
import MiSnapUX
#endif
#if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
import MiSnapFacialCaptureUX
#endif
#if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
import MiSnapVoiceCaptureUX
#endif
/**
 Defines an interface for delegates of `MiSnapWorkflowViewControllerDelegate` to receive callbacks
 */
protocol MiSnapWorkflowViewControllerDelegate: NSObject {
    /**
     Delegates receive this callback only when license status is anything but valid
     */
    func miSnapWorkflowLicenseStatus(_ status: MiSnapLicenseStatus)
    /**
     Delegates receive this callback when the workflow was successfully completed and the final result is available
     */
    func miSnapWorkflowSuccess(_ result: MiSnapWorkflowResult)
    /**
     Delegates receive this callback after each completed step (optional)
     */
    func miSnapWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep)
    /**
     Delegates receive this callback when a user cancels a flow on any step
     */
    func miSnapWorkflowCancelled(_ result: MiSnapWorkflowResult)
    /**
     Delegates receive this callback when an error occurs in any SDK
     */
    func miSnapWorkflowError(_ result: MiSnapWorkflowResult)
    
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    /**
     Delegates receive this callback when an NFC step is skipped by a user (optional)
     */
    func miSnapWorkflowNfcSkipped(_ result: [String : Any])
    #endif
    
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    /**
     Delegates receive this callback when a use has chosen a phrase in an Enrollment flow
     */
    func miSnapWorkflowDidSelectPhrase(_ phrase: String)
    #endif
}

extension MiSnapWorkflowViewControllerDelegate {
    func miSnapWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep) {}
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    func miSnapWorkflowNfcSkipped(_ result: [String : Any]) {}
    #endif
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    func miSnapWorkflowDidSelectPhrase(_ phrase: String) {}
    #endif
}
/**
 Workflow view controller
 */
class MiSnapWorkflowViewController: UIViewController {
    private weak var delegate: MiSnapWorkflowViewControllerDelegate?
    private var containerView: UIView = UIView()
    private var controller: MiSnapWorkflowController?
    private var currentChildVC: UIViewController?
    private var supportedOrientation: UIInterfaceOrientationMask = .all
    /**
     Initializes a view controller for MobileVerify
     */
    init(with steps:[MiSnapWorkflowStep], delegate: MiSnapWorkflowViewControllerDelegate) {
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
        
        controller = MiSnapWorkflowController(with: steps, delegate: self)
        controller?.nextStep()
    }
    /**
     Initializes a view controller for MiPass
     */
    init(for flow: MiSnapWorkflowFlow, with steps:[MiSnapWorkflowStep], delegate: MiSnapWorkflowViewControllerDelegate, phrase: String? = nil) {
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
        
        controller = MiSnapWorkflowController(for: flow, with: steps, delegate: self, phrase: phrase)
        controller?.nextStep()
    }
    /**
     Static helper to check camera permission
     */
    public static func checkCameraPermission(handler: @escaping (Bool) -> Void) {
        #if canImport(MiSnapUX) && canImport(MiSnap)
        MiSnapViewController.checkCameraPermission(handler: handler)
        #elseif canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
        MiSnapFacialCaptureViewController.checkCameraPermission(handler: handler)
        #endif
    }
    /**
     Static helper to check microphone permission
     */
    public static func checkMicrophonePermission(handler: @escaping (Bool) -> Void) {
        #if canImport(MiSnapUX) && canImport(MiSnap)
        MiSnapViewController.checkMicrophonePermission(handler: handler)
        #elseif canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
        MiSnapFacialCaptureViewController.checkMicrophonePermission(handler: handler)
        #elseif canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        MiSnapVoiceCaptureViewController.checkMicrophonePermission(handler: handler)
        #endif
    }
    /**
     Static helper to check min disk space
     */
    public static func hasMinDiskSpace(_ minDiskSpace: Int) -> Bool {
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.frame = view.frame
        view.addSubview(containerView)
    }
        
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        containerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let childVC = currentChildVC {
            childVC.viewWillTransition(to: size, with: coordinator)
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientation
    }
    
    override var shouldAutorotate: Bool {
        if supportedOrientation == .portrait {
            if !UIApplication.shared.statusBarOrientation.isPortrait {
                return true
            }
            return false
        } else if supportedOrientation == .landscape && UIApplication.shared.statusBarOrientation.isLandscape {
            return false
        }
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Private methods
    private func present(asChildViewController vc:UIViewController) {
        vc.navigationController?.navigationBar.isHidden = true
        vc.modalPresentationStyle = .fullScreen
        
        self.addChild(vc)
        self.containerView.addSubview(vc.view)
        vc.view.frame = containerView.bounds
        
        vc.didMove(toParent: self)
    }
    
    private func move(from fromVC:UIViewController, to toVC:UIViewController) {
        toVC.navigationController?.navigationBar.isHidden = true
        toVC.modalPresentationStyle = .fullScreen
        
        toVC.view.frame = fromVC.view.frame
        self.addChild(toVC)
        fromVC.willMove(toParent: nil)
        
        transition(from: fromVC, to: toVC, duration: 0.0, options: .transitionCrossDissolve) {
            toVC.didMove(toParent: self)
            fromVC.removeFromParent()
        }
    }
    
    func dismiss() {
        if let childVC = currentChildVC {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        
        currentChildVC = nil
        controller?.delegate = nil
        controller = nil
        delegate = nil
        
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func willRotate(for orientationMask: UIInterfaceOrientationMask) -> Bool {
        if UIInterfaceOrientation.current.isPortrait && (orientationMask == .landscape || orientationMask == .landscapeLeft || orientationMask == .landscapeRight) {
            return true
        } else if UIInterfaceOrientation.current.isLandscape && (orientationMask == .portrait || orientationMask == .portraitUpsideDown || orientationMask == .all) {
            return true
        }
        return false
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: MiSnapWorkflowControllerDelegate callbacks
extension MiSnapWorkflowViewController: MiSnapWorkflowControllerDelegate {
    func miSnapWorkflowControllerLicenseStatus(_ status: MiSnapLicenseStatus) {
        delegate?.miSnapWorkflowLicenseStatus(status)
        dismiss()
    }
    
    func miSnapWorkflowControllerPresent(_ vc: UIViewController!, supportedOrientation: UIInterfaceOrientationMask, step: MiSnapWorkflowStep) {
        self.supportedOrientation = supportedOrientation
        
        var delay: Int = 0
        if willRotate(for: supportedOrientation) {
            delay = 250
        }
        
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            for window in windowScene.windows {
                window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: supportedOrientation))
        } else {
            if supportedOrientation == .portrait || supportedOrientation == .all {
                UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            } else if supportedOrientation == .landscape {
                UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }
            
            _ = self.supportedInterfaceOrientations
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) { [weak self] in
            guard let self = self else { return }
            if let childVC = self.currentChildVC {
                self.move(from: childVC, to: vc)
            } else {
                self.present(asChildViewController: vc)
            }
            
            self.currentChildVC = vc
        }
    }
    
    func miSnapWorkflowControllerDidFinishPresentingSteps(_ result: MiSnapWorkflowResult) {
        delegate?.miSnapWorkflowSuccess(result)
        dismiss()
    }
    
    func miSnapWorkflowControllerIntermediate(_ result: Any, step: MiSnapWorkflowStep) {
        delegate?.miSnapWorkflowIntermediate(result, step: step)
    }
    
    func miSnapWorkflowControllerCancelled(_ result: MiSnapWorkflowResult) {
        delegate?.miSnapWorkflowCancelled(result)
        dismiss()
    }
    
    func miSnapWorkflowControllerError(_ result: MiSnapWorkflowResult) {
        delegate?.miSnapWorkflowError(result)
        dismiss()
    }
    
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    func miSnapWorkflowControllerNfcSkipped(_ result: [String : Any]) {
        delegate?.miSnapWorkflowNfcSkipped(result)
    }
    #endif
    
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    func miSnapWorkflowControllerDidSelectPhrase(_ phrase: String) {
        delegate?.miSnapWorkflowDidSelectPhrase(phrase)
    }
    #endif
}

extension UINavigationController {
    override open var shouldAutorotate: Bool {
        if let visibleVC = visibleViewController {
            return visibleVC.shouldAutorotate
        }
        return super.shouldAutorotate
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let visibleVC = visibleViewController {
            return visibleVC.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let visibleVC = visibleViewController {
            return visibleVC.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}

private extension UIInterfaceOrientation {
    static var current: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            guard let window = UIApplication.shared.windows.first, let scene = window.windowScene else { return .unknown }
            return scene.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
