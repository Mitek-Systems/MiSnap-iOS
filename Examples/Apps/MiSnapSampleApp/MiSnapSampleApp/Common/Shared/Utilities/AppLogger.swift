//
//  AppLogger.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

// swiftlint:disable identifier_name

import Foundation
import os

/// Global logger for the sample app.
let AppLogger = Logger(subsystem: "com.miteksystems.MiSnapSampleApp", category: "App")

/// Shared JSON formatter used by both SwiftUI and UIKit result screens.
enum JSONFormatter {
    static func prettyPrint(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
}

// swiftlint:enable identifier_name
