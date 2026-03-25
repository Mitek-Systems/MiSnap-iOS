//
//  OrientationManager.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

/// Manages device orientation throughout the app.
///
/// This manager provides a centralized way to control which orientations
/// are supported at any given time. It's particularly useful when different
/// features require different orientations (e.g., portrait-only for face capture,
/// all orientations for document capture).
///
/// ## Usage
/// ```swift
/// // Set specific orientation
/// OrientationManager.shared.setOrientation(.portrait)
///
/// // Set different orientations for iPhone vs iPad
/// OrientationManager.shared.setOrientation(iPhone: .portrait, iPad: .all)
///
/// // Reset to default (all orientations)
/// OrientationManager.shared.resetToDefault()
/// ```
///
/// ## Requirements
/// Your AppDelegate must implement `application(_:supportedInterfaceOrientationsFor:)`
/// and return `OrientationManager.shared.currentOrientation`:
/// ```swift
/// func application(_ application: UIApplication,
///                  supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
///     return OrientationManager.shared.currentOrientation
/// }
/// ```
final class OrientationManager {
    /// Shared singleton instance
    static let shared = OrientationManager()
    
    private init() {}
    
    /// Current orientation mask that the app supports
    /// This value is read by AppDelegate to determine allowed orientations
    private(set) var currentOrientation: UIInterfaceOrientationMask = .all
    
    /// Sets the supported orientation for the app
    /// - Parameter orientation: The desired interface orientation mask (e.g., .portrait, .landscape, .all)
    func setOrientation(_ orientation: UIInterfaceOrientationMask) {
        currentOrientation = orientation
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            let value: Int
            switch orientation {
            case .portrait:             value = UIInterfaceOrientation.portrait.rawValue
            case .portraitUpsideDown:   value = UIInterfaceOrientation.portraitUpsideDown.rawValue
            case .landscapeLeft:        value = UIInterfaceOrientation.landscapeLeft.rawValue
            case .landscapeRight:       value = UIInterfaceOrientation.landscapeRight.rawValue
            default:                    value = UIInterfaceOrientation.unknown.rawValue
            }
            UIDevice.current.setValue(value, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    /// Sets orientation based on device type (iPhone vs iPad)
    /// - Parameters:
    ///   - iPhone: The orientation mask for iPhone
    ///   - iPad: The orientation mask for iPad
    func setOrientation(iPhone: UIInterfaceOrientationMask, iPad: UIInterfaceOrientationMask) {
        let orientation = UIDevice.current.userInterfaceIdiom == .pad ? iPad : iPhone
        setOrientation(orientation)
    }
    
    /// Resets orientation to support all orientations (default state)
    func resetToDefault() {
        setOrientation(.all)
    }
}
