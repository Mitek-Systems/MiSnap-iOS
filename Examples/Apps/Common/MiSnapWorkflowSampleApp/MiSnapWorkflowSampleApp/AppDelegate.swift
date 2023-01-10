//
//  AppDelegate.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 11/25/19.
//  Copyright © 2019 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapLicenseManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MiSnapLicenseManager.shared().setLicenseKey("eyJzaWduYXR1cmUiOiJvNElpS1RvbHhFa1dSWUUxQ2VEalVIRm94ZTRxOStrOGhsNU5pZ2Zxa0ZQLytXVGhCeDZZV3MwVjhWMHZkMGtqZlJBaHB2VUhuUThXM2t6RHZsS1dueE0vV1VYcGhRcThVV2ZySGFNek1NcXdRc0VZRlFtMzdvdmVrQVN2ZmZMdnVRTEt5NENtamZieFRiNTBxcGtZaVRMMjQ1S2ZlSjVVMk4rQXBZZkxVM1YzNThGc1Zpait4bXR4VkdiY3hQTmkxekdoODloMUsyUmxOMEpPajVTTytpTGNFN1hBZTJEakNDbWdrV1dXejhRL25BQXM3VnVLM091YU9GNEE0WVd5ZUc5eW44RlFkcVNJdXUyNHB0ZkNjMGFxajFsejBrRlFxN0l3ams0NGIrYWZ0cTQvTWJ4Vm5FNWlvYkc0YTJOYVQwZnFOSWtPWm04S3NBOUlsZmtMUVE9PSIsInNpZ25lZCI6eyJleHBpcnkiOiIyMDMyLTEyLTMwIiwiZmVhdHVyZXMiOlsiYmFyY29kZSIsImRlcG9zaXQiLCJmYWNlIiwiZ2VuZXJpYyIsImlkIiwibmZjIiwib2RjIiwib2RlIiwidm9pY2UiLCJlbSJdLCJhcHBsaWNhdGlvbklkZW50aWZpZXIiOnsiaW9zIjpbImNvbS5taXRla3N5c3RlbXMuKiJdfSwiZ3BvIjoiMTZkIiwib3JnYW5pemF0aW9uIjoiTWl0ZWsgU3lzdGVtcyBJbmMuIiwidmVyc2lvbiI6IjEuMCJ9fQ==")
        print(MiSnapLicenseManager.shared().description)
        
        /**
         By default, this app functions in `offline` mode (a transaction isn't send to a back end from processing)
         Set your valid credentials and update configuration with valid info to enable `online` mode (a transaction is sent to a back end from processing)
         */
        let configuration = MitekPlatformConfiguration(withClientId: "your_client_id_here", clientSecret: "your_client_secret_here")
            .withMobileVerifyConfiguration { mobileVerify in
                mobileVerify.tokenUrl = "your_mobile_verify_token_url_here"
                mobileVerify.url = "your_mobile_verify_url_here"
                mobileVerify.scope = "your_mobile_verify_scope_here"
            }
            .withMiPassConfiguration { miPass in
                miPass.tokenUrl = "your_mipass_token_url_here"
                miPass.baseUrl = "your_mipass_base_url_here"
                miPass.scope = "your_mipass_scope_here"
            }
        MitekPlatform.shared.set(configuration: configuration)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
