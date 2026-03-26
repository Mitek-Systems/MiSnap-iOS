//
//  MiSnapNFCDocumentType+Ext.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import Foundation
import MiSnapNFC

extension MiSnapNFCDocumentType: Identifiable {
    public var id: Int { rawValue }
}

extension MiSnapNFCDocumentType {
    var displayName: String {
        switch self {
        case .passport:         return "Passport"
        case .id:               return "ID"
        case .dl:               return "DL"
        case .none:
            assertionFailure("displayName should not be called for .none")
            return "Unknown"
        @unknown default:
            assertionFailure("Unknown MiSnapNFCDocumentType")
            return "Unknown"
        }
    }
    var symbolName: String {
        switch self {
        case .passport:         return "book"
        case .id:               return "person.text.rectangle"
        case .dl:               return "car"
        case .none:             return "questionmark"
        @unknown default:       return "questionmark"
        }
    }
}
