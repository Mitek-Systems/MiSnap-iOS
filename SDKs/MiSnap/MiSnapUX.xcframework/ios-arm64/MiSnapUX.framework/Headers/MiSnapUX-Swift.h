// Generated by Apple Swift version 5.5 (swiftlang-1300.0.31.1 clang-1300.0.29.1)
#ifndef MISNAPUX_SWIFT_H
#define MISNAPUX_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(ns_consumed)
# define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
#else
# define SWIFT_RELEASES_ARGUMENT
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreGraphics;
@import CoreMedia;
@import Foundation;
@import MiSnap;
@import MiSnapCamera;
@import MiSnapLicenseManager;
@import MiSnapScience;
@import ObjectiveC;
@import UIKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="MiSnapUX",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class MiSnapParameters;
@class MiSnapUxParameters;
@class MiSnapGuideViewConfiguration;
@class MiSnapHintViewConfiguration;
@class MiSnapGlareViewConfiguration;
@class MiSnapCancelViewConfiguration;
@class MiSnapHelpViewConfiguration;
@class MiSnapTorchViewConfiguration;
@class MiSnapCameraShutterViewConfiguration;
@class MiSnapRecordingIndicatorViewConfiguration;
@class MiSnapSuccessCheckmarkViewConfiguration;
@class MiSnapLocalizationConfiguration;
@class NSString;

/// A session  configuration
SWIFT_CLASS("_TtC8MiSnapUX19MiSnapConfiguration")
@interface MiSnapConfiguration : NSObject
/// SDK parameters
@property (nonatomic, readonly, strong) MiSnapParameters * _Nonnull parameters;
/// UX parameters
@property (nonatomic, readonly, strong) MiSnapUxParameters * _Nonnull uxParameters;
/// Guide view configuration
@property (nonatomic, readonly, strong) MiSnapGuideViewConfiguration * _Nonnull guide;
/// Hint view configuration
@property (nonatomic, readonly, strong) MiSnapHintViewConfiguration * _Nonnull hint;
/// Glare view configuration
@property (nonatomic, readonly, strong) MiSnapGlareViewConfiguration * _Nonnull glare;
/// Cancel button configuration
@property (nonatomic, readonly, strong) MiSnapCancelViewConfiguration * _Nonnull cancel;
/// Help button configuration
@property (nonatomic, readonly, strong) MiSnapHelpViewConfiguration * _Nonnull help;
/// Torch button configuration
@property (nonatomic, readonly, strong) MiSnapTorchViewConfiguration * _Nonnull torch;
/// Camera shutter button configuration
@property (nonatomic, readonly, strong) MiSnapCameraShutterViewConfiguration * _Nonnull cameraShutter;
/// Recording indicator view configuration
@property (nonatomic, readonly, strong) MiSnapRecordingIndicatorViewConfiguration * _Nonnull recordingIndicator;
/// Success checkmark view configuration
@property (nonatomic, readonly, strong) MiSnapSuccessCheckmarkViewConfiguration * _Nonnull successCheckmark;
/// Creates and returns configuration object with default UX configuration.
/// <ul>
///   <li>
///     Return: An instance of <code>MiSnapConfiguration</code>
///   </li>
/// </ul>
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
/// Creates and returns configuration object with default SDK parameters for a given document type.
/// <ul>
///   <li>
///     Return: An instance of <code>MiSnapConfiguration</code>
///   </li>
/// </ul>
- (nonnull instancetype)initFor:(MiSnapScienceDocumentType)documentType OBJC_DESIGNATED_INITIALIZER;
/// Convenience function for SDK parameters customization
- (MiSnapConfiguration * _Nonnull)withCustomParametersWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapParameters * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for UX parameters customization
- (MiSnapConfiguration * _Nonnull)withCustomUxParametersWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapUxParameters * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Guide view customization
- (MiSnapConfiguration * _Nonnull)withCustomGuideWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapGuideViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Hint view customization
- (MiSnapConfiguration * _Nonnull)withCustomHintWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapHintViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Glare view customization
- (MiSnapConfiguration * _Nonnull)withCustomGlareWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapGlareViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Cancel button customization
- (MiSnapConfiguration * _Nonnull)withCustomCancelWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapCancelViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Help button customization
- (MiSnapConfiguration * _Nonnull)withCustomHelpWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapHelpViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Torch button customization
- (MiSnapConfiguration * _Nonnull)withCustomTorchWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapTorchViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Camera shutter button customization
- (MiSnapConfiguration * _Nonnull)withCustomCameraShutterWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapCameraShutterViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Recording indicator view customization
- (MiSnapConfiguration * _Nonnull)withCustomRecordingIndicatorWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapRecordingIndicatorViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Success checkmark view customization
- (MiSnapConfiguration * _Nonnull)withCustomSuccessCheckmarkWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapSuccessCheckmarkViewConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for Localization customization
- (MiSnapConfiguration * _Nonnull)withCustomLocalizationWithCompletion:(SWIFT_NOESCAPE void (^ _Nonnull)(MiSnapLocalizationConfiguration * _Nonnull))completion SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for applying UX customization
- (MiSnapConfiguration * _Nonnull)applying:(MiSnapConfiguration * _Nonnull)template_ SWIFT_WARN_UNUSED_RESULT;
/// Convenience function for initializing a configuration with given SDK and UX parameters
- (nonnull instancetype)initWith:(MiSnapParameters * _Nonnull)parameters uxParameters:(MiSnapUxParameters * _Nullable)uxParameters OBJC_DESIGNATED_INITIALIZER;
/// Description of <code>MiSnapConfiguration</code>
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
@end

@class NSBundle;

/// Localization configuration
SWIFT_CLASS("_TtC8MiSnapUX31MiSnapLocalizationConfiguration")
@interface MiSnapLocalizationConfiguration : NSObject
/// Bundle where localizable files are located
@property (nonatomic, strong) NSBundle * _Nonnull bundle;
/// Localizable file name
@property (nonatomic, copy) NSString * _Nonnull stringsName;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
/// Description of <code>MiSnapLocalizationConfiguration</code>
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
@end

/// Review mode
typedef SWIFT_ENUM(NSInteger, MiSnapReviewMode, open) {
/// Present review screen when an image is acquired in <code>Manual</code> mode only
  MiSnapReviewModeManualOnly = 0,
/// Present review screen when an image is acquired in either <code>Auto</code> or <code>Manual</code> mode
  MiSnapReviewModeAutoAndManual = 1,
};

enum MiSnapUxTutorialMode : NSInteger;

/// Defines an interface for delegates of <code>MiSnapTutorialViewController</code> to receive callbacks
SWIFT_PROTOCOL("_TtP8MiSnapUX36MiSnapTutorialViewControllerDelegate_")
@protocol MiSnapTutorialViewControllerDelegate
/// A continue button for a specified <code>tutoriaMode</code> is pressed
- (void)tutorialContinueButtonActionFor:(enum MiSnapUxTutorialMode)tutorialMode;
@optional
/// A retry button is pressed
- (void)tutorialRetryButtonAction;
@required
/// A cancel button is pressed
- (void)tutorialCancelButtonAction;
@end

@class NSNumber;

/// UX parameters used during the document acquisition process
SWIFT_CLASS("_TtC8MiSnapUX18MiSnapUxParameters")
@interface MiSnapUxParameters : NSObject
/// Timeout (sec)
/// Range: 1…90
/// Default: 20
@property (nonatomic) NSTimeInterval timeout;
/// Indicates whether an introductory instruction screen should be presented
@property (nonatomic) BOOL showIntroductoryInstructionScreen;
/// Indicates whether a timeout screen should be presented
@property (nonatomic) BOOL showTimeoutScreen;
/// Indicates whether a help screen should be presented
@property (nonatomic) BOOL showHelpScreen;
/// Indicates whether a review screen should be presented
@property (nonatomic) BOOL showReviewScreen;
/// Review mode
/// <ul>
///   <li>
///     See: <code>MiSnapReviewMode</code>
///   </li>
/// </ul>
@property (nonatomic) enum MiSnapReviewMode reviewMode;
/// Indicates whether a session should seamlessly failover to Manual instead of presenting a Timeour/Failover screen
@property (nonatomic) BOOL seamlessFailover;
/// Indicates whether MiSnapViewController should be automatically dismissed or
/// will be dismissed by a presenting view controller
@property (nonatomic) BOOL autoDismiss;
/// Indicates whether a manual button should be displayed in <code>Auto</code> mode
/// note:
/// It’s recommended NOT to override to <code>true</code> as it might negatively impact acceptance rate on a back end.
@property (nonatomic) BOOL showManualButtonInAuto;
/// Indicates whether corner points should be displayed for debugging purposes
@property (nonatomic) BOOL showCorners;
/// Time between hints (sec)
/// Range: 1…10
/// Default: 3
@property (nonatomic) NSTimeInterval hintUpdatePeriod;
/// Time to delay ending of a session after a successful image acquisition (sec)
/// Range: 1.5…10
/// Default: 1.5
@property (nonatomic) NSTimeInterval terminationDelay;
/// An image image that should be injected for unit/UI testing
/// note:
/// Only applies to iOS Simulator
@property (nonatomic, copy) NSString * _Nullable injectImageName;
/// UX parameters dictionary representation
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> * _Nonnull dictionary;
/// Description of <code>MiSnapUxParameters</code>
@property (nonatomic, readonly, copy) NSString * _Nonnull description;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

/// Tutorial mode
typedef SWIFT_ENUM(NSInteger, MiSnapUxTutorialMode, open) {
/// Tutorial mode is not set
  MiSnapUxTutorialModeNone = 0,
/// Introductory instruction
  MiSnapUxTutorialModeInstruction = 1,
/// Help
  MiSnapUxTutorialModeHelp = 2,
/// Timeout
  MiSnapUxTutorialModeTimeout = 3,
/// Review
  MiSnapUxTutorialModeReview = 4,
};

@class NSCoder;
@protocol MiSnapViewControllerDelegate;
@protocol UIViewControllerTransitionCoordinator;

/// A view controller that controls an invoked session
SWIFT_CLASS("_TtC8MiSnapUX20MiSnapViewController")
@interface MiSnapViewController : UIViewController
/// A configuration a session was initialized with
@property (nonatomic, readonly, strong) MiSnapConfiguration * _Nonnull configuration;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder SWIFT_UNAVAILABLE;
/// Creates and returns view controller with a given configuration and sets a delegate that’ll be receiving callbacks
- (nonnull instancetype)initWith:(MiSnapConfiguration * _Nonnull)configuration delegate:(id <MiSnapViewControllerDelegate> _Nonnull)delegate OBJC_DESIGNATED_INITIALIZER;
/// Called after the view has been loaded.
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)viewDidLoad;
/// Called when the view is about to made visible
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)viewWillAppear:(BOOL)animated;
/// Called when the view’s size is changed by its parent
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator> _Nonnull)coordinator;
/// Called when the view is dismissed, covered or otherwise hidden
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)viewWillDisappear:(BOOL)animated;
/// Indicates whether a status bar should be hidden
/// note:
/// Only exposed due to public status of parent’s property. Do not override it.
@property (nonatomic, readonly) BOOL prefersStatusBarHidden;
/// Indicates whether a view can rotate
/// note:
/// Only exposed due to public status of parent’s property. Do not override it.
@property (nonatomic, readonly) BOOL shouldAutorotate;
/// Returns orientations supported by the view controller
/// note:
/// Only exposed due to public status of parent’s property. Do not override it.
@property (nonatomic, readonly) UIInterfaceOrientationMask supportedInterfaceOrientations;
/// Presents another view controller
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)presentViewController:(UIViewController * _Nonnull)viewControllerToPresent animated:(BOOL)flag completion:(void (^ _Nullable)(void))completion;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil SWIFT_UNAVAILABLE;
@end



@interface MiSnapViewController (SWIFT_EXTENSION(MiSnapUX)) <MiSnapTutorialViewControllerDelegate>
/// Called when a tutorial view controller’s continue button is pressed
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)tutorialContinueButtonActionFor:(enum MiSnapUxTutorialMode)tutorialMode;
/// Called when a tutorial view controller’s retry button is pressed
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)tutorialRetryButtonAction;
/// Called when a tutorial view controller’s cancel button is pressed
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)tutorialCancelButtonAction;
@end

@class NSData;

@interface MiSnapViewController (SWIFT_EXTENSION(MiSnapUX)) <MiSnapCameraDelegate>
/// Called when a camera received a sample buffer
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)didReceiveSampleBuffer:(CMSampleBufferRef _Nonnull)sampleBuffer;
/// Called when a camera received a decoded barcode string
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)didDecodeBarcode:(NSString * _Nonnull)decodedBarcodeString;
/// Called when a camera finished recording a video
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)didFinishRecordingVideo:(NSData * _Nullable)videoData;
/// Called when a camera is configured and ready to be started
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)didFinishConfiguringSession;
@end


@class MiSnapResult;
@class NSException;

@interface MiSnapViewController (SWIFT_EXTENSION(MiSnapUX)) <MiSnapAnalyzerDelegate>
/// Called when an analyzer detects an invalid license
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)miSnapAnalyzerLicenseStatus:(MiSnapLicenseStatus)status;
/// Called when an analyzer detects a frame that passes all Image Quality Analysis checks
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)miSnapAnalyzerSuccess:(MiSnapResult * _Null_unspecified)result;
/// Called when an analyzer finishes Image Quality Analysis of the current frame
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)miSnapAnalyzerFrameResult:(MiSnapResult * _Null_unspecified)result;
/// Called when an analyzer is cancelled
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)miSnapAnalyzerCancelled:(MiSnapResult * _Null_unspecified)result;
/// Called whenever an analyzer catches an exception
/// note:
/// Only exposed due to public status of parent’s function. Do not call it.
- (void)miSnapAnalyzerException:(NSException * _Null_unspecified)exception;
@end


@interface MiSnapViewController (SWIFT_EXTENSION(MiSnapUX))
/// Sets a delegate that’ll be receiving callbacks
- (void)setWithDelegate:(id <MiSnapViewControllerDelegate> _Nullable)delegate;
/// Pauses analysis
- (void)pauseAnalysis;
/// Resumes analysis
- (void)resumeAnalysis;
/// Returns MiSnap version
+ (NSString * _Nonnull)miSnapVersion SWIFT_WARN_UNUSED_RESULT;
/// Returns MiSnapScience version
+ (NSString * _Nonnull)miSnapScienceVersion SWIFT_WARN_UNUSED_RESULT;
/// Checks a camera permission and asynchronously returns a result
- (void)checkCameraPermissionWithHandler:(void (^ _Nonnull)(BOOL))handler;
/// Checks a microphone permission and asynchronously returns a result
- (void)checkMicrophonePermissionWithHandler:(void (^ _Nonnull)(BOOL))handler;
/// Checks if a device has a given space in MB
- (BOOL)hasMinDiskSpace:(NSInteger)minDiskSpace SWIFT_WARN_UNUSED_RESULT;
@end



/// Defines an interface for delegates of <code>MiSnapViewController</code> to receive callbacks
SWIFT_PROTOCOL("_TtP8MiSnapUX28MiSnapViewControllerDelegate_")
@protocol MiSnapViewControllerDelegate
/// Delegates receive this callback only when license status is anything but valid
- (void)miSnapLicenseStatus:(MiSnapLicenseStatus)status;
/// Delegates receive this callback in one of the following cases:
/// <ul>
///   <li>
///     a frame passes Image Quality Analysis (IQA) check in <code>MiSnapModeAuto</code>
///   </li>
///   <li>
///     a user manually triggers image acqusition
///   </li>
/// </ul>
- (void)miSnapSuccess:(MiSnapResult * _Nonnull)result;
/// Delegates receive this callback whenever a user cancels a session
- (void)miSnapCancelled:(MiSnapResult * _Nonnull)result;
/// Delegates receive this callback whenever an exception is occured while perfroming an image analysis
- (void)miSnapException:(NSException * _Nonnull)exception;
@optional
/// Delegates receive this callback whenever a session is started
/// note:
/// It’s optional
- (void)miSnapDidStartSession;
/// Delegates receive this callback when a user presses help button and <code>showHelpScreen</code> is overridden to <code>false</code> in <code>MiSnapUxParameters</code>
/// note:
/// It’s optional
- (void)miSnapHelpAction:(NSArray<NSString *> * _Nonnull)messages;
/// Delegates receive this callback when a session times out and <code>showTimeoutScreen</code> is overridden to <code>false</code> in <code>MiSnapUxParameters</code>
/// note:
/// It’s optional
- (void)miSnapTimeoutAction:(NSArray<NSString *> * _Nonnull)messages;
/// Delegates receive this callback when a camera finishes recording a video when <code>recordVideo</code> is overridden to <code>true</code> in <code>MiSnapCameraParameters</code>
/// note:
/// It’s optional
- (void)miSnapDidFinishRecordingVideo:(NSData * _Nullable)videoData;
/// Delegates receive this callback when a session is completed and ready to be dissmised and <code>autoDismiss</code> is overridden to <code>false</code> in <code>MiSnapUxParameters</code>
/// note:
/// It’s optional
- (void)miSnapShouldBeDismissed;
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
#endif