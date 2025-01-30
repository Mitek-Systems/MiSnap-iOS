//
//  MobileVerifyRequest.swift
//  MitekRequest
//
//  Created by Stas Tsuprenko on 6/29/22.
//  Copyright © 2022 Mitek Systems Inc. All rights reserved.
//

// swiftlint:disable function_parameter_count identifier_name line_length

import UIKit

/**
 MobileVerify request error
 */
public enum MobileVerifyRequestError: Error {
    /**
     Front evidence is not set
     */
    case frontEvidenceNotSet
    /**
     Front evidence data is not set
     */
    case frontEvidenceDataNotSet
    /**
     Back evidence data is not set
     */
    case backEvidenceDataNotSet
    /**
     Selfie evidence is not set
     */
    case selfieEvidenceNotSet
    /**
     Selfie evidence data is not set
     */
    case selfieEvidenceDataNotSet
    /**
     Selfie verifications are not enabled
     */
    case selfieVerificationsNotEnabled
    /**
     Invalid selfie verifications combination
     */
    case invalidSelfieVerificationsCombination
    /**
     Required inputs for NFC evidence are missing
     */
    case nfcEvidenceRequiredInputsMissing
    /**
     Invalid format for data group in NFC evidence
     */
    case nfcEvidenceDataGroupsInvalidFormat
    /**
     Required inputs for Active Authentication are missing in NFC evidence
     */
    case nfcActiveAuthEvidenceRequiredInputsMissing
    /**
     Empty QR code
     */
    case emptyQrCode
    /**
     Empty PDF417
     */
    case emptyPdf417
    /**
     Empty RTS
     */
    case emptyRts
    /**
     Empty AI based RTS
     */
    case emptyAiBasedRts
    /**
     Description
     */
    var description: String {
        switch self {
        case .frontEvidenceNotSet:
            return "Front evidence is required. Call `addFrontEvidence(withData:, qrcode:, customerReferenceId:)`"
        case .frontEvidenceDataNotSet:
            return "Provide a valid base64 encoded image data when `addFrontEvidence(withData:, qrcode:, rts:, customerReferenceId:)` is called"
        case .backEvidenceDataNotSet:
            return "Provide a valid base64 encoded image data when `addBackEvidence(withData:, pdf417:, rts:, customerReferenceId:)` is called"
        case .selfieEvidenceNotSet:
            return "`addSelfieEvidence(withData:)` should be called when `addVerifications(_:)` is called with `faceComparison` and `faceComparison` or `faceBlocklist`"
        case .selfieEvidenceDataNotSet:
            return "Provide a valid base64 encoded image data when `addSelfieEvidence(withData:)` is called"
        case .selfieVerificationsNotEnabled:
            return "`addSelfieEvidence(withData:)` is called but no face verifications are set.\nRequired verifications:\n\t`faceComparison`\nOptional:\n\t`faceLiveness`,\n\t`faceBlocklist`"
        case .invalidSelfieVerificationsCombination:
            return "`faceLiveness` was added to a list of verifications without a required `faceComparison`"
        case .nfcEvidenceRequiredInputsMissing:
            return "All of the following properties [`sod`, `com`, `dataFormat`, `dataGroups`, `chipAuthOutput`] should be set with valid non-empty values when `addNfcEvidence(withSod:, com:, dataFormat:, dataGroups:, portrait:, mibi:, chipAuthOutput:, activeAuthInput:)` is called"
        case .nfcEvidenceDataGroupsInvalidFormat:
            return "`dataGroups` dicitonary of NFC evidence is not a correct format.\nExpected format:\n\tKey: dg<number> (e.g. `dg1`, `dg14`)\n\tValue: an empty or valid hex string"
        case .nfcActiveAuthEvidenceRequiredInputsMissing:
            return "When optional `activeAuthInput` of NFC evidence is set then all of its properties [`ecdsaPublicKey`, `signature`, `challenge`] should be set"
        case .emptyQrCode:
            return "When optional parameter `qrcode` is set in `addFrontEvidence(withData:, qrcode:, rts:, customerReferenceId:)` it should be a valid non-empty string"
        case .emptyPdf417:
            return "When optional parameter `pdf417` is set in `addBackEvidence(withData:, pdf417:, rts:, customerReferenceId:)` it should be a valid non-empty string"
        case .emptyRts:
            return "When optional parameter `rts` is set it should be a valid non-empty string"
        case .emptyAiBasedRts:
            return "When optional parameter `aiBasedRts` is set it should be a valid non-empty string"
        }
    }
}
/**
 MobileVerify NFC data format
 */
public enum MobileVerifyRequestNfcDataFormat: String, Equatable {
    /**
     NFC data format is not set
     */
    case unknown
    /**
     ICAO
     */
    case icao
    /**
     eDL
     */
    case dl
    /**
     String value
     */
    var stringValue: String {
        switch self {
        case .unknown:  return "unknown"
        case .icao:     return "icao_9303"
        case .dl:       return "eu_edl"
        }
    }
    /**
     NFC data format from String
     */
    public static func from(_ string: String) -> MobileVerifyRequestNfcDataFormat {
        switch string {
        case "icao_9303":   return .icao
        case "eu_edl":      return .dl
        default:            return .unknown
        }
    }
}
/**
 MobileVerify response image type
 */
public enum MobileVerifyRequestResponseImageType: String, Equatable {
    /**
     Cropped portrait
     */
    case croppedPortrait
    /**
     Cropped signature
     */
    case croppedSignature
    /**
     Cropped document
     */
    case croppedDocument
    /**
     String value
     */
    var stringValue: String {
        switch self {
        case .croppedPortrait:      return "CroppedPortrait"
        case .croppedSignature:     return "CroppedSignature"
        case .croppedDocument:      return "CroppedDocument"
        }
    }
}
/**
 MobileVerify verificiation
 */
public enum MobileVerifyRequestVerification: String, Equatable {
    /**
     Face comparison
     */
    case faceComparison
    /**
     Face liveness
     */
    case faceLiveness
    /**
     Face blocklist
     */
    case faceBlocklist
    /**
     Face velocity
     */
    case faceVelocity
    /**
     Data signal AAMVA
     */
    case dataSignalAAMVA
    /**
     Injection attack detection
     */
    case injectionAttackDetection
    /**
     Injection attack detection AI
     */
    case injectionAttackDetectionAI
    /**
     Template attack detection
     */
    case templateAttackDetection
    /**
     String value
     */
    var stringValue: String {
        switch self {
        case .faceComparison:               return "faceComparison"
        case .faceLiveness:                 return "faceLiveness"
        case .faceBlocklist:                return "faceBlocklist"
        case .faceVelocity:                 return "faceVelocity"
        case .dataSignalAAMVA:              return "dataSignalAAMVA"
        case .injectionAttackDetection:     return "injectionAttackDetection"
        case .injectionAttackDetectionAI:   return "injectionAttackDetectionAI"
        case .templateAttackDetection:      return "templateAttackDetection"
        }
    }
}

private class MobileVerifyRequestDossierMetadata: NSObject {
    var customerReferenceId: String = ""
}

private class MobileVerifyRequestEvidenceIdDocumentFront: NSObject {
    var data: String = ""
    var rts: String?
    var customerReferenceId: String?
    var qrCode: String?
}

private class MobileVerifyRequestEvidenceIdDocumentBack: NSObject {
    var data: String = ""
    var rts: String?
    var customerReferenceId: String?
    var pdf417: String?
}

private class MobileVerifyRequestEvidenceIdDocumentNfc: NSObject {
    var sod: String = ""
    var com: String = ""
    var dataFormat: MobileVerifyRequestNfcDataFormat = .unknown
    var dataGroups: [String : String] = [:]
    var portrait: String?
    var mibi: String?
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
        if let mibi = nfcRequestDictionary["mibi"] as? String {
            nfcEvidence.mibi = mibi
        }
        
        return nfcEvidence
    }
}
/**
 MobileVerify Selfie biometric evidence
 */
public class MobileVerifyRequestEvidenceBiometricSelfie: NSObject {
    var data: String = ""
    var rts: String?
    var aiBasedRts: String?
}
/**
 MobileVerify request
 */
public class MobileVerifyAutoAuthenticationRequest: NSObject {
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

    /**
     Default initializer
     */
    override init() {
        super.init()
    }
    /**
     Adds optional dossier metadata
     */
    public func addDossierMetadata(withCustomerReferenceId customerReferenceId: String) {
        dossierMetadataSet = true
        dossierMetadata.customerReferenceId = customerReferenceId
    }
    /**
     Adds front evidence
     */
    public func addFrontEvidence(withData data: String, qrCode: String? = nil, rts: String? = nil, customerReferenceId: String? = nil) {
        frontEvidenceSet = true
        frontEvidence.data = data
        frontEvidence.rts = rts
        #if !DEBUG
        if let rts = rts, !rts.isEmpty {
            addVerifications([.injectionAttackDetection])
        }
        #endif
        frontEvidence.customerReferenceId = customerReferenceId
        frontEvidence.qrCode = qrCode
    }
    /**
     Adds back evidence
     */
    public func addBackEvidence(withData data: String, pdf417: String? = nil, rts: String? = nil, customerReferenceId: String? = nil) {
        backEvidenceSet = true
        backEvidence.data = data
        backEvidence.rts = rts
        #if !DEBUG
        if let rts = rts, !rts.isEmpty {
            addVerifications([.injectionAttackDetection])
        }
        #endif
        backEvidence.customerReferenceId = customerReferenceId
        backEvidence.pdf417 = pdf417
    }
    /**
     Adds NFC evidence from individual properties (pre-5.x)
     */
    public func addNfcEvidence(withSod sod: String,
                               com: String,
                               dataFormat: MobileVerifyRequestNfcDataFormat,
                               dataGroups: [String : String],
                               portrait: String? = nil,
                               mibi: String? = nil,
                               chipAuthOutput: String,
                               activeAuthInput: [String : Any]? = nil) {
        nfcEvidenceSet = true
        nfcEvidence.sod = sod
        nfcEvidence.com = com
        nfcEvidence.dataFormat = dataFormat
        nfcEvidence.dataGroups = dataGroups
        nfcEvidence.portrait = portrait
        nfcEvidence.mibi = mibi
        nfcEvidence.chipAuthOutput = chipAuthOutput
        nfcEvidence.activeAuthInput = activeAuthInput
    }
    /**
     Adds NFC evidence from NFC request dictionary (5.x and onward)
     */
    public func addNfcEvidence(from nfcRequestDictionary: [String : Any]) {
        nfcEvidenceSet = true
        nfcEvidence = MobileVerifyRequestEvidenceIdDocumentNfc.from(nfcRequestDictionary)
    }
    /**
     Adds selfie evidence
     */
    public func addSelfieEvidence(withData data: String, rts: String? = nil, aiBasedRts: String? = nil) {
        selfieEvidenceSet = true
        selfieEvidence.data = data
        selfieEvidence.rts = rts
        #if !DEBUG
        if let rts = rts, !rts.isEmpty {
            addVerifications([.injectionAttackDetection])
        }
        #endif
        selfieEvidence.aiBasedRts = aiBasedRts
        if let aiBasedRts = aiBasedRts, !aiBasedRts.isEmpty {
            addVerifications([.injectionAttackDetectionAI])
        }
    }
    /**
     Adds verifications
     */
    public func addVerifications(_ verifications: [MobileVerifyRequestVerification]) {
        verificationsSet = true
        for verification in verifications where !self.verifications.contains(verification) {
            self.verifications.append(verification)
        }
    }
    /**
     Adds response images
     */
    public func addResponseImages(_ responseImages: [MobileVerifyRequestResponseImageType]) {
        for responseImage in responseImages where !self.responseImages.contains(responseImage) {
            self.responseImages.append(responseImage)
        }
    }
    /**
     Errors in the request
     */
    public var errors: [MobileVerifyRequestError]? {
        var errors: [MobileVerifyRequestError] = []
        if frontEvidenceSet {
            if frontEvidence.data.isEmpty {
                errors.append(.frontEvidenceDataNotSet)
            }
            if let qrCode = frontEvidence.qrCode, qrCode.isEmpty {
                errors.append(.emptyQrCode)
            }
            if let rts = frontEvidence.rts, rts.isEmpty {
                errors.append(.emptyRts)
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
            if let rts = backEvidence.rts, rts.isEmpty {
                errors.append(.emptyRts)
            }
        }
        
        if selfieEvidenceSet {
            if selfieEvidence.data.isEmpty {
                errors.append(.selfieEvidenceDataNotSet)
            }
            if let rts = selfieEvidence.rts, rts.isEmpty {
                errors.append(.emptyRts)
            }
            if let aiBasedRts = selfieEvidence.aiBasedRts, aiBasedRts.isEmpty {
                errors.append(.emptyAiBasedRts)
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
            if nfcEvidence.sod.isEmpty || nfcEvidence.com.isEmpty || nfcEvidence.dataFormat == .unknown || nfcEvidence.dataGroups.isEmpty || nfcEvidence.chipAuthOutput.isEmpty {
                errors.append(.nfcEvidenceRequiredInputsMissing)
            }
            if !nfcEvidence.dataGroups.isEmpty {
                for (k, _) in nfcEvidence.dataGroups where !k.starts(with: "dg") {
                    errors.append(.nfcEvidenceDataGroupsInvalidFormat)
                    break
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
    /**
     MobileVerify request dictionary that can be serialized to JSON data for URLRequest httpBody
     */
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
            if let rts = frontEvidence.rts {
                frontDictionary["encryptedPayload"] = rts
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
            if let rts = backEvidence.rts {
                backDictionary["encryptedPayload"] = rts
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
                "chipAuthOutput" : nfcEvidence.chipAuthOutput
            ]
            
            if let portrait = nfcEvidence.portrait {
                nfcDictionary["portrait"] = portrait
            }
            
            if let mibi = nfcEvidence.mibi {
                nfcDictionary["mibi"] = mibi
            }
            
            if let activeAuthInput = nfcEvidence.activeAuthInput {
                nfcDictionary["activeAuthInput"] = activeAuthInput
            }
            
            idDocumentDictionary["nfc"] = nfcDictionary
        }
        
        evidence.append(idDocumentDictionary)
        
        if selfieEvidenceSet {
            var selfieDictionary: [String : String] = [
                "type" : "Biometric",
                "biometricType" : "Selfie",
            ]
            if let aiBasedRts = selfieEvidence.aiBasedRts {
                selfieDictionary["data"] = aiBasedRts
            } else {
                selfieDictionary["data"] = selfieEvidence.data
            }
            if let rts = selfieEvidence.rts {
                selfieDictionary["encryptedPayload"] = rts
            }
            
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

// swiftlint:enable function_parameter_count identifier_name line_length
