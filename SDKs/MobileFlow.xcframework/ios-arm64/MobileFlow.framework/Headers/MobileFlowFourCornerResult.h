//
//  MobileFlowFourCornerResult.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 7/8/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  MobileFlowFourCornerResult stores the results from a four corner analysis
 *  of an image or frame
 *
 *  @see `MobileFlowDocResult`
 */
@interface MobileFlowFourCornerResult : NSObject

/**
 *  The confidence the corners were detected.
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) NSInteger confidence;

/**
 *  The confidence the background was "busy".
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) NSInteger busyBackgroundConfidence;

/**
 *  The confidence the background had low contrast.
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) NSInteger lowContrastBackgroundConfidence;

/**
 *  Corner A
 */
@property (nonatomic, assign, readonly) CGPoint cornerA;

/**
 *  Corner B
 */
@property (nonatomic, assign, readonly) CGPoint cornerB;

/**
 *  Corner C
 */
@property (nonatomic, assign, readonly) CGPoint cornerC;

/**
 *  Corner D
 */
@property (nonatomic, assign, readonly) CGPoint cornerD;

/**
 *  The top-left most point of the area of interest.
 *  Combined with with the `bottomRight` property, this defines the
 *  bounding box for the region of interest.
 */
@property (nonatomic, assign, readonly) CGPoint topLeft;

/**
 *  The bottom-right most point of the area of interest.
 *  Combined with the `topLeft` property, this defines the bounding
 *  box for the region of interest.
 */
@property (nonatomic, assign, readonly) CGPoint bottomRight;

/**
 *  The relative angle between the four corners and bounding box.
 *  Closer to zero indicates the image and it's bounding box are
 *  aligned and the region of interest is not warped due to perspective.
 *
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) float skewAngle;

/**
 *  Skew angle from CoreVision.  
 *  Values are in tenths of degrees.
 */
@property (nonatomic, assign, readonly) int cvSkewAngle;

/**
 *  Rotation angle from CoreVision.  
 *  Values are in tenths of degrees.
 */
@property (nonatomic, assign, readonly) int cvRotationAngle;

/**
 *  The minimum padding from the corner rectangle 
 *  to the edge of the framebuffer.  Values are in pixels.
 */
@property (nonatomic, assign, readonly) int cvMinPadding;

/**
 *  The relative width the four corner rectangle fills the 
 *  screen horizontally.  A value of 1000 indicates the 
 *  corners entirely fill the horizontal area.
 *  
 *  Range: [0,1000]
 */
@property (nonatomic, assign, readonly) int cvMinHorizontalFill;

@end

