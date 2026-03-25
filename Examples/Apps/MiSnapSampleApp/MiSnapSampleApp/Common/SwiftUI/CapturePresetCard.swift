//
//  CapturePresetCard.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct CapturePresetCard: View {
    let symbolName: String
    let title: String
    let details: String?
    let isEnabled: Bool
    let action: () -> Void
    
    init(symbolName: String, title: String, details: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.symbolName = symbolName
        self.title = title
        self.details = details
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbolName)
                    .font(.system(size: 28, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(minHeight: 20)
                
                if let details = details {
                    Text(details)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.7)
    }
}

#Preview {
    CapturePresetCard(
        symbolName: "doc.text.viewfinder",
        title: "Passport"
    ) {
        print("Card tapped")
    }
    .padding()
}
