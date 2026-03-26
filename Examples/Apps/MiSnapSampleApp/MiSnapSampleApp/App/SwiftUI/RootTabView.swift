//
//  RootTabView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

// MARK: - Root View
struct RootTabView: View {
    var body: some View {
#if swift(>=5.10)
        if #available(iOS 18, *) {
            ModernTabs()
        } else {
            LegacyTabs()
        }
#else
        LegacyTabs()
#endif
    }
}

// MARK: - Tab Configuration
private enum AppTab: Int, CaseIterable {
    case documents = 0
    case face = 2
    case voice = 3
    case nfc = 1
    case workflow = 4
    
    var title: String {
        switch self {
        case .documents: return "Docs"
        case .nfc: return "NFC"
        case .face: return "Face"
        case .voice: return "Voice"
        case .workflow: return "Workflow"
        }
    }
    
    var icon: String {
        switch self {
        case .documents: return "person.text.rectangle"
        case .nfc: return "dot.radiowaves.left.and.right"
        case .face: return "faceid"
        case .voice: return "waveform"
        case .workflow: return "checklist"
        }
    }
    
    @MainActor
    @ViewBuilder
    var destination: some View {
        switch self {
        case .documents: DocumentsView(viewModel: DocumentsViewModel())
        case .nfc:       NFCView(viewModel: NFCViewModel())
        case .face:      FaceView(viewModel: FaceViewModel())
        case .voice:     VoiceView(viewModel: VoiceViewModel())
        case .workflow:  WorkflowView(viewModel: WorkflowViewModel())
        }
    }
}

#if swift(>=5.10)
// MARK: - Modern Implementation (iOS 18+)
@available(iOS 18, *)
private struct ModernTabs: View {
    @State private var selectedTab: AppTab = .documents
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Tab(tab.title, systemImage: tab.icon, value: tab) {
                    tab.destination
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
#endif

// MARK: - Legacy Implementation (iOS 16-17)
private struct LegacyTabs: View {
    @State private var selectedTab: AppTab = .documents
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tab.destination
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }
}

// MARK: - Previews
#Preview("Main Tabs — Light") {
    RootTabView()
}

#Preview("Main Tabs — Dark") {
    RootTabView()
        .preferredColorScheme(.dark)
}
