//
//  MiSnapViewControllerRepresentable.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnap
import MiSnapUX

struct MiSnapViewControllerRepresentable: UIViewControllerRepresentable {
    let configuration: MiSnapConfiguration
    let onLicenseStatus: (MiSnapLicenseStatus) -> Void
    let onSuccess: (MiSnapResult) -> Void
    let onCancelled: (MiSnapResult) -> Void
    let onException: (NSException) -> Void
    let onShouldBeDismissed: () -> Void
    let onCustomTutorial: CustomTutorialHandler?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLicenseStatus: onLicenseStatus,
            onSuccess: onSuccess,
            onCancelled: onCancelled,
            onException: onException,
            onShouldBeDismissed: onShouldBeDismissed,
            onCustomTutorial: onCustomTutorial
        )
    }
    
    class Coordinator: NSObject, MiSnapViewControllerDelegate {
        let onLicenseStatus: (MiSnapLicenseStatus) -> Void
        let onSuccess: (MiSnapResult) -> Void
        let onCancelled: (MiSnapResult) -> Void
        let onException: (NSException) -> Void
        let onShouldBeDismissed: () -> Void
        let onCustomTutorial: CustomTutorialHandler?
        weak var miSnapViewController: MiSnapViewController?
        
        init(
            onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void,
            onSuccess: @escaping (MiSnapResult) -> Void,
            onCancelled: @escaping (MiSnapResult) -> Void,
            onException: @escaping (NSException) -> Void,
            onShouldBeDismissed: @escaping () -> Void,
            onCustomTutorial: CustomTutorialHandler?
        ) {
            self.onLicenseStatus = onLicenseStatus
            self.onSuccess = onSuccess
            self.onCancelled = onCancelled
            self.onException = onException
            self.onShouldBeDismissed = onShouldBeDismissed
            self.onCustomTutorial = onCustomTutorial
        }
        
        func miSnapLicenseStatus(_ status: MiSnapLicenseStatus) {
            onLicenseStatus(status)
        }
        
        func miSnapSuccess(_ result: MiSnapResult) {
            onSuccess(result)
        }
        
        func miSnapCancelled(_ result: MiSnapResult) {
            onCancelled(result)
        }
        
        func miSnapException(_ exception: NSException) {
            onException(exception)
        }
        
        func miSnapShouldBeDismissed() {
            onShouldBeDismissed()
        }
        
        func miSnapCustomTutorial(_ documentType: MiSnapScienceDocumentType,
                                  tutorialMode: MiSnapUxTutorialMode,
                                  mode: MiSnapMode,
                                  statuses: [NSNumber]?,
                                  image: UIImage?) {
            onCustomTutorial?(documentType, tutorialMode, mode, statuses, image, miSnapViewController)
        }
    }
    
    func makeUIViewController(context: Context) -> MiSnapViewController {
        let viewController = MiSnapViewController(with: configuration, delegate: context.coordinator)
        context.coordinator.miSnapViewController = viewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MiSnapViewController, context: Context) {}
    
    func dismantleUIViewController(_ uiViewController: MiSnapViewController, coordinator: Coordinator) {
        coordinator.miSnapViewController = nil
    }
}
