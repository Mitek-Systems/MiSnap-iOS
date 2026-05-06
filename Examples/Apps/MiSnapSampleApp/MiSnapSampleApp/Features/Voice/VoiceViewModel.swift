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
import MiSnapAssetManager

@MainActor
class VoiceViewModel: ObservableObject {
    @Published var selectedPreset: VoicePreset?
    @Published var captureResult: VoiceCaptureResult?
    @Published var alert: AlertConfig?
    @Published var shouldShowCapture = false
    @Published private(set) var hasEnrolledPhrase = false

    let availablePresets = VoicePreset.allCases
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
        guard let selectedPreset else { return nil }
        return makeConfiguration(for: selectedPreset)
    }

    // MARK: - Preset Availability
    func isEnabled(_ preset: VoicePreset) -> Bool {
        switch preset {
        case .verification:
            // Verification requires a saved phrase from a prior enrollment
            return hasEnrolledPhrase
        case .enrollment, .customEnrollment:
            return true
        }
    }

    // MARK: - Integration Flow Entry Point
    func select(_ preset: VoicePreset) {
        selectedPreset = preset
        AppLogger.info("Selected voice preset: \(preset.rawValue)")
        
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
            selectedPreset = nil
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
                        self.selectedPreset = nil
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
            selectedPreset = nil
            return false
        }
        
        return true
    }
    
    // MARK: - Build MiSnapVoiceCaptureConfiguration
    func makeConfiguration(for preset: VoicePreset) -> MiSnapVoiceCaptureConfiguration {
        switch preset {
        case .enrollment:
            return MiSnapVoiceCaptureConfiguration(for: .enrollment)
                .withCustomUxParameters { parameters in
                    // IMPORTANT: When autoDismiss is false, you must implement the optional
                    // miSnapVoiceCaptureShouldBeDismissed() delegate callback to properly dismiss
                    // the SDK after it completes its internal cleanup.
                    // See handleDismiss() and MiSnapVoiceCaptureViewControllerRepresentable.onShouldBeDismissed
                    parameters.autoDismiss = false
                }

        case .verification:
            // The phrase must match exactly the one selected during enrollment.
            let phrase = UserDefaults.standard.object(forKey: "phrase") as? String ?? ""
            return MiSnapVoiceCaptureConfiguration(for: .verification, phrase: phrase)
                .withCustomUxParameters { parameters in
                    parameters.autoDismiss = false
                }

        case .customEnrollment:
            // Template + .applying() pattern — same approach as customDocument.
            // All UX/UI customization lives in the template so it can be reused across
            // enrollment and verification without duplicating code.
            // SDK parameters (snrMin) go on the per-flow configuration, not the template.
            let accent = UIColor(red: 0.20, green: 0.60, blue: 0.40, alpha: 1)

            let template = MiSnapVoiceCaptureConfiguration()
                .withCustomUxParameters { parameters in
                    parameters.autoDismiss = false
                }
                // Provide a custom phrase list instead of the SDK's built-in defaults.
                // The SDK reads misnap_voice_capture_ux_phrase_1...N from the specified
                // .strings file, stopping at the first missing or empty value.
                .withCustomLocalization { localization in
                    localization.stringsName = "MiSnapVoiceCaptureCustomLocalizable"
                }
                // Phrase selection screen — the user picks their passphrase before recording
                .withCustomPhraseSelection { phraseSelection in
                    phraseSelection.message.color = accent
                    phraseSelection.phrase.font = .systemFont(ofSize: 21, weight: .bold)
                    phraseSelection.buttons.primary.backgroundColor = accent
                    phraseSelection.buttons.primary.backgroundColorDarkMode = accent
                    phraseSelection.buttons.secondary.color = accent
                    phraseSelection.buttons.secondary.colorDarkMode = accent
                    phraseSelection.buttons.secondary.borderColor = accent
                    phraseSelection.buttons.secondary.borderColorDarkMode = accent
                }
                // Introductory instruction screen shown before recording begins
                .withCustomIntroductoryInstruction { introductoryInstruction in
                    introductoryInstruction.message.font = .systemFont(ofSize: 22, weight: .thin)
                    introductoryInstruction.buttons.primary.backgroundColor = accent
                    introductoryInstruction.buttons.primary.backgroundColorDarkMode = accent
                    introductoryInstruction.buttons.secondary.color = accent
                    introductoryInstruction.buttons.secondary.colorDarkMode = accent
                    introductoryInstruction.buttons.secondary.borderColor = accent
                    introductoryInstruction.buttons.secondary.borderColorDarkMode = accent
                }
                // Recording screen — covers success, neutral, and failure states
                .withCustomRecording { recording in
                    recording.success.color = .white
                    recording.success.backgroundColor = accent
                    recording.neutral.color = accent
                    recording.neutral.backgroundColor = accent.withAlphaComponent(0.12)
                    recording.failure.color = .white
                    recording.failure.backgroundColor = .systemRed
                    
                    recording.buttons.primary.backgroundColor = accent
                    recording.buttons.primary.backgroundColorDarkMode = accent
                    recording.buttons.secondary.color = accent
                    recording.buttons.secondary.colorDarkMode = accent
                    recording.buttons.secondary.borderColor = accent
                    recording.buttons.secondary.borderColorDarkMode = accent
                    
                    recording.message.color = accent
                    recording.phrase.backgroundColor = accent.withAlphaComponent(0.10)
                    recording.failureMessage.font = .systemFont(ofSize: 22, weight: .bold)
                    
                }

            return MiSnapVoiceCaptureConfiguration(for: .enrollment)
                .withCustomParameters { parameters in
                    // Minimum signal-to-noise ratio for an accepted recording.
                    // Higher values = stricter quality requirement.
                    // Default is ~5.0; 7.1 matches the legacy customization example.
                    parameters.snrMin = 7.1
                }
                .applying(template)
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
        selectedPreset = nil
        
        // Publish the result to trigger the result screen (if capture was successful)
        if let result = pendingResult {
            captureResult = result
            
            // Handle enrollment-specific logic
            switch result.flow {
            case .enrollment:
                if let selectedPhrase = selectedPhrase {
                    // Save the enrolled phrase for future verification
                    UserDefaults.standard.set(selectedPhrase, forKey: "phrase")
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
