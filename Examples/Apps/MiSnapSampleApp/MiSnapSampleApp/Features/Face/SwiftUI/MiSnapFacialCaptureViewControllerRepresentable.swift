//
//  MiSnapFacialCaptureViewControllerRepresentable.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

struct MiSnapFacialCaptureViewControllerRepresentable: UIViewControllerRepresentable {
    let configuration: MiSnapFacialCaptureConfiguration
    let onLicenseStatus: (MiSnapLicenseStatus) -> Void
    let onSuccess: (MiSnapFacialCaptureResult) -> Void
    let onCancelled: (MiSnapFacialCaptureResult) -> Void
    let onException: (NSException) -> Void
    let onShouldBeDismissed: () -> Void
    // Optional: provide these to replace the SDK's built-in help and timeout screens.
    // They are only called when showHelpScreen / showTimeoutScreen are false in UxParameters.
    // The closure receives the live MiSnapFacialCaptureViewController so you can call
    // captureVC.presentVC(_:) to show your own tutorial UI above the capture session.
    var onHelpAction: ((MiSnapFacialCaptureViewController) -> Void)?
    var onTimeoutAction: ((MiSnapFacialCaptureViewController) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onLicenseStatus: onLicenseStatus,
            onSuccess: onSuccess,
            onCancelled: onCancelled,
            onException: onException,
            onShouldBeDismissed: onShouldBeDismissed,
            onHelpAction: onHelpAction,
            onTimeoutAction: onTimeoutAction
        )
    }

    class Coordinator: NSObject, MiSnapFacialCaptureViewControllerDelegate {
        let onLicenseStatus: (MiSnapLicenseStatus) -> Void
        let onSuccess: (MiSnapFacialCaptureResult) -> Void
        let onCancelled: (MiSnapFacialCaptureResult) -> Void
        let onException: (NSException) -> Void
        let onShouldBeDismissed: () -> Void
        let onHelpAction: ((MiSnapFacialCaptureViewController) -> Void)?
        let onTimeoutAction: ((MiSnapFacialCaptureViewController) -> Void)?
        weak var captureViewController: MiSnapFacialCaptureViewController?

        init(
            onLicenseStatus: @escaping (MiSnapLicenseStatus) -> Void,
            onSuccess: @escaping (MiSnapFacialCaptureResult) -> Void,
            onCancelled: @escaping (MiSnapFacialCaptureResult) -> Void,
            onException: @escaping (NSException) -> Void,
            onShouldBeDismissed: @escaping () -> Void,
            onHelpAction: ((MiSnapFacialCaptureViewController) -> Void)?,
            onTimeoutAction: ((MiSnapFacialCaptureViewController) -> Void)?
        ) {
            self.onLicenseStatus = onLicenseStatus
            self.onSuccess = onSuccess
            self.onCancelled = onCancelled
            self.onException = onException
            self.onShouldBeDismissed = onShouldBeDismissed
            self.onHelpAction = onHelpAction
            self.onTimeoutAction = onTimeoutAction
        }

        func miSnapFacialCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
            onLicenseStatus(status)
        }

        func miSnapFacialCaptureSuccess(_ result: MiSnapFacialCaptureResult) {
            onSuccess(result)
        }

        func miSnapFacialCaptureCancelled(_ result: MiSnapFacialCaptureResult) {
            onCancelled(result)
        }

        func miSnapException(_ exception: NSException) {
            onException(exception)
        }

        func miSnapFacialCaptureShouldBeDismissed() {
            onShouldBeDismissed()
        }

        // Optional delegate methods — only called when showHelpScreen / showTimeoutScreen are false
        func miSnapFacialCaptureHelpAction() {
            guard let captureVC = captureViewController else { return }
            onHelpAction?(captureVC)
        }

        func miSnapFacialCaptureTimeoutAction() {
            guard let captureVC = captureViewController else { return }
            onTimeoutAction?(captureVC)
        }
    }

    func makeUIViewController(context: Context) -> MiSnapFacialCaptureViewController {
        let controller = MiSnapFacialCaptureViewController(with: configuration, delegate: context.coordinator)
        context.coordinator.captureViewController = controller
        return controller
    }

    func updateUIViewController(_ uiViewController: MiSnapFacialCaptureViewController, context: Context) {}
}
