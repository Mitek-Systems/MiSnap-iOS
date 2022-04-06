//
//  MiSnapFacialCaptureCamera.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 10/27/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureCameraParameters.h>

/**
 Defines an interface for delegates of MiSnapFacialCaptureCameraDelegate
*/
@protocol MiSnapFacialCaptureCameraDelegate <NSObject>

@required
/**
 Called whenever a `MiSnapFacialCaptureCamera` instance outputs a new video frame (`CMSampleBufferRef`)
 
 @param sampleBuffer
 A `CMSampleBuffer` object containing the video frame data and additional information about the frame, such as its format and presentation time.
 
 Delegates receive this message whenever the output captures and outputs a new video frame, decoding or re-encoding it as specified by its videoSettings property. Delegates can use the provided video frame in conjunction with other APIs for further processing. This method will be called on the dispatch queue specified by the output's videoQueue property. This method is called periodically, so it must be efficient to prevent capture performance problems, including dropped frames.
 
 Clients that need to reference the CMSampleBuffer object outside of the scope of this method must CFRetain it and then CFRelease it when they are finished with it.
 
 Note that to maintain optimal performance, some sample buffers directly reference pools of memory that may need to be reused by the device system and other capture inputs. This is frequently the case for uncompressed device native capture where memory blocks are copied as little as possible. If multiple sample buffers reference such pools of memory for too long, inputs will no longer be able to copy new samples into memory and those samples will be dropped. If your application is causing samples to be dropped by retaining the provided CMSampleBuffer objects for too long, but it needs access to the sample data for a long period of time, consider copying the data into a new buffer and then calling CFRelease on the sample buffer if it was previously retained so that the memory it references can be reused.
*/
- (void)didReceiveSampleBuffer:(CMSampleBufferRef _Nullable)sampleBuffer;

@optional

/**
 @param sampleBuffer
 A CMSampleBuffer object containing information about the dropped frame, such as its format and presentation time. This sample buffer will contain none of the original video data.
 
 Delegates receive this message whenever a video frame is dropped. This method is called once for each dropped frame. The CMSampleBuffer object passed to this delegate method will contain metadata about the dropped video frame, such as its duration and presentation time stamp, but will contain no actual video data.
*/
- (void)didDropSampleBuffer:(CMSampleBufferRef _Nullable)sampleBuffer;

/**
 Camera configuration must be done before final UX configuration to allow a smooth transition to the video presentation.
 
 Delegates receive this message when camera was configured and ready for use.
*/
- (void)didFinishConfiguringSession;

/**
 Delegates receive this message whenever a PDF417 Data is decoded. This method is called once for each frame where a barcode is decoded. The NSString object passed to this delegate method will contain PDF417 Data.
 
 @param decodedBarcodeString
 A NSString object containing PDF417 Data
 
 - Note: detectPDF417 property of `MiSnapFacialCaptureCamera` should be set to TRUE to enable Camera to decode barcodes
*/
- (void)didDecodeBarcode:(NSString *_Nullable)decodedBarcodeString;

/**
 Delegates receive this message whenever a video is recorded. The NSData object passed to this delegate method contains recorded video.
 
 - Note: RecordVideo property of MiSnapFacialCaptureCameraParameters should be set to TRUE to enable MiSnapFacialCapture to record videos
 */
- (void)didFinishRecordingVideo:(NSData *_Nullable)videoData;

@end

/**
 MiSnapFacialCaptureCamera is a class that defines an interface for a camera that implements an AVCaptureSession.
 */
@interface MiSnapFacialCaptureCamera : UIView
/**
 The delegate that implements the `MiSnapFacialCaptureCameraDelegate` and that will receive the required protocol methods from `MiSnapFacialCaptureCamera`
 */
@property (nonatomic, weak) id <MiSnapFacialCaptureCameraDelegate> _Nullable delegate;
/**
 `TRUE` indicates that camera doesn't require configuration. `FALSE` indicates that camera hasn't been configured yet
*/
@property (readonly, getter=isConfigured) BOOL configured;
/**
 The resolution (`CGSize`) of `MiSnapFacialCaptureCamera`
*/
@property (readonly) CGSize resolution;
/**
 When set to `TRUE` runs session with RGBA images. When set to `FALSE` runs session with Gray images.
 
 Default: `TRUE`
 */
@property (nonatomic) BOOL analyzeRGBVideo;
/**
 When set to `TRUE` enables barcode scanning capabilities. When set to `FALSE` barcode scanning capabilities are disabled.
 
 Default: `FALSE`
 */
@property (nonatomic) BOOL detectPDF417;
/**
 An object that configures camera specific parameters
 */
@property (nonatomic) MiSnapFacialCaptureCameraParameters *_Nullable parameters;
/**
 Creates an instance of `MiSnapFacialCaptureCamera`
 @param sessionPreset the `AVCaptureSessionPreset` to use
 @param pixelBufferFormat the `kCVPixelFormatType` to use
 @param position the `AVCaptureDevicePosition` to use
 @param frame the frame for the `MiSnapFacialCaptureCamera` view
 @return an instance of `MiSnapFacialCaptureCamera` that is initialized and ready to start
 */
- (instancetype _Nullable )initWithPreset:(AVCaptureSessionPreset _Nullable)sessionPreset format:(NSInteger)pixelBufferFormat position:(AVCaptureDevicePosition)position frame:(CGRect)frame;
/**
 Creates an instance of `MiSnapFacialCaptureCamera`
 @param sessionPreset the `AVCaptureSessionPreset` to use
 @param pixelBufferFormat the `kCVPixelFormatType` to use
 @param position the `AVCaptureDevicePosition` to use
 @param cameraOrientation the `UIInterfaceOrientation` of `MiSnapFacialCaptureCamera`
 @param frame the frame for the `MiSnapFacialCaptureCamera` view
 @return an instance of `MiSnapFacialCaptureCamera` that is initialized and ready to start
*/
- (instancetype _Nullable)initWithPreset:(AVCaptureSessionPreset _Nullable)sessionPreset format:(NSInteger)pixelBufferFormat position:(AVCaptureDevicePosition)position orientation:(UIInterfaceOrientation)cameraOrientation frame:(CGRect)frame;
/**
 Creates an instance of MiSnapSDKCamera
 @param desiredResolution the desired resolution (`CGSize`) for the `MiSnapFacialCaptureCamera`
 @param pixelBufferFormat the `kCVPixelFormatType` to use
 @param position the `AVCaptureDevicePosition` to use
 @param frame the frame for the `MiSnapFacialCaptureCamera`  view
 @return an instance of `MiSnapFacialCaptureCamera` that is initialized and ready to start
 */
- (instancetype _Nullable)initWithDesiredResolution:(CGSize)desiredResolution format:(NSInteger)pixelBufferFormat position:(AVCaptureDevicePosition)position frame:(CGRect)frame;
/**
 Sets a session preset and pixel buffer format
 @param sessionPreset the `AVCaptureSessionPreset` to set
 @param pixelBufferFormat the `kCVPixelFormatType` to set
 */
- (void)setPreset:(AVCaptureSessionPreset _Nullable)sessionPreset format:(NSInteger)pixelBufferFormat;
/**
Sets a session preset, pixel buffer format and device position
@param sessionPreset the `AVCaptureSessionPreset` to set
@param pixelBufferFormat the `kCVPixelFormatType` to set
@param devicePosition the `AVCaptureDevicePosition` to set
*/
- (void)setPreset:(AVCaptureSessionPreset _Nullable)sessionPreset format:(NSInteger)pixelBufferFormat position:(AVCaptureDevicePosition)devicePosition;
/**
 Updates the preview layer with a `UIInterfaceOrientation` deviceOrientation
 
 @param deviceOrientation the `UIInterfaceOrientation` to set for the preview layer
 */
- (void)updatePreviewLayer:(UIInterfaceOrientation)deviceOrientation;
/**
 Checks the camera permission
 */
+ (void)checkCameraPermission:(void (^_Nonnull)(BOOL granted))handler;
/**
 Checks the microphone permission
 */
+ (void)checkMicrophonePermission:(void (^_Nonnull)(BOOL granted))handler;
/**
 Starts the camera to begin callbacks from the `MiSnapFacialCaptureCameraDelegate`
 */
- (void)start;
/**
 Stops the camera and callbacks from the `MiSnapFacialCaptureCameraDelegate`.
 
 The camera can start again from the stopped state.
 */
- (void)stop;
/**
 Shutdown the camera. To continue use, the camera must be initialized again.
 */
- (void)shutdown;
/**
 Discards a video recording if it exists on cancel or timeout events
*/
- (void)discardRecording;
/**
 Check if the status of the torch
 @return a `BOOL` indicating the torch is either `ON` or `OFF`
 */
- (BOOL)isTorchOn;
/**
 Change the status of the torch to `ON`
 @return a `BOOL` indicating the torch status changed to ON
 */
- (BOOL)turnTorchOn;
/**
 Change the status of the torch to `OFF`
 @return a `BOOL` indicating the torch status changed to `OFF`
 */
- (BOOL)turnTorchOff;
/**
 Check that the device has a torch
 @return a `BOOL` indicating the device has a torch or not
 */
- (BOOL)hasTorch;

@end
