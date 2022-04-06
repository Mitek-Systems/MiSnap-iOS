//
//  MiSnapLicenseManager.h
//  MiSnapLicenseManager
//
//  Created by Stas Tsuprenko on 9/11/20.
//

#import <Foundation/Foundation.h>

/**
 Licensed feature
 */
typedef NS_ENUM(NSInteger, MiSnapLicenseFeature) {
    /**
     Feature is not set
     */
    MiSnapLicenseFeatureNone                = 0,
    /**
     Generic
     
     Allows invoking Generic document type
     */
    MiSnapLicenseFeatureGeneric             = 1,
    /**
     Deposit
     
     Allows invoking Check Front and Check Back document types
     */
    MiSnapLicenseFeatureDeposit             = 2,
    /**
     Barcode
     
     Allows scanning barcodes
     */
    MiSnapLicenseFeatureBarcode             = 3,
    /**
     ID
     
     Allows invoking ID Front and Back, Passport document types
     */
    MiSnapLicenseFeatureId                  = 4,
    /**
     On-Device Classification
     
     When enabled:
     * In combination with `MiSnapLicenseFeatureId` allows invoking Any ID to acquire an image of any supported identity document
     * Prevents capturing 2 sides of the same identity document and some unsupported documents
     */
    MiSnapLicenseFeatureODC                 = 5,
    /**
     On-Device Extraction
     
     When enabled, returns parsed information from supported identity documents
     */
    MiSnapLicenseFeatureODE                 = 6,
    /**
     Near Field Communication
     
     Allows invoking MiSnapNFC SDK
     */
    MiSnapLicenseFeatureNFC                 = 7,
    /**
     Face
     
     Allows invoking MiSnapFacialCapture SDK
     */
    MiSnapLicenseFeatureFace                = 8,
    /**
     Voice
     
     - Note: Not implemented yet. Exposed for future use.
     */
    MiSnapLicenseFeatureVoice               = 9
};

/**
 License status
 */
typedef NS_ENUM(NSInteger, MiSnapLicenseStatus) {
    /**
     License status is not set
     */
    MiSnapLicenseStatusNone                     = 0,
    /**
     License is valid
     */
    MiSnapLicenseStatusValid                    = 1,
    /**
     License is tempered with
     */
    MiSnapLicenseStatusNotValid                 = 2,
    /**
     License is valid but expired
     */
    MiSnapLicenseStatusExpired                  = 3,
    /**
     License is valid but an application bundle identifier is not supported
     */
    MiSnapLicenseStatusNotValidAppId            = 4,
    /**
     License is valid but iOS platform is not licensed
     */
    MiSnapLicenseStatusPlatformNotSupported     = 5,
    /**
     License is valid but a given feature is not supported
     */
    MiSnapLicenseStatusFeatureNotSupported      = 6
};

/**
 Verifies validity of a license key
 */
@interface MiSnapLicenseManager : NSObject
/**
 Singleton instance
 
 @return The `MiSnapLicenseManager` instance.
 */
+ (instancetype _Nonnull)shared;
/**
 Destroys the singleton
 */
+ (void)destroySharedInstance;
/**
 License status.
 
 @see `MiSnapLicenseStatus`
 */
@property (nonatomic, readonly) MiSnapLicenseStatus status;
/**
 Sets a license key
 */
- (void)setLicenseKey:(NSString * _Nullable)licenseKey;
/**
 Returns whether a given feature is supported by a license key
 */
- (BOOL)featureSupported:(MiSnapLicenseFeature)feature;
/**
 Convenience method that returns a license status in `NSString` representation
 */
+ (NSString * _Nonnull)stringFromStatus:(MiSnapLicenseStatus)status;
/**
 Version
 */
+ (NSString * _Nonnull)version;

@end


