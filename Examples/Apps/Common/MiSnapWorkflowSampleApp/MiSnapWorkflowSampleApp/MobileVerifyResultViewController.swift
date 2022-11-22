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
        guard MitekPlatform.shared.hasValidMobileVerifyConfiguration else {
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
        let encodedBackImage = result.idBack?.encodedImage
        let pdf417 = result.idBack?.extraction?.barcodeString
        let qrCode = result.passportQr?.extraction?.barcodeString
        let nfcRequestDictionary = result.nfc?[MiSnapNFCKey.requestDictionary]
        let encodedFaceImage = result.face?.encodedImage
        
        // Create a MobileVerify request dictionary using MobileVerifyRequest utility
        
        let mvRequest = MobileVerifyRequest()
        if let encodedFrontImage = encodedFrontImage {
            mvRequest.addFrontEvidence(withData: encodedFrontImage, qrCode: qrCode)
        }
        if let encodedBackImage = encodedBackImage {
            mvRequest.addBackEvidence(withData: encodedBackImage, pdf417: pdf417)
        }
        if let nfcRequestDictionary = nfcRequestDictionary as? [String : Any] {
            mvRequest.addNfcEvidence(from: nfcRequestDictionary)
        }
        if let encodedFaceImage = encodedFaceImage {
            mvRequest.addSelfieEvidence(withData: encodedFaceImage)
            mvRequest.addVerifications([.faceComparison, .faceLiveness])
        }
        
        if let errors = mvRequest.errors {
            print("Errors generating MobileVerifyRequest:")
            for (idx, error) in errors.enumerated() {
                print("\(idx + 1). \(error.description)")
            }
            return
        }
        
        guard let requestDictionary = mvRequest.dictionary else { return }
        
        // Send a request to MobileVerify using Networking utility
        
        MitekPlatform.shared.authenticate(requestDictionary) { rawResponse, error in
            serverResult.stopTimer()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let error = error {
                    var errorMessage: String = ""
                    if let urlError = error as? URLError {
                        errorMessage = "Authentication error: \(urlError.errorCode) - \(self.messageFrom(urlError.errorCode))"
                    } else {
                        errorMessage = "Authentication error: \(error.localizedDescription)"
                    }
                    print(errorMessage)
                    self.removeLoadingView(with: errorMessage)
                } else if let rawResponse = rawResponse {
                    serverResult.parse(rawResponse)
                    if let nfcResult = self.result.nfc { serverResult.update(with: nfcResult) }
                    self.configureSubviews()
                    self.removeLoadingView(animated: true)
                }
            }
        }
    }
    
    override func configureResultView() -> UIStackView {
        return MobileVerifyResultView(with: result, serverResult: serverResult, frame: view.safeAreaLayoutGuide.layoutFrame)
    }
}
