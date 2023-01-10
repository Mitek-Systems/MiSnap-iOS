//
//  MiSnapParameters.h
//  MiSnap
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapCamera/MiSnapCameraParameters.h>
#import <MiSnapScience/MiSnapScienceParameters.h>

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
    MiSnapTutorialModeNone              = 0,
    /**
     Tutorial that's presented before a session is started
     */
    MiSnapTutorialModeInstruction       = 1,
    /**
     Tutorial that's presented when a user presses "Help" button
     */
    MiSnapTutorialModeHelp              = 2,
    /**
     Tutorial that's presented upon a timeout in `MiSnapModeAuto`
     */
    MiSnapTutorialModeTimeout           = 3,
    /**
     Tutorial that's presented to a user to visually inspect an image
     */
    MiSnapTutorialModeReview            = 4
};

/**
 Parameters used during the document acquisition process
 */
@interface MiSnapParameters : NSObject
/**
 Creates and returns parameters object with default parameter values.
 
 @return An instance of `MiSnapParameters`
 */
- (instancetype _Nonnull)initFor:(MiSnapScienceDocumentType)documentType;
/**
 An object that configures science specific parameters
 */
@property (nonatomic, readwrite) MiSnapScienceParameters * _Nonnull science;
/**
 An object that configures camera specific parameters
 */
@property (nonatomic, readwrite) MiSnapCameraParameters * _Nonnull camera;
/**
 Mode that's used to acquire an image
 */
@property (nonatomic, readwrite) MiSnapMode mode;
/**
 Compression to apply to an acquired image (100 - no compression, 0 - absolute compression)
 
 Range: `50...100`
 */
@property (nonatomic, readwrite) NSInteger compression;
/**
 A delay in milliseconds between the first frame that passed all IQA checks before continuing analysis

 Range: `0...2000`
 */
@property (nonatomic, readwrite) NSInteger frameDelay;
/**
 Application version
 */
@property (nonatomic, readwrite) NSString * _Nullable applicationVersion;
/**
 Server version
 */
@property (nonatomic, readwrite) NSString * _Nullable serverVersion;
/**
 Indicates whether hints need to be presented to a user in Manual mode
 
 Default: `FALSE`
 
 - Note: This is a licensed feature therefore in addition to overriding this parameter to `TRUE`, it needs to be available in a license key for Enhanced Manual functionality to work
 */
@property (nonatomic, readwrite) BOOL enhancedManualEnabled;
/**
 Logs UX parameters into MIBI for analytics
 */
- (void)logUxParameters:(NSDictionary * _Nonnull)uxParametersDictionary;
/**
 @return Dictionary of parameters
 */
- (NSDictionary * _Nonnull)toDictionary;

@end

