//
//  MiSnapMibiData.h
//  MiSnapMibiData
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <MiSnapMibiData/MiSnapUxpEventManager.h>
#import <UIKit/UIKit.h>

/*!
 @class MiSnapMibiData
 @abstract
 MiSnapMibiData is a class that defines methods to manage MibiData. Dictionaries and UXP events are added to
 the mibiDataDictionary accessible via the property. The MibiData can be accessed as JSON NSData or as an NSString.
 The MibiData can be added as EXIF to an image with compression. The returned NSData can be encoded as a base64 NSString.
 */
@interface MiSnapMibiData : NSObject

/*!
 @abstract
 returns MIBI data version
 */
+ (NSString*)version;

/*!
 @abstract
 A dictionary of MIBI data elements
 */
@property (nonatomic, readwrite) NSMutableDictionary *mibiDataDictionary;

/*!
 @abstract
 MIBI Data in JSON format
 */
@property (nonatomic, readonly) NSData *mibiDataJson;

/*!
 @abstract
 MIBI Data in string format
 */
@property (nonatomic, readonly) NSString *mibiDataString;

/*!
 @abstract
 Add elements to MIBI data dictionary
 @param dictionary the NSDictionary to add
 */
- (void)addToMibiDataDictionary:(NSDictionary *)dictionary;

/*!
 @abstract
 Add elements to MIBI data parameters dictionary
 @param dictionary the NSDictionary to add
 */
- (void)addToMibiDataParametersDictionary:(NSDictionary *)dictionary;

/*! @abstract
 Add UXP events to MIBI data dictionary
 @param uxpEvents the NSArray of NSDictionary object to add
 */
- (void)addUXP:(NSArray<NSDictionary *> *)uxpEvents;

/*! @abstract
 Add MIBI data to an original image
 @param image the image to add the EXIF data to
 @param compression defines how much to compress the image. Range [0.0 - 100.0] as a percentage
 @return compressed image data with MIBI data added to EXIF
 */
- (NSData *)addMibiDataToImage:(UIImage *)image withCompression:(CGFloat)compression;

/*! @abstract
 Encode image data using base64
 @param input the NSData to encode
 @return string that represents base64 encoded image data
 */
- (NSString *)base64Encoding:(NSData *)input;

@end

