/*!
 @header signal.h
 @brief Signal analysis features header file.
 */

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
/*!
 @interface SNRComputer
 @brief Class for calculating input voice signal signal-to-noise ratio (SNR).
 */
@interface SNRComputer : NSObject

/*!
 @brief Creates SNRComputer instance.
 @param initPath path to config file or directory containing init data
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)initPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Computes signal-to-noise ratio (SNR) with given PCM16 audio samples.
 @param PCM16Samples audio samples in PCM16 format
 @param sampleRate   sampling rate of audio samples
 @param error pointer to NSError for error reporting
 @return Computed SNR.
 */
- (NSNumber* _Nullable)compute:(NSData* _Nonnull)PCM16Samples
                    sampleRate:(int)sampleRate
                         error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Computes signal-to-noise ration (SNR) with given WAW file.
 @param wavPath path to WAV file
 @param error pointer to NSError for error reporting
 @return Computed SNR.
 */
- (NSNumber* _Nullable)compute:(NSString* _Nonnull)wavPath error:(NSError* _Nullable* _Nullable)error;

@end