//
//  MobileFlowSpikeNormalizer.h
//  MobileFlow
//
//  Created by Steve Blake on 12/19/18.
//  Copyright © 2018 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MobileFlowSpikeNormalizer : NSObject

- (instancetype)initWithThreshold:(int)threshold numberOfFrames:(int)frames;

- (BOOL)isSpike:(int)iqaResult;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
