//
//  FaceCaptureResult.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import Foundation
import MiSnapFacialCapture

// MARK: - Identifiable MiSnap Result Wrapper
struct FaceCaptureResult: Identifiable {
    let id: UUID
    let result: MiSnapFacialCaptureResult
    
    var mibiString: String? {
        var components: [String] = []
        
        // Add AI-based RTS payload size if available
        if let aiBasedRts = result.aiBasedRts {
            let payloadSize = aiBasedRts.count
            let formattedSize = ByteCountFormatter.string(fromByteCount: Int64(payloadSize), countStyle: .file)
            components.append("AI-based RTS payload size: \(formattedSize)")
        }
        
        // Add MIBI string
        if let mibi = result.mibi.string {
            components.append(mibi)
        }
        
        return components.isEmpty ? nil : components.joined(separator: "\n\n")
    }
    
    var image: UIImage? {
        result.image
    }
    
    init(_ result: MiSnapFacialCaptureResult) {
        self.id = UUID()
        self.result = result
    }
}
