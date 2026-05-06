//
//  DocumentsViewModel.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import Combine
import os
import MiSnap
import MiSnapUX
import MiSnapAssetManager

@MainActor
class DocumentsViewModel: ObservableObject {
    @Published var selectedPreset: DocumentPreset?
    @Published var captureResult: DocumentCaptureResult?
    @Published var alert: AlertConfig?
    @Published var shouldShowCapture = false
    
    let availablePresets = DocumentPreset.allCases
    
    private var pendingResult: DocumentCaptureResult?
    
    // MARK: - Initialization
    init() {
        // Set your MiSnap license key
        setupLicense()
    }
    
    // MARK: - Setup License
    private func setupLicense() {
        let licenseKey = LicenseKey.key
        MiSnapLicenseManager.shared.setLicenseKey(licenseKey)
        AppLogger.debug("🔑 MiSnap License: \(MiSnapLicenseManager.shared.description)")
    }
    
    // MARK: - Integration Flow Entry Point
    func selectPreset(_ preset: DocumentPreset) {
        selectedPreset = preset
        AppLogger.info("Selected document preset: \(preset.rawValue)")
        
        // Start the validation and presentation flow
        Task {
            await presentCapture()
        }
    }
    
    // MARK: - Present Capture Flow
    private func presentCapture() async {
        // Check license
        guard checkLicense() else { return }
        
        // Check camera permission
        guard await checkCameraPermission() else { return }
        
        // All checks passed - present capture
        shouldShowCapture = true
    }
    
    // MARK: Check License Status
    private func checkLicense() -> Bool {
        let licenseStatus = MiSnapLicenseManager.shared.status
        AppLogger.info("Checking license status: \(licenseStatus.stringValue)")
        
        guard licenseStatus == .valid else {
            AppLogger.error("🔑 License is not valid: \(licenseStatus.stringValue)")
            showLicenseAlert(message: "MiSnap license status: \(licenseStatus.stringValue)")
            selectedPreset = nil
            return false
        }
        
        return true
    }
    
    // MARK: Check Camera Permission
    private func checkCameraPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            MiSnapViewController.checkCameraPermission { granted in
                Task { @MainActor in
                    if !granted {
                        AppLogger.warning("❌ Camera permission denied")
                        self.showPermissionDeniedAlert()
                        self.selectedPreset = nil
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // MARK: - Build MiSnap Configuration
    func makeConfiguration(for preset: DocumentPreset) -> MiSnapConfiguration {
        // Create configuration using the SDK document type
        let configuration = MiSnapConfiguration(for: preset.documentType)
            .withCustomUxParameters { parameters in
                // IMPORTANT: When autoDismiss is false, you must implement the optional
                // miSnapShouldBeDismissed() delegate callback to properly dismiss the SDK
                // after it completes its internal cleanup.
                // See handleDismiss() and MiSnapViewControllerRepresentable.onShouldBeDismissed
                parameters.autoDismiss = false
            }
        
        // Apply custom parameters for specific document types
        switch preset {
        case .passport, .checkFront, .checkBack:
            return configuration.withCustomParameters { parameters in
                // Allow both portrait and landscape orientations for passport and checks
                parameters.science.orientationMode = .devicePortraitGuidePortrait
            }
        case .customIDFront:
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
            return configuration
                .withCustomUxParameters { uxParameters in
                    // Disable SDK's built-in tutorial screens and drive all four modes
                    // through the miSnapCustomTutorial(_:tutorialMode:mode:statuses:image:) delegate callback.
                    uxParameters.useCustomTutorials = true
                }
                .withCustomCancel { cancel in
                    cancel.image = UIImage(systemName: "xmark.app.fill", withConfiguration: symbolConfig)
                    cancel.imageTintColor = .systemRed
                    cancel.size = CGSize(width: 48, height: 48)
                }
                .withCustomHelp { help in
                    help.image = UIImage(systemName: "questionmark.app.fill", withConfiguration: symbolConfig)
                    help.imageTintColor = .systemGreen
                    help.size = CGSize(width: 48, height: 48)
                }
                .withCustomTorch { torch in
                    torch.colorEnabled = .systemBlue
                    torch.colorDisabled = .systemGray
                }
                .withCustomCameraShutter { cameraShutter in
                    cameraShutter.image = UIImage(systemName: "camera.circle.fill", withConfiguration: symbolConfig)
                    cameraShutter.size = CGSize(width: 48, height: 48)
                }
                .withCustomGuide { guide in
                    guide.vignette.style = .semitransparent
                    guide.vignette.color = .black
                    guide.vignette.alpha = 0.8
                    guide.outline.mainBorderWidth = 5
                    guide.outline.mainBorderColor = .systemBlue
                }
                .withCustomGlare { glare in
                    glare.borderColor = .systemOrange
                    glare.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.35)
                }
                .withCustomHint { hint in
                    hint.backgroundColor = .black
                    hint.textColor = .white
                    hint.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                }
                .withCustomRecordingIndicator { recordingIndicator in
                    recordingIndicator.alpha = 0.85
                }
                .withCustomSuccess { success in
                    success.checkmark.color = .systemGreen
                    success.checkmark.cutoutFillColor = UIColor.systemGreen.withAlphaComponent(0.4)
                }

        case .customDocument:
            let accent = UIColor(red: 0.35, green: 0.30, blue: 0.85, alpha: 1)

            let template = MiSnapConfiguration()
                .withCustomUxParameters { uxParameters in
                    // IMPORTANT: When autoDismiss is false, implement miSnapShouldBeDismissed()
                    // and dismiss from SwiftUI. See handleDismiss() and MiSnapViewControllerRepresentable.
                    uxParameters.autoDismiss = false
                }
                // Style the SDK's built-in instruction / help / timeout / review screens
                .withCustomTutorial { tutorial in
                    tutorial.backgroundColor = .secondarySystemBackground
                }
                .withCustomGuide { guide in
                    guide.vignette.style = .blur
                    guide.vignette.alpha = 0.9
                    guide.outline.mainBorderColor = accent
                }
                .withCustomGlare { glare in
                    glare.borderColor = accent
                    glare.backgroundColor = accent.withAlphaComponent(0.3)
                }
                .withCustomDocumentLabel { label in
                    label.font = .systemFont(ofSize: 17, weight: .medium)
                }
                .withCustomCancel { cancel in
                    cancel.color = accent
                }
                .withCustomHelp { help in
                    help.color = accent
                }
                .withCustomTorch { torch in
                    torch.colorEnabled = accent
                    torch.colorDisabled = UIColor(white: 0.5, alpha: 1)
                }
                .withCustomCameraShutter { cameraShutter in
                    cameraShutter.color = accent
                    cameraShutter.size = cameraShutter.size.scaled(by: 0.9)
                }
                .withCustomHint { hint in
                    hint.backgroundColor = accent.withAlphaComponent(0.9)
                    hint.textColor = .white
                }
                .withCustomRecordingIndicator { recordingIndicator in
                    recordingIndicator.alpha = 0.85
                }
                .withCustomSuccess { success in
                    success.checkmark.color = accent
                    success.checkmark.cutoutFillColor = accent.withAlphaComponent(0.4)
                }
            
            return configuration
                .applying(template)

        default:
            return configuration
        }
    }
    
    // MARK: - Handle Delegate Callbacks and Process Result
    func handleLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle license status updates if needed
        // Currently handled in checkLicense() during initialization
    }
    
    func handleSuccessfulCapture(_ result: MiSnapResult) {
        // Process and store the result until SDK is ready to dismiss
        pendingResult = DocumentCaptureResult(result)
    }
    
    func handleCancellation(_ result: MiSnapResult) {
        // User cancelled - Clean up temporary storage
        pendingResult = nil
    }
    
    func handleException(_ exception: NSException) {
        // Handle exceptions from MiSnap SDK if needed
        // Log the exception and potentially show an error alert
    }
    
    func handleCustomTutorial(for preset: DocumentPreset) -> CustomTutorialHandler? {
        switch preset {
        case .customIDFront:   return presentCustomTutorial
        case .customDocument:  return presentSelectiveTutorial
        default:               return nil
        }
    }
    // swiftlint:disable function_parameter_count
    private func presentCustomTutorial(
        _ documentType: MiSnapScienceDocumentType,
        _ tutorialMode: MiSnapUxTutorialMode,
        _ mode: MiSnapMode,
        _ statuses: [NSNumber]?,
        _ image: UIImage?,
        _ viewController: MiSnapViewController?
    ) {
        guard let miSnapVC = viewController else { return }
        let tutorialVC = CustomTutorialViewController(
            for: documentType,
            tutorialMode: tutorialMode,
            mode: mode,
            statuses: statuses,
            image: image,
            delegate: miSnapVC
        )
        miSnapVC.present(tutorialVC, animated: false)
    }

    private func presentSelectiveTutorial(
        _ documentType: MiSnapScienceDocumentType,
        _ tutorialMode: MiSnapUxTutorialMode,
        _ mode: MiSnapMode,
        _ statuses: [NSNumber]?,
        _ image: UIImage?,
        _ viewController: MiSnapViewController?
    ) {
        guard tutorialMode == .timeout, let miSnapVC = viewController else {
            // Instruction, help, and review — do nothing here.
            // The SDK will present its default built-in screen for these modes.
            return
        }
        // Suppress the SDK's default timeout screen before presenting our own.
        // Without this call, both screens would appear.
        miSnapVC.skipDefaultTutorial()
        let tutorialVC = CustomTutorialViewController(
            for: documentType,
            tutorialMode: tutorialMode,
            mode: mode,
            statuses: statuses,
            image: image,
            delegate: miSnapVC
        )
        miSnapVC.present(tutorialVC, animated: true)
    }
    // swiftlint:enable function_parameter_count
    
    // MARK: - Dismiss Capture Controller
    func handleDismiss() {
        // SDK signals it's safe to dismiss after completing internal cleanup
        // Remove the capture view from SwiftUI hierarchy
        shouldShowCapture = false
        selectedPreset = nil
        
        // Publish the result to trigger the result screen (if capture was successful)
        if let result = pendingResult {
            captureResult = result
        }
        
        // Clean up temporary storage
        pendingResult = nil
    }

    // MARK: - Alert Helpers
    private func showPermissionDeniedAlert() {
        alert = .permissionDenied(.camera)
    }
    
    private func showLicenseAlert(message: String) {
        alert = .licenseError(message: message)
    }
}
