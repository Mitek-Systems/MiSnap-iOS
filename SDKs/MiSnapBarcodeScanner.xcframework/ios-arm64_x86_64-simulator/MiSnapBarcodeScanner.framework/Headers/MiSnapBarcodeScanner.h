//
//  MiSnapBarcodeScanner.h
//  MiSnapBarcodeScanner
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UiKit/UIKit.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerCamera.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerAnalyzer.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerMibiData.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScannerResult.h>

typedef NS_ENUM(NSInteger, MiSnapBarcodeGuideMode)
{
    MiSnapBarcodeGuideModeDevicePortraitGuidePortrait = 0,
    MiSnapBarcodeGuideModeDevicePortraitGuideLandscape,
    MiSnapBarcodeGuideModeNoGuide
};

/*! @header
 
 The MiSnapBarcodeScanner SDK API is an interface that allows the app developer targeting Mitek
 Mobile Imaging servers to construct mobile device apps.
 
 The API consists of
 
 - constant values that can be used by the app developers
 
 @author Mitek Engineering on 2015-01-22
 @copyright 2012-15 Mitek Systems, Inc. All rights reserved.
 @unsorted
 */



@interface MiSnapBarcodeScanner : NSObject

/*! @abstract the current MiSnapBarcodeScanner SDK version
 @return string representing the current MiSnapBarcodeScanner SDK version
 */
+ (NSString *)miSnapBarcodeScannerVersion;

/*!
 @abstract Used to identify the current set of returned MiBI values
 @return a string the represents the MiBI dataset version
 */
+ (NSString *)mibiVersion;

@end

/*! The key constant to access the value containing the MIBI/UXP data collected during the video
 auto-capture process in MiSnap as passed in the @link MiSnapViewControllerDelegate @/link
 protocol method callbacks
 @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link and
 @link miSnapCancelledWithResults: @/link.
 
 Mitek Best Practices Guide recommend passing this data to the Mitek imaging server to which
 the app is connected (usually via app proxy server) in the case of cancellation to ensure
 that MIBI/UXP data for abandoned sessions is collected.
 */
extern NSString* const kMiSnapBarcodeScannerMIBIData;

/*!	An indicator of whether or not the torch was on or off at the end of the MiSnapBarcodeScanner session
 
 @note Values
 TRUE == Torch was on at end of session<br>
 FALSE  == Torch was off at end of session
 */
extern NSString* const kMiSnapBarcodeScannerTorchState;

/*!	@group MiSnapBarcodeScanner Output Parameters key constants
 @abstract keys for values in NSDictionary passed back as parameter to
 @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link or
 @link miSnapCancelledWithResults: @/link
 */

/*! The key constant to access the value containing the PDF417 data captured by the barcode
 reader library in MiSnapBarcodeScanner as passed in the @link MiSnapBarcodeScannerDelegate @/link protocol
 method callback @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link
 */
extern NSString* const kMiSnapBarcodeScannerPDF417Data;

/*! The key constant to access the value indicating success or cancellation, passed in the @link MiSnapBarcodeScannerDelegate @/link protocol
 method callbacks @link miSnapFinishedReturningEncodedImage:originalImage:andResults: @/link
 and @link miSnapCancelledWithResults: @/link
 
 @note Values
 @link kMiSnapBarcodeScannerResultSuccessPDF417 @/link , @link kMiSnapResultCameraNotSufficient @/link ,
 @link kMiSnapBarcodeScannerResultCancelled @/link , @link kMiSnapResultVideoCaptureFailed @/link .
 */
extern NSString* const kMiSnapBarcodeScannerResultCode;

/*! MiSnapBarcodeScanner PDF417 Capture transaction resulted in successful capture and translation */
extern NSString* const kMiSnapBarcodeScannerResultSuccessPDF417;

/*! MiSnapBarcodeScanner transaction cancelled by user */
extern NSString* const kMiSnapBarcodeScannerResultCancelled;

/*! MiSnapBarcodeScannerTutorial has been shown to a user */
extern NSString* const kMiSnapBarcodeScannerShowTutorial;
