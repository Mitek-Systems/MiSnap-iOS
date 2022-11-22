//
//  MiPassResultViewController.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 7/12/21.
//

import UIKit
import MiSnapVoiceCapture
import MiSnapFacialCapture

class MiPassResultViewController: ResultViewController {
    private var serverResult: MiPassResult?
    
    private let enrollmentInput: MiPassEnrollmentInput
    private let enrollmentModification: MiPassEnrollmentModification
    private let phrase: String?
                
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with result: MiSnapWorkflowResult,
         enrollmentInput: MiPassEnrollmentInput,
         enrollmentModification: MiPassEnrollmentModification,
         phrase: String?) {
        self.enrollmentInput = enrollmentInput
        self.enrollmentModification = enrollmentModification
        self.phrase = phrase
        super.init(with: result)
    }
    
    override func handleResults() {
        logVoiceResults(result.voice)
        
        guard MitekPlatform.shared.hasValidMiPassConfiguration else {
            handleEnrollmentFrontEndResult()
            return configureSubviews()
        }
        
        serverResult = MiPassResult()
        guard let serverResult = serverResult else { return }
        serverResult.startTimer()
        
        switch result.flow {
        case .enrollment:
            switch enrollmentModification {
            case .newOrUpdateExisting:
                if let _ = enrollmentInput.enrollmentId {
                    addLoadingView(text: "Updating existing enrollment...")
                } else {
                    addLoadingView(text: "Enrolling...")
                }
            case .deleteExistingAndReenroll:
                addLoadingView(text: "Deleting existing enrollment and re-enrolling...")
            default:
                break
            }
            handleEnrollment()
        case .verification:
            addLoadingView(text: "Verifying...")
            handleVerification()
        default:
            break
        }
    }
    
    override func configureResultView() -> UIStackView {
        return MiPassResultView(with: serverResult, result: result, frame: view.safeAreaLayoutGuide.layoutFrame)
    }
}

// MARK: Private processing functions
extension MiPassResultViewController {
    private func handleEnrollment() {
        guard let serverResult = serverResult else { return }
        if enrollmentModification == .deleteExistingAndReenroll, let id = enrollmentInput.enrollmentId {
            let semaphore = DispatchSemaphore(value: 0)
            MitekPlatform.shared.deleteEnrollment(withId: id) { [weak self] (rawResponse, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                } else if let rawResponse = rawResponse {
                    print("Successfully deleted exising enrollment:\n\(rawResponse)")
                    self.enrollmentInput.reset()
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        // Create a MiPass Enrollment request dictionary using MiPassRequest utility
        
        let miPassRequest = MiPassRequest(for: .enrollment)
        
        if let enrollmentId = enrollmentInput.enrollmentId {
            miPassRequest.addEnrollmentId(enrollmentId)
        }
        
        if let voiceResults = result.voice {
            var voiceSamples: [Data] = []
            for voiceResult in voiceResults {
                guard let data = voiceResult.data else { continue }
                voiceSamples.append(data)
            }
            miPassRequest.addVoiceFeatures(voiceSamples)
        }
        
        if let faceResult = result.face, let encodedSelfieImage = faceResult.encodedImage {
            miPassRequest.addEncodedSelfieImage(encodedSelfieImage)
        }
        
        if let errors = miPassRequest.errors {
            print("Errors generating MiPassRequest for Enrollment:")
            for (idx, error) in errors.enumerated() {
                print("\(idx + 1). \(error.description)")
            }
            return
        }
        
        guard let requestDictionary = miPassRequest.dictionary else { return }
        
        // Send an Enrollment request to MiPass using Networking utility
        
        MitekPlatform.shared.enroll(requestDictionary) { [weak self] (rawResponse, error) in
            guard let self = self else { return }
            serverResult.stopTimer()
            
            DispatchQueue.main.async {
                if let error = error {
                    var errorMessage: String = ""
                    if let urlError = error as? URLError {
                        errorMessage = "Server error: \(urlError.errorCode) - \(self.messageFrom(urlError.errorCode))"
                    } else {
                        errorMessage = "Server error: \(error.localizedDescription)"
                    }
                    print(errorMessage)
                    self.removeLoadingView(with: errorMessage)
                } else if let rawResponse = rawResponse {
                    serverResult.parse(rawResponse)
                    self.configureSubviews()
                    self.removeLoadingView()
                    self.logServerResult(serverResult)
                    
                    self.handleEnrollmentServerResult(serverResult)
                }
            }
        }
    }
    
    private func handleEnrollmentServerResult(_ serverResult: MiPassResult) {
        if !enrollmentInput.voiceEnrolled {
            enrollmentInput.voiceEnrolled = serverResult.voiceEnrolled
        }
        if !enrollmentInput.faceEnrolled {
            enrollmentInput.faceEnrolled = serverResult.faceEnrolled
        }
        enrollmentInput.enrollmentId = serverResult.enrollmentId
        enrollmentInput.phrase = phrase
    }
    
    private func handleEnrollmentFrontEndResult() {
        if enrollmentModification == .deleteExistingAndReenroll {
            enrollmentInput.reset()
        }
        enrollmentInput.phrase = phrase
        if let _ = result.voice {
            enrollmentInput.voiceEnrolled = true
        }
        if let _ = result.face {
            enrollmentInput.faceEnrolled = true
        }
    }
    
    private func handleVerification() {
        guard let serverResult = serverResult else { return }
        
        // Create a MiPass Verification request dictionary using MiPassRequest utility
        
        let miPassRequest = MiPassRequest(for: .verification)
        
        if let enrollmentId = enrollmentInput.enrollmentId {
            miPassRequest.addEnrollmentId(enrollmentId)
        }
        
        if let voiceResults = result.voice, let firstResult = voiceResults.first, let data = firstResult.data {
            miPassRequest.addVoiceFeature(data)
        }
        
        if let faceResult = result.face, let encodedSelfieImage = faceResult.encodedImage {
            miPassRequest.addEncodedSelfieImage(encodedSelfieImage)
        }
        
        if let errors = miPassRequest.errors {
            print("Errors generating MiPassRequest for Verification:")
            for (idx, error) in errors.enumerated() {
                print("\(idx + 1). \(error.description)")
            }
            return
        }
        
        guard let requestDictionary = miPassRequest.dictionary else { return }
        
        // Send a Verify request to MiPass using Networking utility
        
        MitekPlatform.shared.verify(requestDictionary) { rawResponse, error in
            serverResult.stopTimer()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let error = error {
                    var errorMessage: String = ""
                    if let urlError = error as? URLError {
                        errorMessage = "Server error: \(urlError.errorCode) - \(self.messageFrom(urlError.errorCode))"
                    } else {
                        errorMessage = "Server error: \(error.localizedDescription)"
                    }
                    print(errorMessage)
                    self.removeLoadingView(with: errorMessage)
                } else if let rawResponse = rawResponse {
                    serverResult.parse(rawResponse)
                    self.configureSubviews()
                    self.removeLoadingView()
                    self.logServerResult(serverResult)
                }
            }
        }
    }
}

// MARK: Other helper functions
extension MiPassResultViewController {
    private func logVoiceResults(_ results: [MiSnapVoiceCaptureResult]?) {
        guard let results = results else { return }

        var message = "MiSnapVoiceCapture success with:\n"
        for result in results {
            if let data = result.data {
                message += "\tData size \(data.size(.useKB))"
            }
            message += " | speech length: \(result.speechLength) ms"
            message += " | snr: \(String(format: "%.2f", result.snr)) dB"
            message += "\n"
        }
        print(message)
    }
    
    private func logServerResult(_ serverResult: MiPassResult) {
        print("Roundtrip time: \(serverResult.roundtripTime)")
        print("Server processing time: \(serverResult.processingTime)")
        print("Request ID: \(serverResult.requestId ?? "")")
        print("Enrollment ID: \(serverResult.enrollmentId ?? "")")
        print("Overall Judgement: \(serverResult.judgement.stringValue)")
        if let voiceJudgement = serverResult.voiceJudgement {
            print("Voice Judgement: \(voiceJudgement.stringValue)")
            if let voiceErrors = serverResult.voiceErrors, !voiceErrors.isEmpty {
                for voiceError in voiceErrors {
                    print(voiceError)
                }
            }
        }
        
        if let faceJudgement = serverResult.faceJudgement {
            print("Face Judgement: \(faceJudgement.stringValue)")
            if let faceErrors = serverResult.faceErrors, !faceErrors.isEmpty {
                for faceError in faceErrors {
                    print(faceError)
                }
            }
        }
        
        if result.flow == .enrollment {
            print("Voice Enrolled: \(String(describing: serverResult.voiceEnrolled))")
            print("Face Enrolled: \(String(describing: serverResult.faceEnrolled))")
        }
    }
}
