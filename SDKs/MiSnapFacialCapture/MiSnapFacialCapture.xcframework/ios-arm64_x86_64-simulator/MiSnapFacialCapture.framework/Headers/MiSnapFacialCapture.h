//
//  MiSnapFacialCapture.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureParameters.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureResult.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureAnalyzer.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureCamera.h>

/**
 Umbrella header
*/
@interface MiSnapFacialCapture : NSObject
/**
 Version
 */
+ (NSString * _Nonnull)version;
/**
 Checks Camera permission
 */
+ (void)checkCameraPermission:(void (^_Nonnull)(BOOL granted))handler;

@end
