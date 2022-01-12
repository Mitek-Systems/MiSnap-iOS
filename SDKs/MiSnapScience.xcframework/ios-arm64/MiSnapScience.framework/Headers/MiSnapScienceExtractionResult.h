//
//  MiSnapScienceExtractionResult.h
//  MiSnapScience
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MiSnapScienceExpirationStatus) {
    MiSnapScienceExpirationStatusUndetermined = 0,
    MiSnapScienceExpirationStatusValid,
    MiSnapScienceExpirationStatusExpired
};

NS_ASSUME_NONNULL_BEGIN

/**
 MiSnapScienceExtractionResult is a class that defines extraction result
 */
@interface MiSnapScienceExtractionResult : NSObject

@property (nonatomic, readonly) NSString * _Nullable licenseClass;

@property (nonatomic, readonly) NSString * _Nullable restrictionCodes;

@property (nonatomic, readonly) NSString * _Nullable endorsementCodes;
/**
 Issue date string in a raw format
 */
@property (nonatomic, readonly) NSString * _Nullable issueDate;

/**
 Issue date string in format YYYY-MM-DD
 ## Important notes ##
 For DLs issue date is only formatted for USA and Canada. Otherwise, raw issue date string is returned
 as raw format for other countries is not yet known
 */
@property (nonatomic, readonly) NSString * _Nullable issueDateFormatted;

/**
 Expiration date string in a raw format
 */
@property (nonatomic, readonly) NSString * _Nullable expirationDate;

/**
 Expiration date string in format YYYY-MM-DD
 ## Important notes ##
 For DLs expiration date is only formatted for USA and Canada. Otherwise, raw issue date string is returned
 as raw format for other countries is not yet known
 */
@property (nonatomic, readonly) NSString * _Nullable expirationDateFormatted;

/**
 Date of birth string in a raw format
 */
@property (nonatomic, readonly) NSString * _Nullable dateOfBirth;

/**
 Date of birth string in format YYYY-MM-DD
 ## Important notes ##
 For DLs date of birth is only formatted for USA and Canada. Otherwise, raw issue date string is returned
 as raw format for other countries is not yet known
 */
@property (nonatomic, readonly) NSString * _Nullable dateOfBirthFormatted;

@property (nonatomic, readonly) NSString * _Nullable surname;

/**
 A code that indicates whether a surname has been truncated (T), has not been truncated (N), or – unknown whether truncated (U)
 */
@property (nonatomic, readonly) NSString * _Nullable surnameTruncation;

/**
 Other surname by which document holder is known
 */
@property (nonatomic, readonly) NSString * _Nullable surnameAlias;

@property (nonatomic, readonly) NSString * _Nullable givenName;

/**
 A code that indicates whether a given name has been truncated (T), has not been truncated (N), or – unknown whether truncated (U)
 */
@property (nonatomic, readonly) NSString * _Nullable givenNameTruncation;

/**
 Other given name by which document holder is known
 */
@property (nonatomic, readonly) NSString * _Nullable givenNameAlias;

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

@property (nonatomic, readonly) NSString * _Nullable personalNumber;

@property (nonatomic, readonly) NSString * _Nullable optionalNumber;

@property (nonatomic, readonly) NSString * _Nullable nationality;

/**
 Country and municipality and/or state/province
 */
@property (nonatomic, readonly) NSString * _Nullable placeOfBirth;

@property (nonatomic, readonly) BOOL organDonor;

@property (nonatomic, readonly) BOOL veteran;

/**
 Returns document expiration status if expiration date was extracted and it was successfully formatted. Otherwise, MiSnapScienceExpirationStatusUndetermined
 See `MiSnapScienceExpirationStatus` enum for all possible values
 */
@property (nonatomic, readonly) MiSnapScienceExpirationStatus expirationStatus;

/**
 A string representation of an expiration status
 */
@property (nonatomic, readonly) NSString * _Nonnull expirationStatusString;

/**
 Returns document holder's age if date of birth was extracted and it was successfully formatted. Otherwise -1,
 */
@property (nonatomic, readonly) NSInteger age;

@property (nonatomic, readonly) NSString * _Nullable barcodeString;

@property (nonatomic, readonly) NSString * _Nullable mrzString;

@property (nonatomic, readonly) NSArray * _Nullable uniqueOcrStrings;

- (NSString *)debugString;

@end

NS_ASSUME_NONNULL_END
