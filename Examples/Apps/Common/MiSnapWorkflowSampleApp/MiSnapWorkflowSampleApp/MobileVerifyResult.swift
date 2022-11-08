//
//  MobileVerifyResponse.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 6/26/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit
#if canImport(MiSnapNFC)
import MiSnapNFC
#endif

public enum MobileVerifyBioInfo: String {
    case givenName = "Given Name"
    case surname = "Surname"
    case sex = "Sex"
    case dateOfBirth = "Date Of Birth"
    case placeOfBirth = "Place of Birth"
    case nationality = "Nationality"
    case personalGovId = "Personal Government ID"
}

public enum MobileVerifyAddressInfo: String {
    case addressLine1 = "Address Line 1"
    case addressLine2 = "Address Line 2"
    case city = "City"
    case postalCode = "Postal Code"
    case state = "State"
    case country = "Country"
}

public enum MobileVerifyDocumentInfo: String {
    case documentType = "Document Type"
    case documentTypeCode = "Document Type Code"
    case documentNumber = "Document Number"
    case dateOfExpiry = "Expiry Date"
    case dateOfIssue = "Issue Date"
    case licenseClass = "License Class"
    case issuingCountry = "Issuing Country"
    case issuingAuthority = "Issuing Authority"
}

public struct MobileVerifyVerification: Decodable {
    let name: String
    let probability: Int
    let judgement: MitekPlatformJudgement
    let notifications: [String: String]
    let verificationType: Int
    let version: String
    let documentId: String?
}

public struct MobileVerifyFindings: Decodable {
    let authenticated: Bool
    let probability: Int
    let verifications: [MobileVerifyVerification]
}

public struct MobileVerifyAddress: Decodable {
    let country: String?
    let stateProvince: String?
    let addressLine1: String?
    let city: String?
    let postalCode: String?
}

public struct MobileVerifyExtractedDataDynamicProperties: Decodable {
    let sex: String?
    let licenseClass: String?
    let nationality: String?
    let issuingCountry: String?
    let nationalityCode: String?
    let personalGovID: String?
}

public struct MobileVerifyExtractedDataName: Decodable {
    let surname: String?
    let givenNames: String?
    let fullName: String?
}

public struct MobileVerifyExtractedData: Decodable {
    let address: MobileVerifyAddress?
    let documentNumber: String?
    let dateOfIssue: String?
    let dateOfExpiry: String?
    let dateOfBirth: String?
    let dynamicProperties: MobileVerifyExtractedDataDynamicProperties?
    let name: MobileVerifyExtractedDataName?
}

public struct MobileVerifyEvidence: Decodable {
    let evidenceId: String
    let type: String
    let extractedData: MobileVerifyExtractedData?
    
    enum CodingKeys: String, CodingKey {
        case evidenceId
        case type
        case extractedData
    }
}

public struct MobileVerifyDossierMetadata: Decodable {
    let dossierId: String?
    let createdDateTime: String?
}

public struct MobileVerifyResponse: Decodable {
    let processingTime: Int
    let dossierMetadata: MobileVerifyDossierMetadata
    let evidence: [MobileVerifyEvidence]
    let findings: MobileVerifyFindings
    
    enum CodingKeys: String, CodingKey {
        case processingTime
        case dossierMetadata
        case evidence
        case findings
    }
}

public enum MobileVerifyFindingName: String, Equatable {
    case overall
    case nfc
    case optical
    case faceComparison
    case faceLiveness
    
    var summary: String {
        switch self {
        case .overall:              return "Overall Judgement"
        case .nfc:                  return "NFC Judgement"
        case .optical:              return "Optical Judgement"
        case .faceComparison:       return "Face Comparison"
        case .faceLiveness:         return "Face Liveness Detection"
        }
    }
    
    var details: String {
        switch self {
        case .overall:              return ""
        case .nfc:                  return "NFC Authenticators"
        case .optical:              return "Optical Authenticators"
        case .faceComparison:       return "Face Comparison Authenticators"
        case .faceLiveness:         return "Liveness Authenticators"
        }
    }
    
    var authenticatorNames: [String] {
        switch self {
        case .overall:              return []
        case .nfc:                  return ["NFC Passive Authentication", "NFC Active Authentication", "NFC Chip Authentication"]
        case .optical:              return []
        case .faceComparison:       return ["Face Comparison"]
        case .faceLiveness:         return ["Face Liveness"]
        }
    }
}

public struct MobileVerifyFinding {
    let name: MobileVerifyFindingName
    let judgement: MitekPlatformJudgement
    let verifications: [MobileVerifyVerification]
}

public class MobileVerifyResult {
    private var startTime: Date = Date()
    private var response: MobileVerifyResponse?
    private var nfcResult: [String : Any]?
    
    private var licenseClasses: [[String : String]]?
    
    private(set) var roundtripTime: Int = 0
    public var processingTime: Int {
        guard let response = response else { return 0 }
        return response.processingTime
    }
    public var dossierId: String? {
        return response?.dossierMetadata.dossierId
    }
    
    private(set) var overallFinding: MobileVerifyFinding!
    private(set) var nfcFinding: MobileVerifyFinding?
    private(set) var opticalFinding: MobileVerifyFinding?
    private(set) var faceComparisonFinding: MobileVerifyFinding?
    private(set) var faceLivenessFinding: MobileVerifyFinding?
    
    public var bioInfo: [String] {
        var info: [MobileVerifyBioInfo : String] = [:]
        
        if let response = response, let evidence = response.evidence.first(where: { $0.type == "IdDocument" }), let extractedData = evidence.extractedData {
            if let name = extractedData.name {
                if let givenName = name.givenNames {
                    info[.givenName] = givenName
                }
                if let surname = name.surname {
                    info[.surname] = surname
                }
            }
            if let dynamicProperties = extractedData.dynamicProperties {
                if let sex = dynamicProperties.sex {
                    info[.sex] = sex
                }
                if let nationality = dynamicProperties.nationalityCode {
                    info[.nationality] = nationality
                }
                if let personalGovernmentId = dynamicProperties.personalGovID {
                    info[.personalGovId] = personalGovernmentId
                }
            }
            if let dateOfBirth = extractedData.dateOfBirth {
                info[.dateOfBirth] = dateOfBirth
            }
        }
        
        // override Server bio info results with NFC ones
        #if canImport(MiSnapNFC)
        if let nfcResult = nfcResult {
            
            if let personalNumber = nfcResult[MiSnapNFCKey.personalNumber] as? String {
                info[.personalGovId] = personalNumber
            }
            if let givenName = nfcResult[MiSnapNFCKey.givenName] as? String {
                info[.givenName] = givenName
            }
            if let surname = nfcResult[MiSnapNFCKey.surname] as? String {
                info[.surname] = surname
            }
            if let sex = nfcResult[MiSnapNFCKey.sex] as? String {
                info[.sex] = sex
            }
            if let nationality = nfcResult[MiSnapNFCKey.nationality] as? String {
                info[.nationality] = nationality
            }
            if let dateOfBirth = nfcResult[MiSnapNFCKey.dateOfBirth] as? String {
                info[.dateOfBirth] = dateOfBirth
            }
            if let placeOfBirth = nfcResult[MiSnapNFCKey.placeOfBirth] as? String {
                info[.placeOfBirth] = placeOfBirth
            }
        }
        #endif
        
        var array = [String]()
        
        if let givenName = info[.givenName] { array.append("\(MobileVerifyBioInfo.givenName.rawValue):\(givenName)") }
        if let surname = info[.surname] { array.append("\(MobileVerifyBioInfo.surname.rawValue):\(surname)") }
        if let sex = info[.sex] { array.append("\(MobileVerifyBioInfo.sex.rawValue):\(sex)") }
        if let dateOfBirth = info[.dateOfBirth] { array.append("\(MobileVerifyBioInfo.dateOfBirth.rawValue):\(dateOfBirth)") }
        if let placeOfBirth = info[.placeOfBirth] { array.append("\(MobileVerifyBioInfo.placeOfBirth.rawValue):\(placeOfBirth)") }
        if let nationality = info[.nationality] { array.append("\(MobileVerifyBioInfo.nationality.rawValue):\(nationality)") }
        if let personalGovId = info[.personalGovId] { array.append("\(MobileVerifyBioInfo.personalGovId.rawValue):\(personalGovId)") }
        
        return array
    }
    
    public var address: [String] {
        var info: [MobileVerifyAddressInfo : String] = [:]
        
        if let response = response, let evidence = response.evidence.first(where: { $0.type == "IdDocument" }), let extractedData = evidence.extractedData {
            if let address = extractedData.address {
                if let addressLine1 = address.addressLine1 {
                    info[.addressLine1] = addressLine1
                }
                if let city = address.city {
                    info[.city] = city
                }
                if let state = address.stateProvince {
                    info[.state] = state
                }
                if let postalCode = address.postalCode {
                    info[.postalCode] = postalCode
                }
                if let country = address.country {
                    info[.country] = country
                }
            }
        }
        
        // override Server address results with NFC ones
        #if canImport(MiSnapNFC)
        if let nfcResult = nfcResult {
            if let issuingCountry = nfcResult[MiSnapNFCKey.issuingCountry] as? String {
                info[.country] = issuingCountry
            }
            if let nfcAddress = nfcResult[MiSnapNFCKey.address] as? String {
                info[.addressLine1] = nfcAddress
            }
        }
        #endif
        
        var array = [String]()
        if let addressLine1 = info[.addressLine1] { array.append("\(MobileVerifyAddressInfo.addressLine1.rawValue):\(addressLine1)") }
        if let addressLine2 = info[.addressLine2] { array.append("\(MobileVerifyAddressInfo.addressLine2.rawValue):\(addressLine2)") }
        if let city = info[.city] { array.append("\(MobileVerifyAddressInfo.city.rawValue):\(city)") }
        if let state = info[.state] { array.append("\(MobileVerifyAddressInfo.state.rawValue):\(state)") }
        if let postalCode = info[.postalCode] { array.append("\(MobileVerifyAddressInfo.postalCode.rawValue):\(postalCode)") }
        if let country = info[.country] { array.append("\(MobileVerifyAddressInfo.country.rawValue):\(country)") }
        return array
    }
    
    public var documentInfo: [String] {
        var info: [MobileVerifyDocumentInfo : String] = [:]
        
        if let response = response, let evidence = response.evidence.first(where: { $0.type == "IdDocument" }), let extractedData = evidence.extractedData {
            if let documentNumber = extractedData.documentNumber {
                info[.documentNumber] = documentNumber
            }
            if let dateOfIssue = extractedData.dateOfIssue {
                info[.dateOfIssue] = dateOfIssue
            }
            if let dateOfExpiry = extractedData.dateOfExpiry {
                info[.dateOfExpiry] = dateOfExpiry
            }
            if let dynamicProperties = extractedData.dynamicProperties {
                if let licenseClass = dynamicProperties.licenseClass {
                    info[.licenseClass] = licenseClass
                }
                if let issuingCountry = dynamicProperties.issuingCountry {
                    info[.issuingCountry] = issuingCountry
                }
            }
        }
        
        // override Server document info results with NFC ones
        #if canImport(MiSnapNFC)
        if let nfcResult = nfcResult {
            if let documentNumber = nfcResult[MiSnapNFCKey.documentNumber] as? String {
                info[.documentNumber] = documentNumber
            }
            if let documentType = nfcResult[MiSnapNFCKey.documentType] as? String {
                info[.documentType] = documentType
            }
            if let documentTypeCode = nfcResult[MiSnapNFCKey.documentTypeCode] as? String {
                info[.documentTypeCode] = documentTypeCode
            }
            if let issuingCountry = nfcResult[MiSnapNFCKey.issuingCountry] as? String {
                info[.issuingCountry] = issuingCountry
            }
            if let issuingAuthority = nfcResult[MiSnapNFCKey.issuingAuthority] as? String {
                info[.issuingAuthority] = issuingAuthority
            }
            if let dateOfExpiry = nfcResult[MiSnapNFCKey.documentExpiryDate] as? String {
                info[.dateOfExpiry] = dateOfExpiry
            }
            if let issueDate = nfcResult[MiSnapNFCKey.documentIssueDate] as? String {
                info[.dateOfIssue] = issueDate
            }
            if let nfcLicenseClasses = nfcResult[MiSnapNFCKey.licenseClasses] as? [[String : String]] {
                licenseClasses = nfcLicenseClasses
            }
        }
        #endif
        
        var array = [String]()
        if let documentType = info[.documentType] { array.append("\(MobileVerifyDocumentInfo.documentType.rawValue):\(documentType)") }
        if let documentTypeCode = info[.documentTypeCode] { array.append("\(MobileVerifyDocumentInfo.documentTypeCode.rawValue):\(documentTypeCode)") }
        if let documentNumber = info[.documentNumber] { array.append("\(MobileVerifyDocumentInfo.documentNumber.rawValue):\(documentNumber)") }
        if let licenseClasses = licenseClasses {
            array.append("\(MobileVerifyDocumentInfo.licenseClass.rawValue):\(MobileVerifyDocumentInfo.dateOfIssue.rawValue):\(MobileVerifyDocumentInfo.dateOfExpiry.rawValue)")
            for licenseClass in licenseClasses {
                if let licenseClassName = licenseClass[MiSnapNFCKey.licenseClass],
                   let doi = licenseClass[MiSnapNFCKey.licenseClassIssueDate],
                   let doe = licenseClass[MiSnapNFCKey.licenseClassExpiryDate] {
                    array.append("\(licenseClassName):\(doi):\(doe)")
                }
            }
        } else {
            if let dateOfIssue = info[.dateOfIssue] { array.append("\(MobileVerifyDocumentInfo.dateOfIssue.rawValue):\(dateOfIssue)") }
            if let dateOfExpiry = info[.dateOfExpiry] { array.append("\(MobileVerifyDocumentInfo.dateOfExpiry.rawValue):\(dateOfExpiry)") }
            if let licenseClass = info[.licenseClass] { array.append("\(MobileVerifyDocumentInfo.licenseClass.rawValue):\(licenseClass)") }
        }
        if let issuingCountry = info[.issuingCountry] { array.append("\(MobileVerifyDocumentInfo.issuingCountry.rawValue):\(issuingCountry)") }
        if let issuingAuthority = info[.issuingAuthority] { array.append("\(MobileVerifyDocumentInfo.issuingAuthority.rawValue):\(issuingAuthority)") }
        return array
    }
    
    public func parse(_ rawResponse: [AnyHashable : Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: rawResponse) {
            response = try? JSONDecoder().decode(MobileVerifyResponse.self, from: jsonData)
            
            guard let response = response else { return }
            
            let overallJudgment: MitekPlatformJudgement = response.findings.authenticated ? .authentic : .fraudulent
            overallFinding = MobileVerifyFinding(name: .overall, judgement: overallJudgment, verifications: response.findings.verifications)
            
            let nfcVerifications = response.findings.verifications.filter { MobileVerifyFindingName.nfc.authenticatorNames.contains( $0.name ) }
            if !nfcVerifications.isEmpty {
                let nfcJudgement: MitekPlatformJudgement = overallJudgement(from: nfcVerifications)
                nfcFinding = MobileVerifyFinding(name: .nfc, judgement: nfcJudgement, verifications: nfcVerifications)
            }
            
            let faceComparisonVerifications = response.findings.verifications.filter { MobileVerifyFindingName.faceComparison.authenticatorNames.contains( $0.name ) }
            if !faceComparisonVerifications.isEmpty {
                let faceComparisonJudgement: MitekPlatformJudgement = overallJudgement(from: faceComparisonVerifications)
                faceComparisonFinding = MobileVerifyFinding(name: .faceComparison, judgement: faceComparisonJudgement, verifications: faceComparisonVerifications)
            }
            
            let faceLivenessVerifications = response.findings.verifications.filter { MobileVerifyFindingName.faceLiveness.authenticatorNames.contains( $0.name ) }
            if !faceLivenessVerifications.isEmpty {
                let faceLivenessJudgement: MitekPlatformJudgement = overallJudgement(from: faceLivenessVerifications)
                faceLivenessFinding = MobileVerifyFinding(name: .faceLiveness, judgement: faceLivenessJudgement, verifications: faceLivenessVerifications)
            }
            
            let opticalVerifications = response.findings.verifications.filter {
                !(MobileVerifyFindingName.nfc.authenticatorNames.contains( $0.name ) ||
                MobileVerifyFindingName.faceComparison.authenticatorNames.contains( $0.name ) ||
                MobileVerifyFindingName.faceLiveness.authenticatorNames.contains( $0.name ))
            }
            if !opticalVerifications.isEmpty {
                let opticalJudgement: MitekPlatformJudgement = overallJudgement(from: opticalVerifications)
                opticalFinding = MobileVerifyFinding(name: .optical, judgement: opticalJudgement, verifications: opticalVerifications)
            }            
        }
    }
    
     public func update(with nfcResult: [String : Any]) {
        self.nfcResult = nfcResult
    }
    
    public func startTimer() {
        startTime = Date()
    }
    
    public func stopTimer() {
        roundtripTime = Int(Date().timeIntervalSince(startTime) * 1000)
    }
    
    private func overallJudgement(from verifications: [MobileVerifyVerification]) -> MitekPlatformJudgement {
        let judgementsUnique = verifications.map { $0.judgement }.unique()
        
        if judgementsUnique.count == 1 && judgementsUnique.contains(.undetermined) {
            return .undetermined
        } else if judgementsUnique.contains(.fraudulent) {
            return .fraudulent
        }
        return .authentic
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
