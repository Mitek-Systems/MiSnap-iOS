//
//  NFCViewModel.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import Combine
import os
import MiSnapCore
import MiSnapNFC
import MiSnapNFCUX

@MainActor
class NFCViewModel: ObservableObject {
    @Published var selectedPreset: MiSnapNFCDocumentType?
    @Published var captureResult: NFCResult?
    @Published var alert: AlertConfig?
    @Published var shouldShowCapture = false
        
    // NFC Input Fields
    // These values are typically extracted from document OCR or barcode scanning
    @Published var documentNumber = ""
    @Published var dateOfBirth = ""
    @Published var dateOfExpiry = ""
    @Published var mrzString = ""
    
    let availablePresets: [MiSnapNFCDocumentType] =  [.passport, .id, .dl]
    
    private var pendingResult: NFCResult?
    
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
    
    var currentConfiguration: MiSnapNFCConfiguration? {
        guard let selectedPreset else { return nil }
        return makeConfiguration(for: selectedPreset)
    }
    
    // MARK: - Integration Flow Entry Point
    func selectPreset(_ preset: MiSnapNFCDocumentType) {
        selectedPreset = preset
        AppLogger.info("Selected NFC preset: \(preset.rawValue)")
        
        // Start the validation and presentation flow
        Task {
            await presentCapture()
        }
    }
    
    // MARK: - Present Capture Flow
    private func presentCapture() async {
        // Check license
        guard checkLicense() else { return }
        
        // Validate NFC inputs (document data and chip location)
        guard validateNFCInputs() else { return }
        
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
    
    // MARK: - Validate NFC Inputs
    private func validateNFCInputs() -> Bool {
        guard let documentType = selectedPreset else { return false }
        
        // Determine if document has NFC chip based on provided data
        let chipLocation = MiSnapNFCChipLocator.chipLocation(
            mrzString: mrzString,
            documentNumber: documentNumber,
            dateOfBirth: dateOfBirth,
            dateOfExpiry: dateOfExpiry
        )
        
        // Validate that the document can be read via NFC
        // IDs and Passports must have a chip, Driver's licenses require MRZ data
        let hasNoChip = chipLocation == .noChip
        let isIdOrPassport = documentType == .id || documentType == .passport
        let isDriversLicense = documentType == .dl
        
        // Cannot read NFC if:
        // - ID/Passport has no chip detected, OR
        // - Driver's license is missing MRZ string
        let cannotReadNFC = (hasNoChip && isIdOrPassport) || (isDriversLicense && mrzString.isEmpty)
        
        if cannotReadNFC {
            showValidationAlert()
            selectedPreset = nil
            return false
        }
        
        return true
    }
    
    // MARK: - Build MiSnapNFC Configuration
    func makeConfiguration(for documentType: MiSnapNFCDocumentType) -> MiSnapNFCConfiguration {
        // Determine chip location from document data
        let chipLocation = MiSnapNFCChipLocator.chipLocation(
            mrzString: mrzString,
            documentNumber: documentNumber,
            dateOfBirth: dateOfBirth,
            dateOfExpiry: dateOfExpiry
        )
        
        // Build configuration with document inputs
        let configuration = MiSnapNFCConfiguration()
            .withCustomUxParameters { parameters in
                // Disable auto-dismiss to manually control dismissal timing
                // IMPORTANT: When autoDismiss is false, you must implement the optional
                // miSnapNfcShouldBeDismissed() delegate callback to properly dismiss
                // the SDK after it completes its internal cleanup.
                // See `handleDismiss()` and `MiSnapNFCViewControllerRepresentable.onShouldBeDismissed`
                parameters.autoDismiss = false
            }
            .withInputs { inputs in
                // Provide document data for NFC chip authentication
                inputs.documentNumber = self.documentNumber
                inputs.dateOfBirth = self.dateOfBirth
                inputs.dateOfExpiry = self.dateOfExpiry
                inputs.mrzString = self.mrzString
                inputs.documentType = documentType
                inputs.chipLocation = chipLocation
            }
        
        return configuration
    }
    
    // MARK: - Handle Delegate Callbacks and Process Result
    func handleLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle license status updates if needed
        // Currently handled in checkLicense() during initialization
    }
    
    func handleSuccessfulCapture(_ result: [String: Any]) {
        // Process and store the result until SDK is ready to dismiss
        pendingResult = NFCResult(result)
    }
    
    func handleCancellation(_ result: [String: Any]) {
        // User cancelled - clean up temporary storage
        pendingResult = nil
    }
    
    func handleSkipped(_ result: [String: Any]) {
        // User skipped - clean up temporary storage
        pendingResult = nil
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
    private func showValidationAlert() {
        alert = AlertConfig(
            title: "Document Not Supported",
            message: "There is no chip in a document with provided information or a document is not supported yet."
        )
    }
    
    private func showLicenseAlert(message: String) {
        alert = .licenseError(message: message)
    }
}
