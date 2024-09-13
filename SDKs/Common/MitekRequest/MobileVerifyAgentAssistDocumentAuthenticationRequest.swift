//
//  MobileVerifyAgentAssistRequest.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Stas Tsuprenko on 12/6/23.
//  Copyright © 2023 Mitek Systems Inc. All rights reserved.
//

import UIKit

/**
 MobileVerify request error
 */
public enum MobileVerifyAgentAssistRequestError: Error {
    /**
     Images are not set
     */
    case imagesNotSet
    /**
     Description
     */
    var description: String {
        switch self {
        case .imagesNotSet:
            return "Images are not set. Call `addImage(_ image:)` and provide at least one image"
        }
    }
}

class MobileVerifyAgentAssistDocumentAuthenticationRequest: NSObject {
    private var transactionRequestId: String = ""
    private var customerReferenceId: String = ""
    private var images: [String] = []
    private var deviceExtractedDatas: [String] = []
    
    /**
     Default initializer
     */
    override init() {
        super.init()
    }
    /**
     Adds optional transaction request ID
     */
    public func addTransactionRequestId(_ transactionRequestId: String) {
        self.transactionRequestId = transactionRequestId
    }
    /**
     Adds optional customer reference ID
     */
    public func addCustomerReferenceId(_ customerReferenceId: String) {
        self.customerReferenceId = customerReferenceId
    }
    /**
     Adds base64 image
     */
    public func addImage(_ image: String) {
        images.append(image)
    }
    /**
     Adds device extracted data (PDF417 string)
     */
    public func addDeviceExtractedData(_ data: String?) {
        guard let data = data else { return }
        deviceExtractedDatas.append(data)
    }
    /**
     Errors in the request
     */
    public var errors: [MobileVerifyAgentAssistRequestError]? {
        var errors: [MobileVerifyAgentAssistRequestError] = []
        
        if images.isEmpty {
            errors.append(.imagesNotSet)
        }
        
        if errors.isEmpty {
            return nil
        }
        return errors
    }
    /**
     MobileVerifyAgentAssist request dictionary that can be serialized to JSON data for URLRequest httpBody
     */
    public var dictionary: [String : Any]? {
        if let _ = errors { return nil }
        var dictionary: [String : Any] = [:]
        
        if !transactionRequestId.isEmpty {
            dictionary["transactionRequestId"] = transactionRequestId
        }
        
        if !customerReferenceId.isEmpty {
            dictionary["customerReferenceId"] = customerReferenceId
        }
        
        dictionary["images"] = images.map { ["data": $0] }
        
        if !deviceExtractedDatas.isEmpty {
            dictionary["deviceExtractedData"] = deviceExtractedDatas.map { ["dataType": "PDF417_STRING", "data": $0] }
        }
        
        return dictionary
    }
}
