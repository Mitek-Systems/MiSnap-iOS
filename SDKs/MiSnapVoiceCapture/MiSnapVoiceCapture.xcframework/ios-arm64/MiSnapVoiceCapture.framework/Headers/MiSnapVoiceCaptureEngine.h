//
//  MiSnapVoiceCaptureWrapper.h
//  MiSnapVoiceCapture
//
//  Created by Stas Tsuprenko on 7/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MiSnapVoiceCaptureEngine : NSObject

@property (nonatomic, readonly) float speechStart;

@property (nonatomic, readonly) float speechLength;

@property (nonatomic, readonly) float silenceLength;

@property (nonatomic, readonly) NSError * _Nullable error;

- (instancetype)init;

- (void)createStream:(int)sampleRate;

- (void)processSample:(NSData * _Nonnull)pcm16Sample;

- (float)getSpeechLength:(NSString *)wavPath;

- (float)computeSNR:(NSString * _Nonnull)wavPath;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
