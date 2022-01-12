//
//  MiSnapBarcodeScannerTutorialViewController.m
//  MiSnapBarcodeScannerUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import "MiSnapBarcodeScannerTutorialViewController.h"
#import "MiSnapBarcodeScanner+NSString.h"

@interface MiSnapBarcodeScannerTutorialViewController ()

@property (nonatomic) UILabel *dontShowLabel;
@property (nonatomic) UIImageView *checkboxImageView;
@property (nonatomic) UIView *tapView;
@property (nonatomic) BOOL shouldShowFirstTimeTutorial;
@property (nonatomic) UIInterfaceOrientation statusbarOrientation;

@end

@implementation MiSnapBarcodeScannerTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self.cancelButton setTitle:[NSString localizedStringForKey:@"dialog_misnap_barcode_cancel"] forState:UIControlStateNormal];
    [self.cancelButton setAccessibilityLabel:[NSString localizedStringForKey:@"dialog_misnap_barcode_cancel"]];
    
    if (self.tutorialMode == MiSnapBarcodeScannerTutorialModeFirstTime ||
        self.tutorialMode == MiSnapBarcodeScannerTutorialModeFailover ||
        self.tutorialMode == MiSnapBarcodeScannerTutorialModeHelp)
    {
        [self.continueButton setTitle:[NSString localizedStringForKey:@"dialog_misnap_barcode_capture"] forState:UIControlStateNormal];
        [self.continueButton setAccessibilityLabel:[NSString localizedStringForKey:@"dialog_misnap_barcode_capture"]];
        [self.retryButton setTitle:[NSString localizedStringForKey:@"dialog_misnap_barcode_capture"] forState:UIControlStateNormal];
        [self.retryButton setAccessibilityLabel:[NSString localizedStringForKey:@"dialog_misnap_barcode_capture"]];
    }
    
    self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.continueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.retryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if (self.tutorialMode == MiSnapBarcodeScannerTutorialModeFirstTime)
    {
        self.backgroundImageName = @"barcode_tutorial_id_back_with_background";
    }
    
    if (self.backgroundImageName && ![self.backgroundImageName isEqualToString:@""])
    {
        self.backgroundImageView.image = [self imageWithName:self.backgroundImageName orientation:self.statusbarOrientation guideMode:self.guideMode];
        [self.view bringSubviewToFront:self.backgroundImageView];
    }
    else
    {
        self.backgroundImageView.image = nil;
    }
    
    if (self.tutorialMode == MiSnapBarcodeScannerTutorialModeFirstTime)
    {
        [self addDontShowAgainCheckbox];
    }
    
    if (self.navigationController != nil)
    {
        [self.navigationController setNavigationBarHidden:TRUE];
    }
    
    if (self.timeoutDelay == 0.0)
    {
        [self showButtons];
    }
    else
    {
        self.cancelButton.alpha = 0.0;
        self.retryButton.alpha = 0.0;
        self.continueButton.alpha = 0.0;
        self.buttonBackgroundView.alpha = 0.0;
        
        if (self.numberOfButtons == 0)
        {
            [self performSelector:@selector(continueButtonAction:) withObject:nil afterDelay:self.timeoutDelay/1000.0];
        }
        else
        {
            [self performSelector:@selector(showButtons) withObject:nil afterDelay:self.timeoutDelay/1000.0];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return TRUE;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context)
    {
        self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (self.backgroundImageName && ![self.backgroundImageName isEqualToString:@""])
        {
            self.backgroundImageView.image = [self imageWithName:self.backgroundImageName orientation:self.statusbarOrientation guideMode:self.guideMode];
            [self.view bringSubviewToFront:self.backgroundImageView];
        }
        else
        {
            self.backgroundImageView.image = nil;
        }
        
        CGFloat offset = 0;
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && size.width / size.height > 1.8 && UIInterfaceOrientationIsLandscape(self.statusbarOrientation))
        {
            offset = 20;
        }
        else if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && size.height / size.width > 1.8 && UIInterfaceOrientationIsPortrait(self.statusbarOrientation))
        {
            offset = 35;
        }
        else if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            offset = 30;
        }
        
        self.dontShowLabel.center = CGPointMake(size.width * 0.5, size.height - self.buttonBackgroundView.frame.size.height - self.dontShowLabel.frame.size.height - offset);
        self.checkboxImageView.center = CGPointMake(self.dontShowLabel.center.x - self.dontShowLabel.frame.size.width * 0.5 - self.checkboxImageView.frame.size.width * 0.5 - 5, self.dontShowLabel.center.y);
        self.tapView.center = CGPointMake(self.dontShowLabel.center.x - self.checkboxImageView.frame.size.width * 0.5, self.dontShowLabel.center.y);
        [self.view bringSubviewToFront:self.dontShowLabel];
        [self.view bringSubviewToFront:self.checkboxImageView];
        [self.view bringSubviewToFront:self.tapView];
    }
    completion:nil];
}

#pragma mark - Implementation

- (void)setTutorialMode:(MiSnapBarcodeScannerTutorialMode)tutorialMode
{
    if (tutorialMode < MiSnapBarcodeScannerTutorialModeNone || tutorialMode > MiSnapBarcodeScannerTutorialModeFailover)
    {
        _tutorialMode = MiSnapBarcodeScannerTutorialModeNone;
    }
    else
    {
        _tutorialMode = tutorialMode;
    }
    
    int numberOfButtons = 0;
    switch (_tutorialMode)
    {
        case MiSnapBarcodeScannerTutorialModeNone:
            break;
            
        case MiSnapBarcodeScannerTutorialModeFirstTime:
        case MiSnapBarcodeScannerTutorialModeFailover:
        case MiSnapBarcodeScannerTutorialModeHelp:
        default:
            numberOfButtons = 2;
            break;
    }
    self.numberOfButtons = numberOfButtons;
    self.timeoutDelay = 0;
}

- (void)setNumberOfButtons:(int)numberOfButtons
{
    if (numberOfButtons < 0)
    {
        _numberOfButtons = 0;
    }
    else if (numberOfButtons > 3)
    {
        _numberOfButtons = 3;
    }
    else
    {
        _numberOfButtons = numberOfButtons;
    }
}

- (UIImage *)imageWithName:(NSString *)imageName orientation:(UIInterfaceOrientation)orientation guideMode:(MiSnapBarcodeGuideMode)guideMode
{
    NSString *tutorialImageName;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        tutorialImageName = [NSString stringWithFormat:@"%@.jpg", imageName];
    }
    else
    {
        
        if (guideMode == MiSnapBarcodeGuideModeDevicePortraitGuideLandscape)
        {
            tutorialImageName = [NSString stringWithFormat:@"%@_portrait_2.jpg", imageName];
        }
        else
        {
            tutorialImageName = [NSString stringWithFormat:@"%@_portrait.jpg", imageName];
        }
    }
    
    UIImage *tutorialImage = [UIImage imageNamed:tutorialImageName];
    return tutorialImage;
}

- (void)showButtons
{
    if (self.speakableText && ![self.speakableText isEqualToString:@""])
    {
        NSString* localizedStr = [NSString localizedStringForKey:self.speakableText];
        self.backgroundImageView.accessibilityLabel = localizedStr;
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, localizedStr);
    }
    
    if (self.numberOfButtons == 0)
    {
        self.cancelButton.hidden = TRUE;
        self.retryButton.hidden = TRUE;
        self.continueButton.hidden = TRUE;
        
        self.cancelButton.enabled = FALSE;
        self.retryButton.enabled = FALSE;
        self.continueButton.enabled = FALSE;
        
        self.buttonBackgroundView.hidden = FALSE;
    }
    else if (self.numberOfButtons == 1)
    {
        self.cancelButton.hidden = TRUE;
        self.retryButton.hidden = FALSE;
        self.continueButton.hidden = TRUE;
        
        self.cancelButton.enabled = FALSE;
        self.retryButton.enabled = TRUE;
        self.continueButton.enabled = FALSE;
        
        self.buttonBackgroundView.hidden = FALSE;
    }
    else if (self.numberOfButtons == 2)
    {
        self.cancelButton.hidden = FALSE;
        self.retryButton.hidden = TRUE;
        self.continueButton.hidden = FALSE;
        
        self.cancelButton.enabled = TRUE;
        self.retryButton.enabled = FALSE;
        self.continueButton.enabled = TRUE;
        
        self.buttonBackgroundView.hidden = FALSE;
    }
    else if (self.numberOfButtons == 3)
    {
        self.cancelButton.hidden = FALSE;
        self.retryButton.hidden = FALSE;
        self.continueButton.hidden = FALSE;
        
        self.cancelButton.enabled = TRUE;
        self.retryButton.enabled = TRUE;
        self.continueButton.enabled = TRUE;
        
        self.buttonBackgroundView.hidden = FALSE;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.cancelButton.alpha = 1.0;
        self.retryButton.alpha = 1.0;
        self.continueButton.alpha = 1.0;
        self.buttonBackgroundView.alpha = 1.0;
    }];
}

- (IBAction)cancelButtonAction:(id)sender
{    
    if ([self.delegate respondsToSelector:@selector(tutorialCancelButtonAction)])
    {
        [self.delegate tutorialCancelButtonAction];
    }
}

- (IBAction)continueButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tutorialContinueButtonAction)])
    {
        [self.delegate tutorialContinueButtonAction];
    }
}

- (IBAction)retryButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tutorialRetryButtonAction)])
    {
        [self.delegate tutorialRetryButtonAction];
    }
}

- (void)addDontShowAgainCheckbox
{
    self.shouldShowFirstTimeTutorial = TRUE;
    
    [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:kMiSnapBarcodeScannerShowTutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat offset = 0;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && screenWidth / screenHeight > 1.8 && UIInterfaceOrientationIsLandscape(self.statusbarOrientation))
    {
        offset = 20;
    }
    else if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && screenHeight / screenWidth > 1.8 && UIInterfaceOrientationIsPortrait(self.statusbarOrientation))
    {
        offset = 35;
    }
    else if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        offset = 30;
    }
    
    NSString *dontShowString = @"Don't show this screen again";
    CGFloat dontShowAgainFontSize = 17.0;
    
    CGSize maximumSize = CGSizeMake(screenWidth * 0.9, 50);
    CGRect dontShowRect = [dontShowString boundingRectWithSize:maximumSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:dontShowAgainFontSize] } context:nil];
    //NSLog(@"Don't show this again size: %@", NSStringFromCGRect(dontShowRect));
    
    self.dontShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dontShowRect.size.width, dontShowRect.size.height)];
    self.dontShowLabel.center = CGPointMake(screenWidth * 0.5, screenHeight - self.buttonBackgroundView.frame.size.height - self.dontShowLabel.frame.size.height - offset);
    self.dontShowLabel.text = dontShowString;
    self.dontShowLabel.font = [UIFont systemFontOfSize:dontShowAgainFontSize];
    [self.dontShowLabel setTextColor:[UIColor blackColor]];

    self.checkboxImageView = [[UIImageView alloc] init];
    self.checkboxImageView.image = [UIImage imageNamed:@"barcode_checkbox_unchecked"];
    self.checkboxImageView.frame = CGRectMake(0, 0, dontShowRect.size.height - 5, dontShowRect.size.height - 5);
    self.checkboxImageView.center = CGPointMake(self.dontShowLabel.center.x - self.dontShowLabel.frame.size.width * 0.5 - self.checkboxImageView.frame.size.width * 0.5 - 5, self.dontShowLabel.center.y);
    
    self.tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.checkboxImageView.frame.size.width + self.dontShowLabel.frame.size.width + 30, self.dontShowLabel.frame.size.height + 20)];
    self.tapView.center = CGPointMake(self.dontShowLabel.center.x - self.checkboxImageView.frame.size.width * 0.5, self.dontShowLabel.center.y);
    self.tapView.userInteractionEnabled = TRUE;
    self.tapView.accessibilityIdentifier = dontShowString;
    
    UITapGestureRecognizer *dontShowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dontShowTapped)];
    dontShowTap.numberOfTapsRequired = 1;
    [self.tapView addGestureRecognizer:dontShowTap];
    
    [self.view addSubview:self.dontShowLabel];
    [self.view addSubview:self.checkboxImageView];
    [self.view addSubview:self.tapView];
}

- (void)dontShowTapped
{
    //NSLog(@"Don't show was tapped");
    if (self.shouldShowFirstTimeTutorial)
    {
        self.checkboxImageView.image = [UIImage imageNamed:@"barcode_checkbox_checked"];
        self.shouldShowFirstTimeTutorial = FALSE;
    }
    else
    {
        self.checkboxImageView.image = [UIImage imageNamed:@"barcode_checkbox_unchecked"];
        self.shouldShowFirstTimeTutorial = TRUE;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:kMiSnapBarcodeScannerShowTutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)storyboardId
{
    return NSStringFromClass([self class]);
}

+ (MiSnapBarcodeScannerTutorialViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"MiSnapBarcodeScanner" bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:[MiSnapBarcodeScannerTutorialViewController storyboardId]];
}

- (void)dealloc {
    //NSLog(@"%@ is deallocated", NSStringFromClass(self.class));
}

@end
