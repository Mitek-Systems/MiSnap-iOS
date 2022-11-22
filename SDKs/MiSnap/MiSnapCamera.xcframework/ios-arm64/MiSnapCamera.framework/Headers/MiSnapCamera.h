//
//  MiSnapCamera.h
//  MiSnapCamera
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapCamera/MiSnapCameraParameters.h>

/**
 Defines an interface for delegates of `MiSnapCamera` to receive callbacks
 */
@protocol MiSnapCameraDelegate <NSObject>

@required

/**
 Delegates receive this message whenever the output captures and outputs a new video frame, decoding or re-encoding it as specified by its videoSettings property. Delegates can use the provided video frame in conjunction with other APIs for further processing. This method is called periodically, so it must be efficient to prevent capture performance problems, including dropped frames.
 
     Clients that need to reference the CMSampleBuffer object outside of the scope of this method must CFRetain it and then CFRelease it when they are finished with it.
 
 Note that to maintain optimal performance, some sample buffers directly reference pools of memory that may need to be reused by the device system and other capture inputs. This is frequently the case for uncompressed device native capture where memory blocks are copied as little as possible. If multiple sample buffers reference such pools of memory for too long, inputs will no longer be able to copy new samples into memory and those samples will be dropped. If your application is causing samples to be dropped by retaining the provided CMSampleBuffer objects for too long, but it needs access to the sample data for a long period of time, consider copying the data into a new buffer and then calling CFRelease on the sample buffer if it was previously retained so that the memory it references can be reused.
 
 @param sampleBuffer A CMSampleBuffer object containing the video frame data and additional information about the frame, such as its format and presentation time.
 */
- (void)didReceiveSampleBuffer:(CMSampleBufferRef _Nonnull )sampleBuffer;

@optional

/**
 Delegates receive this message whenever a video frame is dropped. This method is called once for each dropped frame. The CMSampleBuffer object passed to this delegate method will contain metadata about the dropped video frame, such as its duration and presentation time stamp, but will contain no actual video data.
 
 @param sampleBuffer A CMSampleBuffer object containing metadata such as duration and presentation time stamp but no actual video data
 */
- (void)didDropSampleBuffer:(CMSampleBufferRef _Nonnull )sampleBuffer;

/**
 Delegates receive this message after `MiSnapCamera` is configured and ready to be used
 */
- (void)didFinishConfiguringSession;

/**
 Delegates receive this message whenever a PDF417 Data is decoded. This method is called once for each frame where a barcode is decoded. The `NSString` object passed to this delegate method will contain PDF417 decoded string.
 
 @param decodedBarcodeString An `NSString` object containing PDF417 decoded string
 
 @note `scanBarcode` property of `MiSnapCamera` should be set to TRUE to enable decoding barcodes
 */
- (void)didDecodeBarcode:(NSString *_Nonnull)decodedBarcodeString;

/**
 Delegates receive this message whenever a video is recorded. The NSData object passed to this delegate method contains recorded video.
 
 @param videoData
 A NSData object that represents a recorded video
  
 @note `recordVideo` property of `MiSnapCameraParameters` should be set to TRUE to enable recording videos
 */
- (void)didFinishRecordingVideo:(NSData *_Nullable)videoData;

@end

/**
 An interface for a camera that implements an AVCaptureSession.
 */
@interface MiSnapCamera: UIView
/**
 Version
 */
+ (NSString * _Nonnull)version;
/**
 An object conforming to the `MiSnapCameraDelegate` protocol that will receive callbacks when they're available
 */
@property (nonatomic, readwrite, weak) NSObject<MiSnapCameraDelegate> * _Nullable delegate;
/**
 An object that configures camera specific parameters
 */
@property (nonatomic, readwrite) MiSnapCameraParameters  * _Nonnull parameters;

/**
 Controls the camera orientation.
 */
@property (nonatomic, readwrite) UIInterfaceOrientation orientation;

/**
 `TRUE` indicates that camera doesn't require configuration. `FALSE` indicates that camera hasn't been yet configured yet
*/
@property (nonatomic, readonly, getter=isConfigured) BOOL configured;

/**
 Indicates whether a device has a torch or not
 */
@property (nonatomic, readonly) BOOL hasTorch;

/**
 Iindicates whether the torch is ON or OFF
 */
@property (nonatomic, readonly, getter=isTorchOn) BOOL torchOn;

/**
 Creates an instance of `MiSnapCamera`
 */
- (instancetype _Nonnull)initWith:(MiSnapCameraParameters * _Nonnull)parameters orientation:(UIInterfaceOrientation)orientation delegate:(NSObject<MiSnapCameraDelegate> * _Nullable)delegate frame:(CGRect)frame;

/**
 Updates the preview layer with an orientation
 
 @param orientation the orientation to set for the preview layer
 */
- (void)updatePreviewLayer:(UIInterfaceOrientation)orientation;

/**
 Checks the camera permission
 */
+ (void)checkCameraPermission:(void (^_Nonnull)(BOOL granted))handler;

/**
 Checks the microphone permission
 */
+ (void)checkMicrophonePermission:(void (^_Nonnull)(BOOL granted))handler;

/**
 Start the camera to begin callbacks for the `MiSnapCameraDelegate`
 */
- (void)start;

/**
 Stop the camera and callbacks from the `MiSnapCameraDelegate`.
 
 The camera can start again from the stopped state.
 */
- (void)stop;

/**
 Shutdown the camera.
 
 To continue use, the camera must be initialized again.
 */
- (void)shutdown;

/**
 Turns torch on
 @return a BOOL indicating the torch status changed to ON
 */
- (BOOL)turnTorchOn;

/**
 Turn torch off
 @return a BOOL indicating the torch status changed to OFF
 */
- (BOOL)turnTorchOff;

/**
A convenience method to discards a video recording if it exists on cancel or timeout events
*/
- (void)discardRecording;

/**
 Sets an `image` that will be output in didReceiveSampleBuffer: callback with a given `frameRate`
 
 @note Only applies to a Simulator
 */
- (void)setImage:(UIImage * _Nullable)image frameRate:(NSInteger)frameRate;

@end
