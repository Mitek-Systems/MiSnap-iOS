//
//  MiSnapImageUtilities.h
//  MiSnap
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#ifndef MiSnapSDKImageUtilities_h
#define MiSnapSDKImageUtilities_h

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface MiSnapImageUtilities : NSObject

/**
 *  Rotates a CGImageRef by a specified number of radians.
 *
 *  @param image   Source image to rotate
 *  @param radians Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A new CGImageRef that contains the rotated image
 *
 *  @since 1.0
 */
+ (CGImageRef)rotateCGImage:(CGImageRef)image byRadians:(double)radians;

/**
 *  Rotates a UIImage by a specified number of radians.
 *
 *  @param image   Source image to rotate
 *  @param radians Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A new UIImage that contains the rotated image
 *
 *  @since 5.0
 */
+ (UIImage *)rotateUIImage:(UIImage *)image byRadians:(double)radians;


/**
 *  Returns the sampleBuffer of an image.
 *
 *  @param image Source image in 32-bit ARGB format.
 *
 *  @return A CMSampleBufferRef containing the image data.
 *
 *  @since 1.1
 */
+ (CMSampleBufferRef)sampleBufferFromCGImage:(CGImageRef)image;

/**
 *  Returns the sampleBuffer of an image.
 *
 *  @param image Source image in 32-bit ARGB format.
 *
 *  @return A CMSampleBufferRef containing the image data.
 *
 *  @since 5.0
 */
+ (CMSampleBufferRef)sampleBufferFromImage:(UIImage *)image;

/**
 *  Returns a UIImage from sampleBuffer data
 *
 *  @param sampleBuffer Source data of an image
 *  @param deviceOrientation The UIDeviceOrientation of sampleBuffer
 *
 *  @return A UIImage representing the image data
 *
 *  @since 1.1
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer withDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

/**
 *  Returns a UIImage from sampleBuffer data with UIDeviceOrientationUnknown
 *
 *  @param sampleBuffer Source data of an image
 *
 *  @return A UIImage representing the image data
 *
 *  @since 1.1
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 *  Returns a rotated UIImage from UIImage
 *
 *  @param image Original image
 *  @param orientation The UIInterfaceOrientation of application
 *
 *  @return A UIImage representing the image data
 *
 *  @since 1.1
 */
+ (UIImage *)imageFromUIImage:(UIImage *)image withOrientation:(UIInterfaceOrientation)orientation;

/**
 *  Returns a UIImage from sampleBuffer data adjusted for orientation
 *
 *  @param sampleBuffer Source data of an image
 *
 *  @return UIImage representing the image data
 *
 *  @since 1.0
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer adjustedForOrientation:(UIInterfaceOrientation)orientation;

/**
 *  Returns the raw pixel buffer of an image.
 *
 *  @param image Source image in 32-bit ARGB format.
 *
 *  @return A CVImageBufferRef (aka CVPixelBufferRef) containing the image data.
 *
 *  @since 1.0
 */
+ (CVImageBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

/**
 *  Returns a deep copy of a pixel buffer of an image.
 *
 *  @param pixelBuffer Source image in 32-bit ARGB format.
 *
 *  @return A CVImageBufferRef (aka CVPixelBufferRef) containing a deep copy of a pixel buffer of an image.
 *
 *  @since 5.0
 */
+ (CVPixelBufferRef)copyPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 *  Returns a deep copy of a sample buffer of an image.
 *
 *  @param sampleBuffer a sample buffer to copy.
 *
 *  @return A CMSampleBufferRef containing a deep copy of a sample buffer of an image.
 *
 *  @since 5.0
 */
+ (CMSampleBufferRef)copySampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 *  Returns a UIImage from pixel buffer data
 *
 *  @param pixelBuffer Source data of an image
 *
 *  @return A UIImage representing the image data
 *
 *  @since 1.0
 */
//+ (UIImage *)imageWithPixelBuffer:(CVImageBufferRef)pixelBuffer;


/**
 *  Returns the color channel data of a 32-bit ARGB image
 *
 *  @param pixelBuffer The pixel buffer of the image data
 *  @param point       The point of interest
 *  @param red         Red value at specified point
 *  @param green       Green value at the specified point
 *  @param blue        Blue value at the specified point
 *  @param alpha	   Alpha value at the specified point
 *
 *  @since 1.0
 */
//+ (void)getColorFromPixelBuffer:(CVImageBufferRef)pixelBuffer atPoint:(CGPoint)point red:(uint8_t*)red green:(uint8_t*)green blue:(uint8_t*)blue alpha:(uint8_t*)alpha;


/**
 *  Returns a UIColor containing the color of an image (32-bit ARGB) at a specified point.
 *
 *  @param pixelBuffer The pixel buffer of the image data
 *  @param point       The point of interest
 *
 *  @return A UIColor object to containing the color information at the specified point.
 *
 *  @since 1.0
 */
//+ (UIColor *)getColorFromPixelBuffer:(CVImageBufferRef)pixelBuffer atPoint:(CGPoint)point;

@end

#endif /* MiSnapSDKImageUtilities */
