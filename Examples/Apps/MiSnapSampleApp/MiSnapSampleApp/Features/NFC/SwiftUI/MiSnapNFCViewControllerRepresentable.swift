//
//  MiSnapNFCViewControllerRepresentable.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapCore
import MiSnapNFC
import MiSnapNFCUX

struct MiSnapNFCViewControllerRepresentable: UIViewControllerRepresentable {
    let configuration: MiSnapNFCConfiguration
    let onLicenseStatus: (MiSnapLicenseStatus) -> Void
    let onSuccess: ([String : Any]) -> Void
    let onCancelled: ([String : Any]) -> Void
    let onSkipped: ([String : Any]) -> Void
    let onShouldBeDismissed: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLicenseStatus: onLicenseStatus,
            onSuccess: onSuccess,
            onCancelled: onCancelled,
            onSkipped: onSkipped,
            onShouldBeDismissed: onShouldBeDismissed
        )
    }
    
    class Coordinator: NSObject, MiSnapNFCViewControllerDelegate {
        let onLicenseStatus: (MiSnapLicenseStatus) -> Void
        let onSuccess: ([String : Any]) -> Void
        let onCancelled: ([String : Any]) -> Void
        let onSkipped: ([String : Any]) -> Void
        let onShouldBeDismissed: () -> Void
        
        init(
            onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void,
            onSuccess: @escaping ([String : Any]) -> Void,
            onCancelled: @escaping ([String : Any]) -> Void,
            onSkipped: @escaping ([String : Any]) -> Void,
            onShouldBeDismissed: @escaping () -> Void
        ) {
            self.onLicenseStatus = onLicenseStatus
            self.onSuccess = onSuccess
            self.onCancelled = onCancelled
            self.onSkipped = onSkipped
            self.onShouldBeDismissed = onShouldBeDismissed
        }
        
        // Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
        func miSnapNfcLicenseStatus(_ status: MiSnapLicenseStatus) {
            onLicenseStatus(status)
        }
        
        func miSnapNfcSuccess(_ result: [String : Any]) {
            // Handle successful session results here
            onSuccess(result)
        }
        
        func miSnapNfcCancelled(_ result: [String: Any]) {
            onCancelled(result)
        }
        
        func miSnapNfcSkipped(_ result: [String: Any]) {
            onSkipped(result)
        }
        
        func miSnapNfcShouldBeDismissed() {
            onShouldBeDismissed()
        }
    }
    
    func makeUIViewController(context: Context) -> MiSnapNFCViewController {
        return MiSnapNFCViewController(with: configuration, delegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: MiSnapNFCViewController, context: Context) {}
}
