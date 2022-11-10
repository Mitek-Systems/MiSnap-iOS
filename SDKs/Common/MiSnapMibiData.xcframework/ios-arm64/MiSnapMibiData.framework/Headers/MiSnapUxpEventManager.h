//
//  MiSnapUxpEventManager.h
//  MiSnapMibiData
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UXP event
 */
typedef NS_ENUM(NSInteger, MiSnapUxpEvent) {
    /**
     UXP event is not set
     */
    MiSnapUxpEventNone = 0,
    /**
     Check Front is expected but some other document is found
     */
    MiSnapUxpEventCheckFrontFailure,
    /**
     Check Back is expected but Check Front is found
     */
    MiSnapUxpEventCheckBackFailure,
    /**
     Front of identity document is expected but some other document is found
     */
    MiSnapUxpEventIdentityFrontFailure,
    /**
     Back of identity document is expected but some other document is found
     */
    MiSnapUxpEventIdentityBackFailure,
    /**
     Passport is expected but some other document is found
     */
    MiSnapUxpEventPassportFailure,
    /**
     A document is not found
     */
    MiSnapUxpEventNotFoundFailure,
    /**
     Document's MRZ confidence is below a threshold
     */
    MiSnapUxpEventMrzFailure,
    /**
     Contrast between a document and background is below a threshold
     */
    MiSnapUxpEventContrastFailure,
    /**
     Confidence that background doesn't have competing edges is below a threshold
     */
    MiSnapUxpEventBackgroundFailure,
    /**
     Tilt angle (one side of a document is closer to a camera than others) is above a threshold
     */
    MiSnapUxpEventAngleFailure,
    /**
     Rotation angle (a position of a document with respect to a guide) is above a threshold
     */
    MiSnapUxpEventRotationAngleFailure,
    /**
     A distance to a document is below a threshold
     */
    MiSnapUxpEventTooFarFailure,
    /**
     One or more document's edge are closer to a frame edge than a threshold allows
     */
    MiSnapUxpEventTooCloseFailure,
    /**
     A document with a wrong aspect ratio is found
     */
    MiSnapUxpEventAspectRatioFailure,
    /**
     Document's sharpness is below a threshold
     */
    MiSnapUxpEventSharpnessFailure,
    /**
     Document's brightness is below a threshold
     */
    MiSnapUxpEventBrightnessFailure,
    /**
     Document's brightness is above a threshold
     */
    MiSnapUxpEventMaxBrightnessFailure,
    /**
     Document's glare is below a threshold
     */
    MiSnapUxpEventGlareFailure,
    /**
     Classification is in progress
     */
    MiSnapUxpEventClassificationInProgress,
    /**
     A face is not found
     */
    MiSnapUxpEventFaceNotFoundFailure,
    /**
     A face is not centered
     */
    MiSnapUxpEventFaceNotCenteredFailure,
    /**
     Multiple faces are detected
     */
    MiSnapUxpEventFaceMultipleFacesFailure,
    /**
     Face roll is above a threshold
     */
    MiSnapUxpEventFaceRollFailure,
    /**
     Face pitch is above a threshold
     */
    MiSnapUxpEventFacePitchFailure,
    /**
     Face yaw is above a threshold
     */
    MiSnapUxpEventFaceYawFailure,
    /**
     A distance to a face is below a threshold
     */
    MiSnapUxpEventFaceTooFarFailure,
    /**
     A distance to a face is above a threshold
     */
    MiSnapUxpEventFaceTooCloseFailure,
    /**
     An excessive device movement is detected
     */
    MiSnapUxpEventFaceNotStillFailure,
    /**
     A smile detected when a user shouldn't smile
     */
    MiSnapUxpEventFaceStopSmilingFailure,
    /**
     Hold still when a countdown timer is presented
     */
    MiSnapUxpEventHoldStill,
    /**
     A user should smile
     */
    MiSnapUxpEventSmile,
    /**
     Verbose error
     */
    MiSnapUxpEventErrorVerbose,
    /**
     Verbose success
     */
    MiSnapUxpEventSuccessVerbose,
    /**
     Verbose timeout
     */
    MiSnapUxpEventTimeoutVerbose,
    /**
     Verbose start
     */
    MiSnapUxpEventStartVerbose,
    /**
     Verbose read
     */
    MiSnapUxpEventReadVerbose,
    /**
     Verbose unknown tag
     */
    MiSnapUxpEventUnknownTagVerbose,
    /**
     Verbose PACE support
     */
    MiSnapUxpEventPaceSupportVerbose,
    /**
     Verbose Chip Authentication support
     */
    MiSnapUxpEventCASupportVerbose,
    /**
     Verbose Active Authentication support
     */
    MiSnapUxpEventAASupportVerbose,
    /**
     Verbose access mechanism
     */
    MiSnapUxpEventAccessMechanismVerbose,
    /**
     Verbose data is discarded
     */
    MiSnapUxpEventDiscardVerbose,
    /**
     Verbose session is cancelled
     */
    MiSnapUxpEventCancelVerbose,
    /**
     A session is cancelled
     */
    MiSnapUxpEventCancel,
    /**
     An introductory instruction screen is presented
     */
    MiSnapUxpEventInstruction,
    /**
     A help screen is presented
     */
    MiSnapUxpEventHelp,
    /**
     A timeout screen is presented
     */
    MiSnapUxpEventTimeout,
    /**
     A review screen is presented
     */
    MiSnapUxpEventReview,
    /**
     Acquired frame's corner confidence
     */
    MiSnapUxpEventMeasuredConfidence,
    /**
     Acquired frame's corner points
     */
    MiSnapUxpEventMeasuredCornerPoints,
    /**
     Acquired frame's MICR confidence
     */
    MiSnapUxpEventMeasuredMicrConfidence,
    /**
     Acquired frame's contrast confidence
     */
    MiSnapUxpEventMeasuredContrast,
    /**
     Acquired frame's background confidence
     */
    MiSnapUxpEventMeasuredBackground,
    /**
     Acquired frame's tilt angle
     */
    MiSnapUxpEventMeasuredAngle,
    /**
     Acquired frame's rotation angle
     */
    MiSnapUxpEventMeasuredRotationAngle,
    /**
     Acquired frame's sharpness
     */
    MiSnapUxpEventMeasuredSharpness,
    /**
     Acquired frame's brightness (exposure)
     */
    MiSnapUxpEventMeasuredBrightness,
    /**
     Acquired frame's glare confidence
     */
    MiSnapUxpEventMeasuredGlare,
    /**
     Acquired document's width ratio relative to a frame width
     */
    MiSnapUxpEventMeasuredWidth,
    /**
     A frame is acquired in Auto mode
     */
    MiSnapUxpEventMeasuredAutoTime,
    /**
     A frame is acquired in Manual mode
     */
    MiSnapUxpEventMeasuredManualTime,
    /**
     A user chose to restart a session in Manual mode after a session timed out in Auto mode
     */
    MiSnapUxpEventMeasuredFailover,
    /**
     A torch was turned on
     */
    MiSnapUxpEventTorchOn,
    /**
     A torch was turned off
     */
    MiSnapUxpEventTorchOff,
    /**
     A session started in Auto mode
     */
    MiSnapUxpEventStartAuto,
    /**
     A session started in Manual mode
     */
    MiSnapUxpEventStartManual,
    /**
     A device is in Landscape orientation when an image is acquired
     */
    MiSnapUxpEventOrientationLandscape,
    /**
     A device is in Portrait orientation when an image is acquired
     */
    MiSnapUxpEventOrientationPortrait
};

/**
 Manages User Experience Payload (UXP) events during a session.
 */
@interface MiSnapUxpEventManager : NSObject
/**
 Singleton instance
 
 @return The `MiSnapUxpEventManager` instance.
 */
+ (instancetype _Nonnull)shared;
/**
 Destroys the singleton;
 
 Resets the session time and makes sure there's no memory leak
 */
+ (void)destroyShared;

/**
 Starts a new session by clearing the list and starting a timer
 */
- (void)start;
/**
 Adds the given event with its timestamp
 
 @param event `MiSnapUxpEvent` event to add
 @param value `NSString` value of the event
 */
- (void)addEvent:(MiSnapUxpEvent)event value:(NSString * _Nullable)value;
/**
 Adds the given event with its timestamp
 
 @param event `MiSnapUxpEvent` event to add
 */
- (void)addEvent:(MiSnapUxpEvent)event;
/**
UXP events added during the session
 */
@property (nonatomic, readonly) NSArray<NSDictionary *> * _Nonnull events;
/**
A total session duration
 */
@property (nonatomic, readonly) NSInteger totalDuration;

@end
