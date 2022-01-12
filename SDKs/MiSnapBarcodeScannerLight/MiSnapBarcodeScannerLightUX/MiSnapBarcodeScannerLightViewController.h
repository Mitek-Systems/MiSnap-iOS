//
//  MiSnapBarcodeScannerLightViewController.h
//  MiSnapBarcodeScannerLightUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UiKit/UIKit.h>
#import <MiSnapBarcodeScannerLight/MiSnapBarcodeScannerLight.h>
#import "MiSnapBarcodeScannerLightOverlayView.h"
#import "MiSnapBarcodeScannerLightTutorialViewController.h"

@class MiSnapBarcodeScannerLightViewController;

/*! @header
 
 The MiSnapBarcodeScannerLight SDK API is an interface that allows the app developer targeting Mitek
 Mobile Imaging servers to construct mobile device apps.
 
 The API consists of
 
 - a method for invoking the MiSnapBarcodeScannerLight, which starts the capture session
 and captures a PDF417 barcode
 
 - constant values that can be used by the app developers
 
 - callback protocols to which the app must conform in order to retrieve MiSnapBarcodeScannerLight results
 
 @author Mitek Engineering on 2015-01-22
 @copyright 2012-15 Mitek Systems, Inc. All rights reserved.
 @unsorted
 */

/*!
 
 Apps making use of the MiSnapBarcodeScannerLight SDK must conform to this protocol in order to be called by
 MiSnapBarcodeScannerLight for successuful capture with barcode(PDF417) data or canceled session, both with results.
 
 */
@protocol MiSnapBarcodeScannerLightDelegate <NSObject>

@optional
/*! @abstract This delegate callback method is called upon successful PDF417 barcode scanning.

@param encodedImage for resultCode @link kMiSnapBarcodeScannerLightResultSuccessPDF417 @/link, this value will be nil.
@param originalImage for resultCode @link kMiSnapBarcodeScannerLightResultSuccessPDF417 @/link, this value
will be nil.
@param results dictionary containing the result code.
For resultCode @link kMiSnapBarcodeScannerLightResultSuccessPDF417 @/link, this dictionary
will also contain the decoded PDF417 data (via key
                                           @link kMiSnapBarcodeScannerLightPDF417Data @/link).
*/
- (void)miSnapFinishedReturningEncodedImage:(NSString *)encodedImage
                              originalImage:(UIImage *)originalImage
                                 andResults:(NSDictionary *)results;

/*! @abstract This delegate callback method is called upon successful PDF417 barcode scanning.
 
 @param encodedImage for resultCode @link kMiSnapBarcodeScannerLightResultSuccessPDF417 @/link, this value will be nil.
 @param originalImage for resultCode @link kMiSnapBarcodeScannerLightResultSuccessPDF417 @/link, this value
 will be nil.
 @param results dictionary containing the result code.
 For resultCode @link kMiSnapBarcodeScannerLightResultSuccessPDF417 @/link, this dictionary
 will also contain the decoded PDF417 data (via key
 @link kMiSnapBarcodeScannerLightPDF417Data @/link).
  @param docType a document type used for capturing a document
 */
- (void)miSnapFinishedReturningEncodedImage:(NSString *)encodedImage
                              originalImage:(UIImage *)originalImage
                                 andResults:(NSDictionary *)results
                            forDocumentType:(NSString *)docType;

/*!
 
 @abstract invoked if the user cancels a capture MiSnapBarcodeScannerLight transaction or other conditions occur
 that cause a MiSnapBarcodeScannerLight transaction to end without capturing an image.
 
 The result code will be @link kMiSnapBarcodeScannerLightResultCancelled @/link if the user touched the X Cancel
 button during capture.
 
 The results will also contain a value for the key @link kMiSnapBarcodeScannerLightMIBIData @/link if such data
 was captured prior to cancellation or other termination conditions.
 
 @param results dictionary containing the result code (via key @link kMiSnapResultCode @/link)
 and other information about the termination of the MiSnap transaction.
 
 */
- (void)miSnapCancelledWithResults:(NSDictionary *)results;

/*!
 
 @abstract invoked if the user cancels a capture MiSnapBarcodeScannerLight transaction or other conditions occur
 that cause a MiSnapBarcodeScannerLight transaction to end without capturing an image.
 
 The result code will be @link kMiSnapBarcodeScannerLightResultCancelled @/link if the user touched the X Cancel
 button during capture.
 
 The results will also contain a value for the key @link kMiSnapBarcodeScannerLightMIBIData @/link if such data
 was captured prior to cancellation or other termination conditions.
 
 @param results dictionary containing the result code (via key @link kMiSnapResultCode @/link)
 and other information about the termination of the MiSnap transaction.
 
  @param docType a document type used for capturing a document
 */
- (void)miSnapCancelledWithResults:(NSDictionary *)results forDocumentType:(NSString *)docType;

/*!
 
 @abstract invoked whenever MiSnapBarcodeScannerLight starts a capture session. Also invoked when the session is restarted after timeout or failover.
 
 @discussion The start of a session may be important to client apps to modify or customize the session.  Using this
 method allows the client to show some additional information to the user, or invoke a delay of the image analysis,
 or any other desired action.
 
 This is invoked for kMiSnapDocumentTypePDF417 and all capture modes.
 
 @param controller that started MiSnapBarcodeScannerLight.
 
 */
- (void)miSnapBarcodeDidStartSession:(MiSnapBarcodeScannerLightViewController *)controller;

@end

@interface MiSnapBarcodeScannerLightViewController : UIViewController

/*! @abstract a pointer back to the method implementing the callback methods MiSnapBarcodeScannerLight will invoke
 upon transaction termination
 */
@property (nonatomic) id <MiSnapBarcodeScannerLightDelegate> delegate;

/*! indicates how much to compress the image. Typically, images are compressed to reduce
 bandwidth overhead and time when transferring the image to servers.
 
The recommended default value is 0.6 or 40% compression.
@note Values
range: 0.0-1.0<br>
0.0 == "minimum quality"/"maximum compression"<br>
1.0 == "maximum quality"/"no compression"<br>
default = 0.6
*/
@property (nonatomic) float encodedImageQuality;

/*!
 @property guideMode
 @abstract
    Indicates the guide mode in use by the BarcodeScannerLight
 @discussion
    For a list of supported guide modes see <MiSnapBarcodeScannerLight/MiSnapBarcodeScannerLight.h>
 */
@property (nonatomic) MiSnapBarcodeLightGuideMode guideMode;

/*! @abstract Sets Guide rectangle line width, color, alpha and Vignette alpha
 defaults:
 line width = 3.0 px
 line color = red
 line alpha = 0.7
 vignette alpha = 0.7
 */
- (void)setLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor lineAlpha:(CGFloat)lineAlpha vignetteAlpha:(CGFloat)vignetteAlpha;

/*! @abstract Sets Guide landscape and portrait fill, aspect ratio, corner radius
 defaults:
 landscape fill = 0.7 (applied to a guide width in device Landscape orientation and a guide height in MiSnapBarcodeLightGuideModeDevicePortraitGuidePortrait guide mode)
 portrait fill = 0.875 (applied to a guide width in MiSnapBarcodeLightGuideModeDevicePortraitGuideLandscape guide mode)
 aspect ratio = 1.59 (aspect ratio of ID-1 format)
 corner radius = 15 px
 */
- (void)setGuideLandscapeFill:(CGFloat)landscapeFill portraitFill:(CGFloat)portraitFill aspectRatio:(CGFloat)guideAspectRatio cornerRadius:(CGFloat)cornerRadius;

/*! @abstract pause analysis of images. The camera will continue to run but images are not analyzed or captured.
 */- (void)pauseAnalysis;

/*! @abstract resume analysis of images. A successful image can be captured.
 */
- (void)resumeAnalysis;

/*!
 @abstract Convenience method to instantiate MiSnapBarcodeScannerLightViewController from a storyboard
 */
+ (MiSnapBarcodeScannerLightViewController *)instantiateFromStoryboard;

@end
