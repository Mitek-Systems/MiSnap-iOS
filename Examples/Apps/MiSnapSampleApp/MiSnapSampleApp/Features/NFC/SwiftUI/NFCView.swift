//
//  NFCView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct NFCView: View {
    @StateObject var viewModel: NFCViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        inputFieldsSection
                        captureTypesGrid
                    }
                }
            }
            .navigationTitle("NFC")
            .onTapGesture {
                // Dismiss keyboard when tapping outside text fields
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            // Present NFC capture screen when a document type is selected
            .fullScreenCover(isPresented: $viewModel.shouldShowCapture) {
                // Get configuration from ViewModel
                if let configuration = viewModel.currentConfiguration {
                    MiSnapNFCViewControllerRepresentable(
                        configuration: configuration,
                        onLicenseStatus: viewModel.handleLicenseStatus,
                        onSuccess: viewModel.handleSuccessfulCapture,
                        onCancelled: viewModel.handleCancellation,
                        onSkipped: viewModel.handleSkipped,
                        onShouldBeDismissed: viewModel.handleDismiss
                    )
                    .background(Color.black)
                    .ignoresSafeArea()
                }
            }
            .sheet(item: $viewModel.captureResult) { result in
                resultView(for: result)
            }
            .alert(item: $viewModel.alert) { $0.alert }
        }
        // Restrict to portrait orientation
        .onAppear { OrientationManager.shared.setOrientation(.portrait) }
    }
    
    // MARK: - Subviews
    
    private var inputFieldsSection: some View {
        VStack(spacing: 8) {
            MonospacedInputField(title: "Document Number", text: $viewModel.documentNumber)
            MonospacedInputField(title: "Date of Birth (YYMMDD)", text: $viewModel.dateOfBirth, keyboardType: .numberPad)
            MonospacedInputField(title: "Expiration Date (YYMMDD)", text: $viewModel.dateOfExpiry, keyboardType: .numberPad)
            MonospacedInputField(title: "MRZ String", text: $viewModel.mrzString)
        }
        .padding()
    }
    
    private var captureTypesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.availablePresets) { documentType in
                CapturePresetCard(
                    symbolName: documentType.symbolName,
                    title: documentType.displayName
                ) {
                    viewModel.selectPreset(documentType)
                }
            }
        }
        .padding()
    }
    
    private func resultView(for result: NFCResult) -> some View {
        return ResultView(
            response: result.nfcData?.formattedNFCString ?? "",
            images: result.images
        )
    }
}

// MARK: - Previews

#Preview("NFC") {
    NFCView(viewModel: NFCViewModel())
}
