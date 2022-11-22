//
//  MiSnapWorkflowController.swift
//  MiSnapWorkflow
//
//  Created by Stas Tsuprenko on 11/25/19.
//  Copyright © 2019 Mitek Systems Inc. All rights reserved.
//

import UIKit
import CoreNFC
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
 Workflow step
 */
enum MiSnapWorkflowStep : String, Equatable {
    /**
     Not set
     */
    case none = "None"
    #if canImport(MiSnapUX) && canImport(MiSnap)
    /**
     Any identity document (ID/DL/RP Front or Back, Passport)
     */
    case anyId = "Any_ID"
    /**
     ID/DL/RP Front
     */
    case idFront = "ID_Front"
    /**
     ID/DL/RP Back
     */
    case idBack = "ID_Back"
    /**
     Passport
     */
    case passport = "Passport"
    /**
     Passport QR
     */
    case passportQr = "Passport_QR"
    #endif
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    /**
     NFC
     */
    case nfc = "NFC"
    #endif
    #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
    /**
     Face
     */
    case face = "Face"
    #endif
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    /**
     Voice
     */
    case voice = "Voice"
    #endif
}
/**
 Flow
 */
enum MiSnapWorkflowFlow: Int {
    /**
     Authentication (MobileVerify)
     */
    case authentication
    /**
     Enrollment (MiPass)
     */
    case enrollment
    /**
     Verification (MiPass)
     */
    case verification
}
/**
 Defines an interface for delegates of `MiSnapWorkflowControllerDelegate` to receive callbacks
 */
protocol MiSnapWorkflowControllerDelegate: NSObject {
    /**
     Delegates receive this callback only when license status is anything but valid
     */
    func miSnapWorkflowControllerLicenseStatus(_ status: MiSnapLicenseStatus)
    /**
     Delegates receive this callback when there's a view controller for a given step should be presented
     */
    func miSnapWorkflowControllerPresent(_ vc: UIViewController!, supportedOrientation: UIInterfaceOrientationMask, step: MiSnapWorkflowStep)
    /**
     Delegates receive this callback when all steps are successfully presented and the final result is available
     */
    func miSnapWorkflowControllerDidFinishPresentingSteps(_ result: MiSnapWorkflowResult)
    /**
     Delegates receive this callback after each completed step
     */
    func miSnapWorkflowControllerIntermediate(_ result: Any, step: MiSnapWorkflowStep)
    /**
     Delegates receive this callback when a user cancels a flow on any step
     */
    func miSnapWorkflowControllerCancelled(_ result: MiSnapWorkflowResult)
    /**
     Delegates receive this callback when an error occurs in any SDK
     */
    func miSnapWorkflowControllerError(_ result: MiSnapWorkflowResult)
    
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    /**
     Delegates receive this callback when an NFC step is skipped by a user
     */
    func miSnapWorkflowControllerNfcSkipped(_ result: [String : Any])
    #endif
    
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    /**
     Delegates receive this callback when a use has chosen a phrase in an Enrollment flow
     */
    func miSnapWorkflowControllerDidSelectPhrase(_ phrase: String)
    #endif
}

extension MiSnapWorkflowControllerDelegate {
    func miSnapWorkflowControllerIntermediate(_ result: Any, step: MiSnapWorkflowStep) {}
    func miSnapWorkflowControllerNfcSkipped(_ result: [String : Any]) {}
}
/**
 Workflow result
 */
class MiSnapWorkflowResult: NSObject {
    #if canImport(MiSnapUX) && canImport(MiSnap)
    /**
     ID/DL/RP Front result
     */
    var idFront: MiSnapResult?
    /**
     ID/DL/RP Back result
     */
    var idBack: MiSnapResult?
    /**
     Passport result
     */
    var passport: MiSnapResult?
    /**
     Passport QR result
     */
    var passportQr: MiSnapResult?
    #endif
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    /**
     NFC result
     */
    var nfc: [String : Any]?
    #endif
    #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
    /**
     Face result
     */
    var face: MiSnapFacialCaptureResult?
    #endif
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    /**
     Voice result
     */
    var voice: [MiSnapVoiceCaptureResult]?
    #endif
    /**
     Flow
     */
    var flow: MiSnapWorkflowFlow = .authentication
    /**
     Resets existing results
     */
    internal func reset() {
        #if canImport(MiSnapUX) && canImport(MiSnap)
        idFront = nil
        idBack = nil
        passport = nil
        passportQr = nil
        #endif
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        nfc = nil
        #endif
        #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
        face = nil
        #endif
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        voice = nil
        #endif
    }
}
/**
 Workflow controller
 */
class MiSnapWorkflowController: NSObject {
    /**
     Delegate
     */
    public weak var delegate: MiSnapWorkflowControllerDelegate?
    private var flow: MiSnapWorkflowFlow = .authentication
    private var phrase: String?
    
    private var result = MiSnapWorkflowResult()
    
    private var completedStep: MiSnapWorkflowStep = .none
    private var step: MiSnapWorkflowStep = .none
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    private var nfcDocumentType: MiSnapNFCDocumentType = .none
    private var nfcChipLocation: MiSnapNFCChipLocation = .noChip
    #endif
    private var mutableSteps: [MiSnapWorkflowStep]
    
    private var mrzString: String = ""
    private var documentNumber: String = ""
    private var dateOfBirth: String = ""
    private var dateOfExpiry: String = ""
    
    private var cancelled: Bool = false
    
    private var licenseStatus: MiSnapLicenseStatus?
    
    private lazy var controllerFactory: MiSnapWorkflowViewControllerFactory = {
        return MiSnapWorkflowViewControllerFactory()
    }()
    
    private lazy var viewController: UIViewController? = {
        return UIViewController.init()
    }()
    /**
     Initializes a controller for MobileVerify
     */
    public init(with steps:[MiSnapWorkflowStep], delegate: MiSnapWorkflowControllerDelegate) {
        self.mutableSteps = steps
        self.delegate = delegate
        self.result.flow = flow
    }
    /**
     Initializes a controller for MiPass
     */
    public init(for flow: MiSnapWorkflowFlow, with steps:[MiSnapWorkflowStep], delegate: MiSnapWorkflowControllerDelegate, phrase: String? = nil) {
        self.flow = flow
        self.result.flow = flow
        self.mutableSteps = steps
        self.delegate = delegate
        self.phrase = phrase
    }
    /**
     Presents the next step
     */
    public func nextStep() {
        if let licenseStatus = licenseStatus {
            delegate?.miSnapWorkflowControllerLicenseStatus(licenseStatus)
            return
        } else if cancelled {
            return
        }
        
        guard let step = mutableSteps.first else {
            cleanup()
            delegate?.miSnapWorkflowControllerDidFinishPresentingSteps(result)
            return
        }
        self.step = step
        mutableSteps.removeFirst()
        
        viewController = UIViewController.init()
        switch step {
        #if canImport(MiSnapUX) && canImport(MiSnap)
        case .idFront, .idBack, .passport, .passportQr:
            viewController = controllerFactory.buildMiSnapVC(for: step, delegate: self)
        #endif
        #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
        case .nfc:
            if #available(iOS 13, *) {
                viewController = controllerFactory.buildMiSnapNFCVC(mrzString: mrzString,
                                                                    documentNumber: documentNumber,
                                                                    dateOfBirth: dateOfBirth,
                                                                    dateOfExpiry: dateOfExpiry,
                                                                    documentType: nfcDocumentType,
                                                                    chipLocation: nfcChipLocation,
                                                                    delegate: self)
            } else {
                viewController = UIViewController.init()
            }
        #endif
        #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
        case .face:
            viewController = controllerFactory.buildMiSnapFacialCaptureVC(delegate: self)
        #endif
        #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
        case .voice:
            viewController = controllerFactory.buildMiSnapVoiceCaptureVC(for: flow, phrase: phrase, delegate: self)
        #endif
        default:
            fatalError("Could not build a desired view controller")
        }
        let orientation = controllerFactory.supportedOrientationFor(step: step)
        
        delegate?.miSnapWorkflowControllerPresent(viewController, supportedOrientation: orientation, step: step)
    }
    
    // MARK: Private methods
    private func cleanup(cancelled: Bool = false) {
        viewController = nil
        mutableSteps.removeAll()
        self.cancelled = cancelled
    }
}

// MARK: MiSnapViewControllerDelegate callbacks
#if canImport(MiSnapUX) && canImport(MiSnap)
extension MiSnapWorkflowController: MiSnapViewControllerDelegate {
    func miSnapLicenseStatus(_ status: MiSnapLicenseStatus) {
        licenseStatus = status
        cleanup()
    }
    
    func miSnapException(_ exception: NSException) {}
    
    func miSnapSuccess(_ result: MiSnapResult) {
        if step == .anyId {
            guard let step = stepFrom(miSnapDocumentType: result.classification.documentTypeString, previousStep: completedStep) else {
                return nextStep()
            }
            completedStep = step
        } else {
            completedStep = step
        }
        
        switch completedStep {
        case .idFront:      self.result.idFront = result
        case .idBack:       self.result.idBack = result
        case .passport:     self.result.passport = result
        case .passportQr:   self.result.passportQr = result
        default:            break
        }
        
        delegate?.miSnapWorkflowControllerIntermediate(result, step: completedStep)
                
        if let extraction = result.extraction {
            if let mrzString = extraction.mrzString {
                self.mrzString = mrzString
            }
            if let documentNumber = extraction.documentNumber {
                self.documentNumber = documentNumber
            }
            if let dateOfBirth = extraction.dateOfBirth {
                self.dateOfBirth = dateOfBirth
            }
            if let dateOfExpiry = extraction.expirationDate {
                self.dateOfExpiry = dateOfExpiry
            }
        }
        
        if shouldAddNfcStep() {
            #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
            if #available(iOS 13.0, *), NFCTagReaderSession.readingAvailable {
                if !self.mutableSteps.contains(.nfc) {
                    var index = -1
                    if let idBackIndex = self.mutableSteps.firstIndex(of: .idBack) {
                        if let idFrontIndex = self.mutableSteps.firstIndex(of: .idFront), idFrontIndex > idBackIndex {
                            index = idFrontIndex
                        } else {
                            index = idBackIndex
                        }
                    } else if let idFrontIndex = self.mutableSteps.firstIndex(of: .idFront) {
                        index = idFrontIndex
                    }
                    self.mutableSteps.insert(.nfc, at: index + 1)
                }
            }
            #endif
        }
        
        if let extraction = result.extraction, extraction.additionalStep == .passportQr {
            self.mutableSteps.insert(.passportQr, at: 0)
        }
    }
    
    func miSnapShouldBeDismissed() {
        nextStep()
    }
    
    func miSnapCancelled(_ result: MiSnapResult) {
        // Send cancellation workflow result only for a step that was cancelled by resetting results for all previous successful steps
        self.result.reset()
        switch step {
        case .idFront:      self.result.idFront = result
        case .idBack:       self.result.idBack = result
        case .passport:     self.result.passport = result
        case .passportQr:   self.result.passportQr = result
        default:            break
        }
        
        cleanup(cancelled: true)
        
        delegate?.miSnapWorkflowControllerCancelled(self.result)
    }
    
    private func stepFrom(miSnapDocumentType: String, previousStep: MiSnapWorkflowStep) -> MiSnapWorkflowStep? {
        switch miSnapDocumentType {
        case "Passport": return .passport
        case "DL_Front", "eDL_Front", "ID_Front", "RP_Front": return .idFront
        case "DL_Back", "ID_Back": return .idBack
        case "Unknown":
            if previousStep == .idFront {
                return .idBack
            }
            return nil
        default: return nil
        }
    }
    
    private func shouldAddNfcStep() -> Bool {
        guard !self.mutableSteps.contains(.nfc) else { return false }
        if documentNumber != "", dateOfBirth != "", dateOfBirth.count == 6, dateOfExpiry != "", dateOfExpiry.count == 6, mrzString != "" {
            if completedStep == .passport {
                nfcDocumentType = .passport
            } else {
                nfcDocumentType = .id
            }
            #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
            if #available(iOS 13, *) {
                nfcChipLocation = MiSnapNFCChipLocator.chipLocation(mrzString: mrzString, documentNumber: documentNumber, dateOfBirth: dateOfBirth, dateOfExpiry: dateOfExpiry)
                if nfcChipLocation != .noChip {
                    return true
                }
            }
            #endif
        } else if mrzString != "", mrzString.count == 30, mrzString.starts(with: "D") {
            nfcDocumentType = .dl
            #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
            return true
            #endif
        }

        return false
    }
}
#endif

// MARK: MiSnapNFCViewControllerDelegate callbacks
#if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
extension MiSnapWorkflowController: MiSnapNFCViewControllerDelegate {
    func miSnapNfcLicenseStatus(_ status: MiSnapLicenseStatus) {
        licenseStatus = status
        cleanup()
    }
    
    func miSnapNfcSuccess(_ result: [String : Any]) {
        delegate?.miSnapWorkflowControllerIntermediate(result, step: .nfc)
        self.result.nfc = result
    }
    
    func miSnapNfcCancelled(_ result: [String : Any]) {
        // Send cancellation workflow result only for a step that was cancelled by resetting results for all previous successful steps
        self.result.reset()
        self.result.nfc = result
        
        cleanup(cancelled: true)
        
        delegate?.miSnapWorkflowControllerCancelled(self.result)
    }
    
    func miSnapNfcSkipped(_ result: [String : Any]) {
        delegate?.miSnapWorkflowControllerNfcSkipped(result)
        /* Do not perform cleanup here as it'll prevent from presenting the next step if available
         and do not reset workflow result since it's erase results for all previous successful steps*/
    }
    
    func miSnapNfcShouldBeDismissed() {
        nextStep()
    }
}
#endif

// MARK: MiSnapFacialCaptureViewControllerDelegate callbacks
#if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
extension MiSnapWorkflowController: MiSnapFacialCaptureViewControllerDelegate {
    func miSnapFacialCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
        licenseStatus = status
        cleanup()
    }
    
    func miSnapFacialCaptureSuccess(_ result: MiSnapFacialCaptureResult) {
        delegate?.miSnapWorkflowControllerIntermediate(result, step: .face)
        self.result.face = result
    }
    
    func miSnapFacialCaptureCancelled(_ result: MiSnapFacialCaptureResult) {
        // Send cancellation workflow result only for a step that was cancelled by resetting results for all previous successful steps
        self.result.reset()
        self.result.face = result
        
        cleanup(cancelled: true)
        
        delegate?.miSnapWorkflowControllerCancelled(self.result)
    }
    
    func miSnapFacialCaptureShouldBeDismissed() {
        nextStep()
    }
}
#endif

// MARK: MiSnapVoiceCaptureViewControllerDelegate callbacks
#if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
extension MiSnapWorkflowController: MiSnapVoiceCaptureViewControllerDelegate {
    func miSnapVoiceCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
        licenseStatus = status
        cleanup()
    }
    
    func miSnapVoiceCaptureDidSelectPhrase(_ phrase: String) {
        delegate?.miSnapWorkflowControllerDidSelectPhrase(phrase)
    }
    
    func miSnapVoiceCaptureSuccess(_ results: [MiSnapVoiceCaptureResult], for flow: MiSnapVoiceCaptureFlow) {
        delegate?.miSnapWorkflowControllerIntermediate(results, step: .voice)
        self.result.voice = results
    }
    
    func miSnapVoiceCaptureCancelled(_ result: MiSnapVoiceCaptureResult) {
        // Send cancellation workflow result only for a step that was cancelled by resetting results for all previous successful steps
        self.result.reset()
        self.result.voice = [result]
        
        cleanup(cancelled: true)
        
        delegate?.miSnapWorkflowControllerCancelled(self.result)
    }
    
    func miSnapVoiceCaptureError(_ result: MiSnapVoiceCaptureResult) {
        // Send error workflow result only for a step that has an error by resetting results for all previous successful steps
        self.result.reset()
        self.result.voice = [result]
        
        cleanup(cancelled: true)
        
        delegate?.miSnapWorkflowControllerError(self.result)
    }
    
    func miSnapVoiceCaptureShouldBeDismissed() {
        nextStep()
    }
}
#endif
