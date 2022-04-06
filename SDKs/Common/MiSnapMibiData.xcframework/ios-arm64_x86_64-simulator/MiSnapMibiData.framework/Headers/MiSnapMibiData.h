//
//  MiSnapMibiData.h
//  MiSnapMibiData
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <MiSnapMibiData/MiSnapUxpEventManager.h>
#import <UIKit/UIKit.h>

/**
 MIBI Data  element
 */
typedef NS_ENUM(NSInteger, MiSnapMibiDataElement) {
    /**
     MIBI version
     */
    MiSnapMibiDataElementMibiVersion = 0,
    /**
     Device info
     */
    MiSnapMibiDataElementDeviceInfo,
    /**
     SDK info
     */
    MiSnapMibiDataElementSdkInfo,
    /**
     Platform private
     */
    MiSnapMibiDataElementPlatformPrivate,
    /**
     Session info
     */
    MiSnapMibiDataElementSessionInfo,
    /**
     Device
     */
    MiSnapMibiDataElementDevice,
    /**
     Manufacturer
     */
    MiSnapMibiDataElementManufacturer,
    /**
     Model
     */
    MiSnapMibiDataElementModel,
    /**
     Platfrom
     */
    MiSnapMibiDataElementPlatfrom,
    /**
     OS
     */
    MiSnapMibiDataElementOS,
    /**
     Modules
     */
    MiSnapMibiDataElementModules,
    /**
     Name
     */
    MiSnapMibiDataElementName,
    /**
     Version
     */
    MiSnapMibiDataElementVersion,
    /**
     Parameters
     */
    MiSnapMibiDataElementParameters,
    /**
     Original
     */
    MiSnapMibiDataElementOriginal,
    /**
     Final
     */
    MiSnapMibiDataElementFinal,
    /**
     UXP
     */
    MiSnapMibiDataElementUXP,
    /**
     Result code
     */
    MiSnapMibiDataElementResultCode,
    /**
     Image width
     */
    MiSnapMibiDataElementImageWidth,
    /**
     Image height
     */
    MiSnapMibiDataElementImageHeight,
    /**
     Orientation
     */
    MiSnapMibiDataElementOrientation,
    /**
     Classification document type
     */
    MiSnapMibiDataElementClassificationDocumentType
};

/**
 Mitek Business Intelligence (MIBI) Data is a library that collects non-PII session analytics
 */
@interface MiSnapMibiData : NSObject
/**
 Version
 */
+ (NSString * _Nonnull)version;
/**
 JSON representation of MIBI Data
 */
@property (nonatomic, readonly) NSData * _Nullable mibiDataJson;
/**
 String representation of MIBI Data
 */
@property (nonatomic, readonly) NSString * _Nullable mibiDataString;
/**
 Sets module name and its version
 */
- (void)setModuleWithName:(NSString * _Nonnull)name version:(NSString * _Nonnull)version;
/**
 Sets session info
 */
- (void)setSessionInfo:(NSDictionary * _Nonnull)dictionary;
/**
 Add key-value pair to MIBI Data
 
 @param value `NSString` value to add
 @param element `MiSnapMibiDataElement` key to add value for
 */
- (void)setValue:(NSString * _Nonnull)value forElement:(MiSnapMibiDataElement)element;
/**
 Add elements to MIBI Data Parameters dictionary
 
 @param dictionary the NSDictionary of parameters to add
 */
- (void)setParameters:(NSDictionary * _Nonnull)dictionary original:(BOOL)original;
/**
 Add UXP events to MIBI data dictionary
 
 @param uxpEvents the `NSArray` of UXP events
 */
- (void)setUXP:(NSArray<NSDictionary *> * _Nonnull)uxpEvents;
/**
 Add MIBI data to an original image
 
 @param image the image to add the EXIF data to
 @param compression defines how much to compress the image. Range [0.0 - 100.0] as a percentage
 
 @return compressed image data with MIBI data added to EXIF
 */
- (NSData * _Nullable)addTo:(UIImage * _Nonnull)image withCompression:(CGFloat)compression;
/**
 Encode image data using base64
 
 @param input the NSData to encode
 
 @return string that represents base64 encoded image data
 */
- (NSString * _Nullable)base64Encoding:(NSData * _Nonnull)input;

@end

