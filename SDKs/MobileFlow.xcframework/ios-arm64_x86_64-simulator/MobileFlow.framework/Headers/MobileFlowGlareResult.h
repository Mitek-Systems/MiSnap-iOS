//
//  MobileFlowGlareResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 7/8/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  MobileFlowGlareResult stores the results from a glare analysis.
 */
@interface MobileFlowGlareResult : NSObject

/**
 *  The rectangle where glare was found
 */
@property (nonatomic, assign, readonly) CGRect glareRect;

/**
 *  The percentage that of the entire image that is affected by glare.
 *  A higher confidence indicates less glare in the image.
 *
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) NSInteger confidence;

@end
