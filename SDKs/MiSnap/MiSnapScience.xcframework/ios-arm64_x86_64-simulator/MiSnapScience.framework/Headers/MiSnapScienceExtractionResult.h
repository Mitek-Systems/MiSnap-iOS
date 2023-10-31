//
//  MiSnapScienceExtractionResult.h
//  MiSnapScience
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapScience/MiSnapScienceParameters.h>

/**
 Expiration status
 */
typedef NS_ENUM(NSInteger, MiSnapScienceExpirationStatus) {
    /**
     Expiration status wasn't determined
     */
    MiSnapScienceExpirationStatusUndetermined = 0,
    /**
     A document is valid (not expired)
     */
    MiSnapScienceExpirationStatusValid,
    /**
     A document has expired
     */
    MiSnapScienceExpirationStatusExpired
};

/**
 Additional step
 */
typedef NS_ENUM(NSInteger, MiSnapScienceAdditionalStep) {
    /**
     Additional step is not set
     */
    MiSnapScienceAdditionalStepNone = 0,
    /**
     QR code in NLD passport issued after 2021-08-30
     */
    MiSnapScienceAdditionalStepPassportQr
};

NS_ASSUME_NONNULL_BEGIN

/**
 Extraction result
 */
@interface MiSnapScienceExtractionResult : NSObject
/**
 A license class
 */
@property (nonatomic, readonly) NSString * _Nullable licenseClass;
/**
 Restriction codes
 */
@property (nonatomic, readonly) NSString * _Nullable restrictionCodes;
/**
 Endorsement codes
 */
@property (nonatomic, readonly) NSString * _Nullable endorsementCodes;
/**
 Issue date string in a raw format
 */
@property (nonatomic, readonly) NSString * _Nullable issueDate;
/**
 Issue date string in format YYYY-MM-DD
 
 @note For DLs issue date is only formatted for USA and Canada. Otherwise, raw issue
 date string is returned as format for other countries is not yet known
 */
@property (nonatomic, readonly) NSString * _Nullable issueDateFormatted;
/**
 Expiration date string in a raw format
 */
@property (nonatomic, readonly) NSString * _Nullable expirationDate;
/**
 Expiration date string in format YYYY-MM-DD
 
 @note For DLs expiration date is only formatted for USA and Canada. Otherwise, raw issue
 date string is returned as format for other countries is not yet known
 */
@property (nonatomic, readonly) NSString * _Nullable expirationDateFormatted;
/**
 Date of birth string in a raw format
 */
@property (nonatomic, readonly) NSString * _Nullable dateOfBirth;
/**
 Date of birth string in format YYYY-MM-DD
 
 @note For DLs date of birth is only formatted for USA and Canada. Otherwise, raw issue
 date string is returned as format for other countries is not yet known
 */
@property (nonatomic, readonly) NSString * _Nullable dateOfBirthFormatted;
/**
 Surname of a document holder
 */
@property (nonatomic, readonly) NSString * _Nullable surname;
/**
 A code that indicates whether a surname has been truncated (T), has not been truncated (N), or – unknown whether truncated (U)
 */
@property (nonatomic, readonly) NSString * _Nullable surnameTruncation;
/**
 Other surname by which document holder is known
 */
@property (nonatomic, readonly) NSString * _Nullable surnameAlias;
/**
 A document holder's given name
 */
@property (nonatomic, readonly) NSString * _Nullable givenName;
/**
 A code that indicates whether a given name has been truncated (T), has not been truncated (N), or – unknown whether truncated (U)
 */
@property (nonatomic, readonly) NSString * _Nullable givenNameTruncation;
/**
 Other given name by which document holder is known
 */
@property (nonatomic, readonly) NSString * _Nullable givenNameAlias;
/**
 A document holder's middle name
 */
@property (nonatomic, readonly) NSString * _Nullable middleName;
/**
 A code that indicates whether a middle name has been truncated (T), has not been truncated (N), or – unknown whether truncated (U)
 */
@property (nonatomic, readonly) NSString * _Nullable middleNameTruncation;
/**
 Name suffix (If jurisdiction participates in systems requiring name suffix):
 - JR (Junior)
 - SR (Senior)
 - 1ST or I (First)
 - 2ND or II (Second)
 - 3RD or III (Third)
 - 4TH or IV (Fourth)
 - 5TH or V (Fifth)
 - 6TH or VI (Sixth)
 - 7TH or VII (Seventh)
 - 8TH or VIII (Eighth)
 - 9TH or IX (Ninth)
 */
@property (nonatomic, readonly) NSString * _Nullable suffix;
/**
 Other suffix by which document holder is known
 */
@property (nonatomic, readonly) NSString * _Nullable suffixAlias;
/**
 Address on line 1 (of possible 2)
 */
@property (nonatomic, readonly) NSString * _Nullable addressLine1;
/**
 Address on line 2 (of possible 2)
 */
@property (nonatomic, readonly) NSString * _Nullable addressLine2;
/**
 City
 */
@property (nonatomic, readonly) NSString * _Nullable city;
/**
 State
 */
@property (nonatomic, readonly) NSString * _Nullable state;
/**
 Postal code
 */
@property (nonatomic, readonly) NSString * _Nullable postalCode;
/**
 Country
 */
@property (nonatomic, readonly) NSString * _Nullable country;
/**
 Document number
 */
@property (nonatomic, readonly) NSString * _Nullable documentNumber;
/**
 Sex
 */
@property (nonatomic, readonly) NSString * _Nullable sex;
/**
 Eye color
 */
@property (nonatomic, readonly) NSString * _Nullable eyeColor;
/**
 Height
 */
@property (nonatomic, readonly) NSString * _Nullable height;
/**
 Weight
 */
@property (nonatomic, readonly) NSString * _Nullable weight;
/**
 Hair color
 */
@property (nonatomic, readonly) NSString * _Nullable hairColor;
/**
 Personal number
 */
@property (nonatomic, readonly) NSString * _Nullable personalNumber;
/**
 Optional number
 */
@property (nonatomic, readonly) NSString * _Nullable optionalNumber;
/**
 Nationality
 */
@property (nonatomic, readonly) NSString * _Nullable nationality;
/**
 Country and municipality and/or state/province where a document holder was born
 */
@property (nonatomic, readonly) NSString * _Nullable placeOfBirth;
/**
 Indicates whether a document holder is an organ donor
 */
@property (nonatomic, readonly) BOOL organDonor;
/**
 Indicates whether a document holder is a veteran
 */
@property (nonatomic, readonly) BOOL veteran;
/**
 Returns document expiration status if expiration date was extracted and it was successfully formatted. Otherwise, MiSnapScienceExpirationStatusUndetermined
 See `MiSnapScienceExpirationStatus` enum for all possible values
 */
@property (nonatomic, readonly) MiSnapScienceExpirationStatus expirationStatus;
/**
 A string representation of `expirationStatus`
 */
@property (nonatomic, readonly) NSString * _Nonnull expirationStatusString;
/**
 Document holder's age if date of birth was extracted and successfully formatted. Otherwise -1
 */
@property (nonatomic, readonly) NSInteger age;
/**
 A barcode string
 */
@property (nonatomic, readonly) NSString * _Nullable barcodeString;
/**
 A barcode type
 */
@property (nonatomic, readonly) MiSnapScienceBarcodeType barcodeType;
/**
 A string representation of `barcodeType`
 */
@property (nonatomic, readonly) NSString * _Nonnull barcodeTypeString;
/**
 An MRZ string
 */
@property (nonatomic, readonly) NSString * _Nullable mrzString;
/**
 Unique strings extracted by OCR engine
 */
@property (nonatomic, readonly) NSArray * _Nullable uniqueOcrStrings;
/**
 Additional steps that should be presented as a result of finishing the current session
 */
@property (nonatomic, readonly) MiSnapScienceAdditionalStep additionalStep;
/**
 A string representation of `additionalStep`
 */
@property (nonatomic, readonly) NSString * _Nonnull additionalStepString;
/**
 MRZ bounding box
 */
@property (nonatomic, readonly) CGRect mrzBoundingBox;
/**
 The bounding boxes around personal number in MRZ
 */
@property (nonatomic, readonly) NSArray * _Nullable personalNumberBoundingBoxes;
/**
 The array of four corner points of the detect barcode
 */
@property (nonatomic, readonly) NSArray * _Nullable barcodePoints;
/**
 A string representation of `MiSnapScienceExtractionResult`
 */
- (NSString *)debugString;

@end

NS_ASSUME_NONNULL_END
