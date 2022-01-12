//
//  MobileFlowFocusResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 7/20/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileFlowFocusResult : NSObject

/**
 *  Focus score (higher is better)
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) NSInteger score;

@end
