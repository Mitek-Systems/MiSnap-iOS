//
//  MiSnapScienceMrz.h
//  MiSnapScience
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MRZ result
*/
@interface MiSnapScienceMrz : NSObject
/**
 The confidence that the MRZ was found
 */
@property (nonatomic, assign) NSInteger confidence;
/**
 The MRZ string
 */
@property (nonatomic, strong) NSString *mrzString;
/**
 Document number parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *docNumber;
/**
 Date of birth parsed from the `mrzString` in format YYMMDD
 */
@property (nonatomic, strong) NSString *dob;
/**
 Date of birth parsed from the `mrzString` in format YYYY-MM-DD
 */
@property (nonatomic, strong) NSString *dobFormatted;
/**
 Date of expiry parsed from the `mrzString` in format YYMMDD
 */
@property (nonatomic, strong) NSString *doe;
/**
 Date of expiry parsed from the `mrzString` in format YYYY-MM-DD
 */
@property (nonatomic, strong) NSString *doeFormatted;
/**
 First name parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *firstName;
/**
 Last name parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *lastName;
/**
 Contry parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *country;
/**
 Nationality parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *nationality;
/**
 Sex parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *sex;
/**
 Personal number parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *personalNumber;
/**
 Optional number parsed from the `mrzString`
 */
@property (nonatomic, strong) NSString *optionalNumber;
/**
 The bounding boxes around personal number in MRZ
 */
@property (nonatomic, strong) NSArray *personalNumberBoundingBoxes;
/**
 A dictionary describing `MiSnapScienceMrz` object
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
