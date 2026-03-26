//
//  AppDelegate.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    /// Returns the supported interface orientations for the app.
    /// By delegating to `OrientationManager`, different features can dynamically control
    /// which orientations are allowed (e.g., portrait-only for face capture, landscape for documents).
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.currentOrientation
    }
}
