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
            return configuration
                // Use custom tutorials
                // See `CustomTutorialViewController` for implementation
                .withCustomUxParameters { uxParameters in
                    uxParameters.useCustomTutorials = true
                }
                // Customize cancel button
                .withCustomCancel { element in
                    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
                    element.image = UIImage(systemName: "xmark.app.fill", withConfiguration: config)
                    element.imageTintColor = .red
                    element.size = CGSize(width: 48, height: 48)
                }
                // Customize help button
                .withCustomHelp { element in
                    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
                    element.image = UIImage(systemName: "questionmark.app.fill", withConfiguration: config)
                    element.imageTintColor = .green
                    element.size = CGSize(width: 48, height: 48)
                }
                // Customize camera shutter button (manual mode)
                .withCustomCameraShutter { element in
                    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
                    element.image = UIImage(systemName: "camera.circle.fill", withConfiguration: config)
                    element.size = CGSize(width: 48, height: 48)
                }
                // Customize guide (vignette and outline)
                .withCustomGuide { element in
                    // Vignette (darkened area around the guide)
                    element.vignette.style = .semitransparent
                    element.vignette.color = .black
                    element.vignette.alpha = 0.8
                    
                    // Outline (border around the document area)
                    element.outline.alpha = 0.7
                    element.outline.mainBorderWidth = 5
                    element.outline.mainBorderColor = .blue
                }
                // Customize hint text
                .withCustomHint { hint in
                    hint.backgroundColor = .black
                    hint.textColor = .white
                    hint.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                }
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
        // Return custom tutorial handler for `.customIDFront` preset or nil otherwise
        guard preset == .customIDFront else { return nil }
        return presentCustomTutorial
    }
    
    // swiftlint:disable:next function_parameter_count
    private func presentCustomTutorial(
        _ documentType: MiSnapScienceDocumentType,
        _ tutorialMode: MiSnapUxTutorialMode,
        _ mode: MiSnapMode,
        _ statuses: [NSNumber]?,
        _ image: UIImage?,
        _ viewController: MiSnapViewController?
    ) {
        guard let miSnapVC = viewController else { return }
        
        // Create custom tutorial view controller with current capture context
        let customTutorialVC = CustomTutorialViewController(
            for: documentType,
            tutorialMode: tutorialMode,
            mode: mode,
            statuses: statuses,
            image: image,
            delegate: miSnapVC
        )
        
        // Present the custom tutorial over MiSnap capture screen
        miSnapVC.present(customTutorialVC, animated: false)
    }
    
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
