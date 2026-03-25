//
//  MiSnapBarcodeScannerVDSResult.h
//  MiSnapBarcodeScanner
//
//  Created by Stas Tsuprenko on 1/8/26.
//  Copyright © 2026 miteksystems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerVDSHeader.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Visible Digital Seal (VDS) Result
 */
@interface MiSnapBarcodeScannerVDSResult : NSObject
/**
 Indicates whether this result is VDS
 
 Default: `FALSE`
 
 - Note, it's only `TRUE` when scanned barcode is ICAO 9303-13 compliant
 */
@property (nonatomic, readonly) BOOL isVds;
/**
 Header
 */
@property (nonatomic, readonly) MiSnapBarcodeScannerVDSHeader * _Nonnull header;
/**
 Visible Digital Seal payload
 */
@property (nonatomic, readonly) NSString * _Nullable payload;

@end

NS_ASSUME_NONNULL_END
