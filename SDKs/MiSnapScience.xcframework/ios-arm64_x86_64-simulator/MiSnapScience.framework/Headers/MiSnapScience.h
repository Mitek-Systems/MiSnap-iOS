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

/*!
 @class MiSnapScience
 @abstract
 MiSnapScience is a class that defines an interface for analyzing a video frames and the science results.
 
 @discussion
 MiSnapScience is an interface for creating and initializing an instance of the Science abstraction. The instance
 can then be used to analyze a sampleBuffer to obtain MiSnapSDKScienceResults.  The MiSnapSDKScienceResults can then be
 analyzed to obtain MiSnapSDKAnalyzeResults which indicate if the image is acceptable or what the reasons for failure were.
 */
@interface MiSnapScience : NSObject

/*!
 @abstract Creates an instance of MiSnapSDKScience
 @param parameters the MiSnapSDKScienceParameters to use
 @param orientation the interface orientation to use
 @return an instance of MiSnapSDKScience that is ready to use
 */
- (instancetype _Nonnull)initWithParameters:(MiSnapScienceParameters * _Nonnull)parameters orientation:(UIInterfaceOrientation)orientation;

/**
 Analyze the sampleBuffer video image and return the results
 @param sampleBuffer the video image to analyze
 @param completionBlock a completion block containing results
 */
- (void)analyzeFrame:(CMSampleBufferRef _Nullable)sampleBuffer completed:(void (^_Nonnull)(MiSnapScienceResult * _Nullable scienceResults))completionBlock;

/**
 A method to receive camera decoded barcode string that can be used for analysis
 */
- (void)didReceiveDecodedBarcode:(NSString * _Nonnull)decodedBarcodeString;

/*!
 @abstract deinitializes all properties to avoid retain cycles (memory leaks)
 */
- (void)shutdown;

/*!
 @abstract Interface orientation needed for performing calculations
 */
@property (nonatomic) UIInterfaceOrientation orientation;

/*!
 @abstract provides the version of the science
 @return the string of the science version
 */
+ (NSString * _Nonnull)version;

@end
