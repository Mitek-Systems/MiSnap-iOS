//
//  CustomFacialCaptureTutorialView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

struct CustomFacialCaptureTutorialView: View {
    let mode: MiSnapFacialCaptureTutorialMode
    let onCancel: () -> Void
    let onContinue: () -> Void
    let onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            illustration
            Spacer()
            actions
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .statusBarHidden()
    }
}

// MARK: - Content
//   The only requirement is that onCancel, onContinue, and onRetry remain wired to buttons
//   so the SDK can properly handle Cancel, Continue/Manual, and Retry.
private extension CustomFacialCaptureTutorialView {
    var illustration: some View {
        VStack(spacing: 24) {
            Image(systemName: symbolName)
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text(titleText)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(subtitleText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var actions: some View {
        VStack(spacing: 12) {
            if mode == .timeout, let onRetry {
                Button("Retry", action: onRetry)
                    .buttonStyle(TutorialPrimaryButtonStyle())
            }

            Button(mode == .timeout ? "Manual" : "Continue", action: onContinue)
                .buttonStyle(TutorialPrimaryButtonStyle())

            Button("Cancel", action: onCancel)
                .buttonStyle(TutorialSecondaryButtonStyle())
        }
    }

    var symbolName: String {
        switch mode {
        case .help:    return "person.crop.circle.badge.questionmark"
        case .timeout: return "clock.badge.exclamationmark"
        default:       return "questionmark.circle"
        }
    }

    var titleText: String {
        switch mode {
        case .help:    return "Need some help?"
        case .timeout: return "Time's up"
        default:       return ""
        }
    }

    var subtitleText: String {
        switch mode {
        case .help:    return "Make sure your face is well-lit and centered in the oval."
        case .timeout: return "How would you like to proceed?"
        default:       return ""
        }
    }
}

// MARK: - Button Styles

private struct TutorialPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.primary)
            .clipShape(.capsule)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

private struct TutorialSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

// MARK: - Previews

#Preview("Help") {
    CustomFacialCaptureTutorialView(
        mode: .help,
        onCancel: {},
        onContinue: {},
        onRetry: nil
    )
}

#Preview("Timeout") {
    CustomFacialCaptureTutorialView(
        mode: .timeout,
        onCancel: {},
        onContinue: {},
        onRetry: {}
    )
}

#Preview("Help – Dark") {
    CustomFacialCaptureTutorialView(
        mode: .help,
        onCancel: {},
        onContinue: {},
        onRetry: nil
    )
    .preferredColorScheme(.dark)
}
