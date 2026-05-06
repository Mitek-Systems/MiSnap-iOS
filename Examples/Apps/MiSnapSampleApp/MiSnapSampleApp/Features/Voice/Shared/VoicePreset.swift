//
//  VoicePreset.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import MiSnapVoiceCapture

enum VoicePreset: String, CaseIterable, Identifiable {
    case enrollment       = "Enrollment"
    case customEnrollment = "Custom Enrollment"
    case verification     = "Verification"

    var id: String { rawValue }

    var flow: MiSnapVoiceCaptureFlow {
        switch self {
        case .enrollment, .customEnrollment: return .enrollment
        case .verification:                  return .verification
        }
    }

    var symbolName: String {
        switch self {
        case .enrollment:       return "waveform.badge.plus"
        case .customEnrollment: return "waveform.badge.plus"
        case .verification:     return "waveform"
        }
    }
}
