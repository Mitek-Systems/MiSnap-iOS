//
//  MonospacedInputField.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import SwiftUI

struct MonospacedInputField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(CustomRoundedTextFieldStyle())
            .font(.system(size: 17, weight: .regular, design: .monospaced))
            .keyboardType(keyboardType)
            .clearButton(text: $text)
    }
}
