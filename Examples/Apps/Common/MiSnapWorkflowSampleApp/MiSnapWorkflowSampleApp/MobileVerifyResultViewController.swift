//
//  MobileVerifyResultViewController.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 12/10/19.
//  Copyright © 2019 Mitek Systems Inc. All rights reserved.
//

import UIKit
#if canImport(MiSnapNFC)
import MiSnapNFC
#endif

class MobileVerifyResultViewController: ResultViewController {
    private var serverResult: MobileVerifyResult?
    
    override func handleResults() {
        guard MitekPlatform.shared.configurationV2.isValid else {
            return configureSubviews()
        }
        
        serverResult = MobileVerifyResult()
        guard let serverResult = serverResult else { return }
        
        serverResult.startTimer()
        addLoadingView(text: "Authenticating...")
        
        // Get all necessary inputs
        
        var encodedFrontImage: String?
        if let idFront = result.idFront {
            encodedFrontImage = idFront.encodedImage
        } else if let passport = result.passport {
            encodedFrontImage = passport.encodedImage
        }
        var frontRts = result.idFront?.rts
        if let passportRts = result.passport?.rts {
            frontRts = passportRts
        }
        let encodedBackImage = result.idBack?.encodedImage
        let backRts = result.idBack?.rts
        let pdf417 = result.idBack?.extraction?.barcodeString
        let qrCode = result.passportQr?.extraction?.barcodeString
        let nfcRequestDictionary = result.nfc?[MiSnapNFCKey.requestDictionary]
        let encodedFaceImage = result.face?.encodedImage
        let faceRts = result.face?.rts
        
        // Create a MobileVerify request dictionary using MobileVerifyRequest utility
        
        let mvAutoAuthenticationRequest = MobileVerifyAutoAuthenticationRequest()
        let mvAADocAuthenticationRequest = MobileVerifyAgentAssistDocumentAuthenticationRequest()
        
        if let encodedFrontImage = encodedFrontImage {
            mvAutoAuthenticationRequest.addFrontEvidence(withData: encodedFrontImage, qrCode: qrCode, rts: frontRts)
            mvAADocAuthenticationRequest.addImage(encodedFrontImage)
        }
        if let encodedBackImage = encodedBackImage {
            mvAutoAuthenticationRequest.addBackEvidence(withData: encodedBackImage, pdf417: pdf417, rts: backRts)
            mvAADocAuthenticationRequest.addImage(encodedBackImage)
            mvAADocAuthenticationRequest.addDeviceExtractedData(pdf417)
        }
        if let nfcRequestDictionary = nfcRequestDictionary as? [String : Any] {
            mvAutoAuthenticationRequest.addNfcEvidence(from: nfcRequestDictionary)
        }
        if let encodedFaceImage = encodedFaceImage {
            mvAutoAuthenticationRequest.addSelfieEvidence(withData: encodedFaceImage, rts: faceRts)
            mvAutoAuthenticationRequest.addVerifications([.faceComparison, .faceLiveness])
        }
        
        if let _ = frontRts {
            mvAutoAuthenticationRequest.addVerifications([.injectionAttackDetection])
        }
        if let _ = backRts {
            mvAutoAuthenticationRequest.addVerifications([.injectionAttackDetection])
        }
        if let _ = faceRts {
            mvAutoAuthenticationRequest.addVerifications([.injectionAttackDetection])
        }
        
        if let errors = mvAutoAuthenticationRequest.errors {
            print("Errors generating MobileVerifyAutoAuthenticationRequest:")
            for (idx, error) in errors.enumerated() {
                print("\(idx + 1). \(error.description)")
            }
            return
        }
        
        guard let requestDictionary = mvAutoAuthenticationRequest.dictionary else { return }
        
        // Send a request to MobileVerifyAutoAuthentication using MitekPlatform utility
        MitekPlatform.shared.authenticateAuto(requestDictionary, api: .v2) { rawResponse, error in
            serverResult.stopTimer()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let error = error {
                    serverResult.set(error: error)
                } else if let rawResponse = rawResponse {
                    serverResult.parse(rawResponse)
                    if let nfcResult = self.result.nfc { serverResult.update(with: nfcResult) }
                }
                self.configureSubviews()
                self.removeLoadingView()
            }
        }
    }
    
    override func configureResultView() -> UIStackView {
        return MobileVerifyResultView(with: result, serverResult: serverResult, frame: view.safeAreaLayoutGuide.layoutFrame)
    }
}
