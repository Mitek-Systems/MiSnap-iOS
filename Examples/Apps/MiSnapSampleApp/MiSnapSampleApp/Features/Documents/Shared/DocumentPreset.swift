//
//  DocumentPreset.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import Foundation
import MiSnap

enum DocumentPreset: String, CaseIterable, Identifiable {
    case anyId = "Any ID"
    case passport = "Passport"
    case idFront = "ID Front"
    case idBack = "ID Back"
    case checkFront = "Check Front"
    case checkBack = "Check Back"
    case generic = "Generic"
    case customIDFront = "Custom ID Front"
    case customDocument = "Custom Document"
    
    var id: String { rawValue }
    
    var symbolName: String {
        switch self {
        case .anyId:          return "person.text.rectangle.fill"
        case .passport:       return "book"
        case .idFront:        return "person.text.rectangle"
        case .idBack:         return "creditcard"
        case .checkFront:     return "banknote"
        case .checkBack:      return "banknote"
        case .generic:        return "rectangle.dashed"
        case .customIDFront:  return "circle.rectangle.filled.pattern.diagonalline"
        case .customDocument: return "doc.badge.gearshape.fill"
        }
    }
}

// MARK: - Document Type Mapping
extension DocumentPreset {
    var documentType: MiSnapScienceDocumentType {
        switch self {
        case .anyId:            return .anyId
        case .passport:         return .passport
        case .idFront:          return .idFront
        case .idBack:           return .idBack
        case .checkFront:       return .checkFront
        case .checkBack:        return .checkBack
        case .generic:          return .generic
        case .customIDFront:    return .idFront
        case .customDocument:   return .anyId
        }
    }
}
