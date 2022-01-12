//
//  MiSnapBarcodeScannerLightOverlayView.h
//  MiSnapBarcodeScannerLightUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapBarcodeScannerLight/MiSnapBarcodeScannerLight.h>

@interface MiSnapBarcodeScannerLightOverlayView : UIView

@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *torchButton;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

- (void)initWithGuideMode:(MiSnapBarcodeLightGuideMode)guideMode;

- (void)showTorch:(BOOL)hasTorch;

- (void)torchEnabled:(BOOL)torchIsOn;

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation;

- (void)setLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor lineAlpha:(CGFloat)lineAlpha vignetteAlpha:(CGFloat)vignetteAlpha;

- (void)setGuideLandscapeFill:(CGFloat)landscapeFill portraitFill:(CGFloat)portraitFill aspectRatio:(CGFloat)guideAspectRatio cornerRadius:(CGFloat)cornerRadius;

- (void)hideAllUIElements;

@end
