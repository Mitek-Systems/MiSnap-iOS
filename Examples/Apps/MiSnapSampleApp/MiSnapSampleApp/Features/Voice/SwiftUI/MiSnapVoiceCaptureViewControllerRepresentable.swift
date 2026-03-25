//
//  MiSnapVoiceCaptureViewControllerRepresentable.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapCore
import MiSnapVoiceCapture
import MiSnapVoiceCaptureUX

struct MiSnapVoiceCaptureViewControllerRepresentable: UIViewControllerRepresentable {
    let configuration: MiSnapVoiceCaptureConfiguration
    let onLicenseStatus: (MiSnapLicenseStatus) -> Void
    let onPhraseSelected: (String) -> Void
    let onSuccess: ([MiSnapVoiceCaptureResult], MiSnapVoiceCaptureFlow) -> Void
    let onCancelled: (MiSnapVoiceCaptureResult) -> Void
    let onError: (MiSnapVoiceCaptureResult) -> Void
    let onShouldBeDismissed: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLicenseStatus: onLicenseStatus,
            onPhraseSelected: onPhraseSelected,
            onSuccess: onSuccess,
            onCancelled: onCancelled,
            onError: onError,
            onShouldBeDismissed: onShouldBeDismissed
        )
    }
    
    class Coordinator: NSObject, MiSnapVoiceCaptureViewControllerDelegate {
        let onLicenseStatus: (MiSnapLicenseStatus) -> Void
        let onPhraseSelected: (String) -> Void
        let onSuccess: ([MiSnapVoiceCaptureResult], MiSnapVoiceCaptureFlow) -> Void
        let onCancelled: (MiSnapVoiceCaptureResult) -> Void
        let onError: (MiSnapVoiceCaptureResult) -> Void
        let onShouldBeDismissed: () -> Void
        
        init(
            onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void,
            onPhraseSelected: @escaping (String) -> Void,
            onSuccess: @escaping ([MiSnapVoiceCaptureResult], MiSnapVoiceCaptureFlow) -> Void,
            onCancelled: @escaping (MiSnapVoiceCaptureResult) -> Void,
            onError: @escaping (MiSnapVoiceCaptureResult) -> Void,
            onShouldBeDismissed: @escaping () -> Void
        ) {
            self.onLicenseStatus = onLicenseStatus
            self.onPhraseSelected = onPhraseSelected
            self.onSuccess = onSuccess
            self.onCancelled = onCancelled
            self.onError = onError
            self.onShouldBeDismissed = onShouldBeDismissed
        }
        
        func miSnapVoiceCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
            onLicenseStatus(status)
        }
        
        func miSnapVoiceCaptureDidSelectPhrase(_ phrase: String) {
            onPhraseSelected(phrase)
        }
        
        func miSnapVoiceCaptureSuccess(_ results: [MiSnapVoiceCaptureResult], for flow: MiSnapVoiceCaptureFlow) {
            onSuccess(results, flow)
        }
        
        func miSnapVoiceCaptureCancelled(_ result: MiSnapVoiceCaptureResult) {
            onCancelled(result)
        }
        
        func miSnapVoiceCaptureError(_ result: MiSnapVoiceCaptureResult) {
            onError(result)
        }
        
        func miSnapVoiceCaptureShouldBeDismissed() {
            onShouldBeDismissed()
        }
    }
    
    func makeUIViewController(context: Context) -> MiSnapVoiceCaptureViewController {
        return MiSnapVoiceCaptureViewController(with: configuration, delegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: MiSnapVoiceCaptureViewController, context: Context) {}
}
