//
//  MiSnapBarcodeScannerAnalyzer.h
//  MiSnapBarcodeScanner
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerResult.h>

typedef NS_ENUM(NSInteger, MiSnapBarcodeScannerType) {
    MiSnapBarcodeScannerTypePDF417              = 0,
    MiSnapBarcodeScannerTypeQR                  = 1,
    MiSnapBarcodeScannerTypeAztec               = 2,
    MiSnapBarcodeScannerTypeCode39              = 3,
    MiSnapBarcodeScannerTypeCode93              = 4,
    MiSnapBarcodeScannerTypeCode128             = 5,
    MiSnapBarcodeScannerTypeInterleaved2of5     = 6
};

@protocol MiSnapBarcodeScannerAnalyzerDelegate <NSObject>

- (void)barcodeAnalyzerResult:(MiSnapBarcodeScannerResult *)result image:(UIImage *)image;

- (void)barcodeAnalyzerException:(NSException *)exception;

@end

@interface MiSnapBarcodeScannerAnalyzer : NSObject

@property (nonatomic, weak) id <MiSnapBarcodeScannerAnalyzerDelegate> delegate;

- (instancetype)initWith:(NSArray<NSNumber *> *)supportedBarcodeTypes;

- (void)analyzeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
