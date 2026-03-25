//
//  VoiceCaptureResult.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import Foundation
import MiSnapVoiceCapture
import MiSnapCore

// MARK: - Identifiable MiSnapVoiceCapture Result Wrapper
struct VoiceCaptureResult: Identifiable {
    let id: UUID
    let results: [MiSnapVoiceCaptureResult]
    let flow: MiSnapVoiceCaptureFlow
    let summary: String
    let mibiStrings: [String]
    
    var mibiString: String? {
        mibiStrings.first
    }
    
    var voiceData: Data? {
        results.first?.data
    }
    
    init(results: [MiSnapVoiceCaptureResult], flow: MiSnapVoiceCaptureFlow) {
        self.id = UUID()
        self.results = results
        self.flow = flow
        self.summary = results.formatResultsSummary(flow: flow)
        self.mibiStrings = results.map { $0.mibi.string ?? "Failed to exctract MIBI" }
    }
}

// MARK: - Formatting Extension
private extension Array where Element == MiSnapVoiceCaptureResult {
    func formatResultsSummary(flow: MiSnapVoiceCaptureFlow) -> String {
        var summary = ""
        
        // Add flow information at the beginning
        let flowName: String
        switch flow {
        case .enrollment:
            flowName = "Enrollment"
        case .verification:
            flowName = "Verification"
        @unknown default:
            flowName = "Unknown"
        }
        summary += "Flow: \(flowName)\n\n"
        
        for (idx, result) in self.enumerated() {
            summary += "Recording \(idx + 1)\n"
            
            let dataSize = (result.data ?? Data()).count
            let dataSizeKB = String(format: "%.2f KB", Double(dataSize) / 1024.0)
            summary += "Data size: \(dataSizeKB)\n"
            
            let speechLength = String(format: "%.0f ms", result.speechLength)
            summary += "Speech Length: \(speechLength)\n"
            
            let snr = String(format: "%.2f dB", result.snr)
            summary += "Signal-to-Noise Ratio: \(snr)\n"
            
            if idx < self.count - 1 {
                summary += "\n"
            }
        }
        
        return summary
    }
}
