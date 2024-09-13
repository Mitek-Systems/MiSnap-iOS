//
//  MiSnapScienceIQAResult.h
//  MiSnapScience
//
//  Created by Stas Tsuprenko on 12/9/21.
//  Copyright © 2021 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapScience/MiSnapScienceMrz.h>

/**
 IQA Failure
 */
typedef NS_ENUM(NSInteger, IQAFailure) {
    /**
     A document has too much glare
     */
    IQAFailureGlare             = 0,
    /**
     Front of identity document is expected but some other document is found
     
     Requires `MiSnapLicenseFeatureODC` to be supported
     */
    IQAFailureNotIdentityFront  = 1,
    /**
     Back of identity document is expected but some other document is found
     
     Requires `MiSnapLicenseFeatureODC` to be supported
     */
    IQAFailureNotIdentityBack   = 2,
    /**
     Passport is expected but some other document is found
     
     Requires `MiSnapLicenseFeatureODC` to be supported
     */
    IQAFailureNotPassport       = 3,
    /**
     Check Front is expected but some other document is found
     */
    IQAFailureNotCheckFront     = 4,
    /**
     Check Back is expected but Check Front is found
     */
    IQAFailureNotCheckBack      = 5,
    /**
     1-line MRZ of EU DL is obstructed
     */
    IQAFailureMrzObstructed     = 6,
    /**
     A document is not found
     */
    IQAFailureNotFound          = 7,
    /**
     A document and background have insufficient contrast
     for corners to be accurately found
     */
    IQAFailureContrast          = 8,
    /**
     Background has to many lines that can be confused for a document edge
     */
    IQAFailureBackground        = 9,
    /**
     A document is too rotated relative to a guide
     */
    IQAFailureRotation          = 10,
    /**
     A document is tilted so that one side is much closer to a camera than others
     */
    IQAFailureSkew              = 11,
    /**
     A document is too far
     */
    IQAFailureFill              = 12,
    /**
     A document is too close to an edge of a frame
     */
    IQAFailurePadding           = 13,
    /**
     Insufficient lighting conditions
     */
    IQAFailureBrightness        = 14,
    /**
     Too bright lighting conditions
     */
    IQAFailureMaxBrightness     = 15,
    /**
     Document is not sharp
     
     Either a camera is being focused or
     a document is in excessive motion
     */
    IQAFailureSharpness         = 16,
    /**
     A document with a wrong aspect ratio is found
     */
    IQAFailureAspectRatio       = 17
};

NS_ASSUME_NONNULL_BEGIN

/**
 Image Quality Analysis (IQA) result
 */
@interface MiSnapScienceIQAResult : NSObject
/**
 Indicates the success of the analyer result.
 
 When TRUE, the result is acceptable. When FASLE, the result is not acceptable and had at least one `IQAFailure`
 */
@property (nonatomic, readonly, getter=isAcceptable) BOOL acceptable;
/**
 The priority ordered NSArray of `IQAFailure` determined by the analyzer. The NSArray is empty when `acceptable` is TRUE.
 */
@property (nonatomic, readonly) NSArray *orderedFailures;
/**
 The IQA value detected for brightness
 
 Range: 0...1000 (1000 represents the highest possible)
 */
@property (nonatomic, readonly) int brightness;
/**
 The IQA value detected for sharpness.
 
 Range: 0...1000 (1000 represents the highest possible)
 */
@property (nonatomic, readonly) int sharpness;
/**
 The IQA value detected for cornerConfidence.
 
 Range: 0...1000 (1000 represents the highest possible)
 */
@property (nonatomic, readonly) int cornerConfidence;
/**
 The IQA value detected for skew angle.
 
 Range: 0...900 measured in tenths of a percent (i.e. 150 == 15%) (900 represents the highest possible)
 */
@property (nonatomic, readonly) int skewAngle;
/**
 The IQA value detected for rotation angle.
 
 Range: 0...900 measured in tenths of a percent (i.e. 150 == 15%) (900 represents the highest possible)
 */
@property (nonatomic, readonly) int rotationAngle;
/**
 The IQA value detected for width ratio, the percentage of the sceen filled by the document across the widest side.
 
 Range: 0...1000 measured in tenths of a percent (i.e. 650 == 65%)
 */
@property (nonatomic, readonly) int widthRatio;
/**
 The IQA value detected for min padding, the minimum number of pixels between the screen edge and any side of the document.
 
 Range: 0...1000 (0 represents the least possible)
 */
@property (nonatomic, readonly) int minPadding;
/**
 The IQA value detected for glare confidence.
 
 Range: 0...1000 (1000 represents the highest possible confidence that there is no glare. 0 = all glare, 700 = glare covers 30% of frame, 1000 = no glare)
 */
@property (nonatomic, readonly) int glareConfidence;
/** The IQA value detected for MICR confidence.
 
 Range: 0...1000 (1000 represents the highest possible. 0 = no MICR, 500 = partial MICR, 1000 = MICR present)
 */
@property (nonatomic, readonly) int micrConfidence;
/**
 The IQA value detected for MRZ Confidence.
 
 Range: 0...1000 (1000 represents the highest possible. 0 = no MRZ, 500 = partial MRZ, 1000 = MRZ present)
 */
@property (nonatomic, readonly) int mrzConfidence;
/**
 The IQA value detected for backgroundConfidence.
 
 Range: 0...1000 (1000 represents the highest possible. 0 = very busy background, 600 = somewhat busy, 1000 = not busy)
 */
@property (nonatomic, readonly) int backgroundConfidence;
/**
 The IQA value detected for contrastConfidence.
 
 Range: 0...1000 (1000 represents the highest possible. 0 = low or no contrast, 600 = some contrast, 1000 = excellent contrast)
 */
@property (nonatomic, readonly) int contrastConfidence;
/**
 The aspect ratio of an ID document
 */
@property (nonatomic, readonly) int aspectRatio;
/**
 `UIImage` representation of a buffer that was analyzed
 */
@property (nonatomic, readonly) UIImage *image;
/**
 The size of the image analyzed.
 */
@property (nonatomic, readonly) CGSize imageSize;
/**
 The bounding box that surrounds the corners of a document.
 */
@property (nonatomic, readonly) CGRect boundingBox;
/**
 The bounding box that surrounds the corners of a document normalized to a screen size
 */
@property (nonatomic, readonly) CGRect boundingBoxNormalized;
/**
 The bounding box around the largest glare spot detected.
 */
@property (nonatomic, readonly) CGRect glareBoundingBox;
/**
 The bounding box around the largest glare spot detected normalized to a screen size.
 */
@property (nonatomic, readonly) CGRect glareBoundingBoxNormalized DEPRECATED_MSG_ATTRIBUTE("Deprecated since it returns a wrong rect when aspect ratio is anything other than 16:9. Normalize `glareBoundingBox` based on a camera preview rect instead");
/**
 The corner points of the document
 */
@property (nonatomic, readonly) NSArray *cornerPoints;
/**
 The corner points of the document normalized to a screen size
 */
@property (nonatomic, readonly) NSArray *cornerPointsNormalized DEPRECATED_MSG_ATTRIBUTE("Deprecated since it returns wrong corner points when aspect ratio is anything other than 16:9. Normalize `cornerPoints` based on a camera preview rect instead");
/**
 Adds IQA failure to `orderedFailures`
 
 @param failure an IQA failure to add to an array of ordered failures
 */
- (void)addIQAFailure:(IQAFailure)failure;

@end

NS_ASSUME_NONNULL_END
