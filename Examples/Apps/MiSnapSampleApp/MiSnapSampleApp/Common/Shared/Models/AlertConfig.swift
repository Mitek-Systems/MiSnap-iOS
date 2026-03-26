//
//  AlertConfig.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct AlertConfig: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: AlertButton?
    let secondaryButton: AlertButton?
    
    struct AlertButton {
        let title: String
        let action: () -> Void
    }
    
    init(title: String, message: String, primaryButton: AlertButton? = nil, secondaryButton: AlertButton? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    var alert: Alert {
        if let primaryButton = primaryButton, let secondaryButton = secondaryButton {
            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .default(Text(primaryButton.title), action: primaryButton.action),
                secondaryButton: .cancel(Text(secondaryButton.title), action: secondaryButton.action)
            )
        } else if let primaryButton = primaryButton {
            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text(primaryButton.title), action: primaryButton.action)
            )
        } else {
            return Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Factory Methods

extension AlertConfig {
    static func permissionDenied(_ type: PermissionType) -> AlertConfig {
        AlertConfig(
            title: "\(type.displayName) Access Required",
            message: "Please enable \(type.displayName.lowercased()) access in Settings \(type.purpose).",
            primaryButton: .init(title: "Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            },
            secondaryButton: .init(title: "Cancel") { }
        )
    }
    
    static func licenseError(message: String) -> AlertConfig {
        AlertConfig(
            title: "License Error",
            message: message
        )
    }
    
    static func diskSpaceError(minDiskSpace: Int) -> AlertConfig {
        AlertConfig(
            title: "Not Enough Space",
            message: "Please delete old/unused files to have at least \(minDiskSpace) MB of free space."
        )
    }
}

enum PermissionType {
    case camera
    case microphone
    case nfc
    
    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .microphone: return "Microphone"
        case .nfc: return "NFC"
        }
    }
    
    var purpose: String {
        switch self {
        case .camera: return "to capture images"
        case .microphone: return "to record audio"
        case .nfc: return "to read NFC"
        }
    }
}
