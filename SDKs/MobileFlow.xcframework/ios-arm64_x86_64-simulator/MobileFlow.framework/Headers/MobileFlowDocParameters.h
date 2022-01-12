//
//  MobileFlowDocParameters.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 7/8/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileFlow/MobileFlowTypes.h>


/**
 *  MobileFlowDocParameters contains various options and settings
 *  that the calling application may wish to set when analyzing a frame.
 *
 *  These include things like the document type and various processing options.
 */
@interface MobileFlowDocParameters : NSObject

/**
 *  The document type.
 *
 *  @see `MobileFlowDocType`
 */
@property (nonatomic, assign) MobileFlowDocType docType;

/**
 *  The processing options.
 *
 *  @see `MobileFlowProcessingOptions`
 */
@property (nonatomic, assign) MobileFlowProcessOptions processOptions;

/**
 *  The minimum four-corner confidence required to continue frame analysis.
 */
@property (nonatomic, assign) NSInteger fourCornerMinConfidence;

@end
