//
//  MiSnapBarcodeScannerCamera.h
//  MiSnapBarcodeScanner
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MiSnapBarcodeScannerCameraDelegate <NSObject>

@required

/*!
 @method didReceiveSampleBuffer:
 @abstract
 Called whenever a MiSnapBarcodeScannerCamera instance outputs a new video frame.
 
 @param sampleBuffer
 A CMSampleBuffer object containing the video frame data and additional information about the frame, such as its format and presentation time.
 
 @discussion
 Delegates receive this message whenever the output captures and outputs a new video frame, decoding or re-encoding it as specified by its videoSettings property. Delegates can use the provided video frame in conjunction with other APIs for further processing. This method will be called on the dispatch queue specified by the output's videoQueue property. This method is called periodically, so it must be efficient to prevent capture performance problems, including dropped frames.
 
     Clients that need to reference the CMSampleBuffer object outside of the scope of this method must CFRetain it and then CFRelease it when they are finished with it.
 
 Note that to maintain optimal performance, some sample buffers directly reference pools of memory that may need to be reused by the device system and other capture inputs. This is frequently the case for uncompressed device native capture where memory blocks are copied as little as possible. If multiple sample buffers reference such pools of memory for too long, inputs will no longer be able to copy new samples into memory and those samples will be dropped. If your application is causing samples to be dropped by retaining the provided CMSampleBuffer objects for too long, but it needs access to the sample data for a long period of time, consider copying the data into a new buffer and then calling CFRelease on the sample buffer if it was previously retained so that the memory it references can be reused.
 */
- (void)didReceiveSampleBuffer:(CMSampleBufferRef _Nonnull )sampleBuffer;

@optional

/*!
 @method didDropSampleBuffer:
 @abstract
 Called once for each frame that is discarded.
 
 @param sampleBuffer
 A CMSampleBuffer object containing information about the dropped frame, such as its format and presentation time. This sample buffer will contain none of the original video data.
 
 @discussion
 Delegates receive this message whenever a video frame is dropped. This method is called once for each dropped frame. The CMSampleBuffer object passed to this delegate method will contain metadata about the dropped video frame, such as its duration and presentation time stamp, but will contain no actual video data.
 */
- (void)didDropSampleBuffer:(CMSampleBufferRef _Nonnull )sampleBuffer;

/*! @abstract This method is called after configuration of the MiSnapBarcodeScannerCamera
 
 @discussion
 MiSnapBarcodeScannerCamera configuration must be done before final UX configuration to allow a smooth
 transition to the video presentation.
 */
- (void)didFinishConfiguringSession;

@end

/*!
 @class MiSnapBarcodeScannerCamera
 @abstract
 MiSnapBarcodeScannerCamera is a class that defines an interface for a camera that implements an AVCaptureSession.
 
 @discussion
 MiSnapBarcodeScannerCamera is an interface for creating and managing an instance of a camera abstration.
 
 Delegates of a MiSnapBarcodeScannerCamera instance that imlement the MiSnapBarcodeScannerCameraDelegate protocol will receive the defined callbacks.
 
 Management of a camera session includes checking permission, starting, stopping, controlling the torch, and taking a still picture.
 */
@interface MiSnapBarcodeScannerCamera : UIView

/*! @abstract The delegate that implements the MiSnapBarcodeScannerCameraDelegate and that will receive the
 required protocol methods from MiSnapBarcodeScannerCamera
 */
@property (nonatomic, weak) id <MiSnapBarcodeScannerCameraDelegate> _Nullable delegate;

/*! @abstract When set to TRUE runs session with RGBA images. When set to FALSE runs session with Gray images.
 Default is TRUE.
 */
@property (nonatomic) BOOL analyzeRGBVideo;

/*! @abstract When set to TRUE the torch is ion auto mode. When set to FALSE the torch is not in auto mode.
 Default is TRUE.
 */
@property (nonatomic) BOOL torchInAutoMode;

/*! @abstract Controls the camera orientation.
 This should be set to the [UIApplication sharedApplication].statusBarOrientation
 */
@property (nonatomic) UIInterfaceOrientation cameraOrientation;

/*! @abstract Sets the AVCaptureSessionPreset of the camera session
 */
@property (nonatomic) AVCaptureSessionPreset _Nonnull sessionPreset;

/*! @abstract Provides the videoQueue of the camera session
 */
@property (nonatomic, readonly) dispatch_queue_t _Nonnull videoQueue;

/*!
 @abstract Creates an instance of MiSnapBarcodeScannerCameraDelegate
 @param sessionPreset the AVCaptureSessionPreset to use
 @param frame the frame for the MiSnapBarcodeScannerCamera view
 @return an instance of MiSnapBarcodeScannerCamera that is initialized and ready to start
 */
- (instancetype _Nullable )initWithSessionPreset:(AVCaptureSessionPreset _Nullable )sessionPreset pixelBufferFormat:(NSInteger)pixelBufferFormat andFrame:(CGRect)frame;

- (void)setSessionPreset:(AVCaptureSessionPreset _Nullable )sessionPreset pixelBufferFormat:(NSInteger)pixelBufferFormat;

/*!
 @abstract Updates the preview layer with a deviceOrientation
 @param deviceOrientation the orientation to set for the preview layer
 */
- (void)updatePreviewLayer:(UIInterfaceOrientation)deviceOrientation;

/*!
 @abstract Checks the camera permission
 @return a bool indicating the camera permission that has been set
 */
+ (bool)checkCameraPermission;

/*!
 @abstract Start the camera to begin callbacks from the MiSnapBarcodeScannerCameraDelegate
 */
- (void)start;

/*!
 @abstract Stop the camera and callbacks from the MiSnapBarcodeScannerCameraDelegate. The camera can
 start again from the stopped state.
 */
- (void)stop;

/*!
 @abstract Shutdown the camera. To continue use, the camera must be initialized again.
 */
- (void)shutdown;

/*!
 @abstract Check if the status of the torch
 @return a BOOL indicating the torch is either ON or OFF
 */
- (BOOL)isTorchOn;

/*!
 @abstract Change the status of the torch to ON
 @return a BOOL indicating the torch status changed to ON
 */
- (BOOL)turnTorchOn;

/*!
 @abstract Change the status of the torch to OFF
 @return a BOOL indicating the torch status changed to OFF
 */
- (BOOL)turnTorchOff;

/*!
 @abstract Check that the device has a torch
 @return a BOOL indicating the device has a torch or not
 */
- (BOOL)hasTorch;

@end
