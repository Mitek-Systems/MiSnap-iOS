//
//  MiSnapScienceParameters.h
//  MiSnapScience
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MiSnapScienceDocumentType) {
    MiSnapScienceDocumentTypeNone           = 0,
    MiSnapScienceDocumentTypeAnyId          = 1,
    MiSnapScienceDocumentTypePassport       = 2,
    MiSnapScienceDocumentTypeIdFront        = 3,
    MiSnapScienceDocumentTypeIdBack         = 4,
    MiSnapScienceDocumentTypeCheckFront     = 5,
    MiSnapScienceDocumentTypeCheckBack      = 6,
    MiSnapScienceDocumentTypeGeneric        = 7
};

typedef NS_ENUM(NSInteger, MiSnapScienceOrientationMode) {
    // Orientation mode is not set
    MiSnapScienceOrientationModeUnknown                        = 0,
    // Orientation mode where the app supports Landscape only orientation for a device with the Ghost image in Landscape orientation
    MiSnapScienceOrientationModeDeviceLandscapeGuideLandscape  = 1,
    // Orientation mode where the app supports all orientations with the Ghost image in Portrait orientation when a device is in Portrait orientation
    MiSnapScienceOrientationModeDevicePortraitGuidePortrait    = 2,
    // Orientation mode where the app supports all orientations with the Ghost image in Landscape orientation when a device is in Portrait orientation
    MiSnapScienceOrientationModeDevicePortraitGuideLandscape   = 3
};

typedef NS_ENUM(NSInteger, MiSnapScienceGeoRegion)
{
    MiSnapScienceGeoRegionGlobal     = 0, // Default
    MiSnapScienceGeoRegionUS         = 1
};

/**
 Modes for ID Back document type
 */
typedef NS_ENUM(NSInteger, MiSnapScienceIdBackMode) {
    /**
     An ID Back session will be completed as soon as an image passes IQA and
     a barcode will be optionally returned in case if it was read/scanned by that point.
     ## Important notes ##
     This is a good option when ID/DL back with and without PDF417 barcode is allowed
     (e.g. both US and Canada DL back and ID back with 3-line MRZ from most of EU countries)
     */
    MiSnapScienceIdBackModeAcceptableImageRequiredBarcodeOptional  = 0,
    /**
     An ID Back session will be completed when both an image passes IQA and
     a barcode is read/scanned.
     ## Important notes ##
     This is a good option when only ID/DL back with PDF417 barcode is allowed
     (e.g. only US and Canada DL back) and image quality is important
     */
    MiSnapScienceIdBackModeAcceptableImageRequiredBarcodeRequired  = 1,
    /**
     An ID Back session will be completed as soon as a barcode is read/scanned and
     an image used for reading/scanning that may or may not pass IQA is returned
     ## Important notes ##
     This is a good option when only ID/DL back with PDF417 barcode is allowed
     (e.g. only US and Canada DL back) and image quality is not important
     This mode is an equivalent of PDF417 document type in 4.x that was deprecated in 5.x
     */
    MiSnapScienceIdBackModeAcceptableImageOptionalBarcodeRequired  = 2
};

/**
 Barcode types supporrted by ID Back and Any ID document types
 */
typedef NS_ENUM(NSInteger, MiSnapScienceBarcodeType) {
    MiSnapScienceBarcodeTypePDF417              = 0,
    MiSnapScienceBarcodeTypeQR                  = 1,
    MiSnapScienceBarcodeTypeAztec               = 2,
    MiSnapScienceBarcodeTypeCode39              = 3,
    MiSnapScienceBarcodeTypeCode93              = 4,
    MiSnapScienceBarcodeTypeCode128             = 5,
    MiSnapScienceBarcodeTypeInterleaved2of5     = 6
};

/*!
 @class MiSnapSDKScienceParameters
 @abstract
 MiSnapSDKScienceParameters is a class that defines parameters used for analyzing video frames and the science results.
 */
@interface MiSnapScienceParameters : NSObject

/*!
 *  Creates and returns parameters object with default parameter values.
 *
 * @return An instance of `MiSnapScienceParameters`
 */
- (instancetype)initWithDefaultParametersFor:(MiSnapScienceDocumentType)documentType;

/*!
 *  Document type
 *
 */
@property (readwrite, nonatomic) MiSnapScienceDocumentType documentType;

/*!
 *  Document type string representation
 *
 */
@property (readwrite, nonatomic) NSString* documentTypeName;

/*!
 *  The orientation mode.  See the MiSnapScienceOrientationMode enum above for values.
 */
@property (readwrite, nonatomic) MiSnapScienceOrientationMode orientationMode;

/**
 *  The ID Back mode.  See the `MiSnapScienceIdBackMode` enum above for values.
 */
@property (readwrite, nonatomic) MiSnapScienceIdBackMode idBackMode;

/**
 *  Barcode types that ID Back or Any ID document types should scan for. See the `MiSnapScienceBarcodeType` enum above for values.
 */
@property (readwrite, nonatomic) NSArray *supportedBarcodeTypes;

/*!
 *  Minimum horizontal fill required to capture an image in Landscape orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500...1000]
 */
@property (readwrite, nonatomic) NSInteger landscapeFill;

/*!
 *  Minimum horizontal fill required to capture an image in Portrait orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500...1000]
 */
@property (readwrite, nonatomic) NSInteger portraitFill;

/*!
 *  Minimum Corner Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger cornerConfidence;

/*!
 *  Minimum Glare Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger glareConfidence;

/*!
 *  Minimum Contrast Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger contrastConfidence;

/*!
 *  Minimum Background Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger backgroundConfidence;

//TODO: do we need this one? Shoud we rename it to documentFeaturesConfidence?
/*!
 *  Minimum MICR Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger micrConfidence;

/*!
 *  Minimum brightness
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger minBrightness;

/*!
 *  Maximum brightness
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger maxBrightness;

/*!
 *  Minimum sharpness
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger sharpness;

/*!
 *  Minimum image padding between document rectangle and image frame
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger padding;

/*!
 *  Skew angle (tilt)
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger skewAngle;

/*!
 *  Rotation angle
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger rotationAngle;

/*!
 *  Geo.  See MiSnapSDKScienceGeoRegion enum above for values.
 */
@property (readwrite, nonatomic) MiSnapScienceGeoRegion geoRegion;

@end
