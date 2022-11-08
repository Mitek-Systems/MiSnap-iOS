//
//  MobileVerifyRequest.swift
//  MitekRequest
//
//  Created by Mitek Engineering on 6/29/22.
//  Copyright © 2022 Mitek Systems Inc. All rights reserved.
//

// swiftlint:disable function_parameter_count identifier_name line_length

import UIKit

public enum MobileVerifyRequestError: Error {
    case frontEvidenceNotSet
    case frontEvidenceDataNotSet
    case backEvidenceDataNotSet
    case selfieEvidenceNotSet
    case selfieEvidenceDataNotSet
    case selfieVerificationsNotEnabled
    case invalidSelfieVerificationsCombination
    case nfcEvidenceRequiredInputsMissing
    case nfcEvidenceDataGroupsInvalidFormat
    case nfcActiveAuthEvidenceRequiredInputsMissing
    case emptyQrCode
    case emptyPdf417
    
    var description: String {
        switch self {
        case .frontEvidenceNotSet:
            return "Front evidence is required. Call `addFrontEvidence(withData:, qrcode:, customerReferenceId:)`"
        case .frontEvidenceDataNotSet:
            return "Provide a valid base64 encoded image data when `addFrontEvidence(withData:, qrcode:, customerReferenceId:)` is called"
        case .backEvidenceDataNotSet:
            return "Provide a valid base64 encoded image data when `addBackEvidence(withData:, pdf417:, customerReferenceId:)` is called"
        case .selfieEvidenceNotSet:
            return "`addSelfieEvidence(withData:)` should be called when `addVerifications(_:)` is called with `faceComparison` and `faceComparison` or `faceBlocklist`"
        case .selfieEvidenceDataNotSet:
            return "Provide a valid base64 encoded image data when `addSelfieEvidence(withData:)` is called"
        case .selfieVerificationsNotEnabled:
            return "`addSelfieEvidence(withData:)` is called but no face verifications are set.\nRequired verifications:\n\t`faceComparison`\nOptional:\n\t`faceLiveness`,\n\t`faceBlocklist`"
        case .invalidSelfieVerificationsCombination:
            return "`faceLiveness` was added to a list of verifications without a required `faceComparison`"
        case .nfcEvidenceRequiredInputsMissing:
            return "All of the following properties [`sod`, `com`, `dataFormat`, `dataGroups`, `portrait`, `chipAuthOutput`] should be set with valid non-empty values when `addNfcEvidence(withSod:, com:, dataFormat:, dataGroups:, portrait:, chipAuthOutput:, activeAuthInput:)` is called"
        case .nfcEvidenceDataGroupsInvalidFormat:
            return "`dataGroups` dicitonary of NFC evidence is not a correct format.\nExpected format:\n\tKey: dg<number> (e.g. `dg1`, `dg14`)\n\tValue: an empty or valid hex string"
        case .nfcActiveAuthEvidenceRequiredInputsMissing:
            return "When optional `activeAuthInput` of NFC evidence is set then all of its properties [`ecdsaPublicKey`, `signature`, `challenge`] should be set"
        case .emptyQrCode:
            return "When optional parameter `qrcode` is set in `addFrontEvidence(withData:, qrcode:, customerReferenceId:)` it should be a valid non-empty string"
        case .emptyPdf417:
            return "When optional parameter `pdf417` is set in `addBackEvidence(withData:, pdf417:, customerReferenceId:)` it should be a valid non-empty string"
        }
    }
}

public enum MobileVerifyRequestNfcDataFormat: String, Equatable {
    case unknown
    case icao
    case dl

    var stringValue: String {
        switch self {
        case .unknown:  return "unknown"
        case .icao:     return "icao_9303"
        case .dl:       return "eu_edl"
        }
    }
    
    public static func from(_ string: String) -> MobileVerifyRequestNfcDataFormat {
        switch string {
        case "icao_9303":   return .icao
        case "eu_edl":      return .dl
        default:            return .unknown
        }
    }
}

public enum MobileVerifyRequestResponseImageType: String, Equatable {
    case croppedPortrait
    case croppedSignature
    case croppedDocument

    var stringValue: String {
        switch self {
        case .croppedPortrait:      return "CroppedPortrait"
        case .croppedSignature:     return "CroppedSignature"
        case .croppedDocument:      return "CroppedDocument"
        }
    }
}

public enum MobileVerifyRequestVerification: String, Equatable {
    case faceComparison
    case faceLiveness
    case faceBlocklist
    case dataSignalAAMVA
    
    var stringValue: String {
        switch self {
        case .faceComparison:   return "faceComparison"
        case .faceLiveness:     return "faceLiveness"
        case .faceBlocklist:    return "faceBlocklist"
        case .dataSignalAAMVA:  return "dataSignalAAMVA"
        }
    }
}

private class MobileVerifyRequestDossierMetadata: NSObject {
    var customerReferenceId: String = ""
}

private class MobileVerifyRequestEvidenceIdDocumentFront: NSObject {
    var data: String = ""
    var customerReferenceId: String?
    var qrCode: String?
}

private class MobileVerifyRequestEvidenceIdDocumentBack: NSObject {
    var data: String = ""
    var customerReferenceId: String?
    var pdf417: String?
}

private class MobileVerifyRequestEvidenceIdDocumentNfc: NSObject {
    var sod: String = ""
    var com: String = ""
    var dataFormat: MobileVerifyRequestNfcDataFormat = .unknown
    var dataGroups: [String : String] = [:]
    var portrait: String = ""
    var chipAuthOutput: String = ""
    var activeAuthInput: [String : Any]?
    
    internal static func from(_ nfcRequestDictionary: [String : Any]) -> MobileVerifyRequestEvidenceIdDocumentNfc {
        let nfcEvidence = MobileVerifyRequestEvidenceIdDocumentNfc()
        
        if let sod = nfcRequestDictionary["sod"] as? String {
            nfcEvidence.sod = sod
        }
        if let com = nfcRequestDictionary["com"] as? String {
            nfcEvidence.com = com
        }
        if let dataFormatString = nfcRequestDictionary["dataFormat"] as? String {
            nfcEvidence.dataFormat = MobileVerifyRequestNfcDataFormat.from(dataFormatString)
        }
        if let dataGroups = nfcRequestDictionary["dataGroups"] as? [String : String] {
            nfcEvidence.dataGroups = dataGroups
        }
        if let activeAuthInput = nfcRequestDictionary["activeAuthInput"] as? [String : String] {
            nfcEvidence.activeAuthInput = activeAuthInput
        }
        if let chipAuthOutput = nfcRequestDictionary["chipAuthOutput"] as? String {
            nfcEvidence.chipAuthOutput = chipAuthOutput
        }
        if let portrait = nfcRequestDictionary["portrait"] as? String {
            nfcEvidence.portrait = portrait
        }
        
        return nfcEvidence
    }
}

public class MobileVerifyRequestEvidenceBiometricSelfie: NSObject {
    var data: String = ""
}

public class MobileVerifyRequest: NSObject {
    private var dossierMetadata = MobileVerifyRequestDossierMetadata()
    private var frontEvidence = MobileVerifyRequestEvidenceIdDocumentFront()
    private var backEvidence = MobileVerifyRequestEvidenceIdDocumentBack()
    private var nfcEvidence = MobileVerifyRequestEvidenceIdDocumentNfc()
    private var selfieEvidence = MobileVerifyRequestEvidenceBiometricSelfie()
    private var verifications: [MobileVerifyRequestVerification] = []
    private var responseImages: [MobileVerifyRequestResponseImageType] = []

    private var dossierMetadataSet: Bool = false
    private var frontEvidenceSet: Bool = false
    private var backEvidenceSet: Bool = false
    private var nfcEvidenceSet: Bool = false
    private var selfieEvidenceSet: Bool = false
    private var verificationsSet: Bool = false

    override init() {
        super.init()
    }
    
    public func addDossierMetadata(withCustomerReferenceId customerReferenceId: String) {
        dossierMetadataSet = true
        dossierMetadata.customerReferenceId = customerReferenceId
    }
    
    public func addFrontEvidence(withData data: String, qrCode: String? = nil, customerReferenceId: String? = nil) {
        frontEvidenceSet = true
        frontEvidence.data = data
        frontEvidence.customerReferenceId = customerReferenceId
        frontEvidence.qrCode = qrCode
    }
    
    public func addBackEvidence(withData data: String, pdf417: String? = nil, customerReferenceId: String? = nil) {
        backEvidenceSet = true
        backEvidence.data = data
        backEvidence.customerReferenceId = customerReferenceId
        backEvidence.pdf417 = pdf417
    }
    
    public func addNfcEvidence(withSod sod: String,
                               com: String,
                               dataFormat: MobileVerifyRequestNfcDataFormat,
                               dataGroups: [String : String],
                               portrait: String,
                               chipAuthOutput: String,
                               activeAuthInput: [String : Any]? = nil) {
        nfcEvidenceSet = true
        nfcEvidence.sod = sod
        nfcEvidence.com = com
        nfcEvidence.dataFormat = dataFormat
        nfcEvidence.dataGroups = dataGroups
        nfcEvidence.portrait = portrait
        nfcEvidence.chipAuthOutput = chipAuthOutput
        nfcEvidence.activeAuthInput = activeAuthInput
    }
    
    public func addNfcEvidence(from nfcRequestDictionary: [String : Any]) {
        nfcEvidenceSet = true
        nfcEvidence = MobileVerifyRequestEvidenceIdDocumentNfc.from(nfcRequestDictionary)
    }
    
    public func addSelfieEvidence(withData data: String) {
        selfieEvidenceSet = true
        selfieEvidence.data = data
    }
    
    public func addVerifications(_ verifications: [MobileVerifyRequestVerification]) {
        verificationsSet = true
        for verification in verifications {
            if !self.verifications.contains(verification) {
                self.verifications.append(verification)
            }
        }
    }
    
    public func addResponseImages(_ responseImages: [MobileVerifyRequestResponseImageType]) {
        for responseImage in responseImages {
            if !self.responseImages.contains(responseImage) {
                self.responseImages.append(responseImage)
            }
        }
    }
    
    public var errors: [MobileVerifyRequestError]? {
        var errors: [MobileVerifyRequestError] = []
        if frontEvidenceSet {
            if frontEvidence.data.isEmpty {
                errors.append(.frontEvidenceDataNotSet)
            }
            if let qrCode = frontEvidence.qrCode, qrCode.isEmpty {
                errors.append(.emptyQrCode)
            }
        } else {
            errors.append(.frontEvidenceNotSet)
        }
        
        if backEvidenceSet {
            if backEvidence.data.isEmpty {
                errors.append(.backEvidenceDataNotSet)
            }
            if let pdf417 = backEvidence.pdf417, pdf417.isEmpty {
                errors.append(.emptyPdf417)
            }
        }
        
        if selfieEvidenceSet {
            if selfieEvidence.data.isEmpty {
                errors.append(.selfieEvidenceDataNotSet)
            }
            if !verifications.contains(.faceComparison) {
                errors.append(.selfieVerificationsNotEnabled)
            }
            if verifications.contains(.faceLiveness) && !verifications.contains(.faceComparison) {
                errors.append(.invalidSelfieVerificationsCombination)
            }
        } else {
            if verifications.contains(.faceComparison) || verifications.contains(.faceLiveness) || verifications.contains(.faceBlocklist) {
                errors.append(.selfieEvidenceNotSet)
            }
        }
        
        if nfcEvidenceSet {
            if nfcEvidence.sod.isEmpty || nfcEvidence.com.isEmpty || nfcEvidence.dataFormat == .unknown || nfcEvidence.dataGroups.isEmpty || nfcEvidence.portrait.isEmpty || nfcEvidence.chipAuthOutput.isEmpty {
                errors.append(.nfcEvidenceRequiredInputsMissing)
            }
            if !nfcEvidence.dataGroups.isEmpty {
                for (k, _) in nfcEvidence.dataGroups {
                    if !k.starts(with: "dg") {
                        errors.append(.nfcEvidenceDataGroupsInvalidFormat)
                        break
                    }
                }
            }
            if let activeAuthInput = nfcEvidence.activeAuthInput, activeAuthInput.count != 3 {
                errors.append(.nfcActiveAuthEvidenceRequiredInputsMissing)
            }
        }
        if errors.isEmpty {
            return nil
        }
        return errors
    }
    
    public var dictionary: [String : Any]? {
        if let _ = errors { return nil }
        var dictionary: [String : Any] = [:]
        
        if !dossierMetadata.customerReferenceId.isEmpty {
            dictionary["dossierMetadata"] = ["customerReferenceId" : dossierMetadata.customerReferenceId]
        }
        
        var evidence: [[String : Any]] = []
        
        var idDocumentDictionary: [String : Any] = ["type": "IdDocument"]
        
        var images: [[String : Any]] = []
        
        if frontEvidenceSet {
            var frontDictionary: [String : Any] = ["data" : frontEvidence.data]
            if let customerReferenceId = frontEvidence.customerReferenceId {
                frontDictionary["customerReferenceId"] = customerReferenceId
            }
            if let qrCode = frontEvidence.qrCode {
                frontDictionary["encodedData"] = ["qrcode" : qrCode]
            }
            images.append(frontDictionary)
        }
        
        if backEvidenceSet {
            var backDictionary: [String : Any] = ["data" : backEvidence.data]
            if let customerReferenceId = backEvidence.customerReferenceId {
                backDictionary["customerReferenceId"] = customerReferenceId
            }
            if let pdf417 = backEvidence.pdf417 {
                backDictionary["encodedData"] = ["pdf417" : pdf417]
            }
            images.append(backDictionary)
        }
        
        if !images.isEmpty {
            idDocumentDictionary["images"] = images
        }
        
        if nfcEvidenceSet {
            var nfcDictionary: [String : Any] = [
                "sod" : nfcEvidence.sod,
                "com" : nfcEvidence.com,
                "dataFormat" : nfcEvidence.dataFormat.stringValue,
                "dataGroups" : nfcEvidence.dataGroups,
                "portrait" : nfcEvidence.portrait,
                "chipAuthOutput" : nfcEvidence.chipAuthOutput
            ]
            
            if let activeAuthInput = nfcEvidence.activeAuthInput {
                nfcDictionary["activeAuthInput"] = activeAuthInput
            }
            
            idDocumentDictionary["nfc"] = nfcDictionary
        }
        
        evidence.append(idDocumentDictionary)
        
        if selfieEvidenceSet {
            let selfieDictionary: [String : String] = [
                "type" : "Biometric",
                "biometricType" : "Selfie",
                "data" : selfieEvidence.data
            ]
            
            evidence.append(selfieDictionary)
        }
        
        if !evidence.isEmpty {
            dictionary["evidence"] = evidence
        }
        
        var configurationDictionary: [String : Any] = [:]
        
        if !verifications.isEmpty {
            var verificationsDictionary: [String : Bool] = [:]
            for verification in verifications {
                verificationsDictionary[verification.stringValue] = true
            }
            configurationDictionary["verifications"] = verificationsDictionary
        }
        
        configurationDictionary["responseImages"] = responseImages.map { $0.stringValue }
        
        dictionary["configuration"] = configurationDictionary
        
        return dictionary
    }
}
