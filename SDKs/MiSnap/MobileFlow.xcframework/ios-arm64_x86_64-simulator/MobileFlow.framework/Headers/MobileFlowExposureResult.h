//
//  MobileFlowExposureResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 7/20/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileFlowExposureResult : NSObject

/**
 *  Score - higher is better exposure
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) NSInteger score;

@end
