//
//  MiSnapLocalizer.swift
//  MiSnap UX
//
//  Created by Stas Tsuprenko on 6/12/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit

class MiSnapLocalizer {
    private static var sharedInstance: MiSnapLocalizer?
    
    private var bundle: Bundle!
    private var localizableStringsName: String!
    
    class var shared: MiSnapLocalizer {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = MiSnapLocalizer()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        return sharedInstance
    }
    
    class func destroyShared() {
        self.sharedInstance = nil
    }
    
    private init() {
        self.bundle = Bundle.main
        self.localizableStringsName = "MiSnapLocalizable"
    }
    
    public func set(bundle: Bundle = Bundle.main, localizableStringsName: String = "MiSnapLocalizable") {
        self.bundle = bundle
        self.localizableStringsName = localizableStringsName
    }
    
    public func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: key, table: localizableStringsName)
    }
}
