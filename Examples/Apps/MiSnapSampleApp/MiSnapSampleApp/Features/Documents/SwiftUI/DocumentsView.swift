//
//  DocumentsView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct DocumentsView: View {
    @StateObject var viewModel: DocumentsViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    captureTypesGrid
                }
            }
            .navigationTitle("Documents")
            .fullScreenCover(isPresented: $viewModel.shouldShowCapture) {
                if let preset = viewModel.selectedPreset {
                    captureView(for: preset)
                }
            }
            .sheet(item: $viewModel.captureResult) { result in
                resultView(for: result)
            }
            .alert(item: $viewModel.alert) { $0.alert }
        }
        // Allow all orientations for document capture
        .onAppear { OrientationManager.shared.setOrientation(.all) }
    }
    
    // MARK: - Subviews
    private var captureTypesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.availablePresets) { preset in
                CapturePresetCard(
                    symbolName: preset.symbolName,
                    title: preset.rawValue
                ) {
                    viewModel.selectPreset(preset)
                }
            }
        }
        .padding()
    }
    
    private func captureView(for preset: DocumentPreset) -> some View {
        let configuration = viewModel.makeConfiguration(for: preset)
        
        return MiSnapViewControllerRepresentable(
            configuration: configuration,
            onLicenseStatus: viewModel.handleLicenseStatus,
            onSuccess: viewModel.handleSuccessfulCapture,
            onCancelled: viewModel.handleCancellation,
            onException: viewModel.handleException,
            onShouldBeDismissed: viewModel.handleDismiss,
            onCustomTutorial: viewModel.handleCustomTutorial(for: preset)
        )
        .background(Color.black)
        .ignoresSafeArea()
    }
    
    private func resultView(for result: DocumentCaptureResult) -> some View {
        let text = result.mibiString ?? "Failed to extract MIBI data."
        return ResultView(response: text, image: result.image)
    }
}

// MARK: - Previews

#Preview("Documents") {
    DocumentsView(viewModel: DocumentsViewModel())
}
