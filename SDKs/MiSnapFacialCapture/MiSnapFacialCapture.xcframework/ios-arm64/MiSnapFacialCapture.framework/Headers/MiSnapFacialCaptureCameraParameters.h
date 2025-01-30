//
//  MiSnapFacialCaptureCameraParameters.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 2/17/21.
//  Copyright © 2021 miteksystems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Camera specific parameters
 */
@interface MiSnapFacialCaptureCameraParameters : NSObject
/**
 When set to TRUE a video recording of a session (no sound) is returned. When set to FALSE a session is not recorded
 
 Default: FALSE.
 */
@property (nonatomic) BOOL recordVideo;
/**
 When set to TRUE and recordVideo set to TRUE a video recording of a session with sound is returned. When set to FALSE audio is not recorded
 
 Default: FALSE.
 */
@property (nonatomic) BOOL recordAudio;
/**
 Specifies relative quality of a recorded video
 
 Range: [10, 100]
 
 10 - video is recorded with a minimum supported bitrate (the smallest size with a decent quality)
 
 100 - video is recorded with a highest supported bitrate (the biggest size with the best quality)
 
 Default: 10
 */
@property (nonatomic) NSInteger videoQuality;
/**
 Show recording UI
 
 Values: 0, 1
 
 Key: kMiSnapShowRecordingUI
 
 - Note: Only used  when `recordVideo` parameter is `TRUE`
 */
@property (nonatomic) BOOL showRecordingUI;
/**
 RTS enabled
 
 Default: `FALSE`
 */
@property (nonatomic) BOOL aiBasedRtsEnabled;

@end

NS_ASSUME_NONNULL_END
