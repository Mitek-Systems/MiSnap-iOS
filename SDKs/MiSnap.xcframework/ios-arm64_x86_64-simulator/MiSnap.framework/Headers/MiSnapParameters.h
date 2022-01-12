//
//  MiSnapParameters.h
//  MiSnap
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapCamera/MiSnapCameraParameters.h>

/**
 Document type
 */
typedef NS_ENUM(NSInteger, MiSnapDocumentType) {
    /**
     Document type is not set
     */
    MiSnapDocumentTypeNone          = 0,
    /**
     Any ID
     */
    MiSnapDocumentTypeAnyId         = 1,
    /**
     Passport
     */
    MiSnapDocumentTypePassport      = 2,
    /**
     ID Front
     */
    MiSnapDocumentTypeIdFront       = 3,
    /**
     ID Back
     */
    MiSnapDocumentTypeIdBack        = 4,
    /**
     Check Front
     */
    MiSnapDocumentTypeCheckFront    = 5,
    /**
     Check Back
     */
    MiSnapDocumentTypeCheckBack     = 6,
    /**
     Generic
     */
    MiSnapDocumentTypeGeneric       = 7
};

/**
 Document category
 */
typedef NS_ENUM(NSInteger, MiSnapDocumentCategory) {
    /**
     Category is not set
     */
    MiSnapDocumentCategoryNone      = 0,
    /**
     ID
     */
    MiSnapDocumentCategoryId        = 1,
    /**
     Deposit
     */
    MiSnapDocumentCategoryDeposit   = 2
};

/**
 SDK mode
 */
typedef NS_ENUM(NSInteger, MiSnapMode) {
    /**
     Mode is not set
     */
    MiSnapModeNone    = 0,
    /**
     Manual
     
     An image is acquired using a manual trigger
     */
    MiSnapModeManual  = 1,
    /**
     Auto
     
     An image is acquired automatically when it passes all Image Quality Analysis checks
     */
    MiSnapModeAuto    = 2,
};

/**
 Tutorial mode
 */
typedef NS_ENUM(NSInteger, MiSnapTutorialMode) {
    /**
     Tutorial mode is not set
     */
    MiSnapTutorialModeNone            = 0,
    /**
     Tutorial that's presented before a session is started
     */
    MiSnapTutorialModeInstruction     = 1,
    /**
     Tutorial that's presented when a user presses "Help" button
     */
    MiSnapTutorialModeHelp            = 2,
    /**
     Tutorial that's presented upon a timeout in `MiSnapModeAuto`
     */
    MiSnapTutorialModeTimeout         = 3
};

/**
 Orientation mode
 */
typedef NS_ENUM(NSInteger, MiSnapOrientationMode) {
    /**
     Orientation mode is not set
     */
    MiSnapOrientationModeUnknown                        = 0,
    /**
     Orientation mode where the app supports Landscape only orientation for a device with the Guide image in Landscape orientation
     */
    MiSnapOrientationModeDeviceLandscapeGuideLandscape  = 1,
    /**
     Orientation mode where the app supports all orientations with the Guide image in Portrait orientation when a device is in Portrait orientation
     */
    MiSnapOrientationModeDevicePortraitGuidePortrait    = 2,
    /**
     Orientation mode where the app supports all orientations with the Guide image in Landscape orientation when a device is in Portrait orientation
     */
    MiSnapOrientationModeDevicePortraitGuideLandscape   = 3
};

/**
 Mode for ID Back and Any ID document types
 */
typedef NS_ENUM(NSInteger, MiSnapIdBackMode) {
    /**
     ID Back a session will be completed as soon as an image passes IQA and
     a barcode will be optionally returned in case if it was read/scanned by that point.
     
     @note Use this option when ID/DL back with and without PDF417 barcode is allowed
     (e.g. both US and Canada DL back and ID back with 3-line MRZ from most of EU countries).
     */
    MiSnapIdBackModeAcceptableImageRequiredBarcodeOptional  = 0,
    /**
     ID Back a session will be completed when both an image passes IQA and
     a barcode is read/scanned.
     @note Use this option when only ID/DL back with PDF417 barcode is allowed
     (e.g. only US and Canada DL back) and image quality is important
     */
    MiSnapIdBackModeAcceptableImageRequiredBarcodeRequired  = 1,
    /**
     ID Back a session will be completed as soon as a barcode is read/scanned and
     an image used for reading/scanning that may or may not pass IQA is returned.
     
     This mode is an equivalent of PDF417 document type in 4.x that is deprecated in 5.x
     
     @note Use this option when only ID/DL back with PDF417 barcode is allowed
     (e.g. only US and Canada DL back) and image quality is not important
     */
    MiSnapIdBackModeAcceptableImageOptionalBarcodeRequired  = 2
};

/**
 Barcode type supporrted by ID Back and Any ID document types
 */
typedef NS_ENUM(NSInteger, MiSnapBarcodeType) {
    /**
     PDF417
     */
    MiSnapBarcodeTypePDF417              = 0,
    /**
     QR
     */
    MiSnapBarcodeTypeQR                  = 1,
    /**
     Aztec
     */
    MiSnapBarcodeTypeAztec               = 2,
    /**
     Code 39
     */
    MiSnapBarcodeTypeCode39              = 3,
    /**
     Code 93
     */
    MiSnapBarcodeTypeCode93              = 4,
    /**
     Code 128
     */
    MiSnapBarcodeTypeCode128             = 5,
    /**
     Interleaved 2 of 5
     */
    MiSnapBarcodeTypeInterleaved2of5     = 6
};

typedef NS_ENUM(NSInteger, MiSnapGeoRegion)
{
    MiSnapGeoRegionGlobal     = 0,
    MiSnapGeoRegionUS         = 1
};

/**
 Parameters used during the document acquisition process.
 */
@interface MiSnapParameters : NSObject

/**
 Creates and returns parameters object with default parameter values.
 
 @return An instance of `MiSnapParameters`
 */
- (instancetype _Nonnull)initFor:(MiSnapDocumentType)documentType;

/**
 Document type
 */
@property (readonly, nonatomic) MiSnapDocumentType documentType;

/**
 Document type string representation
 */
@property (readwrite, nonatomic) NSString * _Nonnull documentTypeName;

/**
 Document type category
 */
@property (readonly, nonatomic) MiSnapDocumentCategory documentCategory;

/**
 Mode that's used to acquire an image
 */
@property (readwrite, nonatomic) MiSnapMode mode;

/**
 The orientation mode
 */
@property (readwrite, nonatomic) MiSnapOrientationMode orientationMode;

/**
 The ID Back mode
 */
@property (readwrite, nonatomic) MiSnapIdBackMode idBackMode;

/**
 Barcode types that ID Back or Any ID document types should scan for.
 
 @see `MiSnapBarcodeType`.
 */
@property (readwrite, nonatomic) NSArray * _Nonnull supportedBarcodeTypes;

/**
 *  Minimum horizontal fill required to acquire an image in Landscape orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500...1000]
 */
@property (readwrite, nonatomic) NSInteger landscapeFill;

/**
 *  Minimum horizontal fill required to acquire an image in Portrait orientation.  E.g. 800 = 80.0%
 *
 *  Range: [500...1000]
 */
@property (readwrite, nonatomic) NSInteger portraitFill;

/**
 *  Timeout (ms)
 *
 *  Range: [1,000...90,000]
 */
@property (readwrite, nonatomic) NSInteger timeout;

/**
 *  Image quality compression to apply
 *
 *  Range: [50...100]
 */
@property (readwrite, nonatomic) NSInteger imageQuality;

/**
 *  Minimum Corner Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger cornerConfidence;

/**
 *  Minimum Glare Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger glareConfidence;

/**
 *  Minimum Contrast Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger contrastConfidence;

/**
 *  Minimum Background Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger backgroundConfidence;

//TODO: do we need this one? Shoud we rename it to documentFeaturesConfidence?
/**
 *  Minimum MICR Confidence
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger micrConfidence;

/**
 *  Minimum brightness
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger minBrightness;

/**
 *  Maximum brightness
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger maxBrightness;

/**
 *  Minimum sharpness
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger sharpness;

/**
 *  Minimum image padding between document rectangle and image frame
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger padding;

/**
 *  Skew angle (tilt)
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger skewAngle;

/**
 *  Rotation angle
 *
 *  Range: [0...1000]
 */
@property (readwrite, nonatomic) NSInteger rotationAngle;

/**
 *  Geo.  See MiSnapGeoRegion enum above for values.
 */
@property (readwrite, nonatomic) MiSnapGeoRegion geoRegion;

/**
 *  A delay in milliseconds between the first frame that passed all IQA checks before continuing analysis
 *
 *  Range: [0...2000]
 */
@property (nonatomic) NSInteger frameDelay;

/**
 *  Application version
 */
@property (readwrite, nonatomic) NSString * _Nullable applicationVersion;

/**
 *  Server version
 */
@property (readwrite, nonatomic) NSString * _Nullable serverVersion;

/**
 * Seamless failover
 */
@property (readwrite, nonatomic) BOOL seamlessFailover;

/**
 *  Time between hints (ms)
 *
 *  Range: [1000...10000]
 */
@property (readwrite, nonatomic) NSInteger smartHintUpdatePeriod;

/**
 *  Time to delay ending MiSnap session after a successful image acquisition (ms)
 *
 *  Range: [1500...10000]
 */
@property (readwrite, nonatomic) NSInteger terminationDelay;

/**
 *  A string to provide an image to analyze
 */
@property (readwrite, nonatomic) NSString * _Nullable injectImageName;

/**
 An object that configures camera specific parameters
 */
@property (readwrite, nonatomic) MiSnapCameraParameters * _Nonnull camera;

/**
 *  @return dictionary of parameters
 */
- (NSDictionary * _Nonnull)toDictionary;

@end

