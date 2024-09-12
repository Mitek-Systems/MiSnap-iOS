//
//  MobileFlowDocResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 6/28/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MobileFlowGlareResult;
@class MobileFlowFourCornerResult;
@class MobileFlowFocusResult;
@class MobileFlowExposureResult;
@class MobileFlowMicrResult;
@class MobileFlowMrzResult;

/**
 *  MobileFlowDocResult stores the results of a document analysis.  
 *
 *  This structure is an umbrella object for a variety of containers - some of
 *  which may contain valid data depending on the type of analysis performed.
 *  If a analysis routine is not performed, the object will be nil.
 *
 */
@interface MobileFlowDocResult : NSObject

/**
 *  Four corner analysis results
 */
@property (nonatomic, strong, readonly) MobileFlowFourCornerResult *fourCornerResult;

/**
 *  Glare analysis results
 */
@property (nonatomic, strong, readonly) MobileFlowGlareResult *glareResult;

/**
 *  Focus analysis results
 */
@property (nonatomic, strong, readonly) MobileFlowFocusResult *focusResult;

/**
 * Exposure results
 */
@property (nonatomic, strong, readonly) MobileFlowExposureResult *exposureResult;

/**
 *  MICR results
 */
@property (nonatomic, strong, readonly) MobileFlowMicrResult *micrResult;

/**
 * MRZ results
 */
@property (nonatomic, strong, readonly) MobileFlowMrzResult *mrzResult;

/**
 *  Gray-scale cropped and dewarped image of four-corner region
 */
@property (nonatomic, strong, readonly) UIImage *grayCroppedDewarped;

/**
 *  Color cropped and dewarped image of four-corner region
 */
@property (nonatomic, strong, readonly) UIImage *colorCroppedDewarped;

@end
