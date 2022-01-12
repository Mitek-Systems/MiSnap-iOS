//
//  MiSnapLicenseManager.h
//  MiSnapLicenseManager
//
//  Created by Stas Tsuprenko on 9/11/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MiSnapLicenseFeature) {
    MiSnapLicenseFeatureNone                = 0,
    MiSnapLicenseFeatureDepositCapture      = 1,
    MiSnapLicenseFeatureBarcode             = 2,
    MiSnapLicenseFeatureIdCapture           = 3,
    MiSnapLicenseFeatureODC                 = 4,
    MiSnapLicenseFeatureODE                 = 5,
    MiSnapLicenseFeatureODA                 = 6,
    MiSnapLicenseFeatureNFC                 = 7,
    MiSnapLicenseFeatureFaceCapture         = 8,
    MiSnapLicenseFeatureVoiceCapture        = 9
};

typedef NS_ENUM(NSInteger, MiSnapLicenseStatus) {
    MiSnapLicenseStatusNone                     = 0,
    MiSnapLicenseStatusValid                    = 1,
    MiSnapLicenseStatusNotValid                 = 2,
    MiSnapLicenseStatusExpired                  = 3,
    MiSnapLicenseStatusNotValidAppId            = 4,
    MiSnapLicenseStatusPlatformNotSupported     = 5,
    MiSnapLicenseStatusFeatureNotSupported      = 6
};

@interface MiSnapLicenseManager : NSObject

+ (instancetype _Nonnull)shared;

+ (void)destroySharedInstance;

@property (nonatomic, readonly) MiSnapLicenseStatus status;

- (void)setLicenseKey:(NSString * _Nullable)licenseKey;

- (BOOL)featureSupported:(MiSnapLicenseFeature)feature;

+ (NSString * _Nonnull)stringFromStatus:(MiSnapLicenseStatus)status;

+ (NSString * _Nonnull)version;

@end


