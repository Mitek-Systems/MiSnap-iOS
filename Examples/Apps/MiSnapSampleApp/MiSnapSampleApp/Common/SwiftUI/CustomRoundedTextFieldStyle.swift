//
//  CustomRoundedTextFieldStyle.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

// swiftlint:disable identifier_name

import SwiftUI

// MARK: - Custom Text Field Style
struct CustomRoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(.secondaryLabel), lineWidth: 0.5)
            )
    }
}

// swiftlint:enable identifier_name
