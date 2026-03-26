//
//  View+ClearButton.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

extension View {
    func clearButton(text: Binding<String>) -> some View {
        self.overlay(alignment: .trailing) {
            if !text.wrappedValue.isEmpty {
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemBackground))
                        )
                }
                .padding(.trailing, 8)
            }
        }
    }
}
