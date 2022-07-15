//
//  MiSnapScienceClassificationResult.h
//  MiSnapScience
//
//  Created by Stas Tsuprenko on 12/9/21.
//  Copyright © 2021 miteksystems. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Document type that can be classified
 */
typedef NS_ENUM(NSInteger, MiSnapScienceClassificationDocumentType) {
    /**
     A document type wasn't classified
     */
    MiSnapScienceDetectedDocumentTypeUnknown = 0,
    /**
     Passport
     */
    MiSnapScienceDetectedDocumentTypePassport,
    /**
     Passport Card
     */
    MiSnapScienceDetectedDocumentTypePassportCard,
    /**
     Driver's License Front
     */
    MiSnapScienceDetectedDocumentTypeDLFront,
    /**
     Electronic Driver's License Front
     */
    MiSnapScienceDetectedDocumentTypeEDLFront,
    /**
     Driver's License Back
     */
    MiSnapScienceDetectedDocumentTypeDLBack,
    /**
     ID Card Front
     */
    MiSnapScienceDetectedDocumentTypeIDFront,
    /**
     Residence Permit Front
     */
    MiSnapScienceDetectedDocumentTypeRPFront,
    /**
     Identity document back
     
     Either ID Card Back or Residence Permit Back
     */
    MiSnapScienceDetectedDocumentTypeIdentityBack,
    /**
     Front of some Generic documents
     */
    MiSnapScienceDetectedDocumentTypeGenericFront,
    /**
     Back of some Generic documents
     */
    MiSnapScienceDetectedDocumentTypeGenericBack,
    /**
     Credit Card
     */
    MiSnapScienceDetectedDocumentTypeCreditCard,
    /**
     Gift Card
     */
    MiSnapScienceDetectedDocumentTypeGiftCard,
    /**
     Education ID
     */
    MiSnapScienceDetectedDocumentTypeEducationId,
    /**
     Library Card
     */
    MiSnapScienceDetectedDocumentTypeLibraryCard,
    /**
     Some Health Insurance Cards
     */
    MiSnapScienceDetectedDocumentTypeHealthInsurance
};

NS_ASSUME_NONNULL_BEGIN

/**
 Classification result
 */
@interface MiSnapScienceClassificationResult : NSObject
/**
 Indicates whether SDK is done with classification step.
 
 @note The value is automatically set to TRUE if either of below cases is TRUE:
 - an ODC feature is not supported in the license
 - an ODC feature is disabled in parameters
 - a device hardware is not capable of performing ODC
 - a device running iOS older than 13
 - a deposit document type (check front or back) is invoked
 */
@property (nonatomic, readonly, getter=isDone) BOOL done;
/**
 A document type that was classified by the SDK
 
 @see `MiSnapScienceClassificationDocumentType`
 */
@property (nonatomic, readonly) MiSnapScienceClassificationDocumentType documentType;
/**
 A string representation of a document type
 */
@property (nonatomic, readonly) NSString * _Nonnull documentTypeString;
/**
 Indicates whether ODC is supported
 */
@property (nonatomic, readonly) BOOL supported;

@end

NS_ASSUME_NONNULL_END
