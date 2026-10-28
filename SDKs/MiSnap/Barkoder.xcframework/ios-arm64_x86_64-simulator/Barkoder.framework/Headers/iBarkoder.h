#ifndef iBarkoder_h
#define iBarkoder_h

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#else
#endif



typedef enum {
    GlobalOption_SetMaximumThreads = 0,
    GlobalOption_UseGPU,
    GlobalOption_MulticodeCachingEnabled,
    GlobalOption_MulticodeCachingDuration,
    GlobalOption_LazyInitEnable,
    GlobalOption_RestultLocationPreview,
    GlobalOption_DisableGPUCompletely
} GlobalOption;

typedef enum {
    Fast = 0,
    Normal,
    Slow,
    Rigorous
} DecodingSpeed;

typedef enum {
    Grayscale = 0,
    YUV,
    BGRA
} ColorFormat;

typedef enum {
    Aztec,
    AztecCompact,
    QR,
    QRMicro,
    Code128,
    Code93,
    Code39,
    Codabar,
    Code11,
    Msi,
    UpcA,
    UpcE,
    UpcE1,
    Ean13,
    Ean8,
    PDF417,
    PDF417Micro,
    Datamatrix,
    Code25,
    Interleaved25,
    ITF14,
    IATA25,
    Matrix25,
    Datalogic25,
    COOP25,
    Code32,
    Telepen,
    Dotcode,
    IDDocument,
    Databar14,
    DatabarLimited,
    DatabarExpanded,
    PostalIMB,
    Postnet,
    Planet,
    AustralianPost,
    RoyalMail,
    KIX,
    JapanesePost,
    MaxiCode,
    OCRText
    
} DecoderType;


typedef enum {
    Disabled = 0,
    Automatic,
    GS1,
    AAMVA,
    SADL,
    BCBP
} Formatting;

//==========================================================================
// BKImage
//==========================================================================
@interface Image : NSObject
- (id)initWithPixels:(uint8_t *)pixels width: (int) width height: (int) height  colorFormat: (ColorFormat) colorFormat;

@property (nonatomic, readwrite) uint8_t* pixels;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) ColorFormat colorFormat;

@end

//==========================================================================
// Specific Config
//==========================================================================
@interface SpecificConfig : NSObject
- (id)initWithDecoderType:(DecoderType)decoderType;
- (int)setLengthRangeWithMinimum:(int)minimumLength maximum: (int) maximumLength;
- (DecoderType)decoderType;
- (bool)isLicensed;
- (NSString *) typeName;

typedef enum {
    Checksum_Disabled,
    Checksum_Enabled
} StandardChecksum;


@property (nonatomic, readwrite) bool enabled;
@property (nonatomic, readwrite) int expectedCount;
@property (nonatomic, readonly) int minimumLength;
@property (nonatomic, readonly) int maximumLength;
@end


//==========================================================================
// Code 11 Config
//==========================================================================
@interface Code11Config : SpecificConfig
typedef enum {
    Code11_Checksum_Disabled,
    Code11_Checksum_Single,
    Code11_Checksum_Double
} Code11Checksum;

@property (nonatomic, readwrite) Code11Checksum checksum;

- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Code 25 Config
//==========================================================================
@interface Code25Config : SpecificConfig


@property (nonatomic, readwrite) StandardChecksum checksum;

- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// IATA 25 Config
//==========================================================================
@interface IATA25Config : SpecificConfig
@property (nonatomic, readwrite) StandardChecksum checksum;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Matrix 25 Config
//==========================================================================
@interface Matrix25Config : SpecificConfig
@property (nonatomic, readwrite) StandardChecksum checksum;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Datalogic 25 Config
//==========================================================================
@interface Datalogic25Config : SpecificConfig
@property (nonatomic, readwrite) StandardChecksum checksum;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// COOP 25 Config
//==========================================================================
@interface COOP25Config : SpecificConfig
@property (nonatomic, readwrite) StandardChecksum checksum;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Interleaved 2 of 5 Config
//==========================================================================
@interface Interleaved25Config : SpecificConfig

@property (nonatomic, readwrite) StandardChecksum checksum;

- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// ITF14 Config
//==========================================================================
@interface ITF14Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Code 39 Config
//==========================================================================
@interface Code39Config : SpecificConfig
typedef enum  {
    Code39_Checksum_Disabled,
    Code39_Checksum_Enabled
} Code39Checksum;

@property (nonatomic, readwrite) Code39Checksum checksum;

- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Telepen Config
//==========================================================================
@interface TelepenConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Postal IMB Config
//==========================================================================
@interface PostalIMBConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Postnet Config
//==========================================================================
@interface PostnetConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Planet Config
//==========================================================================
@interface PlanetConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// AustralianPost Config
//==========================================================================
@interface AustralianPostConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Royal Mail Config
//==========================================================================
@interface RoyalMailConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Japanese Post Config
//==========================================================================
@interface JapanesePostConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end


//==========================================================================
// KIX Config
//==========================================================================
@interface KIXConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Dotcode Config
//==========================================================================
@interface DotcodeConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Code32 Config
//==========================================================================
@interface Code32Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Msi Config
//==========================================================================
@interface MsiConfig : SpecificConfig
typedef enum  {
    Msi_Checksum_Disabled,
    Msi_Checksum_Mod10,
    Msi_Checksum_Mod11,
    Msi_Checksum_Mod1010,
    Msi_Checksum_Mod1110,
    Msi_Checksum_Mod11IBM,
    Msi_Checksum_Mod1110IBM
} MsiChecksum;

@property (nonatomic, readwrite) MsiChecksum checksum;

- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Aztec Config
//==========================================================================
@interface AztecConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// MaxiCode Config
//==========================================================================
@interface MaxiCodeConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Datamatrix Config
//==========================================================================
@interface DatamatrixConfig : SpecificConfig
@property (nonatomic, readwrite) int dpmMode;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// AztecCompact Config
//==========================================================================
@interface AztecCompactConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// QR Config
//==========================================================================
@interface QRConfig : SpecificConfig
@property (nonatomic, readwrite) bool multiPartMerge;
@property (nonatomic, readwrite) int dpmMode;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// QRMicro Config
//==========================================================================
@interface QRMicroConfig : SpecificConfig
@property (nonatomic, readwrite) int dpmMode;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Code128 Config
//==========================================================================
@interface Code128Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Code93 Config
//==========================================================================
@interface Code93Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Codabar Config
//==========================================================================
@interface CodabarConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// UpcA Config
//==========================================================================
@interface UpcAConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// UpcE Config
//==========================================================================
@interface UpcEConfig : SpecificConfig
@property (nonatomic, readwrite) bool expandToUPCA;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// UpcE1 Config
//==========================================================================
@interface UpcE1Config : SpecificConfig
@property (nonatomic, readwrite) bool expandToUPCA;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Ean13 Config
//==========================================================================
@interface Ean13Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Ean8 Config
//==========================================================================
@interface Ean8Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// PDF417 Config
//==========================================================================
@interface PDF417Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// PDF417Micro Config
//==========================================================================
@interface PDF417MicroConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Databar 14 Config
//==========================================================================
@interface Databar14Config : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Databar Limited Config
//==========================================================================
@interface DatabarLimitedConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Databar Expanded Config
//==========================================================================
@interface DatabarExpandedConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// ID Document Config
//==========================================================================
@interface IDDocumentConfig : SpecificConfig
@property (nonatomic, readwrite) StandardChecksum masterChecksum;
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// OCR Text Config
//==========================================================================
@interface OCRTextConfig : SpecificConfig
- (id)initWithDecoderType:(DecoderType)decoderType;
@end

//==========================================================================
// Config
//==========================================================================
@class Config;

@interface ConfigResponse : NSObject
typedef enum {
    Result_OK,
    Result_Error,
    Result_Warning,
} Result;

@property (nonatomic, readwrite, retain) Config* config;
@property (nonatomic, readwrite) Result result;
@property (nonatomic, readonly, retain) NSString* message;
@end

//==========================================================================
// LicenseCheckResult
//==========================================================================
@interface LicenseCheckResult : NSObject
typedef enum {
    LC_OK = 0,
    LC_OK_NeedServer,
    LC_Error,
} LicenseCheckCode;

@property (nonatomic, readwrite) LicenseCheckCode code;
@property (nonatomic, readwrite, retain) NSString* message;
@end

//==========================================================================
// Config
//==========================================================================
//@interface Config : NSObject
@interface Config : NSObject <NSCopying>
+(ConfigResponse*)configWithLicenseKey:(NSString*)key licenseCheckHandler:(void (^_Nullable)(LicenseCheckResult * _Nonnull result))callback;

+(int) setGlobalOption: (GlobalOption) option value: (int) value;
+(int) getGlobalOption: (GlobalOption) option;
+(void)setcustomOptionGlobal: (NSString *_Nonnull)option value:(int) value;
+(NSDictionary<NSString*, NSString*>* _Nonnull)getLicenseInfo;

@property (nonatomic, readonly, retain) AztecConfig* _Nonnull aztec;
@property (nonatomic, readonly, retain) AztecCompactConfig* _Nonnull aztecCompact;
@property (nonatomic, readonly, retain) QRConfig* _Nonnull qr;
@property (nonatomic, readonly, retain) QRMicroConfig* _Nonnull qrMicro;
@property (nonatomic, readonly, retain) Code128Config* _Nonnull code128;
@property (nonatomic, readonly, retain) Code93Config* _Nonnull code93;
@property (nonatomic, readonly, retain) Code39Config* _Nonnull code39;
@property (nonatomic, readonly, retain) TelepenConfig* _Nonnull telepen;
@property (nonatomic, readonly, retain) DotcodeConfig* _Nonnull dotcode;
@property (nonatomic, readonly, retain) Code32Config* _Nonnull code32;
@property (nonatomic, readonly, retain) CodabarConfig* _Nonnull codabar;
@property (nonatomic, readonly, retain) Code11Config* _Nonnull code11;
@property (nonatomic, readonly, retain) MsiConfig* _Nonnull msi;
@property (nonatomic, readonly, retain) Code25Config* _Nonnull code25;
@property (nonatomic, readonly, retain) IATA25Config* _Nonnull iata25;
@property (nonatomic, readonly, retain) Matrix25Config* _Nonnull matrix25;
@property (nonatomic, readonly, retain) Datalogic25Config* _Nonnull datalogic25;
@property (nonatomic, readonly, retain) COOP25Config* _Nonnull coop25;
@property (nonatomic, readonly, retain) Interleaved25Config* _Nonnull interleaved25;
@property (nonatomic, readonly, retain) ITF14Config* _Nonnull itf14;
@property (nonatomic, readonly, retain) UpcAConfig* _Nonnull upcA;
@property (nonatomic, readonly, retain) UpcEConfig* _Nonnull upcE;
@property (nonatomic, readonly, retain) UpcE1Config* _Nonnull upcE1;
@property (nonatomic, readonly, retain) Ean13Config* _Nonnull ean13;
@property (nonatomic, readonly, retain) Ean8Config* _Nonnull ean8;
@property (nonatomic, readonly, retain) PDF417Config* _Nonnull PDF417;
@property (nonatomic, readonly, retain) PDF417MicroConfig* _Nonnull PDF417Micro;
@property (nonatomic, readonly, retain) DatamatrixConfig* _Nonnull datamatrix;
@property (nonatomic, readonly, retain) Databar14Config* _Nonnull databar14;
@property (nonatomic, readonly, retain) DatabarLimitedConfig* _Nonnull databarLimited;
@property (nonatomic, readonly, retain) DatabarExpandedConfig* _Nonnull databarExpanded;
@property (nonatomic, readonly, retain) PostalIMBConfig* _Nonnull postalIMB;
@property (nonatomic, readonly, retain) PostnetConfig* _Nonnull postnet;
@property (nonatomic, readonly, retain) PlanetConfig* _Nonnull planet;
@property (nonatomic, readonly, retain) AustralianPostConfig* _Nonnull australianPost;
@property (nonatomic, readonly, retain) RoyalMailConfig* _Nonnull royalMail;
@property (nonatomic, readonly, retain) JapanesePostConfig* _Nonnull japanesePost;
@property (nonatomic, readonly, retain) KIXConfig* _Nonnull kix;
@property (nonatomic, readonly, retain) MaxiCodeConfig* _Nonnull maxiCode;

@property (nonatomic, readonly, retain) IDDocumentConfig* _Nonnull idDocument;
@property (nonatomic, readonly, retain) OCRTextConfig* _Nonnull ocrText;

@property (nonatomic, readwrite) DecodingSpeed decodingSpeed;
@property (nonatomic, readwrite) NSString * _Nonnull encodingCharacterSet;
@property (nonatomic, readwrite) Formatting formatting;
@property (nonatomic, readwrite) int maximumResultsCount;
@property (nonatomic, readwrite) int duplicatesDelayMs;
@property (nonatomic, readwrite, copy) NSString * _Nonnull matchFilter;
@property (nonatomic, readwrite) bool returnOnlyMatchedResults;
@property (nonatomic, readwrite) bool upcEanDeblur;
@property (nonatomic, readwrite) bool enableMisshaped1D;
@property (nonatomic, readwrite) bool enableVINRestrictions;
@property (nonatomic, readwrite) int enableComposite;


-(void)setEnabledDecoders:(NSArray* _Nonnull)decoders;
-(NSArray<NSNumber*>* _Nonnull)getEnabledDecoders; // returns array of NSNumbers, getIntValue and cast to DecoderType
-(NSArray<NSNumber*>* _Nonnull)getAvailableDecoders; // returns array of NSNumbers, getIntValue and cast to DecoderType
-(SpecificConfig* _Nonnull)getConfigForDecoder:(DecoderType)decoderType;
-(void)setRegionOfInterestWithLeft:(float)left top:(float)top width:(float)width height:(float)height;
-(CGRect)regionOfInterest;
-(NSString * _Nonnull )getDeviceId;
-(NSString * _Nonnull )getLicenseErrorMessage;
-(int )getcustomOption: (NSString *_Nonnull)option;
-(void)setcustomOption: (NSString *_Nonnull)option value:(int) value;


@end

//==========================================================================
// BKDecoderResult
//==========================================================================
typedef enum {
    BT_Aztec = 0,
    BT_AztecCompact,
    BT_QR,
    BT_QRMicro,
    BT_Code128,
    BT_Code93,
    BT_Code39,
    BT_Codabar,
    BT_Code11,
    BT_Msi,
    BT_UpcA,
    BT_UpcE,
    BT_UpcE1,
    BT_Ean13,
    BT_Ean8,
    BT_PDF417,
    BT_PDF417Micro,
    BT_Datamatrix,
    BT_Code25,
    BT_Interleaved25,
    BT_ITF14,
    BT_IATA25,
    BT_Matrix25,
    BT_Datalogic25,
    BT_COOP25,
    BT_Code32,
    BT_Telepen,
    BT_Dotcode,
    BT_ID_Document,
    BT_ID_Picture,
    BT_ID_MRZ2,
    BT_ID_MRZ3,
    BT_Databar14,
    BT_DatabarLimited,
    BT_DatabarExpanded,
    BT_PostalIMB,
    BT_Postnet,
    BT_Planet,
    BT_AustralianPost,
    BT_RoyalMail,
    BT_KIX,
    BT_JapanesePost,
    BT_MaxiCode
    
} BarcodeType;


@interface BKLocation : NSObject {
    CGPoint location[4];
}
@property (nonatomic, readwrite, retain) NSString *locationName;

-(CGPoint*) getLocationPoints;

@end;

@interface BKImageDescriptor : NSObject

#if TARGET_OS_OSX
@property (nonatomic, strong) NSImage *image;
#else
@property (nonatomic, strong) UIImage *image;
#endif

@property (nonatomic, strong) NSString *name;

- (instancetype)initWithImage:(

#if TARGET_OS_OSX
NSImage
#else
UIImage
#endif
    *)image name:(NSString *)name;

@end

@interface BKDecoderResult : NSObject {
    CGPoint location[4];
}

@property (nonatomic, readwrite) BarcodeType barcodeType;
@property (nonatomic, readwrite, retain) NSString* barcodeTypeName;
@property (nonatomic, readwrite, retain) NSData* binaryData;
@property (nonatomic, readwrite, retain) NSString* textualData;
@property (nonatomic, readwrite, retain) NSString* characterSet;
@property (nonatomic, readwrite, retain) NSDictionary* extra;
@property (nonatomic, readwrite, retain) NSArray<BKLocation*>* extraLocations;
@property (nonatomic, readwrite, retain) NSArray<BKImageDescriptor*>* images;
@property (nonatomic, readwrite) bool isMatched;

-(int)polygonPointCount;
-(CGPoint)polygonPointAt:(int)index;
-(NSString*)getStringForKey:(NSString*)key;
-(NSArray<NSString*>*)getAllKeys;
-(CGPoint)locationAt:(int)index;
-(CGPoint*) getLocationPoints;
-(BKLocation *)getLocationFromExtras:(NSString *)locationName;
-(NSArray *)getLocationsNamesFromExtras;


@end
@compatibility_alias DecoderResult BKDecoderResult;


//==========================================================================
// iBarkoder
//==========================================================================
@interface iBarkoder : NSObject
+(NSString *) GetLibVersion;
+(bool) IsStringVINCompliant: (NSString *) VINString checkLevel: (int) checkLevel;
+(bool) IsDecoderBusy;

+(NSArray<BKDecoderResult*>*)decodeImage:(Config*)config imageRef:(void*)imageRef imageWidth:(int)width imageHeight:(int) height;
+(NSArray<BKDecoderResult*>*)decodeImage:(Config*)config imageRef:(void*)imageRef imageWidth:(int)width imageHeight:(int) height colorFormat: (ColorFormat) colorFormat;

+(NSArray<BKDecoderResult*>*)decodeImageInMemory:(Config*)config imagePixels:(uint8_t*)pixels imageWidth:(int)width imageHeight:(int) height;
+(NSArray<BKDecoderResult*>*)decodeImageInMemory:(Config*)config imagePixels:(uint8_t*)pixels imageWidth:(int)width imageHeight:(int) height colorFormat: (ColorFormat) colorFormat;

+(int) decodeImageAsync:(Config*)config image: (Image*) image callback:(void (^)(NSArray<BKDecoderResult*>*, Image*)) callback;
+(int) decodeSampleBufferAsync:(Config*)config sampleBuffer:(CMSampleBufferRef)sampleBuffer callback:(void (^)(NSArray<BKDecoderResult*>*, CMSampleBufferRef)) callback;
+ (unsigned char*)CGImageToPixels:(CGImageRef) image;
+ (CGImageRef) CGImageFromPixels:(const char*)pixels width:(int)width height:(int)height;
#if TARGET_OS_IOS
+ (UIImage *) UIImageFromPixels:(uint8_t*)pixels width:(int)width height:(int)height;
#else
#endif
#if TARGET_OS_OSX
+ (NSImage *)UIImageFromLocation:(NSImage *)source points:(CGPoint[4])points marginPercent:(float)marginPercent;
#else
+ (UIImage *)UIImageFromLocation:(UIImage *)source points:(CGPoint[4])points marginPercent:(float)marginPercent;
#endif

#if TARGET_OS_OSX
+ (NSImage *)WarpUIImageFromLocation:(NSImage *)source
#else
+ (UIImage *)WarpUIImageFromLocation:(UIImage *)source
#endif
                              points:(CGPoint[4])points   // TL, TR, BR, BL (top-left origin)
                                size:(CGSize)size           // if any dim is 0 → auto-size
                         aspectRatio:(CGFloat)aspectRatio   // if >0 used for auto/derived dimension(s)
                       rotationShift:(NSInteger)rotationShift
                              margin:(CGFloat)margin
                      forceLandscape:(BOOL)forceLandscape;


@end

#endif /* iBarkoder */

