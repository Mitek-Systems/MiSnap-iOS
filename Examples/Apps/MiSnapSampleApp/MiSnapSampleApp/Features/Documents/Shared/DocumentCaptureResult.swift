//
//  DocumentCaptureResult.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import Foundation
import MiSnap

// MARK: - Identifiable MiSnap Result Wrapper
struct DocumentCaptureResult: Identifiable {
    let id: UUID
    let result: MiSnapResult
    
    var mibiString: String? {
        result.mibi.string
    }
    
    var image: UIImage? {
        result.image
    }
    
    init(_ result: MiSnapResult) {
        self.id = UUID()
        self.result = result
    }
}
