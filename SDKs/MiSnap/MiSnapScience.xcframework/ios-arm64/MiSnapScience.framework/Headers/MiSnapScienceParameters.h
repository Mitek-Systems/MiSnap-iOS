//
//  MiSnapScienceParameters.h
//  MiSnapScience
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Document type
 */
typedef NS_ENUM(NSInteger, MiSnapScienceDocumentType) {
    /**
     Document type is not set
     */
    MiSnapScienceDocumentTypeNone           = 0,
    /**
     Any ID
     */
    MiSnapScienceDocumentTypeAnyId          = 1,
    /**
     Passport
     */
    MiSnapScienceDocumentTypePassport       = 2,
    /**
     ID Front
     */
    MiSnapScienceDocumentTypeIdFront        = 3,
    /**
     ID Back
     */
    MiSnapScienceDocumentTypeIdBack         = 4,
    /**
     Check Front
     */
    MiSnapScienceDocumentTypeCheckFront     = 5,
    /**
     Check Back
     */
    MiSnapScienceDocumentTypeCheckBack      = 6,
    /**
     Generic
     */
    MiSnapScienceDocumentTypeGeneric        = 7
};

/**
 Document category
 */
typedef NS_ENUM(NSInteger, MiSnapScienceDocumentCategory) {
    /**
     Category is not set
     */
    MiSnapScienceDocumentCategoryNone      = 0,
    /**
     ID
     */
    MiSnapScienceDocumentCategoryId        = 1,
    /**
     Deposit
     */
    MiSnapScienceDocumentCategoryDeposit   = 2,
    /**
     Generic
     */
    MiSnapScienceDocumentCategoryGeneric   = 3
};

/**
 Orientation mode
 */
typedef NS_ENUM(NSInteger, MiSnapScienceOrientationMode) {
    /**
     Orientation mode is not set
     */
    MiSnapScienceOrientationModeUnknown                        = 0,
    /**
     Orientation mode where the app supports Landscape only orientation for a device with the Guide image in Landscape orientation
     */
    MiSnapScienceOrientationModeDeviceLandscapeGuideLandscape  = 1,
    /**
     Orientation mode where the app supports all orientations with the Guide image in Portrait orientation when a device is in Portrait orientation
     */
    MiSnapScienceOrientationModeDevicePortraitGuidePortrait    = 2,
    /**
     Orientation mode where the app supports all orientations with the Guide image in Landscape orientation when a device is in Portrait orientation
     */
    MiSnapScienceOrientationModeDevicePortraitGuideLandscape   = 3
};

/**
 Mode for ID Back and Any ID document types
 */
typedef NS_ENUM(NSInteger, MiSnapScienceIdBackMode) {
    /**
     ID Back a session will be completed as soon as an image passes IQA and
     a barcode will be optionally returned in case if it was read/scanned by that point.
     
     @note Use this option when ID/DL back with and without PDF417 barcode is allowed
     (e.g. both US and Canada DL back and ID back with 3-line MRZ from most of EU countries).
     */
    MiSnapScienceIdBackModeAcceptableImageRequiredBarcodeOptional  = 0,
    /**
     ID Back a session will be completed when both an image passes IQA and
     a barcode is read/scanned.
     @note Use this option when only ID/DL back with PDF417 barcode is allowed
     (e.g. only US and Canada DL back) and image quality is important
     */
    MiSnapScienceIdBackModeAcceptableImageRequiredBarcodeRequired  = 1,
    /**
     ID Back a session will be completed as soon as a barcode is read/scanned and
     an image used for reading/scanning that may or may not pass IQA is returned.
     
     This mode is an equivalent of PDF417 document type in 4.x that is deprecated in 5.x
     
     @note Use this option when only ID/DL back with PDF417 barcode is allowed
     (e.g. only US and Canada DL back) and image quality is not important
     */
    MiSnapScienceIdBackModeAcceptableImageOptionalBarcodeRequired  = 2
};

/**
 Barcode type supporrted by ID Back and Any ID document types
 */
typedef NS_ENUM(NSInteger, MiSnapScienceBarcodeType) {
    /**
     PDF417
     */
    MiSnapScienceBarcodeTypePDF417              = 0,
    /**
     QR
     */
    MiSnapScienceBarcodeTypeQR                  = 1,
    /**
     Aztec
     */
    MiSnapScienceBarcodeTypeAztec               = 2,
    /**
     Code 39
     */
    MiSnapScienceBarcodeTypeCode39              = 3,
    /**
     Code 93
     */
    MiSnapScienceBarcodeTypeCode93              = 4,
    /**
     Code 128
     */
    MiSnapScienceBarcodeTypeCode128             = 5,
    /**
     Interleaved 2 of 5
     */
    MiSnapScienceBarcodeTypeInterleaved2of5     = 6
};

/**
 Geo region to use when analyzing Check Front
 */
typedef NS_ENUM(NSInteger, MiSnapScienceGeoRegion) {
    /**
     Global
     */
    MiSnapScienceGeoRegionGlobal     = 0,
    /**
     US
     */
    MiSnapScienceGeoRegionUS         = 1
};

/**
 Parameters for the image analysis
 */
@interface MiSnapScienceParameters : NSObject
/**
 Creates and returns parameters object with default parameter values for a given `MiSnapScienceDocumentType`.
 
 @return An instance of `MiSnapScienceParameters`
 */
- (instancetype _Nonnull)initFor:(MiSnapScienceDocumentType)documentType;
/**
 Document type
 */
@property (nonatomic, readonly) MiSnapScienceDocumentType documentType;
/**
 Document type string representation
 */
@property (nonatomic, readwrite) NSString * _Nonnull documentTypeName;
/**
 Document type category
 */
@property (nonatomic, readonly) MiSnapScienceDocumentCategory documentCategory;
/**
 The orientation mode
 */
@property (nonatomic, readwrite) MiSnapScienceOrientationMode orientationMode;
/**
 The ID Back mode
 */
@property (nonatomic, readwrite) MiSnapScienceIdBackMode idBackMode;
/**
 Barcode types that ID Back or Any ID document types should scan for.
 
 @see `MiSnapScienceBarcodeType`
 */
@property (nonatomic, readwrite) NSArray * _Nonnull supportedBarcodeTypes;
/**
 Minimum horizontal fill required to acquire an image in Landscape orientation.  E.g. 800 = 80.0%
 
 Range: 500...1000
 */
@property (nonatomic, readwrite) NSInteger landscapeFill;
/**
 Minimum horizontal fill required to acquire an image in Portrait orientation.  E.g. 800 = 80.0%

 Range: 500...1000
 */
@property (nonatomic, readwrite) NSInteger portraitFill;
/**
 Minimum Corner Confidence
 
 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger cornerConfidence;
/**
 Minimum Glare Confidence

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger glareConfidence;
/**
 Minimum Contrast Confidence

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger contrastConfidence;
/**
 Minimum Background Confidence

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger backgroundConfidence;
/**
 Minimum MICR Confidence

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger micrConfidence;
/**
 Minimum brightness

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger minBrightness;
/**
 Maximum brightness

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger maxBrightness;
/**
 Minimum sharpness

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger sharpness;
/**
 Minimum image padding between document rectangle and image frame

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger padding;
/**
 Skew angle (tilt)

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger skewAngle;
/**
 Rotation angle

 Range: 0...1000
 */
@property (nonatomic, readwrite) NSInteger rotationAngle;
/**
 Geo region
 
 @see `MiSnapScienceGeoRegion`
 */
@property (nonatomic, readwrite) MiSnapScienceGeoRegion geoRegion;
/**
 Indicate whether On-Device Classification should be done when licensed
 
 Default: TRUE
 */
@property (nonatomic, readwrite) BOOL odcEnabled;
/**
 String code for `MiSnapScienceDocumentType`
 */
+ (NSString * _Nonnull)documentTypeCodeFrom:(MiSnapScienceDocumentType)documentType;
/**
 Dictionary of parameters
 */
- (NSDictionary * _Nonnull)toDictionary;

@end
