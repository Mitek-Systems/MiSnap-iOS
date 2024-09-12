//
//  MobileFlowMicrResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 8/4/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  MobileFlowMicrResult stores the OCR results of a check or passport.
 *
 */
@interface MobileFlowMicrResult : NSObject

/**
 *  The confidence that the MICR/MRZ was found
 */
@property (nonatomic, assign, readonly) NSInteger confidence;

/**
 *  The MICR/MRZ string depending on the document type (check or passport)
 */
@property (nonatomic, strong, readonly) NSString *micrString;

/**
 *  The position of the MICR/MRZ
 */
@property (nonatomic, assign, readonly) CGRect micrPosition;

/**
 *  Routing number parsed from the `micrString`
 */
@property (nonatomic, strong, readonly) NSString *routing;

/**
 *  Account number parsed from the `micrString`
 */
@property (nonatomic, strong, readonly) NSString *account;

/**
 *  The check number from the `micrString`
 */
@property (nonatomic, strong, readonly) NSString *check;

/**
 *  The amount of the check from the `micrString` in cents
 */
@property (nonatomic, strong, readonly) NSString *amount;

/**
 *  Image replacement document number from the `micrString`
 */
@property (nonatomic, strong, readonly) NSString *ird;

/**
 *  The tran code from the `micrString`
 */
@property (nonatomic, strong, readonly) NSString *tranCode;

@end
