/*!
 @header speech_summary.h
 @brief Speech summary header file.
 */

#import <Foundation/Foundation.h>

#import <VoiceSdk/common.h>

__attribute__((visibility("default")))
/*!
 @interface SpeechEvent
 @brief Represents a single speech or non-speech event.
 */
@interface SpeechEvent : NSObject

/*!
 @brief Whether the interval contains speech or not.
 */
@property(assign, nonatomic) bool isVoice;

/*!
 @brief Speech event audio interval.
 */
@property(strong, nonatomic, nonnull) AudioInterval* audioInterval;

@end

__attribute__((visibility("default")))
/*!
 @interface SpeechInfo
 @brief Contains speech statistics for processed audio.
 */
@interface SpeechInfo : NSObject

/*!
 @brief Processed audio total length (totalLengthMs = speechLengthMs + backgroundLengthMs) in milliseconds.
 */
@property(assign, nonatomic) float totalLengthMs;

/*!
 @brief Speech signal length in milliseconds.
 */
@property(assign, nonatomic) float speechLengthMs;

/*!
 @brief Non-speech signal length in milliseconds.
 */
@property(assign, nonatomic) float backgroundLengthMs;

@end

__attribute__((visibility("default")))
/*!
 @interface SpeechSummary
 @brief Speech summary class.
 */
@interface SpeechSummary : NSObject

/*!
 @brief Speech statistics for processed audio.
 */
@property(strong, nonatomic, nonnull) SpeechInfo* speechInfo;

/*!
 @brief Speech events for processed audio.
 */
@property(strong, nonatomic, nonnull) NSArray* speechEvents;

@end

__attribute__((visibility("default")))
/*!
 @interface SpeechSummaryStream
 @brief Stateful speech summary stream class, intended to calculate SpeechSummary with
audio samples given in stream. New instance can be obtained with a SpeechSummaryEngine instance.
 @see SpeechSummaryEngine
 */
@interface SpeechSummaryStream : NSObject

/*!
 @brief Adds PCM16 audio samples to process.
 @param PCM16Samples audio samples in PCM16 format
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 */
- (BOOL)addSamples:(NSData* _Nonnull)PCM16Samples error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Retrieves current speech summary state.
 @param error pointer to NSError for error reporting
 @return Speech summary.
 */
- (SpeechSummary* _Nullable)getTotalSpeechSummary:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Retrieves current speech summary state.
 @param error pointer to NSError for error reporting
 @return Speech summary.
 */
- (SpeechInfo* _Nullable)getTotalSpeechInfo:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Retrieves current background length.
 @param error pointer to NSError for error reporting
 @return Silence passed since last speech frame in seconds.
 */
- (NSNumber* _Nullable)getCurrentBackgroundLength:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Retrieves a single speech event from the output queue.
 @param error pointer to NSError for error reporting
 @return One speech event.
 */
- (SpeechEvent* _Nullable)getSpeechEvent:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks if there are speech events in output queue.
 @param error pointer to NSError for error reporting
 @return Boolean flag (true is there are events available, else otherwise).
 */
- (VoiceSdkBool* _Nullable)hasSpeechEvents:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Resets speech summary stream state.
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 */
- (BOOL)reset:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Finalizes input audio stream to process remaining audio
 samples and produce result if it's possible.
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 */
- (BOOL)finalizeStream:(NSError* _Nullable* _Nullable)error;

@end

__attribute__((visibility("default")))
/*!
 @interface SpeechSummaryEngine
 @brief Speech summary engine class, intended to calculate SpeechSummary with given audio samples.
 */
@interface SpeechSummaryEngine : NSObject

/*!
 @brief Creates SpeechSummaryEngine instance.
 @param initPath path to config file or directory containing init data
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)initPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Calculates speech summary with given PCM16 audio samples.
 @param PCM16Samples audio samples in PCM16 format
 @param sampleRate   sampling rate of audio samples
 @param error pointer to NSError for error reporting
 @return Speech summary.
 */
- (SpeechSummary* _Nullable)getSpeechSummary:(NSData* _Nonnull)PCM16Samples
                                  sampleRate:(int)sampleRate
                                       error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Calculates speech summary with given WAW file.
 @param wavPath path to WAV file
 @param error pointer to NSError for error reporting
 @return Speech summary.
 */
- (SpeechSummary* _Nullable)getSpeechSummary:(NSString* _Nonnull)wavPath error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Factory method for creating SpeechSummaryStream.
 @param sampleRate sampling rate of input audio signal in (Hz)
 @param error pointer to NSError for error reporting
 @return Speech summary stream.
 */
- (SpeechSummaryStream* _Nullable)createStream:(int)sampleRate error:(NSError* _Nullable* _Nullable)error;

@end
