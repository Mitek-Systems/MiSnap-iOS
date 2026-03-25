//
//  MiSnapBarcodeScannerVDSHeader.h
//  MiSnapBarcodeScanner
//
//  Created by Stas Tsuprenko on 1/26/26.
//  Copyright © 2026 miteksystems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Visible Digital Seal Header
 */
@interface MiSnapBarcodeScannerVDSHeader : NSObject
/**
 A two- or three-letter code identifying the issuing State or organization according to ICAO 9303-3
 */
@property (nonatomic, readonly) NSString * _Nonnull countryId;
/**
 A reference code to a document that defines the number and encoding of document features
 */
@property (nonatomic, readonly) int featureDefinitionReference;
/**
 The category of the document, e.g. visa, emergency travel document, birth certificate
 */
@property (nonatomic, readonly) int category;

@end

NS_ASSUME_NONNULL_END
