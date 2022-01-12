//
//  MiSnapBarcodeScannerLightOverlayView.m
//  MiSnapBarcodeScannerLightUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import "MiSnapBarcodeScannerLightOverlayView.h"

@interface MiSnapBarcodeScannerLightOverlayView ()

@property (nonatomic) UIInterfaceOrientation orientation;

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat lineAlpha;
@property (nonatomic) CGFloat vignetteAlpha;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat landscapeFill;
@property (nonatomic) CGFloat portraitFill;
@property (nonatomic) CGFloat guideAspectRatio;

@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat midX;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat midY;
@property (nonatomic) CGFloat maxY;

@property (nonatomic) CGFloat biggerSide;
@property (nonatomic) CGFloat smallerSide;

@property (nonatomic) CGFloat guideBiggerSide;
@property (nonatomic) CGFloat guideSmallerSide;

@property (nonatomic) MiSnapBarcodeLightGuideMode guideMode;

@end

@implementation MiSnapBarcodeScannerLightOverlayView

- (void)initWithGuideMode:(MiSnapBarcodeLightGuideMode)guideMode
{
    self.cancelButton.accessibilityLabel = [self localizedStringForKey:@"misnap_barcode_overlay_cancel_button"];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.biggerSide = screenSize.width;
    self.smallerSide = screenSize.height;
    
    if (self.biggerSide < self.smallerSide)
    {
        self.biggerSide = screenSize.height;
        self.smallerSide = screenSize.width;
    }
    
    self.guideMode = guideMode;
    
    self.cancelButton.hidden = FALSE;
    self.torchButton.hidden = FALSE;
    self.logoImageView.hidden = FALSE;
}

- (void)showTorch:(BOOL)hasTorch
{
    if (hasTorch)
    {
        self.torchButton.hidden = FALSE;
    }
    else
    {
        self.torchButton.hidden = TRUE;
    }
}

- (void)torchEnabled:(BOOL)torchIsOn
{
    if (torchIsOn)
    {
        self.torchButton.accessibilityLabel = [self localizedStringForKey:@"misnap_barcode_flash_on"];
        [self.torchButton setImage:[UIImage imageNamed:@"barcode_light_icon_flash_on"] forState:UIControlStateNormal];
    }
    else
    {
        self.torchButton.accessibilityLabel = [self localizedStringForKey:@"misnap_barcode_flash_off"];
        [self.torchButton setImage:[UIImage imageNamed:@"barcode_light_icon_flash_off"] forState:UIControlStateNormal];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor lineAlpha:(CGFloat)lineAlpha vignetteAlpha:(CGFloat)vignetteAlpha
{
    self.lineWidth = lineWidth;
    self.lineColor = lineColor;
    self.lineAlpha = lineAlpha;
    self.vignetteAlpha = vignetteAlpha;
    
    [self setNeedsDisplay];
}

- (void)setGuideLandscapeFill:(CGFloat)landscapeFill portraitFill:(CGFloat)portraitFill aspectRatio:(CGFloat)guideAspectRatio cornerRadius:(CGFloat)cornerRadius
{
    self.landscapeFill = landscapeFill;
    self.portraitFill = portraitFill;
    self.guideAspectRatio = guideAspectRatio;
    self.cornerRadius = cornerRadius;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextSetAlpha(context, self.vignetteAlpha);
    
    [[UIColor blackColor] setFill];
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, self.lineWidth);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.minX, self.midY);
    CGContextAddArcToPoint(context, self.minX, self.minY, self.midX, self.minY, self.cornerRadius);
    CGContextAddArcToPoint(context, self.maxX, self.minY, self.maxX, self.midY, self.cornerRadius);
    CGContextAddArcToPoint(context, self.maxX, self.maxY, self.midX, self.maxY, self.cornerRadius);
    CGContextAddArcToPoint(context, self.minX, self.maxY, self.minX, self.midY, self.cornerRadius);
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [self.lineColor setStroke];
    
    CGContextSetAlpha(context, self.lineAlpha);
    
    CGContextSetLineWidth(context, self.lineWidth);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.minX, self.midY);
    CGContextAddArcToPoint(context, self.minX, self.minY, self.midX, self.minY, self.cornerRadius);
    CGContextAddArcToPoint(context, self.maxX, self.minY, self.maxX, self.midY, self.cornerRadius);
    CGContextAddArcToPoint(context, self.maxX, self.maxY, self.midX, self.maxY, self.cornerRadius);
    CGContextAddArcToPoint(context, self.minX, self.maxY, self.minX, self.midY, self.cornerRadius);
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    self.orientation = orientation;
    
    CGFloat adjustedSide = 0;
    CGRect guideRect = CGRectZero;
    
    adjustedSide = self.biggerSide;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && self.biggerSide / self.smallerSide > 1.8)
    {
        adjustedSide = self.smallerSide * 16/9;
    }
    
    switch (self.orientation)
    {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            if (self.guideMode == MiSnapBarcodeLightGuideModeNoGuide)
            {
                self.accessibilityIdentifier = @"NoGuide";
            }
            else
            {
                self.accessibilityIdentifier = @"DeviceLandscapeGuideLandscape";
            }
            self.guideBiggerSide = adjustedSide * self.landscapeFill;
            self.guideSmallerSide = self.guideBiggerSide / self.guideAspectRatio;
            guideRect = CGRectMake(self.biggerSide / 2 - self.guideBiggerSide / 2, self.smallerSide / 2 - self.guideSmallerSide / 2, self.guideBiggerSide, self.guideSmallerSide);
            break;
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortraitUpsideDown:
            if (self.guideMode == MiSnapBarcodeLightGuideModeDevicePortraitGuidePortrait)
            {
                self.accessibilityIdentifier = @"DevicePortraitGuidePortrait";
                self.guideBiggerSide = adjustedSide * self.landscapeFill;
                self.guideSmallerSide = self.guideBiggerSide / self.guideAspectRatio;
                guideRect = CGRectMake(self.smallerSide / 2 - self.guideSmallerSide / 2, self.biggerSide / 2 - self.guideBiggerSide / 2, self.guideSmallerSide, self.guideBiggerSide);
            }
            else if (self.guideMode == MiSnapBarcodeLightGuideModeDevicePortraitGuideLandscape)
            {
                self.accessibilityIdentifier = @"DevicePortraitGuideLandscape";
                self.guideBiggerSide = self.smallerSide * self.portraitFill;
                self.guideSmallerSide = self.guideBiggerSide / self.guideAspectRatio;
                guideRect = CGRectMake(self.smallerSide / 2 - self.guideBiggerSide / 2, self.biggerSide / 2 - self.guideSmallerSide / 2, self.guideBiggerSide, self.guideSmallerSide);
            }
            else
            {
                self.accessibilityIdentifier = @"NoGuide";
            }
            
            //guideRect = CGRectMake(self.smallerSide / 2 - self.guideSmallerSide / 2, adjustedSide / 2 - self.guideBiggerSide / 2, self.guideSmallerSide, self.guideBiggerSide);
            break;
    }
    self.minX = CGRectGetMinX(guideRect);
    self.midX = CGRectGetMidX(guideRect);
    self.maxX = CGRectGetMaxX(guideRect);
    self.minY = CGRectGetMinY(guideRect);
    self.midY = CGRectGetMidY(guideRect);
    self.maxY = CGRectGetMaxY(guideRect);
    
    if (isnan(self.minX)) { self.minX = 0.0; }
    if (isnan(self.midX)) { self.midX = 0.0; }
    if (isnan(self.maxX)) { self.maxX = 0.0; }
    if (isnan(self.minY)) { self.minY = 0.0; }
    if (isnan(self.midY)) { self.midY = 0.0; }
    if (isnan(self.maxY)) { self.maxY = 0.0; }
    
    [self setNeedsDisplay];
}

- (void)setGuideMode:(MiSnapBarcodeLightGuideMode)guideMode
{
    if (guideMode < MiSnapBarcodeLightGuideModeDevicePortraitGuidePortrait || guideMode > MiSnapBarcodeLightGuideModeNoGuide)
    {
        _guideMode = MiSnapBarcodeLightGuideModeDevicePortraitGuidePortrait;
    }
    else
    {
        _guideMode = guideMode;
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    if (self.guideMode == MiSnapBarcodeLightGuideModeNoGuide)
    {
        _lineWidth = 0.0;
    }
    else if (lineWidth <= 0.0)
    {
        _lineWidth = 3.0;
    }
    else
    {
        _lineWidth = lineWidth;
    }
}

- (void)setLineColor:(UIColor *)lineColor
{
    if (self.guideMode == MiSnapBarcodeLightGuideModeNoGuide)
    {
        _lineColor = [UIColor clearColor];
    }
    else if (lineColor == nil)
    {
        _lineColor = [UIColor redColor];
    }
    else
    {
        _lineColor = lineColor;
    }
}

- (void)setLineAlpha:(CGFloat)lineAlpha
{
    if (self.guideMode == MiSnapBarcodeLightGuideModeNoGuide)
    {
        _lineAlpha = 0.0;
    }
    else if (lineAlpha <= 0.0 || lineAlpha > 1.0)
    {
        _lineAlpha = 0.7;
    }
    else
    {
        _lineAlpha = lineAlpha;
    }
}

- (void)setVignetteAlpha:(CGFloat)vignetteAlpha
{
    if (self.guideMode == MiSnapBarcodeLightGuideModeNoGuide)
    {
        _vignetteAlpha = 0.0;
    }
    else if (vignetteAlpha <= 0.0 || vignetteAlpha > 1.0)
    {
        _vignetteAlpha = 0.7;
    }
    else
    {
        _vignetteAlpha = vignetteAlpha;
    }
}

- (void)setLandscapeFill:(CGFloat)landscapeFill
{
    if (landscapeFill <= 0.0 || landscapeFill > 1.0)
    {
        _landscapeFill = 0.7;
    }
    else
    {
        _landscapeFill = landscapeFill;
    }
}

- (void)setPortraitFill:(CGFloat)portraitFill
{
    if (portraitFill <= 0.0 || portraitFill > 1.0)
    {
        _portraitFill = 0.925;
    }
    else
    {
        _portraitFill = portraitFill;
    }
}

- (void)setGuideAspectRatio:(CGFloat)guideAspectRatio
{
    if (guideAspectRatio <= 0.0)
    {
        _guideAspectRatio = 1.59;
    }
    else
    {
        _guideAspectRatio = guideAspectRatio;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (cornerRadius <= 0.0)
    {
        _cornerRadius = 15;
    }
    else
    {
        _cornerRadius = cornerRadius;
    }
}

- (NSString *)localizedStringForKey:(NSString *)key
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:key value:key table:@"MiSnapBarcodeScannerLightLocalizable"];
}

- (void)hideAllUIElements
{
    self.cancelButton.hidden = TRUE;
    self.torchButton.hidden = TRUE;
    self.logoImageView.hidden = TRUE;
}

@end
