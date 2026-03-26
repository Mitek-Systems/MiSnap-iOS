//
//  WorkflowViewModel.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import Combine
import os
import MiSnapCore
import MiSnapVoiceCapture

@MainActor
class WorkflowViewModel: ObservableObject {
    @Published var workflowResult: WorkflowResult?
    @Published var alert: AlertConfig?
    @Published var shouldShowWorkflow = false
    @Published var selectedWorkflowSteps: [MiSnapWorkflowStep] = []
    @Published var selectedFlow: MiSnapWorkflowFlow = .enrollment
    
    // MARK: - Initialization
    init() {
        setupLicense()
    }
    
    // MARK: - Setup License
    private func setupLicense() {
        let licenseKey = LicenseKey.key
        MiSnapLicenseManager.shared.setLicenseKey(licenseKey)
        AppLogger.debug("🔑 MiSnap License: \(MiSnapLicenseManager.shared.description)")
    }
    
    // MARK: - Integration Flow Entry Point
    func startWorkflow(steps: [MiSnapWorkflowStep], flow: MiSnapWorkflowFlow = .enrollment) {
        selectedWorkflowSteps = steps
        selectedFlow = flow
        
        let stepNames = steps.map { $0.stringValue }.joined(separator: ", ")
        AppLogger.info("Starting \(flow.rawValue) workflow with steps: \(stepNames)")
        
        // Start the validation and presentation flow
        Task {
            await presentWorkflow()
        }
    }
    
    // MARK: - Present Workflow Flow
    private func presentWorkflow() async {
        // Check license
        guard checkLicense() else { return }
        
        // Check feature licenses
        guard checkFeatureLicenses() else { return }
        
        // Check minimum disk space
        guard checkDiskSpace() else { return }
        
        // Check camera permission
        guard await checkCameraPermission() else { return }
        
        // Check microphone permission if voice step is included
        if selectedWorkflowSteps.contains(.voice) {
            guard await checkMicrophonePermission() else { return }
        }
        
        // All checks passed - present workflow
        shouldShowWorkflow = true
    }
    
    // MARK: - Check License Status
    private func checkLicense() -> Bool {
        let licenseStatus = MiSnapLicenseManager.shared.status
        AppLogger.info("Checking license status: \(licenseStatus.stringValue)")
        
        guard licenseStatus == .valid else {
            AppLogger.error("🔑 License is not valid: \(licenseStatus.stringValue)")
            showLicenseAlert(message: "MiSnap license is not valid: \(licenseStatus.stringValue)")
            return false
        }
        
        return true
    }
    
    // MARK: - Check Feature Licenses
    private func checkFeatureLicenses() -> Bool {
        // Check voice feature if voice step is included
        if selectedWorkflowSteps.contains(.voice) {
            guard MiSnapLicenseManager.shared.featureSupported(.voice) else {
                AppLogger.error("🔑 Voice capture is not licensed")
                showLicenseAlert(message: "Voice capture is not licensed")
                return false
            }
        }
        
        // Check face feature if face step is included
        if selectedWorkflowSteps.contains(.face) {
            guard MiSnapLicenseManager.shared.featureSupported(.face) else {
                AppLogger.error("🔑 Face capture is not licensed")
                showLicenseAlert(message: "Face capture is not licensed")
                return false
            }
        }
        
        // Check nfc feature if nfc step is included
        if selectedWorkflowSteps.contains(.nfc) {
            guard MiSnapLicenseManager.shared.featureSupported(.NFC) else {
                AppLogger.error("🔑 NFC reading is not licensed")
                showLicenseAlert(message: "NFC reading is not licensed")
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Check Disk Space
    private func checkDiskSpace() -> Bool {
        let minDiskSpace: Int = 10 // Min disk space in MB required for workflow
        
        guard MiSnapWorkflowViewController.hasMinDiskSpace(minDiskSpace) else {
            AppLogger.error("💾 Insufficient disk space")
            showDiskSpaceAlert(minDiskSpace: minDiskSpace)
            return false
        }
        
        AppLogger.info("✅ Disk space check passed")
        return true
    }
    
    // MARK: - Check Camera Permission
    private func checkCameraPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            MiSnapWorkflowViewController.checkCameraPermission { granted in
                Task { @MainActor in
                    if !granted {
                        AppLogger.warning("❌ Camera permission denied")
                        self.showPermissionDeniedAlert(.camera)
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // MARK: - Check Microphone Permission
    private func checkMicrophonePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            MiSnapWorkflowViewController.checkMicrophonePermission { granted in
                Task { @MainActor in
                    if !granted {
                        AppLogger.warning("❌ Microphone permission denied")
                        self.showPermissionDeniedAlert(.microphone)
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // MARK: - Handle Delegate Callbacks and Process Result
    func handleWorkflowSuccess(_ result: MiSnapWorkflowResult) {
        // Dismiss the controller
        dismissWorkflow()
        
        // Process the MiSnapWorkflowResult
        workflowResult = WorkflowResult(result)
    }
    
    func handleWorkflowCancellation(_ result: MiSnapWorkflowResult) {
        AppLogger.info("❌ Workflow cancelled by user")
        
        // User cancelled - Dismiss the controller
        dismissWorkflow()
    }
    
    func handleWorkflowError(_ result: MiSnapWorkflowResult) {
        // Dismiss the controller
        dismissWorkflow()
        
        // Log error
        if let voice = result.voice, !voice.isEmpty {
            let error = voice[0].error
            AppLogger.error("Error details: \(error)")
        }
        
        // Show error alert
        showErrorAlert(message: "Workflow failed. Please try again.")
    }
    
    func handleLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Dismiss the controller
        dismissWorkflow()
        
        AppLogger.error("🔑 License status issue: \(status.stringValue)")
        
        // Show license alert
        showLicenseAlert(message: "License issue: \(status.stringValue)")
    }
    
    func handleWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep) {
       // Handle intermediate results here
    }
    
    func handleNfcSkipped(_ result: [String: Any]) {
        // Handle NFC step skip here
    }
    
    func handlePhraseSelected(_ phrase: String) {
        // Handle selected phrase for voice step here
    }
    
    // MARK: - Dismiss Workflow Controller
    func dismissWorkflow() {
        shouldShowWorkflow = false
    }
    
    // MARK: - Alert Helpers
    private func showPermissionDeniedAlert(_ type: PermissionType) {
        alert = .permissionDenied(type)
    }
    
    private func showLicenseAlert(message: String) {
        alert = .licenseError(message: message)
    }
    
    private func showDiskSpaceAlert(minDiskSpace: Int) {
        alert = .diskSpaceError(minDiskSpace: minDiskSpace)
    }
    
    private func showErrorAlert(message: String) {
        alert = AlertConfig(
            title: "Error",
            message: message,
            primaryButton: AlertConfig.AlertButton(title: "OK", action: {})
        )
    }
}
