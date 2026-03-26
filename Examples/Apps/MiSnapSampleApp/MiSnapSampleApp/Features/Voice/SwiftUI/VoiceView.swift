//
//  VoiceView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct VoiceView: View {
    @StateObject var viewModel: VoiceViewModel
    
    private let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    captureTypesGrid
                }
            }
            .navigationTitle("Voice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.hasEnrolledPhrase {
                        Button {
                            viewModel.resetEnrollment()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.shouldShowCapture) {
                if let configuration = viewModel.currentConfiguration {
                    MiSnapVoiceCaptureViewControllerRepresentable(
                        configuration: configuration,
                        onLicenseStatus: viewModel.handleLicenseStatus,
                        onPhraseSelected: viewModel.handlePhraseSelected,
                        onSuccess: viewModel.handleSuccessfulCapture,
                        onCancelled: viewModel.handleCancellation,
                        onError: viewModel.handleError,
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
    
    private var captureTypesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.availableFlows, id: \.self) { flow in
                CapturePresetCard(
                    symbolName: flow.symbolName,
                    title: flow.displayName,
                    isEnabled: viewModel.isEnabled(flow),
                    action: { viewModel.select(flow) }
                )
            }
        }
        .padding()
    }
        
    private func resultView(for result: VoiceCaptureResult) -> some View {
        var mibi = ""
        if result.flow == .verification {
            mibi = result.mibiString ?? "Failed to extract MIBI data."
        }
        
        let audioData = result.results.compactMap { $0.data }
        
        return ResultView(
            response: mibi,
            summary: result.summary,
            audioData: audioData.isEmpty ? nil : audioData
        )
    }
}

// MARK: - Previews

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView(viewModel: VoiceViewModel())
            .previewDisplayName("Voice")
    }
}
