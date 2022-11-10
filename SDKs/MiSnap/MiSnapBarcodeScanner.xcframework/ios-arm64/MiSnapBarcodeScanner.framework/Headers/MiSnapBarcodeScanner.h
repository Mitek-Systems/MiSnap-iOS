//
//  MiSnapBarcodeScanner.h
//  MiSnapBarcodeScanner
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UiKit/UIKit.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerAnalyzer.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerResult.h>

/**
 Scans barcodes
 */
@interface MiSnapBarcodeScanner : NSObject
/**
 Version
 */
+ (NSString * _Nonnull)version;

@end
