/*!
 @header media.h
 @brief Media utils (speech analysis) header file.
 */

#import <Foundation/Foundation.h>

#import <VoiceSdk/common.h>

__attribute__((visibility("default")))
/*!
 @interface SpeechEndpointDetector
 @brief Speech endpoint detector class (interface), intended to detect speech end in the audio stream.
 */
@interface SpeechEndpointDetector : NSObject

/*!
 @brief Creates SpeechEndpointDetector instance.
 @param sampleRate input audio sample rate
 @param minSpeechLengthMs minimum length of input signal before speech endpoint detected in milliseconds
 @param maxSilenceLengthMs maximum length of input signal before speech endpoint detected in milliseconds
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithMinSpeechLengthMs:(unsigned int)minSpeechLengthMs
                                 maxSilenceLengthMs:(unsigned int)maxSilenceLengthMs
                                         sampleRate:(unsigned int)sampleRate
                                              error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Resets detector state.
 */
- (BOOL)reset:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Adds new audio samples to the SpeechEndpointDetector.
 @param PCM16Samples PCM16 audio samples
 @param error pointer to NSError for error reporting
 */
- (BOOL)addSamples:(NSData* _Nonnull)PCM16Samples error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Returns detection state.
 @param error pointer to NSError for error reporting
 @return true if speech end was detected, false otherwise.
 */
- (VoiceSdkBool* _Nullable)isSpeechEnded:(NSError* _Nullable* _Nullable)error;

@end
