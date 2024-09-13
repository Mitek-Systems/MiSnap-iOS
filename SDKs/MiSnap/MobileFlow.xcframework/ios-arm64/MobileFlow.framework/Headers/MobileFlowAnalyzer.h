//
//  MobileFlowAnalyzer.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 6/28/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forward declarations
@class MobileFlowDocResult;
@class MobileFlowDocParameters;

/**
 *  MobileFlowAnalyzer preforms image analysis on either a video frame or a still 
 *  image.  Callers can pass in a parameters object to specify various processing
 *  settings and options - like document type and processing options.
 */
@interface MobileFlowAnalyzer : NSObject

/**
 *  Analyze a still image.
 *
 *  @param image  The image to analyze
 *  @param params The processing parameters
 *
 *  @return A `MobileFlowDocResult` object with the results of the analysis
 */
- (MobileFlowDocResult *)analyzeFrame:(UIImage *)image withDocParams:(MobileFlowDocParameters *)params;

/**
 *  Analyze a full color video image.
 *
 *  @param pixelBuffer The pixel buffer to analyze (kCVPixelFormatType_32BGRA)
 *  @param params      The processing parameters
 *
 *  @return A `MobileFlowDocResult` object with the results of the analysis
 */
- (MobileFlowDocResult *)analyzeVideo:(CVPixelBufferRef)pixelBuffer withDocParams:(MobileFlowDocParameters *)params;

/**
 *  Analyze a grayscale video image.
 *
 *  @param pixelBuffer The pixel buffer to analyze (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
 *  @param params      The processing parameters
 *
 *  @return A `MobileFlowDocResult` object with the results of the analysis
 */
- (MobileFlowDocResult *)analyzeGrayVideo:(CVPixelBufferRef)pixelBuffer withDocParams:(MobileFlowDocParameters *)params;

@end
