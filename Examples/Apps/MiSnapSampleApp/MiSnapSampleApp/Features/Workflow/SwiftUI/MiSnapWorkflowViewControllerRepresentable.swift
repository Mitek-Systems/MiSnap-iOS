//
//  MiSnapWorkflowViewControllerRepresentable.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapCore

struct MiSnapWorkflowViewControllerRepresentable: UIViewControllerRepresentable {
    let steps: [MiSnapWorkflowStep]
    let flow: MiSnapWorkflowFlow?
    let phrase: String?
    let onLicenseStatus: (MiSnapLicenseStatus) -> Void
    let onSuccess: (MiSnapWorkflowResult) -> Void
    let onCancelled: (MiSnapWorkflowResult) -> Void
    let onError: (MiSnapWorkflowResult) -> Void
    let onIntermediate: (Any, MiSnapWorkflowStep) -> Void
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    let onNfcSkipped: ([String: Any]) -> Void
    #endif
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    let onPhraseSelected: (String) -> Void
    #endif
    
    // MARK: - Initializers
    
    /// Initialize for MobileVerify (legacy single parameter constructor)
    init(
        steps: [MiSnapWorkflowStep],
        onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void = { _ in },
        onSuccess: @escaping (MiSnapWorkflowResult) -> Void,
        onCancelled: @escaping (MiSnapWorkflowResult) -> Void,
        onError: @escaping (MiSnapWorkflowResult) -> Void,
        onIntermediate: @escaping (Any, MiSnapWorkflowStep) -> Void = { _, _ in },
        onNfcSkipped: @escaping ([String: Any]) -> Void = { _ in },
        onPhraseSelected: @escaping (String) -> Void = { _ in }
    ) {
        self.steps = steps
        self.flow = nil
        self.phrase = nil
        self.onLicenseStatus = onLicenseStatus
        self.onSuccess = onSuccess
        self.onCancelled = onCancelled
        self.onError = onError
        self.onIntermediate = onIntermediate
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        self.onNfcSkipped = onNfcSkipped
        #endif
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        self.onPhraseSelected = onPhraseSelected
        #endif
    }
    
    /// Initialize for MiPass (flow-based constructor)
    init(
        flow: MiSnapWorkflowFlow,
        steps: [MiSnapWorkflowStep],
        phrase: String? = nil,
        onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void = { _ in },
        onSuccess: @escaping (MiSnapWorkflowResult) -> Void,
        onCancelled: @escaping (MiSnapWorkflowResult) -> Void,
        onError: @escaping (MiSnapWorkflowResult) -> Void,
        onIntermediate: @escaping (Any, MiSnapWorkflowStep) -> Void = { _, _ in },
        onNfcSkipped: @escaping ([String: Any]) -> Void = { _ in },
        onPhraseSelected: @escaping (String) -> Void = { _ in }
    ) {
        self.steps = steps
        self.flow = flow
        self.phrase = phrase
        self.onLicenseStatus = onLicenseStatus
        self.onSuccess = onSuccess
        self.onCancelled = onCancelled
        self.onError = onError
        self.onIntermediate = onIntermediate
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        self.onNfcSkipped = onNfcSkipped
        #endif
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        self.onPhraseSelected = onPhraseSelected
        #endif
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLicenseStatus: onLicenseStatus,
            onSuccess: onSuccess,
            onCancelled: onCancelled,
            onError: onError,
            onIntermediate: onIntermediate,
            onNfcSkipped: onNfcSkipped,
            onPhraseSelected: onPhraseSelected
        )
    }
    
    class Coordinator: NSObject, MiSnapWorkflowViewControllerDelegate {
        let onLicenseStatus: (MiSnapLicenseStatus) -> Void
        let onSuccess: (MiSnapWorkflowResult) -> Void
        let onCancelled: (MiSnapWorkflowResult) -> Void
        let onError: (MiSnapWorkflowResult) -> Void
        let onIntermediate: (Any, MiSnapWorkflowStep) -> Void
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        let onNfcSkipped: ([String: Any]) -> Void
        #endif
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        let onPhraseSelected: (String) -> Void
        #endif
        
        init(
            onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void,
            onSuccess: @escaping (MiSnapWorkflowResult) -> Void,
            onCancelled: @escaping (MiSnapWorkflowResult) -> Void,
            onError: @escaping (MiSnapWorkflowResult) -> Void,
            onIntermediate: @escaping (Any, MiSnapWorkflowStep) -> Void,
            onNfcSkipped: @escaping ([String: Any]) -> Void,
            onPhraseSelected: @escaping (String) -> Void
        ) {
            self.onLicenseStatus = onLicenseStatus
            self.onSuccess = onSuccess
            self.onCancelled = onCancelled
            self.onError = onError
            self.onIntermediate = onIntermediate
            #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
            self.onNfcSkipped = onNfcSkipped
            #endif
            #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
            self.onPhraseSelected = onPhraseSelected
            #endif
        }
        
        // MARK: - MiSnapWorkflowViewControllerDelegate
        func miSnapWorkflowLicenseStatus(_ status: MiSnapLicenseStatus) {
            onLicenseStatus(status)
        }
        
        func miSnapWorkflowSuccess(_ result: MiSnapWorkflowResult) {
            onSuccess(result)
        }
        
        func miSnapWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep) {
            onIntermediate(result, step)
        }
        
        func miSnapWorkflowCancelled(_ result: MiSnapWorkflowResult) {
            onCancelled(result)
        }
        
        func miSnapWorkflowError(_ result: MiSnapWorkflowResult) {
            onError(result)
        }
        
        func miSnapWorkflowOrientationDidChange(_ orientations: UIInterfaceOrientationMask, for step: MiSnapWorkflowStep) {
            // Update orientation through the app's orientation manager
            OrientationManager.shared.setOrientation(orientations)
        }
        
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        func miSnapWorkflowNfcSkipped(_ result: [String : Any]) {
            onNfcSkipped(result)
        }
        #endif
        
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        func miSnapWorkflowDidSelectPhrase(_ phrase: String) {
            onPhraseSelected(phrase)
        }
        #endif
    }
    
    func makeUIViewController(context: Context) -> MiSnapWorkflowViewController {
        // Create the workflow view controller
        if let flow = flow {
            // Use the flow-based initializer for MiPass
            return MiSnapWorkflowViewController(
                for: flow,
                with: steps,
                delegate: context.coordinator,
                phrase: phrase
            )
        } else {
            // Use the legacy initializer for MobileVerify
            return MiSnapWorkflowViewController(
                with: steps,
                delegate: context.coordinator
            )
        }
    }
    
    func updateUIViewController(_ uiViewController: MiSnapWorkflowViewController, context: Context) {
        // No updates needed as workflow is stateless once started
    }
    
    static func dismantleUIViewController(_ uiViewController: MiSnapWorkflowViewController, coordinator: Coordinator) {
        // Reset orientation when workflow is dismissed
        OrientationManager.shared.resetToDefault()
    }
}
