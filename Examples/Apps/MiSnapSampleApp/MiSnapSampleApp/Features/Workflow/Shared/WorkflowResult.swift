//
//  WorkflowResult.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapCore
#if canImport(MiSnapUX)
import MiSnap
import MiSnapFacialCapture
import MiSnapVoiceCapture
#endif

// MARK: - Result Model
struct WorkflowResult: Identifiable {
    let id: UUID
    let workflowResult: MiSnapWorkflowResult
    let completedSteps: [MiSnapWorkflowStep]
    let mibiData: String
    let images: [UIImage]
    let audioData: [Data]?
    
    init(_ result: MiSnapWorkflowResult) {
        self.id = UUID()
        self.workflowResult = result
        
        var steps: [MiSnapWorkflowStep] = []
        var mibiStrings: [String] = []
        var capturedImages: [UIImage] = []
        var audioRecordings: [Data] = []
        
        // Process NFC result
        Self.processNFC(result, steps: &steps, mibiStrings: &mibiStrings, images: &capturedImages)
        
        // Process document capture results
        Self.processDocuments(result, steps: &steps, mibiStrings: &mibiStrings, images: &capturedImages)
        
        // Process Face result
        Self.processFace(result, steps: &steps, mibiStrings: &mibiStrings, images: &capturedImages)
        
        // Process Voice results
        Self.processVoice(result, steps: &steps, mibiStrings: &mibiStrings, audioData: &audioRecordings)
                
        self.completedSteps = steps
        self.mibiData = mibiStrings.joined(separator: "\n\n")
        self.images = capturedImages
        self.audioData = audioRecordings.isEmpty ? nil : audioRecordings
    }
    
    // MARK: - Processing Methods
    
    private static func processNFC(
        _ workflowResult: MiSnapWorkflowResult,
        steps: inout [MiSnapWorkflowStep],
        mibiStrings: inout [String],
        images: inout [UIImage]
    ) {
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        if let nfcData = workflowResult.nfc {
            steps.append(.nfc)
            let result = NFCResult(nfcData)
            mibiStrings.append("NFC Result:\n\(nfcData.formattedNFCString)")
            
            if let nfcImages = result.images {
                images.append(contentsOf: nfcImages)
            }
        }
        #endif
    }
    
    private static func processDocuments(
        _ workflowResult: MiSnapWorkflowResult,
        steps: inout [MiSnapWorkflowStep],
        mibiStrings: inout [String],
        images: inout [UIImage]
    ) {
        #if canImport(MiSnapUX) && canImport(MiSnap)
        if let result = workflowResult.idFront {
            steps.append(.idFront)
            mibiStrings.append("ID Front MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        
        if let result = workflowResult.idBack {
            steps.append(.idBack)
            mibiStrings.append("ID Back MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        
        if let result = workflowResult.passport {
            steps.append(.passport)
            mibiStrings.append("Passport MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        
        if let result = workflowResult.passportQr {
            steps.append(.passportQr)
            mibiStrings.append("Passport QR MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        
        if let result = workflowResult.checkFront {
            steps.append(.checkFront)
            mibiStrings.append("Check Front MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        
        if let result = workflowResult.checkBack {
            steps.append(.checkBack)
            mibiStrings.append("Check Back MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        #endif
    }
    
    private static func processFace(
        _ workflowResult: MiSnapWorkflowResult,
        steps: inout [MiSnapWorkflowStep],
        mibiStrings: inout [String],
        images: inout [UIImage]
    ) {
        #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
        if let result = workflowResult.face {
            steps.append(.face)
            mibiStrings.append("Face MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
            if let image = result.image {
                images.append(image)
            }
        }
        #endif
    }
    
    private static func processVoice(
        _ workflowResult: MiSnapWorkflowResult,
        steps: inout [MiSnapWorkflowStep],
        mibiStrings: inout [String],
        audioData: inout [Data]
    ) {
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        if let voiceResults = workflowResult.voice, !voiceResults.isEmpty {
            steps.append(.voice)
            
            for (index, result) in voiceResults.enumerated() {
                mibiStrings.append("Voice Recording \(index + 1) MIBI:\n\(result.mibi.string ?? "Failed to extract MIBI")")
                if let audio = result.data {
                    audioData.append(audio)
                }
            }
        }
        #endif
    }
}
