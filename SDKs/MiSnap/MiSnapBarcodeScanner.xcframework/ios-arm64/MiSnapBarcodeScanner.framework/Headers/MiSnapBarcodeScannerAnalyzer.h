//
//  MiSnapBarcodeScannerAnalyzer.h
//  MiSnapBarcodeScanner
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerResult.h>

@protocol MiSnapBarcodeScannerAnalyzerDelegate <NSObject>

- (void)barcodeAnalyzerResult:(MiSnapBarcodeScannerResult *)result image:(UIImage *)image;

- (void)barcodeAnalyzerException:(NSException *)exception;

@end

@interface MiSnapBarcodeScannerAnalyzer : NSObject

@property (nonatomic, weak) id <MiSnapBarcodeScannerAnalyzerDelegate> delegate;

- (instancetype)initWith:(NSArray<NSNumber *> *)supportedBarcodeTypes;

- (void)analyzeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)analyzePixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
