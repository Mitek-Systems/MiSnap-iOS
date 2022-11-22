//
//  MiPassResult.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 1/25/22.
//

import UIKit

enum MitekPlatformJudgement: String, Equatable, Decodable {
    case authentic = "Authentic"
    case fraudulent = "Fraudulent"
    case undetermined = "Undetermined"
    case enrolled = "Enrolled"
    case updated = "Updated"
    case successful = "Successful"
    case failed = "Failed"
    
    var stringValue: String {
        return self.rawValue.capitalized
    }
    
    var image: UIImage {
        switch self {
        case .authentic, .enrolled, .updated, .successful: return #imageLiteral(resourceName: "checkmark")
        case .fraudulent, .failed: return #imageLiteral(resourceName: "crossmark")
        case .undetermined: return #imageLiteral(resourceName: "na")
        }
    }
}

public struct MiPassVoiceProcessing: Decodable {
    let status: MitekPlatformJudgement
    let reasons: [String]?
}

public struct MiPassFaceProcessing: Decodable {
    let status: MitekPlatformJudgement
    let reasons: [String]?
}

public struct MiPassEnrollmentDetails: Decodable {
    let voiceProcessing: MiPassVoiceProcessing?
    let faceProcessing: MiPassFaceProcessing?
}

public struct MiPassVerificationDetails: Decodable {
    let voiceVerify: MiPassVoiceProcessing?
    let faceVerify: MiPassFaceProcessing?
}

public struct MiPassEnrollmentResponse: Decodable {
    let processingTime: Int
    let requestId: String
    let enrollmentId: String?
    let enrollmentStatus: MitekPlatformJudgement
    let details: MiPassEnrollmentDetails
}

public struct MiPassVerificationResponse: Decodable {
    let processingTime: Int
    let requestId: String
    let enrollmentId: String
    let verificationStatus: MitekPlatformJudgement
    let details: MiPassVerificationDetails
}

public class MiPassResult {
    private var startTime: Date = Date()
    private var enrollmentResponse: MiPassEnrollmentResponse?
    private var verificationResponse: MiPassVerificationResponse?
    private(set) var roundtripTime: Int = 0
    public var processingTime: Int {
        if let response = enrollmentResponse {
            return response.processingTime
        } else if let response = verificationResponse {
            return response.processingTime
        }
        return 0
    }
    public var requestId: String? {
        if let response = enrollmentResponse {
            return response.requestId
        } else if let response = verificationResponse {
            return response.requestId
        }
        return nil
    }
    
    public var enrollmentId: String? {
        if let response = enrollmentResponse {
            return response.enrollmentId
        } else if let response = verificationResponse {
            return response.enrollmentId
        }
        return nil
    }
    
    private(set) var judgement: MitekPlatformJudgement = .undetermined
    private(set) var voiceJudgement: MitekPlatformJudgement?
    private(set) var faceJudgement: MitekPlatformJudgement?
    
    private(set) var voiceErrors: [String]?
    private(set) var faceErrors: [String]?
    
    private(set) var voiceEnrolled: Bool = false
    private(set) var faceEnrolled: Bool = false
    
    public func parse(_ rawResponse: [AnyHashable : Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rawResponse) else { return }
        enrollmentResponse = try? JSONDecoder().decode(MiPassEnrollmentResponse.self, from: jsonData)
        verificationResponse = try? JSONDecoder().decode(MiPassVerificationResponse.self, from: jsonData)
        
        if let response = enrollmentResponse {
            judgement = response.enrollmentStatus
            
            if let voiceResult = response.details.voiceProcessing {
                voiceJudgement = voiceResult.status
                voiceErrors = voiceResult.reasons
                if voiceJudgement != .undetermined && voiceJudgement != .fraudulent && voiceJudgement != .failed {
                    voiceEnrolled = true
                }
            }
            
            if let faceResult = response.details.faceProcessing {
                faceJudgement = faceResult.status
                faceErrors = faceResult.reasons
                if faceJudgement != .undetermined && faceJudgement != .fraudulent && faceJudgement != .failed {
                    faceEnrolled = true
                }
            }
        } else if let response = verificationResponse {
            judgement = response.verificationStatus
            
            if let voiceResult = response.details.voiceVerify {
                voiceJudgement = voiceResult.status
                voiceErrors = voiceResult.reasons
                if voiceJudgement != .undetermined && voiceJudgement != .fraudulent && voiceJudgement != .failed {
                    voiceEnrolled = true
                }
            }
            
            if let faceResult = response.details.faceVerify {
                faceJudgement = faceResult.status
                faceErrors = faceResult.reasons
                if faceJudgement != .undetermined && faceJudgement != .fraudulent && faceJudgement != .failed {
                    faceEnrolled = true
                }
            }
        }
    }
    
    public func startTimer() {
        startTime = Date()
    }
    
    public func stopTimer() {
        roundtripTime = Int(Date().timeIntervalSince(startTime) * 1000)
    }
}
