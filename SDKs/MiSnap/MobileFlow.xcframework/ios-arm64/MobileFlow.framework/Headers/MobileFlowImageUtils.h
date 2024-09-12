//
//  MobileFlowImageUtils.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 6/28/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface MobileFlowImageUtils : NSObject

/**
 *  Creates a `UIImage` from a pixel buffer object.
 *
 *  @param pixelBuffer Source data of an image
 *
 *  @return A `UIImage` representing the image data
 */
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 *  Creates a `UIImage` from a pixel buffer object and rotates it.
 *
 *  @param pixelBuffer Source data of an image
 *  @param radians     Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A `UIimage` representing the image data
 */
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer withRotation:(double)radians;

/**
 *  Converts a UIImage object to grayscale.
 *
 *  @param image Source image to convert
 *
 *  @return A grayscale `UIImage` of the source image
 */
+ (UIImage *)imageToGrayscale:(UIImage *)image;

/**
 *  Converts an Accelerate `vImage_Buffer` into a `UIImage`
 *
 *  @param sourceBuffer Source buffer to convert
 *  @param format The CGImage format (color or grayscale) to use during conversion
 *
 *  @return A `UIImage` from the source buffer
 */
+ (UIImage *)imageFromBuffer:(const vImage_Buffer*)sourceBuffer format:(vImage_CGImageFormat*)format;

/**
 *  Converts a YUV pixel buffer (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) to an BGRA image buffer.
 *
 *  @param pixelBuffer The pixel buffer - must be in the format '420f' format.
 *
 *  @return A vImage_Buffer with an BGRA image data.  Caller is responsible for deallocating the data.
 */
+ (vImage_Buffer)convertYUVPixelBufferToBGRA:(CVPixelBufferRef)pixelBuffer;

/**
 *  Rotates a `CGImageRef` by a specified number of radians
 *
 *  @param image   Source image to rotate
 *  @param radians Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A new `CGImageRef` that contains the rotated image
 */
+ (CGImageRef)rotateCGImage:(CGImageRef)image byRadians:(double)radians;

/**
 *  Creates a 32-bit ARGB pixel buffer from the supplied image.
 *
 *  @param image Source image
 *
 *  @return A new `CVPixelBufferRef` containing the image.
 */
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

/**
 *  Writes a `UIImage` as a JPG to a file.
 *
 *  @param image The image.
 *  @param name  The filename.
 */
+ (void)writeImage:(UIImage *)image withName:(NSString *)name;

/**
 *  Returns a base-64 encoded string from an NSData object.
 *
 *  @param data The input data to encode.
 *
 *  @return An NSString that is the base-64 representation of the data.
 */
+ (NSString *)base64Encoding:(NSData *)data;

@end
