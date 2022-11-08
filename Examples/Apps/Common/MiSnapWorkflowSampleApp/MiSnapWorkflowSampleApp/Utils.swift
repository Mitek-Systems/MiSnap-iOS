//
//  Utils.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 3/31/22.
//

import UIKit

enum Product: String, Equatable, CaseIterable {
    case mobileVerify       = "MobileVerify"
    case miPass             = "MiPass"
    
    static func from(_ index: Int) -> Product {
        switch index {
        case 0: return .mobileVerify
        case 1: return .miPass
        default: fatalError("No Product with index \(index)")
        }
    }
}

enum SDK: String, Equatable, CaseIterable {
    case misnap = "Document"
    case selfie = "Selfie"
    case nfc = "NFC"
    
    static func from(_ index: Int) -> SDK {
        switch index {
        case 0: return .misnap
        case 1: return .selfie
        case 2: return .nfc
        default: fatalError("No SDK with index \(index)")
        }
    }
}

enum NFCField: String, Equatable, CaseIterable {
    case documentNumber
    case dateOfBirth
    case dateOfExpiry
    case mrzString
    
    var placeholder: String {
        switch self {
        case .documentNumber:   return "Document Number"
        case .dateOfBirth:      return "Date of Birth (YYMMDD)"
        case .dateOfExpiry:     return "Date of Expiry (YYMMDD)"
        case .mrzString:        return "MRZ String"
        }
    }
    
    var index: Int {
        switch self {
        case .documentNumber:   return 0
        case .dateOfBirth:      return 1
        case .dateOfExpiry:     return 2
        case .mrzString:        return 3
        }
    }
    
    static func from(_ index: Int) -> NFCField {
        switch index {
        case 0:     return .documentNumber
        case 1:     return .dateOfBirth
        case 2:     return .dateOfExpiry
        case 3:     return .mrzString
        default:    fatalError("NFCField with index \(index) doesn't exist")
        }
    }
}

enum MiPassWorkflowType {
    case faceAndVoice
    case faceOnly
    case voiceOnly
    
    static func from(_ value: Int) -> MiPassWorkflowType {
        switch value {
        case 0:     return .faceAndVoice
        case 1:     return .faceOnly
        case 2:     return .voiceOnly
        default:    fatalError("There's no workflow type with value \(value)")
        }
    }
}

enum MiPassEnrollmentModification {
    case cancelled
    case newOrUpdateExisting
    case deleteExistingAndReenroll
}

extension Data {
    func size(_ unit: ByteCountFormatter.Units) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [unit]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
    }
}

extension URL {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension FileManager {
    func clearTempDirectory() {
        let tempDirUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: tempDirUrl.path), !fileNames.isEmpty else { return }
        for fileName in fileNames {
            try? FileManager.default.removeItem(atPath: tempDirUrl.appendingPathComponent(fileName).path)
        }
    }
}
