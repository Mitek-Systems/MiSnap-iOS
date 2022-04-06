//
//  Utils.swift
//  MiSnapNFCSampleApp
//
//  Created by Stas Tsuprenko on 3/28/22.
//

enum NFCField: String, Equatable, CaseIterable {
    case documentNumber = "documentNumber"
    case dateOfBirth = "dateOfBirth"
    case dateOfExpiry = "dateOfExpiry"
    case mrzString = "mrzString"
    
    var placeholder: String {
        switch self {
        case .documentNumber:   return "Document Number"
        case .dateOfBirth:      return "Date of Birth (YYMMDD)"
        case .dateOfExpiry:     return "Date of Expiry (YYMMDD)"
        case .mrzString:        return "MRZ String"
        }
    }
    
    var index: Int {
        switch self {
        case .documentNumber:   return 0
        case .dateOfBirth:      return 1
        case .dateOfExpiry:     return 2
        case .mrzString:        return 3
        }
    }
    
    static func from(_ index: Int) -> NFCField {
        switch index {
        case 0:     return .documentNumber
        case 1:     return .dateOfBirth
        case 2:     return .dateOfExpiry
        case 3:     return .mrzString
        default:    fatalError("NFCField with index \(index) doesn't exist")
        }
    }
}
