//
//  MiSnapVoiceCaptureFlow+Ext.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import MiSnapVoiceCapture

extension MiSnapVoiceCaptureFlow: Identifiable {
    public var id: Int { rawValue }
}

extension MiSnapVoiceCaptureFlow {
    var displayName: String {
        switch self {
        case .enrollment:         return "Enrollment"
        case .verification:       return "Verification"
        @unknown default:
            assertionFailure("Unknown MiSnapNFCDocumentType")
            return "Unknown"
        }
    }
    var symbolName: String {
        switch self {
        case .enrollment:       return "waveform.badge.plus"
        case .verification:     return "waveform"
        @unknown default:       return "questionmark"
        }
    }
}
