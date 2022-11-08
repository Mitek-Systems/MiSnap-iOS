//
//  MiSnapWorkflowController.swift
//  MiSnapWorkflow
//
//  Created by Mitek Engineering on 11/25/19.
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

enum MiSnapWorkflowStep : String, Equatable {
    case none = "None"
    #if canImport(MiSnapUX) && canImport(MiSnap)
    case anyId = "Any_ID"
    case idFront = "ID_Front"
    case idBack = "ID_Back"
    case passport = "Passport"
    case passportQr = "Passport_QR"
    #endif
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    case nfc = "NFC"
    #endif
    #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
    case face = "Face"
    #endif
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    case voice = "Voice"
    #endif
}

enum MiSnapWorkflowActivity: Int {
    case authentication
    case enrollment
    case verification
}

protocol MiSnapWorkflowControllerDelegate: NSObject {
    func miSnapWorkflowControllerLicenseStatus(_ status: MiSnapLicenseStatus)
    
    func miSnapWorkflowControllerPresent(_ vc: UIViewController!, supportedOrientation: UIInterfaceOrientationMask, step: MiSnapWorkflowStep)
        
    func miSnapWorkflowControllerDidFinishPresentingSteps(_ result: MiSnapWorkflowResult)
    
    func miSnapWorkflowControllerIntermediate(_ result: Any, step: MiSnapWorkflowStep)
    
    func miSnapWorkflowControllerCancelled(_ result: MiSnapWorkflowResult)
    
    func miSnapWorkflowControllerError(_ result: MiSnapWorkflowResult)
    
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    func miSnapWorkflowControllerNfcSkipped(_ result: [String : Any])
    #endif
    
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    func miSnapWorkflowControllerDidSelectPhrase(_ phrase: String)
    #endif
}

extension MiSnapWorkflowControllerDelegate {
    func miSnapWorkflowControllerIntermediate(_ result: Any, step: MiSnapWorkflowStep) {}
}

class MiSnapWorkflowResult: NSObject {
    #if canImport(MiSnapUX) && canImport(MiSnap)
    var idFront: MiSnapResult?
    var idBack: MiSnapResult?
    var passport: MiSnapResult?
    var passportQr: MiSnapResult?
    #endif
    #if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    var nfc: [String : Any]?
    #endif
    #if canImport(MiSnapFacialCaptureUX) && canImport(MiSnapFacialCapture)
    var face: MiSnapFacialCaptureResult?
    #endif
    #if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    var voice: [MiSnapVoiceCaptureResult]?
    #endif
    var activity: MiSnapWorkflowActivity = .authentication
    
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

class MiSnapWorkflowController: NSObject {
    public weak var delegate: MiSnapWorkflowControllerDelegate?
    private var activity: MiSnapWorkflowActivity = .authentication
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
    
    public init(with steps:[MiSnapWorkflowStep], delegate: MiSnapWorkflowControllerDelegate) {
        self.mutableSteps = steps
        self.delegate = delegate
        self.result.activity = activity
    }
    
    public init(for activity: MiSnapWorkflowActivity, with steps:[MiSnapWorkflowStep], delegate: MiSnapWorkflowControllerDelegate, phrase: String? = nil) {
        self.activity = activity
        self.result.activity = activity
        self.mutableSteps = steps
        self.delegate = delegate
        self.phrase = phrase
    }
    
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
            viewController = controllerFactory.buildMiSnapVoiceCaptureVC(for: activity, phrase: phrase, delegate: self)
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
