//
//  MiPassEnrollmentInput.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 1/25/22.
//

import UIKit

public enum MiPassEnrollmentStatus: Int {
    case notEnrolled
    case faceAndVoice
    case faceOnly
    case voiceOnly
    
    var stringValue: String {
        switch self {
        case .notEnrolled:      return "Not Enrolled"
        case .faceAndVoice:     return "Face and Voice"
        case .faceOnly:         return "Face Only"
        case .voiceOnly:        return "Voice Only"
        }
    }
}

public class MiPassEnrollmentInput: NSObject {
    public var phrase: String? {
        didSet {
            UserDefaults.standard.set(phrase, forKey: "EnrollmentPhrase")
            UserDefaults.standard.synchronize()
        }
    }
    
    public var enrollmentId: String? {
        didSet {
            UserDefaults.standard.set(enrollmentId, forKey: "EnrollmentId")
            UserDefaults.standard.synchronize()
        }
    }
    
    public var faceEnrolled: Bool = false {
        didSet {
            UserDefaults.standard.set(faceEnrolled, forKey: "FaceEnrolled")
            UserDefaults.standard.synchronize()
        }
    }
    
    public var voiceEnrolled: Bool = false {
        didSet {
            UserDefaults.standard.set(voiceEnrolled, forKey: "VoiceEnrolled")
            UserDefaults.standard.synchronize()
        }
    }
    
    public var status: MiPassEnrollmentStatus {
        if voiceEnrolled, faceEnrolled {
            return .faceAndVoice
        } else if voiceEnrolled {
            return .voiceOnly
        } else if faceEnrolled {
            return .faceOnly
        }
        return .notEnrolled
    }
    
    public override init() {
        phrase = UserDefaults.standard.string(forKey: "EnrollmentPhrase")
        enrollmentId = UserDefaults.standard.string(forKey: "EnrollmentId")
        faceEnrolled = UserDefaults.standard.bool(forKey: "FaceEnrolled")
        voiceEnrolled = UserDefaults.standard.bool(forKey: "VoiceEnrolled")
    }
    
    public func reset() {
        enrollmentId = nil
        phrase = nil
        voiceEnrolled = false
        faceEnrolled = false
        
        UserDefaults.standard.removeObject(forKey: "EnrollmentPhrase")
        UserDefaults.standard.removeObject(forKey: "EnrollmentId")
        UserDefaults.standard.removeObject(forKey: "FaceEnrolled")
        UserDefaults.standard.removeObject(forKey: "VoiceEnrolled")
        UserDefaults.standard.synchronize()
    }
}
