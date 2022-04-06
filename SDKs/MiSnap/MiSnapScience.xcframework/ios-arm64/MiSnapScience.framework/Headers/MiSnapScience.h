//
//  MiSnapScience.h
//  MiSnapScience
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MiSnapScience/MiSnapScienceParameters.h>
#import <MiSnapScience/MiSnapScienceResult.h>

/**
 Performs frame analysis
 */
@interface MiSnapScience : NSObject
/**
 Creates an instance of `MiSnapScience`
 
 @param parameters the `MiSnapScienceParameters` to use
 @param orientation the `UIInterfaceOrientation` to use
 
 @return an instance of `MiSnapScience` that is ready to use
 */
- (instancetype _Nonnull)initWithParameters:(MiSnapScienceParameters * _Nonnull)parameters orientation:(UIInterfaceOrientation)orientation;
/**
 Analyzes the sampleBuffer and returns the results
 
 @param sampleBuffer the `CMSampleBufferRef`  to analyze
 @param completionBlock a completion block containing results
 */
- (void)analyzeFrame:(CMSampleBufferRef _Nullable)sampleBuffer completed:(void (^_Nonnull)(MiSnapScienceResult * _Nullable scienceResults))completionBlock;
/**
 Passes decoded barcode string that can be used for analysis
 */
- (void)didReceiveDecodedBarcode:(NSString * _Nonnull)decodedBarcodeString;
/**
 Deinitializes all internal objects to avoid retain cycles (memory leaks)
 */
- (void)shutdown;
/**
 Interface orientation needed for performing calculations
 */
@property (nonatomic) UIInterfaceOrientation orientation;
/**
 Version
 */
+ (NSString * _Nonnull)version;
/**
 CoreFlow version
 */
+ (NSString * _Nonnull)coreFlowVersion;

@end
