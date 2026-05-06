//
//  FaceViewModel.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import Combine
import os
import AVFoundation
import MiSnapAssetManager
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

@MainActor
class FaceViewModel: ObservableObject {
    @Published var selectedPreset: FacePreset?
    @Published var captureResult: FaceCaptureResult?
    @Published var alert: AlertConfig?
    @Published var aiBasedRtsEnabled = false
    @Published var cameraPosition: FaceCameraPosition = .front
    @Published var shouldShowCapture = false
    
    let availablePresets = FacePreset.allCases
    
    private var pendingResult: FaceCaptureResult?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Set your MiSnap license key
        setupLicense()
        // When AI-based RTS is turned on, lock camera to front
        $aiBasedRtsEnabled
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in self?.cameraPosition = .front }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup License
    private func setupLicense() {
        let licenseKey = LicenseKey.key
        MiSnapLicenseManager.shared.setLicenseKey(licenseKey)
        AppLogger.debug("🔑 MiSnap License: \(MiSnapLicenseManager.shared.description)")
    }
    
    // MARK: - Integration Flow Entry Point
    func selectPreset(_ preset: FacePreset) {
        selectedPreset = preset
        AppLogger.info("Selected face preset: \(preset.rawValue)")
        
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
    
    // MARK: - Check License Status
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
    
    // MARK: - Check Camera Permission
    private func checkCameraPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            MiSnapFacialCaptureViewController.checkCameraPermission { granted in
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
    
    // MARK: - Build MiSnapFacialCapture Configuration
    func makeConfiguration(for preset: FacePreset) -> MiSnapFacialCaptureConfiguration {
        // Create base configuration
        var configuration = MiSnapFacialCaptureConfiguration()
            .withCustomUxParameters { parameters in
                // Disable auto-dismiss to manually control dismissal timing
                // IMPORTANT: When autoDismiss is false, you must implement the optional
                // miSnapFacialCaptureShouldBeDismissed() delegate callback to properly dismiss
                // the SDK after it completes its internal cleanup.
                // See handleDismiss() and MiSnapFacialCaptureViewControllerRepresentable.onShouldBeDismissed
                parameters.autoDismiss = false
            }
            .withCustomParameters { parameters in
                parameters.camera.position = cameraPosition.avPosition
            }
        
        // Apply AI-based RTS if enabled
        if aiBasedRtsEnabled {
            configuration = configuration
                .withCustomParameters { parameters in
                    parameters.aiBasedRtsEnabled = true
                }
        }
        
        // Apply preset-specific customizations
        switch preset {
        case .selfieCountdown:
            // Standard selfie capture with default countdown timer
            break
            
        case .selfieSmile:
            // Automatic capture triggered by smile detection
            return configuration
                .withCustomParameters { parameters in
                    parameters.selectOnSmile = true
                }
                
        case .selfieGoodIQA:
            // Instant capture mode - no countdown delay
            // Automatically captures when image quality assessment (IQA) criteria are met
            return configuration
                .withCustomParameters { parameters in
                    parameters.countdownTime = 0
                }

        case .customSelfie:
            let accent = UIColor(white: 0.90, alpha: 1)
            let dark   = UIColor(white: 0.08, alpha: 1)
            return configuration
                .withCustomUxParameters { uxParameters in
                    uxParameters.timeout = 25.0
                    // Disable built-in help and timeout screens so the app can present
                    // its own custom tutorial UI via the optional delegate callbacks:
                    // miSnapFacialCaptureHelpAction() and miSnapFacialCaptureTimeoutAction()
                    uxParameters.showHelpScreen = false
                    uxParameters.showTimeoutScreen = false
                }
                .withCustomTutorial { tutorial in
                    // Applies to all SDK-managed tutorial screens: instruction, help, timeout, review.
                    tutorial.backgroundColor = dark
                    tutorial.backgroundColorDarkMode = dark

                    // Primary action button (Continue / Retry / Looks good)
                    tutorial.buttons.primary.backgroundColor = accent
                    tutorial.buttons.primary.backgroundColorDarkMode = accent
                    tutorial.buttons.primary.color = dark
                    tutorial.buttons.primary.colorDarkMode = dark

                    // Secondary action button (Cancel / Manual / Retake)
                    tutorial.buttons.secondary.color = accent
                    tutorial.buttons.secondary.colorDarkMode = accent
                    tutorial.buttons.secondary.borderColor = accent
                    tutorial.buttons.secondary.borderColorDarkMode = accent

                    // Instruction messages and tips
                    tutorial.message.color = accent
                    tutorial.message.colorDarkMode = accent
                    tutorial.messageSecondary.color = accent
                    tutorial.messageSecondary.colorDarkMode = accent
                }
                .withCustomGuide { guide in
                    guide.vignette.style = .blur
                    guide.vignette.alpha = 0.925
                    guide.outline.colorGood = accent
                    guide.outline.colorBad = UIColor(red: 0.937, green: 0.349, blue: 0.192, alpha: 1)
                }
                .withCustomHint { hint in
                    // Feedback text shown during capture — inverted to match the dark vignette
                    hint.color = accent
                    hint.backgroundColor = dark.withAlphaComponent(0.8)
                }
                .withCustomHelp { help in
                    // Replace the SDK's drawn "?" circle with an SF Symbol
                    help.image = UIImage(
                        systemName: "questionmark.circle",
                        withConfiguration: UIImage.SymbolConfiguration(weight: .light)
                    )
                    help.imageTintColor = accent
                }
                .withCustomCancel { cancel in
                    // Replace the SDK's drawn "✕" circle with an SF Symbol
                    cancel.image = UIImage(
                        systemName: "xmark.circle",
                        withConfiguration: UIImage.SymbolConfiguration(weight: .light)
                    )
                    cancel.imageTintColor = accent
                }
                .withCustomCameraShutter { cameraShutter in
                    cameraShutter.color = accent
                    cameraShutter.size = cameraShutter.size.scaled(by: 1.15)
                }
                .withCustomCountdown { countdown in
                    countdown.burnupColor = accent
                    countdown.burnupLineWidth = 5
                    countdown.fontSize = 35.0
                    countdown.textColor = accent
                }
                .withCustomSuccess { success in
                    success.backgroundColor = dark.withAlphaComponent(0.92)
                    success.checkmark.color = accent
                    success.checkmark.cutoutFillColor = accent.withAlphaComponent(0.45)
                    success.message.color = accent
                }
        }
        
        return configuration
    }
    
    // MARK: - Handle Delegate Callbacks and Process Result
    func handleLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle license status updates if needed
        // Currently handled in checkLicense() during initialization
    }
    
    func handleSuccessfulCapture(_ result: MiSnapFacialCaptureResult) {
        // Process and store the result until SDK is ready to dismiss
        pendingResult = FaceCaptureResult(result)
    }
    
    func handleCancellation(_ result: MiSnapFacialCaptureResult) {
        // User cancelled - clean up temporary storage
        pendingResult = nil
    }
    
    func handleException(_ exception: NSException) {
        // Handle exceptions from MiSnap SDK if needed
        // Log the exception and potentially show an error alert
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

enum FaceCameraPosition {
    case front
    case back
}

extension FaceCameraPosition {
    var avPosition: AVCaptureDevice.Position {
        switch self {
        case .front: return .front
        case .back: return .back
        }
    }
}
