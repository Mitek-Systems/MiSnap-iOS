//
//  NFCResult.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapNFC

// MARK: - Identifiable NFCResult
struct NFCResult: Identifiable {
    let id: UUID
    let nfcData: [String : Any]?
    var faceImage: UIImage?
    var signatureImage: UIImage?
    
    init(_ result: [String : Any]) {
        self.id = UUID()
        self.nfcData = result
        
        // Extract face image if available
        self.faceImage = result[MiSnapNFCKey.faceImage] as? UIImage
        
        // Extract signature image if available
        self.signatureImage = result[MiSnapNFCKey.signatureImage] as? UIImage
    }
    
    var images: [UIImage]? {
        let allImages = [faceImage, signatureImage].compactMap { $0 }
        return allImages.isEmpty ? nil : allImages
    }
}

// MARK: - Formatted String
extension Dictionary where Key == String, Value == Any {
    var formattedNFCString: String {
        guard !self.isEmpty else { return "" }
        
        var lines: [String] = []
        
        // Simple key-value mappings
        let fieldMappings: [(key: String, label: String)] = [
            (MiSnapNFCKey.givenName, "Given name"),
            (MiSnapNFCKey.surname, "Surname"),
            (MiSnapNFCKey.dateOfBirth, "Date of birth"),
            (MiSnapNFCKey.placeOfBirth, "Place of birth"),
            (MiSnapNFCKey.sex, "Gender"),
            (MiSnapNFCKey.nationality, "Nationality"),
            (MiSnapNFCKey.documentNumber, "Document number"),
            (MiSnapNFCKey.documentExpiryDate, "Document expiry date"),
            (MiSnapNFCKey.documentIssueDate, "Document issue date"),
            (MiSnapNFCKey.address, "Address"),
            (MiSnapNFCKey.telephone, "Telephone"),
            (MiSnapNFCKey.profession, "Profession"),
            (MiSnapNFCKey.title, "Title"),
            (MiSnapNFCKey.personalSummary, "Personal summary"),
            (MiSnapNFCKey.custodyInformation, "Custody information"),
            (MiSnapNFCKey.personalNumber, "Personal number"),
            (MiSnapNFCKey.issuingCountry, "Issuing country"),
            (MiSnapNFCKey.issuingAuthority, "Issuing authority"),
            (MiSnapNFCKey.documentType, "Document type"),
            (MiSnapNFCKey.documentTypeCode, "Document type code"),
            (MiSnapNFCKey.MRZ, "MRZ"),
            (MiSnapNFCKey.authenticationOutputs, "CA")
        ]
        
        // Process simple fields
        for (key, label) in fieldMappings {
            if let value = self[key] as? String {
                lines.append("\(label): \(value)")
            }
        }
        
        // Handle array of strings (otherTravelDocNumbers)
        if let otherTravelDocNumbers = self[MiSnapNFCKey.otherTravelDocNumbers] as? [String] {
            for docNumber in otherTravelDocNumbers {
                lines.append("Other travel doc number: \(docNumber)")
            }
        }
        
        // Handle license classes
        if let licenseClasses = self[MiSnapNFCKey.licenseClasses] as? [[String: String]] {
            lines.append("License classes:")
            for licenseClass in licenseClasses {
                if let className = licenseClass[MiSnapNFCKey.licenseClass],
                   let issueDate = licenseClass[MiSnapNFCKey.licenseClassIssueDate],
                   let expiryDate = licenseClass[MiSnapNFCKey.licenseClassExpiryDate] {
                    lines.append("  \(className) (DOI: \(issueDate), DOE: \(expiryDate))")
                }
            }
        }
        
        return lines.joined(separator: "\n")
    }
}
