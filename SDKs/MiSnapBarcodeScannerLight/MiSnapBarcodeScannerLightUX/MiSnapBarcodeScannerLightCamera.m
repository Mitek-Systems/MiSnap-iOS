//
//  MiSnapBarcodeScannerLightCamera.m
//  MiSnapBarcodeScannerLightUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import "MiSnapBarcodeScannerLightCamera.h"

@interface MiSnapBarcodeScannerLightCamera() <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) AVCaptureSession *session;

@property (nonatomic) AVCaptureDeviceInput *deviceInput;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) AVCaptureMetadataOutput *metaDataOutput;
@property (nonatomic) AVCaptureDevice *captureDevice;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) NSInteger pixelBufferFormat;

@property (nonatomic) bool isTorchON;

@end

@implementation MiSnapBarcodeScannerLightCamera

- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)sessionPreset pixelBufferFormat:(NSInteger)pixelBufferFormat andFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        
        self.analyzeRGBVideo = TRUE;
        self.session = [[AVCaptureSession alloc] init];
        _videoQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        self.isTorchON = FALSE;
        self.torchInAutoMode = TRUE;
        self.frame = frame;
        self.pixelBufferFormat = pixelBufferFormat;
        self.sessionPreset = sessionPreset;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.analyzeRGBVideo = TRUE;
        self.session = [[AVCaptureSession alloc] init];
        _videoQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        self.isTorchON = FALSE;
        self.torchInAutoMode = TRUE;
        
    }
    return self;
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset pixelBufferFormat:(NSInteger)pixelBufferFormat
{
    self.pixelBufferFormat = pixelBufferFormat;
    self.sessionPreset = sessionPreset;
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset
{
    _sessionPreset = sessionPreset;
    //TODO: set self.cameraOrientation to status bar orientation???
    dispatch_async( self.videoQueue, ^{
        [self configureSession];
    } );
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    if (self.videoPreviewLayer == nil) {
        self.videoPreviewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    self.videoPreviewLayer.session = session;
    
}

- (void)start {
#if !TARGET_IPHONE_SIMULATOR
    dispatch_async( self.videoQueue, ^{
        [self.session startRunning];
    });
#endif
}

- (void)stop
{
#if !TARGET_IPHONE_SIMULATOR
    [self turnTorchOff];
    
    if (self.session == nil)
    {
        return;
    }
    
    @synchronized(self.session)
    {
        if (self.session.isRunning) {
            [self.session stopRunning];
        }
    }
#endif
}

- (void)shutdown
{
#if !TARGET_IPHONE_SIMULATOR
    if (self.session == nil)
    {
        return;
    }
    
    @synchronized(self.session)
    {
        [self.session beginConfiguration];
        
        [self.videoDataOutput setSampleBufferDelegate:nil queue:NULL];
        [self.session removeOutput:self.videoDataOutput];
        [self.session removeInput:self.deviceInput];
        
        [self.session commitConfiguration];
        
        self.videoDataOutput = nil;
        self.session = nil;
    }
#endif
}

- (BOOL)isTorchOn
{
    return self.isTorchON;
}

- (BOOL)turnTorchOn
{
    //NSLog(@"MiSnap Camera Started Video Capture turnTorchOn hasTorch %d torchInAutoMode %d getTorchStatus %d", [self.captureDevice hasTorch], self.torchInAutoMode, [self isTorchOn]);
    
    bool result = false;
    
    if ([self.captureDevice hasTorch])
    {
        self.torchInAutoMode = FALSE;
        
        NSError* error;
        [self.captureDevice lockForConfiguration:&error];
        
        [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
        self.isTorchON = TRUE;
        
        [self.captureDevice unlockForConfiguration];
                
        result = true;
    }
    
    return result;
}

- (BOOL)turnTorchOff
{
    bool result = false;
    
    if ([self.captureDevice hasTorch])
    {
        self.torchInAutoMode = FALSE;
        
        NSError* error;
        [self.captureDevice lockForConfiguration:&error];
        
        [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
        self.isTorchON = FALSE;
        
        [self.captureDevice unlockForConfiguration];
        
        result = true;
    }
    
    return result;
}

- (BOOL)hasTorch
{
    return [self.captureDevice hasTorch];
}

- (void)updatePreviewLayer:(UIInterfaceOrientation)deviceOrientation
{
    if ( UIInterfaceOrientationIsPortrait( deviceOrientation ) || UIInterfaceOrientationIsLandscape( deviceOrientation ) ) {
        self.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
        
        if (self.cameraOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
            for (AVCaptureOutput *output in outputs)
            {
                for (AVCaptureConnection *connection in output.connections)
                {
                    if ([connection isVideoOrientationSupported])
                    {
                        [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationLandscapeLeft];
                    }
                }
            }
        }
        else if (self.cameraOrientation == UIInterfaceOrientationPortrait)
        {
            NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
            for (AVCaptureOutput *output in outputs)
            {
                for (AVCaptureConnection *connection in output.connections)
                {
                    if ([connection isVideoOrientationSupported])
                    {
                        [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationPortrait];
                    }
                }
            }
        }
        else if (self.cameraOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
            for (AVCaptureOutput *output in outputs)
            {
                for (AVCaptureConnection *connection in output.connections)
                {
                    if ([connection isVideoOrientationSupported])
                    {
                        [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationPortraitUpsideDown];
                    }
                }
            }
        }
        else
        {
            NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
            for (AVCaptureOutput *output in outputs)
            {
                for (AVCaptureConnection *connection in output.connections)
                {
                    if ([connection isVideoOrientationSupported])
                    {
                        [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationLandscapeRight];
                    }
                }
            }
        }
    }
}

+ (bool)checkCameraPermission
{
    bool permissionGranted = TRUE;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized)
        {
            // do your logic
            permissionGranted = TRUE;
        }
        else if(authStatus == AVAuthorizationStatusDenied)
        {
            permissionGranted = FALSE;
        }
        else if(authStatus == AVAuthorizationStatusRestricted)
        {
            // restricted, normally won't happen
            permissionGranted = FALSE;
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            // not determined?!
            permissionGranted = FALSE;
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted)
                {
                    NSLog(@"Granted access to %@", AVMediaTypeVideo);
                } else {
                    NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                }
            }];
        }
        else
        {
            // impossible, unknown authorization status
            permissionGranted = FALSE;
        }
    }
    
    return permissionGranted;
}

- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    // When self.sessionPreset is bigger then 1920x1080, check for iPad 2 issue fix below around line 358
    if ([self.session canSetSessionPreset:self.sessionPreset]) {
        self.session.sessionPreset = self.sessionPreset;
    }
    else if ([self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    else if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    else
    {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    //======================== Add video input ========================//
    
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    
    self.captureDevice = discoverySession.devices.firstObject;
    
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if ( ! self.deviceInput ) {
        NSLog( @"Could not create video device input: %@", error );
        [self.session commitConfiguration];
        return;
    }
    
    // Check deviceInput here to fix iPad 2 black screen due to preset thinking it can be set to 1920x1080 (possible Apple bug)
    if ( ![self.session canAddInput:self.deviceInput] && [self.session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        // iPad 2 needs 1280x720
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    
    if ( [self.session canAddInput:self.deviceInput] )
    {
        [self.session addInput:self.deviceInput];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            UIInterfaceOrientation statusBarOrientation = self.cameraOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            
            self.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
        } );
    }
    else
    {
        NSLog( @"Could not add video device input to the session" );
        [self.session commitConfiguration];
        return;
    }
    
    //======================== Add data output ========================//
    
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    NSDictionary *videoSettings;
    if (self.analyzeRGBVideo)
    {
        // Setup BGRA color images from AV
        videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(self.pixelBufferFormat) }; // kCVPixelFormatType_32BGRA
    }
    else
    {
        // Setup gray scale images from AV
        videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) };
    }
    
    self.videoDataOutput.videoSettings = videoSettings;
    
    // discard if the data output queue is blocked (as we process the still image)
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:TRUE];
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    dispatch_queue_t videoOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    
    [self.videoDataOutput setSampleBufferDelegate:self queue:videoOutputQueue];
    
    if ([self.session canAddOutput:self.videoDataOutput])
    {
        [self.session addOutput:self.videoDataOutput];
    }
    else
    {
        NSLog(@"Can't add videoDataOutput");
        self.videoDataOutput = nil;
    }
    
    //========================= Add meta data output ==========================//
    
    self.metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metaDataOutputQueue = dispatch_queue_create("MetaDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.metaDataOutput setMetadataObjectsDelegate:self queue:metaDataOutputQueue];
    
    if ([self.session canAddOutput:self.metaDataOutput])
    {
        [self.session addOutput:self.metaDataOutput];
    }
    else
    {
        NSLog(@"Can't add metaDataOutput");
        self.metaDataOutput = nil;
    }
//    NSArray *supportedMetadataTypes = self.metaDataOutput.availableMetadataObjectTypes;
    self.metaDataOutput.metadataObjectTypes = @[AVMetadataObjectTypePDF417Code];
    
    [self.session commitConfiguration];
    
    [self.captureDevice lockForConfiguration:&error];
    
    if ([self.captureDevice isFocusPointOfInterestSupported]) {
        [self.captureDevice setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
    }
        
    if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] == TRUE) {
        [self.captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
        
    [self.captureDevice unlockForConfiguration];
    
    if (error)
    {
        NSLog(@"Failed to set continuous autofocus and point of interest");
        return;
    }
       
    if (self.cameraOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
        for (AVCaptureOutput *output in outputs)
        {
            for (AVCaptureConnection *connection in output.connections)
            {
                if ([connection isVideoOrientationSupported])
                {
                    [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationLandscapeLeft];
                }
            }
        }
    }
    else if (self.cameraOrientation == UIInterfaceOrientationPortrait)
    {
        NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
        for (AVCaptureOutput *output in outputs)
        {
            for (AVCaptureConnection *connection in output.connections)
            {
                if ([connection isVideoOrientationSupported])
                {
                    [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationPortrait];
                }
            }
        }
    }
    else if (self.cameraOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
        for (AVCaptureOutput *output in outputs)
        {
            for (AVCaptureConnection *connection in output.connections)
            {
                if ([connection isVideoOrientationSupported])
                {
                    [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationPortraitUpsideDown];
                }
            }
        }
    }
    else
    {
        NSArray<__kindof AVCaptureOutput *> *outputs = self.session.outputs;
        for (AVCaptureOutput *output in outputs)
        {
            for (AVCaptureConnection *connection in output.connections)
            {
                if ([connection isVideoOrientationSupported])
                {
                    [connection setVideoOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationLandscapeRight];
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishConfiguringSession)])
    {
        [self.delegate didFinishConfiguringSession];
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(didDropSampleBuffer:)]) {
        [self.delegate didDropSampleBuffer:sampleBuffer];
    }
}

- (void) captureOutput:(AVCaptureOutput*)captureOutput
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection*)captureSessionConnection
{
    if (self.captureDevice.isAdjustingFocus || self.captureDevice.isAdjustingExposure || self.captureDevice.isAdjustingWhiteBalance)
    {
        [self captureOutput:captureOutput didDropSampleBuffer:sampleBuffer fromConnection:captureSessionConnection];
    }
    
    if ([self.delegate respondsToSelector:@selector(didReceiveSampleBuffer:)]) {
        [self.delegate didReceiveSampleBuffer:sampleBuffer];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects)
    {
        for (NSString *type in barCodeTypes)
        {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[self.videoPreviewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            //NSLog(@"%@", detectionString);
            if ([self.delegate respondsToSelector:@selector(didDecodeBarcode:)])
            {
                [self.delegate didDecodeBarcode:detectionString];
            }
            break;
        }
    }
    
//    _highlightView.frame = highlightViewRect;
}

@end
