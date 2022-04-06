//
//  MiSnapFacialCaptureAnalyzer.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureParameters.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureResult.h>
#import <MiSnapLicenseManager/MiSnapLicenseManager.h>

/**
Smile status
*/
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureSmileStatus) {
    /**
     Smile status is not set
     */
    MiSnapFacialCaptureSmileStatusNone = 0,
    /**
     Smile is detected
     */
    MiSnapFacialCaptureSmileStatusTrue,
    /**
     Smile is not detected
     */
    MiSnapFacialCaptureSmileStatusFalse
};
/**
 Defines an interface for delegates of `MiSnapFacialCaptureAnalyzerDelegate`
*/
@protocol MiSnapFacialCaptureAnalyzerDelegate <NSObject>
/**
 Delegates receive this callback after analysis of each frame that doesn't pass image quality analysis checks
 
 @param result A `MiSnapFacialCaptureResults` object with the current frame results.
*/
- (void)miSnapFacialCaptureAnalyzerError:(MiSnapFacialCaptureResult *)result;

/**
 Delegates receive this callback whenever a final frame was selected that meets environmental thresholds defined in `MiSnapFacialCaptureParameters`
 
 @param result A `MiSnapFacialCaptureResults` object with a final frame results.
*/
- (void)miSnapFacialCaptureAnalyzerSuccess:(MiSnapFacialCaptureResult *)result;
/**
 Delegates receive this callback whenever a user cancels a session
 
 @param result A `MiSnapFacialCaptureResults` object with an intermediate frame results.
*/
- (void)miSnapFacialCaptureAnalyzerCancelled:(MiSnapFacialCaptureResult *)result;
/**
 Delegates receive this callback when device supports Manual only frame selection (iOS < 12.0)
*/
- (void)miSnapFacialCaptureAnalyzerManualOnly;
/**
 Delegates receive this callback when `selectOnSmile` parameter is  to `FALSE` and `countdownTime` is greater than or equal to `1` (second).
 
 @see `MiSnapFacialCaptureParameters`
*/
- (void)miSnapFacialCaptureAnalyzerStartCountdown;
/**
 Delegates receive this callback only when license status is anything but valid
 
 @param status  See `MiSnapLicenseStatus`
*/
- (void)miSnapFacialCaptureAnalyzerLicenseStatus:(MiSnapLicenseStatus)status;

@end

/**
MiSnapFacialCaptureAnalyzer is a class that defines an interface for controlling analysis of a frame.
*/
@interface MiSnapFacialCaptureAnalyzer : NSObject
/**
 An object conforming to the `MiSnapFacialCaptureAnalyzerDelegate` protocol that will receive callbacks when they're available
*/
@property (nonatomic, weak) id<MiSnapFacialCaptureAnalyzerDelegate> delegate;
/**
 Creates an instance of MiSnapFacialCaptureAnalyzer
 
 @param parameters The `MiSnapFacialCaptureParameters` to use
 
 @return An instance of MiSnapFacialCaptureAnalyzer
*/
- (instancetype)initWithParameters:(MiSnapFacialCaptureParameters *)parameters delegate:(id<MiSnapFacialCaptureAnalyzerDelegate>)delegate;
/**
 Pause the frame analysis for no specific reason. The analyzer can resume again from the paused state.
*/
- (void)pause;
/**
 Pause the frame analysis for one of the tutorial modes. The analyzer can resume again from the paused state.
 @param tutorialMode `MiSnapFacialCaptureTuturialMode`
*/
- (void)pauseFor:(MiSnapFacialCaptureTuturialMode)tutorialMode;
/**
 Starts the frame analysis or resumes if it was paused
*/
- (void)resume;
/**
 Stops the frame analysis and deinitializes all internal objects. Must be called before deinitializing `MiSnapFacialCaptureAnalyzer`
*/
- (void)stop;
/**
 Returns intermediate results and calls `stop`
*/
- (void)cancel;
/**
 Analyzes a provided `CMSampleBuffer`
 
 @param sampleBuffer  A `CMSampleBuffer` object containing the video frame data and additional information about the frame, such as its format and presentation time.
*/
- (void)analyzeSampleBuffer:(CMSampleBufferRef)sampleBuffer;
/**
 Updates `MiSnapFacialCaptureAnalyzer` parameters
 
@param parameters `MiSnapFacialCaptureParameters`
*/
- (void)updateParameters:(MiSnapFacialCaptureParameters *)parameters;
/**
 Select the current frame regardless of analysis result
*/
- (void)selectFrame;
/**
 Logs module with its name and version in MIBI
 */
- (void)logModuleWithName:(NSString *)name version:(NSString *)version;

@end
