//
//  MiSnapBarcodeScannerLightViewController.m
//  MiSnapBarcodeScannerLightUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import "MiSnapBarcodeScannerLightViewController.h"
#import "MiSnapBarcodeScannerLightCamera.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MiSnapBarcodeScannerLightViewController () <MiSnapBarcodeScannerLightCameraDelegate, MiSnapBarcodeScannerLightTutorialViewControllerDelegate>

@property (nonatomic, weak) IBOutlet MiSnapBarcodeScannerLightCamera *camera;
@property (nonatomic, weak) IBOutlet MiSnapBarcodeScannerLightOverlayView *overlayView;

@property (nonatomic, strong) MiSnapBarcodeScannerLightTutorialViewController *tutorialViewController;

@property (nonatomic) UIImage *currentImage;

@property (nonatomic) UIInterfaceOrientation statusbarOrientation;

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat lineAlpha;
@property (nonatomic) CGFloat vignetteAlpha;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat landscapeFill;
@property (nonatomic) CGFloat portraitFill;
@property (nonatomic) CGFloat guideAspectRatio;

@property (nonatomic) BOOL firstTimeTutorialHasBeenShown;
@property (nonatomic) BOOL tutorialCancelled;
@property (nonatomic, assign) BOOL shouldSkipFrames;
@property (nonatomic) BOOL didDecodeBarcode;

@end

@implementation MiSnapBarcodeScannerLightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.encodedImageQuality == 0)
    {
        self.encodedImageQuality = 0.6;
    }
    
    self.shouldSkipFrames = FALSE; // Default is to analyze without skipping
    
    if (self.navigationController)
    {
        self.navigationController.navigationBarHidden = TRUE;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.overlayView hideAllUIElements];
    
    [UIApplication sharedApplication].idleTimerDisabled = TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.tutorialCancelled) { return; }
    
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMiSnapBarcodeScannerLightShowTutorial] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kMiSnapBarcodeScannerLightShowTutorial];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kMiSnapBarcodeScannerLightShowTutorial] && !self.firstTimeTutorialHasBeenShown)
    {
        self.firstTimeTutorialHasBeenShown = TRUE;
        [self showFirstTimeTutorial];
    }
    else
    {
        self.camera.cameraOrientation = UIInterfaceOrientationLandscapeRight;
        [self.camera setSessionPreset:AVCaptureSessionPreset1920x1080 pixelBufferFormat:kCVPixelFormatType_32BGRA];
        self.camera.delegate = self;
        
        [self.overlayView initWithGuideMode:self.guideMode];
        [self.overlayView setLineWidth:self.lineWidth lineColor:self.lineColor lineAlpha:self.lineAlpha vignetteAlpha:self.vignetteAlpha];
        [self.overlayView setGuideLandscapeFill:self.landscapeFill portraitFill:self.portraitFill aspectRatio:self.guideAspectRatio cornerRadius:self.cornerRadius];
        [self.overlayView updateWithOrientation:self.statusbarOrientation];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __block UIInterfaceOrientation toInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context)
     {
         toInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
         
         [self.camera updatePreviewLayer:toInterfaceOrientation];
         
         self.statusbarOrientation = toInterfaceOrientation;
         
         if (self.guideMode != MiSnapBarcodeLightGuideModeNoGuide)
         {
             [self.overlayView updateWithOrientation:self.statusbarOrientation];
         }
    }
    completion:nil];
}

- (void)didFinishConfiguringSession
{
    if ([self.delegate respondsToSelector:@selector(miSnapBarcodeDidStartSession:)])
    {
        [self.delegate miSnapBarcodeDidStartSession:self];
    }
    else
    {
        self.shouldSkipFrames = FALSE;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.camera updatePreviewLayer:self.statusbarOrientation];
        [self.camera start];
        
        [self.overlayView showTorch:self.camera.hasTorch];
        [self.overlayView torchEnabled:self.camera.isTorchOn];
    });
}

- (void)resumeAnalysis
{
    self.shouldSkipFrames = FALSE;
    //NSLog(@"$$$$$$ startCapture");
}

- (void)pauseAnalysis
{
    self.shouldSkipFrames = TRUE;
    //NSLog(@"$$$$$$ pauseCapture");
}

- (void)didReceiveSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    self.currentImage = [self imageFromSampleBuffer:sampleBuffer withDeviceOrientation:UIDeviceOrientationUnknown];
}

- (void)didDecodeBarcode:(NSString *)decodedBarcodeString
{
    if (self.shouldSkipFrames)
    {
        //NSLog(@"%%%%%% didDecodeBarcode shouldSkipFrames %d", self.shouldSkipFrames);
        return;
    }

    if (self.didDecodeBarcode)
    {
        return;
    }
    
    if (self.currentImage)
    {
        self.didDecodeBarcode = TRUE;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* mibiDataString = [self buildBarcodeMIBIDataWithResult:kMiSnapBarcodeScannerLightResultSuccessPDF417];
            
            if (mibiDataString == nil) {
                mibiDataString = @"NO MIBIDATA";
            }
            NSString *nonNilString;
            if (decodedBarcodeString == nil)
            {
                nonNilString = [NSString new];
            }
            else
            {
                nonNilString = decodedBarcodeString;
            }
            
            NSDictionary* returnResults = @{kMiSnapBarcodeScannerLightResultCode:kMiSnapBarcodeScannerLightResultSuccessPDF417,
                                            kMiSnapBarcodeScannerLightPDF417Data:nonNilString,
                                            kMiSnapBarcodeScannerLightMIBIData:mibiDataString
                                            };
            
            NSData *imageData = UIImageJPEGRepresentation(self.currentImage, self.encodedImageQuality);
            NSString *encodedImage = [imageData base64EncodedStringWithOptions:0];
            
            [self shutdownAnimated:TRUE];
            
            [self playShutterSoundAndVibrate:TRUE];
            
            if ([self.delegate respondsToSelector:@selector(miSnapFinishedReturningEncodedImage:originalImage:andResults:forDocumentType:)])
            {
                [self.delegate miSnapFinishedReturningEncodedImage:encodedImage originalImage:self.currentImage andResults:returnResults forDocumentType:@"PDF417"];
            }
            else if ([self.delegate respondsToSelector:@selector(miSnapFinishedReturningEncodedImage:originalImage:andResults:)])
            {
                [self.delegate miSnapFinishedReturningEncodedImage:encodedImage originalImage:self.currentImage andResults:returnResults];
            }

        });
    }
}

- (IBAction)torchButtonAction:(id)sender
{
    if (self.camera.isTorchOn)
    {
        [self.camera turnTorchOff];
        [self.overlayView torchEnabled:FALSE];
    }
    else
    {
        [self.camera turnTorchOn];
        [self.overlayView torchEnabled:TRUE];
    }
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self shutdownAnimated:TRUE];
    
    NSString* mibiDataString = [self buildBarcodeMIBIDataWithResult:kMiSnapBarcodeScannerLightResultCancelled];

    NSDictionary* results = @{kMiSnapBarcodeScannerLightResultCode:  kMiSnapBarcodeScannerLightResultCancelled,
                              kMiSnapBarcodeScannerLightMIBIData:    mibiDataString};
    
    if ([self.delegate respondsToSelector:@selector(miSnapCancelledWithResults:forDocumentType:)])
    {
        [self.delegate miSnapCancelledWithResults:results forDocumentType:@"PDF417"];
    }
    else if ([self.delegate respondsToSelector:@selector(miSnapCancelledWithResults:)])
    {
        [self.delegate miSnapCancelledWithResults:results];
    }
}

- (void)shutdownAnimated:(BOOL)animated
{
    [self.camera stop];
    self.camera.delegate = nil;
    [self.camera shutdown];
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:animated];
    }
    else
    {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (NSString *)buildBarcodeMIBIDataWithResult:(NSString*)resultCode
{
    NSMutableDictionary* mibiData = [MiSnapBarcodeScannerLightMibiData getMibiDataWithResult:resultCode andTorchStatus:self.camera.isTorchOn? @"YES" : @"NO"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mibiData options:kNilOptions error:&error];
    if (error)
    {
        NSLog(@"error");
    }
    
    // Now convert the JSON string into a regular string (human readable)
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)setLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor lineAlpha:(CGFloat)lineAlpha vignetteAlpha:(CGFloat)vignetteAlpha
{
    self.lineWidth = lineWidth;
    self.lineColor = lineColor;
    self.lineAlpha = lineAlpha;
    self.vignetteAlpha = vignetteAlpha;
}

- (void)setGuideLandscapeFill:(CGFloat)landscapeFill portraitFill:(CGFloat)portraitFill aspectRatio:(CGFloat)guideAspectRatio cornerRadius:(CGFloat)cornerRadius
{
    self.landscapeFill = landscapeFill;
    self.portraitFill = portraitFill;
    self.guideAspectRatio = guideAspectRatio;
    self.cornerRadius = cornerRadius;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

- (BOOL)shouldAutorotate
{
    return TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)playShutterSoundAndVibrate:(BOOL)vibrate
{
    NSURL *soundFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"barcode_light_photoshutter" withExtension:@"wav"];
    
    SystemSoundID sound1;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &sound1) ;
    
    if (vibrate)
    {
        AudioServicesPlayAlertSound(sound1);
    }
    else
    {
        AudioServicesPlaySystemSound(sound1);
    }
}

- (void)showFirstTimeTutorial
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (! self.tutorialViewController)
        {
            self.tutorialViewController = [MiSnapBarcodeScannerLightTutorialViewController instantiateFromStoryboard];
            self.tutorialViewController.delegate = self;
            self.tutorialViewController.guideMode = self.guideMode;
            self.tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            // For iOS 13, UIModalPresentationFullScreen is not the default, so be explicit
            self.tutorialViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        
        self.tutorialViewController.tutorialMode = MiSnapBarcodeScannerLightTutorialModeFirstTime;
        
        if (self.navigationController)
        {
            [self.navigationController pushViewController:self.tutorialViewController animated:TRUE];
        }
        else
        {
            [self presentViewController:self.tutorialViewController animated:TRUE completion:nil];
        }
    });
}

- (void)tutorialCancelButtonAction
{
    self.tutorialCancelled = TRUE;
    [self dismissTutorial];
    [self shutdownAnimated:FALSE];
}

- (void)tutorialRetryButtonAction {}

- (void)tutorialContinueButtonAction
{
    [self dismissTutorial];
}

- (void)dismissTutorial
{
    if (self.tutorialViewController != nil)
    {
        if (self.navigationController)
        {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
        else
        {
            [self.tutorialViewController dismissViewControllerAnimated:TRUE completion:nil];
        }
        self.tutorialViewController.delegate = nil;
        self.tutorialViewController = nil;
    }
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer withDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    if (sampleBuffer == nil)
    {
        return nil;
    }
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage* image = nil;
    
    if (deviceOrientation == UIDeviceOrientationUnknown)    // If orientation is unknown, don't scale or rotate
    {                                                       // Image is video and already oriented correctly
        image = [UIImage imageWithCGImage:quartzImage];
    }
    else
    {
        UIImageOrientation imageOrientation;
        
        switch (deviceOrientation)
        {
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationUp;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationDown;
                break;
                
            default:
                imageOrientation = UIImageOrientationRight;
                break;
        }
        
        image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:imageOrientation];
    }
    
    CGImageRelease(quartzImage);
    
    return (image);
}

+ (NSString *)storyboardId
{
    return NSStringFromClass([self class]);
}

+ (MiSnapBarcodeScannerLightViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"MiSnapBarcodeScannerLight" bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:[MiSnapBarcodeScannerLightViewController storyboardId]];
}

- (void)dealloc {
    //NSLog(@"%@ is deallocated", NSStringFromClass(self.class));
}

@end
