//
//  VoiceViewModel.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import Combine
import os
import MiSnapCore
import MiSnapVoiceCapture
import MiSnapVoiceCaptureUX

@MainActor
class VoiceViewModel: ObservableObject {
    @Published var selectedFlow: MiSnapVoiceCaptureFlow?
    @Published var captureResult: VoiceCaptureResult?
    @Published var alert: AlertConfig?
    @Published var shouldShowCapture = false
    @Published private(set) var hasEnrolledPhrase = false
    
    let availableFlows: [MiSnapVoiceCaptureFlow] = [.enrollment, .verification]
    private var selectedPhrase: String?
    private var pendingResult: VoiceCaptureResult?
    
    // MARK: - Initialization
    init() {
        // Set your MiSnap license key
        setupLicense()
        updateEnrollmentStatus()
    }
    
    // MARK: - Setup License
    private func setupLicense() {
        let licenseKey = LicenseKey.key
        MiSnapLicenseManager.shared.setLicenseKey(licenseKey)
        AppLogger.debug("🔑 MiSnap License: \(MiSnapLicenseManager.shared.description)")
    }
    
    var currentConfiguration: MiSnapVoiceCaptureConfiguration? {
        guard let selectedFlow else { return nil }
        return makeConfiguration(for: selectedFlow)
    }
    
    // MARK: - Preset Availability
    func isEnabled(_ flow: MiSnapVoiceCaptureFlow) -> Bool {
        switch flow {
        case .verification:
            // Verification requires a saved phrase from enrollment
            return hasEnrolledPhrase
        case .enrollment:
            return true
        @unknown default:
            return false
        }
    }
    
    // MARK: - Integration Flow Entry Point
    func select(_ flow: MiSnapVoiceCaptureFlow) {
        selectedFlow = flow
        AppLogger.info("Selected voice flow: \(flow.displayName)")
        
        // Start the validation and presentation flow
        Task {
            await presentCapture()
        }
    }
    
    // MARK: - Present Capture Flow
    private func presentCapture() async {
        // Check license
        guard checkLicense() else { return }
        
        // Check microphone permission
        guard await checkMicrophonePermission() else { return }
        
        // Check disk space
        guard checkDiskSpace() else { return }
        
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
            selectedFlow = nil
            return false
        }
        
        return true
    }
    
    // MARK: - Check Microphone Permission
    private func checkMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            MiSnapVoiceCaptureViewController.checkMicrophonePermission { granted in
                Task { @MainActor in
                    if !granted {
                        AppLogger.warning("❌ Microphone permission denied")
                        self.showPermissionDeniedAlert()
                        self.selectedFlow = nil
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // MARK: - Check Disk Space
    private func checkDiskSpace() -> Bool {
        let minDiskSpace: Int = 20 // MB required
        
        guard MiSnapVoiceCaptureViewController.hasMinDiskSpace(minDiskSpace) else {
            AppLogger.warning("⚠️ Not enough disk space available")
            showDiskSpaceAlert(minDiskSpace: minDiskSpace)
            selectedFlow = nil
            return false
        }
        
        return true
    }
    
    // MARK: - Build MiSnapVoiceCaptureConfiguration
    func makeConfiguration(for flow: MiSnapVoiceCaptureFlow) -> MiSnapVoiceCaptureConfiguration {
        let configuration: MiSnapVoiceCaptureConfiguration
        
        switch flow {
        case .enrollment:
            // Create enrollment configuration
            configuration = MiSnapVoiceCaptureConfiguration(for: .enrollment)
            
        case .verification:
            // Create verification configuration with previously enrolled phrase
            // The phrase must match the one used during enrollment
            let phrase = UserDefaults.standard.object(forKey: "phrase") as? String ?? ""
            configuration = MiSnapVoiceCaptureConfiguration(for: .verification, phrase: phrase)
        @unknown default:
            fatalError("Unsupported voice capture flow type: \(flow)")
        }
        
        // Apply common UX parameters
        return configuration
            .withCustomUxParameters { parameters in
                // Disable auto-dismiss to manually control dismissal timing
                // IMPORTANT: When autoDismiss is false, you must implement the optional
                // miSnapVoiceCaptureShouldBeDismissed() delegate callback to properly dismiss
                // the SDK after it completes its internal cleanup.
                // See handleDismiss() and MiSnapVoiceCaptureViewControllerRepresentable.onShouldBeDismissed
                parameters.autoDismiss = false
            }
    }
    
    // MARK: - Handle Delegate Callbacks
    
    func handleLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle license status updates if needed
        // Currently handled in checkLicense() during initialization
    }
    
    func handlePhraseSelected(_ phrase: String) {
        AppLogger.info("Phrase selected: \(phrase)")
        selectedPhrase = phrase
        
        /*
         Handle a phrase selected by a user in an Enrollment flow.
         It's highly recommended to store the phrase in a database on a server side to be able to retrieve it 
         if a user switches a device or re-installs the app.
         For security purposes you might even consider storing the phrase on a server side only and retrieve it for each verification.
         Note, this exact phrase will need to be passed in a configuration for a Verification flow.
         */
    }
    
    func handleError(_ result: MiSnapVoiceCaptureResult) {
        AppLogger.error("Voice capture error: \(result.error)")
        // Error occurred - clean up temporary storage
        pendingResult = nil
    }
    
    func handleSuccessfulCapture(_ results: [MiSnapVoiceCaptureResult], _ flow: MiSnapVoiceCaptureFlow) {
        // Process and store the result until SDK is ready to dismiss
        pendingResult = VoiceCaptureResult(results: results, flow: flow)
    }
    
    func handleCancellation(_ result: MiSnapVoiceCaptureResult) {
        // User cancelled - clean up temporary storage
        pendingResult = nil
    }
    
    // MARK: - Dismiss Capture Controller
    func handleDismiss() {
        // SDK signals it's safe to dismiss after completing internal cleanup
        // Now we can safely remove the capture view from SwiftUI hierarchy
        shouldShowCapture = false
        selectedFlow = nil
        
        // Publish the result to trigger the result screen (if capture was successful)
        if let result = pendingResult {
            captureResult = result
            
            // Handle enrollment-specific logic
            switch result.flow {
            case .enrollment:
                if let selectedPhrase = selectedPhrase {
                    // Save the enrolled phrase for future verification
                    UserDefaults.standard.set(selectedPhrase, forKey: "phrase")
                    UserDefaults.standard.synchronize()
                    AppLogger.info("Phrase saved to UserDefaults: \(selectedPhrase)")
                    updateEnrollmentStatus()
                }
            case .verification:
                break
            @unknown default:
                fatalError()
            }
        }
        
        // Clean up temporary storage
        pendingResult = nil
    }
    
    // MARK: - Enrollment Management
    private func updateEnrollmentStatus() {
        hasEnrolledPhrase = UserDefaults.standard.object(forKey: "phrase") != nil
    }
    
    func resetEnrollment() {
        UserDefaults.standard.removeObject(forKey: "phrase")
        UserDefaults.standard.synchronize()
        AppLogger.info("Voice enrollment reset - phrase removed from UserDefaults")
        updateEnrollmentStatus()
    }
    
    // MARK: - Alert Helpers
    private func showPermissionDeniedAlert() {
        alert = .permissionDenied(.microphone)
    }
    
    private func showLicenseAlert(message: String) {
        alert = .licenseError(message: message)
    }
    
    private func showDiskSpaceAlert(minDiskSpace: Int) {
        alert = .diskSpaceError(minDiskSpace: minDiskSpace)
    }
}
