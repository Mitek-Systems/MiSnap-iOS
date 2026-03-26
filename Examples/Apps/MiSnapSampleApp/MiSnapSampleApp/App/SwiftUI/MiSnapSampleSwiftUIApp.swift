//
//  MiSnapSampleAppSwiftUIApp.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI
import MiSnapCore

@main
struct MiSnapSampleSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var showLaunchScreen = true
    
    init() {
        // If you prefer to set the MiSnap license globally (instead of in each ViewModel),
        // you can do it here. See feature ViewModels (e.g., DocumentsViewModel) for license setting code.
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .overlay(alignment: .topLeading) {
                        TargetBadge(label: "SwiftUI")
                            .padding(.top, 16)
                            .padding(.leading, 16)
                    }
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .onAppear {
                // Dismiss launch screen after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}

private struct TargetBadge: View {
    let label: String
    
    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.secondary.opacity(0.08))
            )
            .overlay(
                Capsule()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 0.5)
            )
            .foregroundColor(.secondary)
    }
}
