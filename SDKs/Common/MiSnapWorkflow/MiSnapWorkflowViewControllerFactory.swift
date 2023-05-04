//
//  MiSnapWorkflowViewControllerFactory.swift
//  MiSnapWorkflow
//
//  Created by Stas Tsuprenko on 11/25/19.
//  Copyright © 2019 Mitek Systems Inc. All rights reserved.
//

import UIKit
#if canImport(MiSnapUX) && canImport(MiSnap)
import MiSnapUX
import MiSnap
#endif
#if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
import MiSnapNFCUX
import MiSnapNFC
#endif
#if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
import MiSnapFacialCaptureUX
import MiSnapFacialCapture
#endif
#if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
import MiSnapVoiceCaptureUX
import MiSnapVoiceCapture
#endif
/**
 Workflow view controller factory
 */
class MiSnapWorkflowViewControllerFactory {
    #if canImport(MiSnapUX) && canImport(MiSnap)
    /**
     Builds MiSnap view controller
     */
    func buildMiSnapVC(for step: MiSnapWorkflowStep, delegate: MiSnapViewControllerDelegate) -> MiSnapViewController {
        let template = MiSnapConfiguration()
            .withCustomUxParameters { uxParameters in
                uxParameters.autoDismiss = false
            }
        
        let configuration: MiSnapConfiguration
        switch step {
        case .idFront:
            configuration = MiSnapConfiguration(for: .idFront).applying(template)
        case .idBack:
            configuration = MiSnapConfiguration(for: .idBack).applying(template)
        case .passport:
            configuration = MiSnapConfiguration(for: .passport).applying(template)
        case .passportQr:
            configuration = MiSnapConfiguration(for: .idBack)
                .withCustomTutorial { tutorial in
                    tutorial.instruction.type = .passportQr
                }
                .withCustomGuide { guide in
                    guide.vignette.alpha = 0.0
                    guide.outline.alpha = 0.0
                }
                .withCustomUxParameters { uxParameters in
                    uxParameters.autoDismiss = false
                }
                .withCustomParameters { parameters in
                    parameters.science.idBackMode = .acceptableImageOptionalBarcodeRequired
                    parameters.science.supportedBarcodeTypes = [MiSnapScienceBarcodeType.QR.rawValue]
                    parameters.science.documentTypeName = "Passport QR"
                }
        default:
            fatalError("\(step) is not handled in MiSnapWorkflowViewControllerFactory.buildMiSnapVC(_:delegate:)")
        }
        
        let miSnapVC = MiSnapViewController(with: configuration, delegate: delegate)
        return miSnapVC
    }
    #endif
    
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    /**
     Builds MiSnapNFC view controller
     */
    @available(iOS 13, *)
    // swiftlint:disable:next function_parameter_count
    func buildMiSnapNFCVC(mrzString: String,
                          documentNumber: String,
                          dateOfBirth: String,
                          dateOfExpiry: String,
                          documentType: MiSnapNFCDocumentType,
                          chipLocation: MiSnapNFCChipLocation,
                          delegate: MiSnapNFCViewControllerDelegate) -> MiSnapNFCViewController {
        let configuration = MiSnapNFCConfiguration()
            .withInputs { inputs in
                inputs.documentNumber = documentNumber
                inputs.dateOfBirth = dateOfBirth
                inputs.dateOfExpiry = dateOfExpiry
                inputs.mrzString = mrzString
                inputs.documentType = documentType
                inputs.chipLocation = chipLocation
            }
            .withCustomUxParameters { uxParameters in
                uxParameters.autoDismiss = false
            }
        
        let nfcVC = MiSnapNFCViewController(with: configuration, delegate: delegate)
        return nfcVC
    }
    #endif
    
    #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
    /**
     Builds MiSnapFacialCapture view controller
     */
    func buildMiSnapFacialCaptureVC(delegate: MiSnapFacialCaptureViewControllerDelegate) -> MiSnapFacialCaptureViewController {
        let configuration = MiSnapFacialCaptureConfiguration()
            .withCustomUxParameters { uxParameters in
                uxParameters.autoDismiss = false
            }
        let facialCaptureVC = MiSnapFacialCaptureViewController(with: configuration, delegate: delegate)
        return facialCaptureVC
    }
    #endif
    
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    /**
     Builds MiSnapVoiceCapture view controller
     */
    func buildMiSnapVoiceCaptureVC(for flow: MiSnapWorkflowFlow, phrase: String?, delegate: MiSnapVoiceCaptureViewControllerDelegate) -> MiSnapVoiceCaptureViewController {
        let configuration = MiSnapVoiceCaptureConfiguration(for: voiceFlow(from: flow), phrase: phrase)
            .withCustomUxParameters { uxParameters in
                uxParameters.autoDismiss = false
            }
        let voiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: delegate)
        return voiceCaptureVC
    }
    
    private func voiceFlow(from flow: MiSnapWorkflowFlow) -> MiSnapVoiceCaptureFlow {
        switch flow {
        case .enrollment:
            return .enrollment
        case .verification, .authentication:
            return .verification
        }
    }
    #endif
    /**
     Supported orientation for a given step
     */
    func supportedOrientationFor(step: MiSnapWorkflowStep) -> UIInterfaceOrientationMask {
        switch step {
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        case .nfc:      return .portrait
        #endif
        #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
        case .face:     return UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
        #endif
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        case .voice:    return .portrait
        #endif
        #if canImport(MiSnapUX) && canImport(MiSnap)
        case .passport: return .landscape
        #endif
        default:        return .all
        }
    }
}
