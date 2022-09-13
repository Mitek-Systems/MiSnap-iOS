//
//  MiSnapVoiceCapture.h
//  MiSnapVoiceCapture
//
//  Created by Stas Tsuprenko on 7/2/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MiSnapVoiceCapture/MiSnapVoiceCaptureEngine.h>
#import <MiSnapLicenseManager/MiSnapLicenseManager.h>

@interface MiSnapVoiceCapture : NSObject
/**
 Version
 */
+ (NSString * _Nonnull)version;
/**
 Checks Microphone permission
 */
+ (void)checkMicrophonePermission:(void (^_Nonnull)(BOOL granted))handler;

@end


