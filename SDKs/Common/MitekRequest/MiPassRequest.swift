//
//  MiPassRequest.swift
//  MitekRequest
//
//  Created by Mitek Engineering on 9/9/22.
//

import UIKit

public enum MobileVerifyMiPassRequestError: Error {
    case notEnoughVoiceFeaturesForEnrollment
    case tooManyVoiceFeaturesForVerification
    case enrollmentIdNotSetForVerification
    case requiredDataNotSetForEnrollment
    case requiredDataNotSetForVerification
    
    var description: String {
        switch self {
        case .notEnoughVoiceFeaturesForEnrollment:
            return "Three voice samples are required for enrollment. Call `addVoiceFeatures(_ :)` and pass an array with 3 voice features"
        case .tooManyVoiceFeaturesForVerification:
            return "Only one voice sample is required for verification. Call `addVoiceFeature(_ :)` instead of `addVoiceFeatures(_ :)`"
        case .enrollmentIdNotSetForVerification:
            return "Enrollment ID is required for verification. Call `addEnrollmentId(_ :)`"
        case .requiredDataNotSetForEnrollment:
            return "At least one of [`voiceFeatures`, `selfieImage`] has to be set for enrollment. Call `addVoiceFeatures(_ :)` and/or `addSelfieImage(_ :)`"
        case .requiredDataNotSetForVerification:
            return "At least one of [`voiceFeature`, `selfieImage`] has to be set for verification. Call `addVoiceFeature(_ :)` and/or `addSelfieImage(_ :)`"
        }
    }
}

public enum MobileVerifyMiPassFlow: String {
    case enrollment
    case verification
}

class MiPassRequest: NSObject {
    private let flow: MobileVerifyMiPassFlow
    private(set) var customerReferenceId: String = ""
    private(set) var enrollmentId: String = ""
    private(set) var voiceSamples: [Data] = []
    private(set) var selfieImageEncoded: String = ""
    
    public init(for flow: MobileVerifyMiPassFlow) {
        self.flow = flow
        super.init()
    }
    
    public func addCustomerReferenceId(_ customerReferenceId: String) {
        self.customerReferenceId = customerReferenceId
    }
    
    public func addEnrollmentId(_ enrollmentId: String) {
        self.enrollmentId = enrollmentId
    }
    
    public func addVoiceFeature(_ voiceSample: Data) {
        self.voiceSamples = [voiceSample]
    }
    
    public func addVoiceFeatures(_ voiceSamples: [Data]) {
        self.voiceSamples = voiceSamples
    }
    
    public func addEncodedSelfieImage(_ selfieImageEncoded: String) {
        self.selfieImageEncoded = selfieImageEncoded
    }
    
    public var errors: [MobileVerifyMiPassRequestError]? {
        var errors: [MobileVerifyMiPassRequestError] = []
        switch flow {
        case .enrollment:
            if !voiceSamples.isEmpty && voiceSamples.count != 3 {
                errors.append(.notEnoughVoiceFeaturesForEnrollment)
            }
            if voiceSamples.isEmpty && selfieImageEncoded.isEmpty {
                errors.append(.requiredDataNotSetForEnrollment)
            }
        case .verification:
            if enrollmentId.isEmpty {
                errors.append(.enrollmentIdNotSetForVerification)
            }
            if !voiceSamples.isEmpty && voiceSamples.count > 1 {
                errors.append(.tooManyVoiceFeaturesForVerification)
            }
            if voiceSamples.isEmpty && selfieImageEncoded.isEmpty {
                errors.append(.requiredDataNotSetForVerification)
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
        
        if !customerReferenceId.isEmpty {
            dictionary["customerReferenceId"] = customerReferenceId
        }
        
        if !enrollmentId.isEmpty {
            dictionary["enrollmentId"] = enrollmentId
        }
        
        switch flow {
        case .enrollment:
            if !voiceSamples.isEmpty {
                dictionary["voiceFeatures"] = voiceSamples.map { ["data" : $0.base64EncodedString()] }
            }
            if !selfieImageEncoded.isEmpty {
                dictionary["selfieImages"] = [["data": selfieImageEncoded]]
            }
        case .verification:
            if !voiceSamples.isEmpty {
                dictionary["voiceFeature"] = ["data" : voiceSamples[0].base64EncodedString()]
            }
            if !selfieImageEncoded.isEmpty {
                dictionary["selfieImage"] = ["data": selfieImageEncoded]
            }
        }
        
        return dictionary
    }
}
