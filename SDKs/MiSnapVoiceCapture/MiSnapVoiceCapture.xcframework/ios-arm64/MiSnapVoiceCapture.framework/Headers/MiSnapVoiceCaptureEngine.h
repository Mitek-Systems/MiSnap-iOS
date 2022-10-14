//
//  MiSnapVoiceCaptureWrapper.h
//  MiSnapVoiceCapture
//
//  Created by Stas Tsuprenko on 7/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 Low level API for speech analysis.
 
 Do not use it without consulting with Mitek representative.
 
 Use `MiSnapVoiceCaptureRecorder` instead
 */
@interface MiSnapVoiceCaptureEngine : NSObject
/**
 Speech start (ms) in a live stream
 */
@property (nonatomic, readonly) float speechStart;
/**
 Speech length (ms) in a live stream
 */
@property (nonatomic, readonly) float speechLength;
/**
 Silence length (ms) in a live stream
 */
@property (nonatomic, readonly) float silenceLength;
/**
 SDK error
 */
@property (nonatomic, readonly) NSError * _Nullable error;
/**
 Initializer
 */
- (instancetype)init;
/**
 Creates a stream for real-time processing
 */
- (void)createStream:(int)sampleRate;
/**
 Processes real-time PCM16 samples
 */
- (void)processSample:(NSData * _Nonnull)pcm16Sample;
/**
 Speech length from .wav file at `wavPath`
 */
- (float)getSpeechLength:(NSString *)wavPath;
/**
 Computes SNR (Signal-to-Noise Ratio) from .wav file at `wavPath`
 */
- (float)computeSNR:(NSString * _Nonnull)wavPath;
/**
 Resets real-time processing results
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
