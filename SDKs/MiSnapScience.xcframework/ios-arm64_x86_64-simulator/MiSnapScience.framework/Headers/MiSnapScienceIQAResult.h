//
//  MiSnapScienceIQAResult.h
//  MiSnapScience
//
//  Created by Stas Tsuprenko on 12/9/21.
//  Copyright © 2021 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapScience/MiSnapScienceMrz.h>

typedef NS_ENUM(NSInteger, IQAFailure)
{
    IQAFailureGlare             = 0,
    IQAFailureNotIdentityFront  = 1,
    IQAFailureNotIdentityBack   = 2,
    IQAFailureNotPassport       = 3,
    IQAFailureNotCheckFront     = 4,
    IQAFailureNotCheckBack      = 5,
    IQAFailureMrzObstructed     = 6,
    IQAFailureNotFound          = 7,
    IQAFailureContrast          = 8,
    IQAFailureBackground        = 9,
    IQAFailureRotation          = 10,
    IQAFailureSkew              = 11,
    IQAFailureFill              = 12,
    IQAFailurePadding           = 13,
    IQAFailureBrightness        = 14,
    IQAFailureMaxBrightness     = 15,
    IQAFailureSharpness         = 16,
    IQAFailureAspectRatio       = 17
};

NS_ASSUME_NONNULL_BEGIN

/**
 MiSnapScienceIQAResult is a class that defines IQA result
 */
@interface MiSnapScienceIQAResult : NSObject

/*!
 @abstract Indicates the success of the analyer result.
 When TRUE, the result is acceptable. When FASLE, the result is not acceptable and had at least one IQAFailure
 */
@property (nonatomic, readonly, getter=isAcceptable) BOOL acceptable;

/*!
 @abstract The priority ordered NSArray the IQAFailures determined by the analyzer. The NSArray is empty when isAcceptable is TRUE.
 */
@property (nonatomic, readonly) NSArray *orderedFailures;

/*!
 @abstract The IQA value detected for brightness.
 Range: [0, 1000] (1000 represents the highest possible)
 */
@property (nonatomic, readonly) int brightness;

/*!
 @abstract The IQA value detected for sharpness.
 Range: [0, 1000] (1000 represents the highest possible)
 */
@property (nonatomic, readonly) int sharpness;

/*!
 @abstract The IQA value detected for cornerConfidence.
 Range: [0, 1000] (1000 represents the highest possible)
 */
@property (nonatomic, readonly) int cornerConfidence;

/*!
 @abstract The IQA value detected for skewAngle.
 Range: [0, 900] measured in tenths of a percent (i.e. 150 == 15%) (900 represents the highest possible)
 */
@property (nonatomic, readonly) int skewAngle;

/*!
 @abstract The IQA value detected for rotationAngle.
 Range: [0, 900] measured in tenths of a percent (i.e. 150 == 15%) (900 represents the highest possible)
 */
@property (nonatomic, readonly) int rotationAngle;

/*!
 @abstract The IQA value detected for areaRatio (bounding box width / bounding box height) * 100; // e.g. 2.6:1 = 260
 */
@property (nonatomic, readonly) int areaRatio;

/*!
 @abstract The IQA value detected for widthRatio, the percentage of the sceen filled by the document across the widest side.
 Range: [0, 1000] measured in tenths of a percent (i.e. 650 == 65%)
 */
@property (nonatomic, readonly) int widthRatio;

/*!
 @abstract The IQA value detected for minPadding, the minimum number of pixels between the screen edge and any corner of the document.
 Range: [0, 1000] (0 represents the least possible)
 */
@property (nonatomic, readonly) int minPadding;

/*!
 @abstract The IQA value detected for glareConfidence.
 Range: [0, 1000] (1000 represents the highest possible confidence that there is no glare. 0 = all glare, 700 = glare covers 30% of frame, 1000 = no glare)
 */
@property (nonatomic, readonly) int glareConfidence;

/*!
 @abstract The IQA value detected for MICR confidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = no MICR, 500 = partial MICR, 1000 = MICR present)
 */
@property (nonatomic, readonly) int micrConfidence;

/*!
 @abstract The IQA value detected for MRZ Confidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = no MRZ, 500 = partial MRZ, 1000 = MRZ present)
 */
@property (nonatomic, readonly) int mrzConfidence;

/*!
 @abstract The IQA value detected for backgroundConfidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = very busy background, 600 = somewhat busy, 1000 = not busy)
 */
@property (nonatomic, readonly) int backgroundConfidence;

/*!
 @abstract The IQA value detected for contrastConfidence.
 Range: [0, 1000] (1000 represents the highest possible. 0 = low or no contrast, 600 = some contrast, 1000 = excellent contrast)
 */
@property (nonatomic, readonly) int contrastConfidence;

/*!
 @abstract The aspect ratio of an ID document
 */
@property (nonatomic, readonly) int aspectRatio;

/*!
 @abstract A placeholder image that clients of this interface can set for convenience.
 */
@property (nonatomic, readonly) UIImage *image;

/*!
 @abstract The size of the image analyzed.
 */
@property (nonatomic, readonly) CGSize imageSize;

/*!
 @abstract The bounding box that surrounds the corners of a document.
 */
@property (nonatomic, readonly) CGRect boundingBox;

/*!
 @abstract The bounding box that surrounds the corners of a document normalized to a screen size
 */
@property (nonatomic, readonly) CGRect boundingBoxNormalized;

/*!
 @abstract The bounding box around the largest glare spot detected.
 */
@property (nonatomic, readonly) CGRect glareBoundingBox;

/*!
 @abstract The bounding box around the largest glare spot detected normalized to a screen size.
 */
@property (nonatomic, readonly) CGRect glareBoundingBoxNormalized;

/*!
 @abstract The corner points of the document
 */
@property (nonatomic, readonly) NSArray* cornerPoints;

/*!
 @abstract The corner points of the document normalized to a screen size
 */
@property (nonatomic, readonly) NSArray* cornerPointsNormalized;

/*!
 *  @param failure an IQA failure to add to an array of ordered failures
 */
- (void)addIQAFailure:(IQAFailure)failure;

@end

NS_ASSUME_NONNULL_END
