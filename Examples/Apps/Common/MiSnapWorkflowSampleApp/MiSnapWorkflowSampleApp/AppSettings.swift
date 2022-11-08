//
//  AppSettings.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 9/12/22.
//

import UIKit

enum AppMode: Int {
    case online
    case offline
    
    var index: Int {
        switch self {
        case .online:   return 0
        case .offline:  return 1
        }
    }
    
    static func from(_ index: Int) -> AppMode {
        switch index {
        case 0:     return .online
        case 1:     return .offline
        default:    fatalError("There's no AppMode with index \(index)")
        }
    }
}

class AppSettings {
    private static var sharedInstance: AppSettings?
    
    class var shared: AppSettings {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = AppSettings()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        return sharedInstance
    }
    
    class func destroyShared() {
        self.sharedInstance = nil
    }
    
    private init() {
        let userDefaults = UserDefaults.standard
        
        if let mode = userDefaults.object(forKey: "AppMode") as? Int {
            self.mode = AppMode.from(mode)
        }
        
        if let voiceDataSavingMode = userDefaults.object(forKey: "VoiceDataSavingMode") as? Int {
            self.voiceDataSavingMode = VoiceDataSavingMode.from(voiceDataSavingMode)
        }
    }
    
    var mode: AppMode = .online {
        didSet {
            UserDefaults.standard.set(mode.index, forKey: "AppMode")
            UserDefaults.standard.synchronize()
        }
    }
    
    var voiceDataSavingMode: VoiceDataSavingMode = .none {
        didSet {
            UserDefaults.standard.set(voiceDataSavingMode.index, forKey: "VoiceDataSavingMode")
            UserDefaults.standard.synchronize()
        }
    }
}
