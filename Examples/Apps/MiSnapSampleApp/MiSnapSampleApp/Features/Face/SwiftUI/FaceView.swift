//
//  FaceView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

struct FaceView: View {
    @StateObject var viewModel: FaceViewModel
    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    aiBasedRtsToggle
                    cameraPositionPicker
                    captureTypesGrid
                }
            }
            .navigationTitle("Face")
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
        // Face capture: portrait only on iPhone, all orientations on iPad
        .onAppear { OrientationManager.shared.setOrientation(iPhone: .portrait, iPad: .all) }
    }
    
    // MARK: - Subviews
    
    private var aiBasedRtsToggle: some View {
        HStack {
            Label("AI-based RTS", systemImage: "sparkles")
                .font(.headline)
            Spacer()
            Toggle("", isOn: $viewModel.aiBasedRtsEnabled)
                .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var cameraPositionPicker: some View {
        HStack {
            Label("Camera", systemImage: "arrow.trianglehead.2.clockwise.rotate.90.camera")
                .font(.headline)
            Spacer()
            Picker("Camera", selection: $viewModel.cameraPosition) {
                Text("Front").tag(FaceCameraPosition.front)
                Text("Back").tag(FaceCameraPosition.back)
            }
            .pickerStyle(.menu)
            .disabled(viewModel.aiBasedRtsEnabled)
        }
        .padding(.horizontal)
    }

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
    
    private func captureView(for preset: FacePreset) -> some View {
        let configuration = viewModel.makeConfiguration(for: preset)
        var onHelpAction: ((MiSnapFacialCaptureViewController) -> Void)?
        var onTimeoutAction: ((MiSnapFacialCaptureViewController) -> Void)?

        if preset == .customSelfie {
            onHelpAction = { captureVC in
                presentTutorial(mode: .help, captureVC: captureVC)
            }
            onTimeoutAction = { captureVC in
                presentTutorial(mode: .timeout, captureVC: captureVC)
            }
        }

        return MiSnapFacialCaptureViewControllerRepresentable(
            configuration: configuration,
            onLicenseStatus: viewModel.handleLicenseStatus,
            onSuccess: viewModel.handleSuccessfulCapture,
            onCancelled: viewModel.handleCancellation,
            onException: viewModel.handleException,
            onShouldBeDismissed: viewModel.handleDismiss,
            onHelpAction: onHelpAction,
            onTimeoutAction: onTimeoutAction
        )
        .background(Color.black)
        .ignoresSafeArea()
    }

    // Wraps CustomFacialCaptureTutorialView in a UIHostingController and presents it
    // above the active capture session using the SDK's presentVC(_:) method.
    private func presentTutorial(mode: MiSnapFacialCaptureTutorialMode, captureVC: MiSnapFacialCaptureViewController) {
        let tutorialView = CustomFacialCaptureTutorialView(
            mode: mode,
            onCancel: { captureVC.tutorialCancelButtonAction() },
            onContinue: { captureVC.tutorialContinueButtonAction(for: mode) },
            onRetry: mode == .timeout ? { captureVC.tutorialRetryButtonAction() } : nil
        )
        let hostingController = UIHostingController(rootView: tutorialView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        captureVC.presentVC(hostingController)
    }
    
    private func resultView(for result: FaceCaptureResult) -> some View {
        let text = result.mibiString ?? "Failed to extract MIBI data."
        return ResultView(response: text, image: result.image)
    }
}

// MARK: - Previews

#Preview("Face") {
    FaceView(viewModel: FaceViewModel())
}
