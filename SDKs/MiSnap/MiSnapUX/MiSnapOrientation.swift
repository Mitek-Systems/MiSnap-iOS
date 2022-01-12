//
//  MiSnapOrientation.swift
//  MiSnap UX
//
//  Created by Mitek Engineering on 2/25/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit

class MiSnapOrientation: NSObject {
    public static var current: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            guard let window = UIApplication.shared.windows.first, let scene = window.windowScene else { return .unknown }
            return scene.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
