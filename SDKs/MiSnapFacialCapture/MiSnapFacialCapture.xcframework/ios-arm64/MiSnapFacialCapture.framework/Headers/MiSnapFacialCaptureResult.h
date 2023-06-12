//
//  MiSnapFacialCaptureResults.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureParameters.h>
#import <MiSnapMibiData/MiSnapMibiData.h>

/**
 Statuses returned by MiSnapFacialCapture.
*/
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureStatus) {
    /**
     Status is not set
     */
    MiSnapFacialCaptureStatusNone               = 0,
    /**
     A face is not found
     */
    MiSnapFacialCaptureStatusFaceNotFound       = 1,
    /**
     More then one face found
     */
    MiSnapFacialCaptureStatusMoreThanOneFace    = 2,
    /**
     Excessive roll (head leans left and right)
     */
    MiSnapFacialCaptureStatusFaceRoll           = 3,
    /**
     Excessive pitch (nose moves up and down / nod)
     */
    MiSnapFacialCaptureStatusFacePitch          = 4,
    /**
     Excessive yaw (nose moves left to right and vice versa)
     */
    MiSnapFacialCaptureStatusFaceYaw            = 5,
    /**
     A face is too far
     */
    MiSnapFacialCaptureStatusTooFar             = 6,
    /**
     A face is too close
     */
    MiSnapFacialCaptureStatusTooClose           = 7,
    /**
     A face is too close to one of the screen edges
     */
    MiSnapFacialCaptureStatusFaceNotCentered    = 8,
    /**
     Excessive device movement
     */
    MiSnapFacialCaptureStatusHoldStill          = 9,
    /**
     A countdown is in progress. A user should hold still
     */
    MiSnapFacialCaptureStatusCountdown          = 10,
    /**
     Insufficient lighting conditions
     
     - Note: Not implemented yet. Exposed for future use.
     */
    MiSnapFacialCaptureStatusTooDark            = 11,
    /**
     One side of a face is lit significantly more than another
     
     - Note: Not implemented yet. Exposed for future use.
     */
    MiSnapFacialCaptureStatusNonUniformLight    = 12,
    /**
     A user should stop smiling
     */
    MiSnapFacialCaptureStatusStopSmiling        = 13,
    /**
     A frame passed all Image Quality Analysis (IQA) checks
     */
    MiSnapFacialCaptureStatusGood               = 14
};
/**
 Result code
 */
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureResultCode) {
    /**
     Result code is not set
     */
    MiSnapFacialCaptureResultCodeNone = 0,
    /**
     A session was completed by manually acquiring an image
     */
    MiSnapFacialCaptureResultCodeSuccessStillCamera,
    /**
     A session was completed by automatically acquiring an image that passed Image Quality Analysis checks
     */
    MiSnapFacialCaptureResultCodeSuccessVideo,
    /**
     A session was cancelled by a user
     */
    MiSnapFacialCaptureResultCodeCancelled
};
/**
MiSnapFacialCaptureResults is a class that defines an interface for results returned by the SDK
*/
@interface MiSnapFacialCaptureResult : NSObject
/**
The highest priority status for the current frame
 
- Note: Priority order is based on `MiSnapFacialCaptureStatus` enum
*/
@property (nonatomic, readonly) MiSnapFacialCaptureStatus highestPriorityStatus;
/**
An array of ordered statuses for the current frame
 
- Note: Priority order is based on `MiSnapFacialCaptureStatus` enum
*/
@property (nonatomic, readonly) NSArray * _Nonnull orderedStatuses;
/**
A `CGRect` rectangle of a face
*/
@property (nonatomic, readonly) CGRect faceRect;
/**
An array of face countour points
*/
@property (nonatomic, readonly) NSArray * _Nullable faceContourPoints;
/**
An array of nose crest points
*/
@property (nonatomic, readonly) NSArray * _Nullable noseCrestPoints;
/**
An array of nose points
*/
@property (nonatomic, readonly) NSArray * _Nullable nosePoints;
/**
An array of left eye points
*/
@property (nonatomic, readonly) NSArray * _Nullable leftEyePoints;
/**
An array of right eye points
*/
@property (nonatomic, readonly) NSArray * _Nullable rightEyePoints;
/**
An array of inner lip points
*/
@property (nonatomic, readonly) NSArray * _Nullable innerLipsPoints;
/**
An array of outer lip points
*/
@property (nonatomic, readonly) NSArray * _Nullable outerLipsPoints;
/**
 An image that was selected based on environmental thresholds defined in `MiSnapFacialCaptureParameters` in `MiSnapFacialCaptureModeAuto` or the frame that was manually selected by a user in `MiSnapFacialCaptureModeManual`
 
 - Note: It's `nil` if the current frame doesn't meet environmental thresholds defined in `MiSnapFacialCaptureParameters` in `MiSnapFacialCaptureModeAuto` or not yet selected by a user in `MiSnapFacialCaptureModeManual`
*/
@property (nonatomic, readonly) UIImage * _Nullable image;
/**
 A base64 encoded representation of an `image`
 
 - Note: it's `nil` if the `image` is nil
*/
@property (nonatomic, readonly) NSString * _Nullable encodedImage;
/**
 A MIBI Data string that has analytics for the session
 
 -Note: It's `nil` unitl a frame is acquired
*/
@property (nonatomic, readonly) NSString * _Nullable mibiDataString DEPRECATED_MSG_ATTRIBUTE("Use `mibi` property instead");
/**
 An object containing non-PII session analytics
 */
@property (nonatomic, readonly) MiSnapMibi * _Nonnull mibi;
/**
 A result code of a session
 
 @see `MiSnapFacialCaptureResult`
*/
@property (nonatomic, readonly) MiSnapFacialCaptureResultCode resultCode;
/**
 @return A localiize key that can be used by UX to query Localizable.strings file to get a localized string
*/
+ (NSString * _Nonnull)localizeKeyFrom:(MiSnapFacialCaptureStatus)status;
/**
 A convenience method for getting a string code representation of `MiSnapFacialCaptureStatus` value
 */
+ (NSString * _Nonnull)codeFromStatus:(MiSnapFacialCaptureStatus)status;
/**
 @param resultCode Result code to get string representation of
 @return A result code in `NSString` format
*/
+ (NSString * _Nonnull)stringFrom:(MiSnapFacialCaptureResultCode)resultCode;

@end
