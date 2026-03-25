//
//  WorkflowView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct WorkflowView: View {
    @StateObject var viewModel: WorkflowViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                workflowCategoriesGrid
            }
            .navigationTitle("Workflow")
            .fullScreenCover(isPresented: $viewModel.shouldShowWorkflow) {
                workflowView
            }
            .sheet(item: $viewModel.workflowResult) { result in
                resultView(for: result)
            }
            .alert(item: $viewModel.alert) { $0.alert }
        }
        // Allow all orientations
        .onAppear { OrientationManager.shared.setOrientation(.all) }
    }
    
    // MARK: - Subviews
    
    private var workflowCategoriesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(WorkflowPreset.allCategories) { preset in
                CapturePresetCard(
                    symbolName: preset.symbolName,
                    title: preset.title,
                    details: preset.details
                ) {
                    startWorkflow(preset)
                }
            }
        }
        .padding()
    }
    
    private var workflowView: some View {
        MiSnapWorkflowViewControllerRepresentable(
            flow: viewModel.selectedFlow,
            steps: viewModel.selectedWorkflowSteps,
            onLicenseStatus: viewModel.handleLicenseStatus,
            onSuccess: viewModel.handleWorkflowSuccess,
            onCancelled: viewModel.handleWorkflowCancellation,
            onError: viewModel.handleWorkflowError,
            onIntermediate: viewModel.handleWorkflowIntermediate,
            onNfcSkipped: viewModel.handleNfcSkipped,
            onPhraseSelected: viewModel.handlePhraseSelected
        )
        .background(Color.black)
        .ignoresSafeArea()
    }
    
    private func resultView(for result: WorkflowResult) -> some View {
        ResultView(
            response: result.mibiData,
            images: result.images,
            audioData: result.audioData
        )
    }
    
    // MARK: - Actions
    
    private func startWorkflow(_ preset: WorkflowPreset) {
        viewModel.startWorkflow(steps: preset.steps)
    }
}

// MARK: - Previews

#Preview("Workflow") {
    WorkflowView(viewModel: WorkflowViewModel())
}
