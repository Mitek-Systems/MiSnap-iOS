//
//  MiSnapCameraParameters.h
//  MiSnapCamera
//
//  Created by Stas Tsuprenko on 2/17/21.
//  Copyright © 2021 miteksystems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 Barcode type
 */
typedef NS_ENUM(NSInteger, MiSnapCameraBarcodeType) {
    /**
     PDF417
     */
    MiSnapCameraBarcodeTypePDF417              = 0,
    /**
     QR
     */
    MiSnapCameraBarcodeTypeQR                  = 1,
    /**
     Aztec
     */
    MiSnapCameraBarcodeTypeAztec               = 2,
    /**
     Code 39
     */
    MiSnapCameraBarcodeTypeCode39              = 3,
    /**
     Code 93
     */
    MiSnapCameraBarcodeTypeCode93              = 4,
    /**
     Code 128
     */
    MiSnapCameraBarcodeTypeCode128             = 5,
    /**
     Interleaved 2 of 5
     */
    MiSnapCameraBarcodeTypeInterleaved2of5     = 6
};

NS_ASSUME_NONNULL_BEGIN

/**
 Torch mode
 */
typedef NS_ENUM(NSInteger, MiSnapCameraTorchMode) {
    /**
     Torch is off
     */
    MiSnapCameraTorchModeOff    = 0,
    /**
     Torch is on
     */
    MiSnapCameraTorchModeOn     = 1
};

/**
 Camera specific parameters
 */
@interface MiSnapCameraParameters : NSObject
/**
 Sets the preset of the camera session.
 
 Default: AVCaptureSessionPreset1920x1080
 */
@property (nonatomic, readwrite) AVCaptureSessionPreset _Nonnull preset;

/**
 Sets the pixel buffer format of the camera session
 
 Default: kCVPixelFormatType_32BGRA
 */
@property (nonatomic, readwrite) NSInteger pixelBufferFormat;
/**
 Sets the camera position
 
 Default: AVCaptureDevicePositionBack
 */
@property (nonatomic) AVCaptureDevicePosition position;
/**
 Torch mode
 
 @see `MiSnapCameraTorchMode`
 */
@property (nonatomic, readwrite) MiSnapCameraTorchMode torchMode;
/**
 When set to TRUE a video recording of a session (no sound) is returned. When set to FALSE a session is not recorded
 
 Default: FALSE.
 */
@property (nonatomic, readwrite) BOOL recordVideo;
/**
 When set to TRUE and recordVideo set to TRUE a video recording of a session with sound is returned. When set to FALSE audio is not recorded
 
 Default: FALSE.
 */
@property (nonatomic, readwrite) BOOL recordAudio;
/**
 Specifies relative quality of a recorded video
 
 Range: [10, 100]
 
 10 - video is recorded with a minimum supported bitrate (the smallest size with a decent quality)
 
 100 - video is recorded with a highest supported bitrate (the biggest size with the best quality)
 
 Default: 10
 */
@property (nonatomic, readwrite) NSInteger videoQuality;
/**
 Show recording UI
 
 Values: 0, 1
 
 Key: kMiSnapShowRecordingUI
 
 @note Only used  when `recordVideo` parameter is `TRUE`
 */
@property (nonatomic, readwrite) BOOL showRecordingUI;
/**
 Indicates whether a camera should be configured to scan barcodes
 
 Default: FALSE.
 
 @note It's recommended to override to TRUE if your app supports
 only AAMVA PDF417 barcodes (US and Canada driver licenses)
 as there's a defect in Apple's API where non-English alphabet characters
 are decoded inacurately (e.g. Spanish and other international DLs)
 
 When overridden to TRUE only PDF417 barcode is being detected by default
 but list of supported barcodes can be modified by overriding `supportedBarcodeTypes` property
 */
@property (nonatomic, readwrite) BOOL scanBarcode;
/**
 An array of `MiSnapCameraBarcodeType` a camera should scan for
 */
@property (nonatomic, readwrite) NSArray * _Nonnull supportedBarcodeTypes;
/**
 Locked focus dictionary
 
 where,
 
 key is a device model (e.g. iPhone15,3)
 
 value is a locked focus float value in a range [0.0, 1.0]
 
 Default: nil
 
 - Note, it's not recommended to set this property without consulting with Mitek representative
 */
@property (nonatomic) NSDictionary * _Nullable lockedFocusDictionary;
/**
 @return Dictionary of parameters
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
