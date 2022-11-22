//
//  MiSnapBarcodeScannerResult.h
//  MiSnapBarcodeScanner
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MiSnapBarcodeScannerType) {
    MiSnapBarcodeScannerTypePDF417              = 0,
    MiSnapBarcodeScannerTypeQR                  = 1,
    MiSnapBarcodeScannerTypeAztec               = 2,
    MiSnapBarcodeScannerTypeCode39              = 3,
    MiSnapBarcodeScannerTypeCode93              = 4,
    MiSnapBarcodeScannerTypeCode128             = 5,
    MiSnapBarcodeScannerTypeInterleaved2of5     = 6
};

NS_ASSUME_NONNULL_BEGIN

@interface MiSnapBarcodeScannerResult : NSObject

@property (nonatomic, readonly) NSString * _Nullable decodedString;
@property (nonatomic, readonly) NSString * _Nullable parsedString;

@property (nonatomic, readonly) NSString * _Nullable licenseClass;
@property (nonatomic, readonly) NSString * _Nullable restrictionCodes;
@property (nonatomic, readonly) NSString * _Nullable endorsementCodes;
@property (nonatomic, readonly) NSString * _Nullable issueDate;
@property (nonatomic, readonly) NSString * _Nullable issueDateFormatted;
@property (nonatomic, readonly) NSString * _Nullable expirationDate;
@property (nonatomic, readonly) NSString * _Nullable expirationDateFormatted;
@property (nonatomic, readonly) NSString * _Nullable dateOfBirth;
@property (nonatomic, readonly) NSString * _Nullable dateOfBirthFormatted;
@property (nonatomic, readonly) NSString * _Nullable surname;
@property (nonatomic, readonly) NSString * _Nullable givenName;
@property (nonatomic, readonly) NSString * _Nullable middleName;
@property (nonatomic, readonly) NSString * _Nullable addressLine1;
@property (nonatomic, readonly) NSString * _Nullable addressLine2;
@property (nonatomic, readonly) NSString * _Nullable city;
@property (nonatomic, readonly) NSString * _Nullable state;
@property (nonatomic, readonly) NSString * _Nullable postalCode;
@property (nonatomic, readonly) NSString * _Nullable country;
@property (nonatomic, readonly) NSString * _Nullable documentNumber;
@property (nonatomic, readonly) NSString * _Nullable sex;
@property (nonatomic, readonly) NSString * _Nullable eyeColor;
@property (nonatomic, readonly) NSString * _Nullable height;
@property (nonatomic, readonly) NSString * _Nullable weight;
@property (nonatomic, readonly) NSString * _Nullable hairColor;
@property (nonatomic, readonly) NSString * _Nullable organDonor;

@property (nonatomic, readonly) MiSnapBarcodeScannerType type;

@end

NS_ASSUME_NONNULL_END
