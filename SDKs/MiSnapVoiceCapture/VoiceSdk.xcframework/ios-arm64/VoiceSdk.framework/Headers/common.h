/*!
 @header common.h
 @brief VoiceSDK common classes header file.
 */

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
/*!
 @interface VoiceSdkBool
 @brief Represents VoiceSDK boolean return type.
 */
@interface VoiceSdkBool : NSObject

@property(assign, nonatomic) bool isTrue;

- (instancetype _Nullable)initWithBool:(bool)isTrue;

@end

__attribute__((visibility("default")))
/*!
 @interface TimeInterval
 @brief Represents a time interval.
 */
@interface TimeInterval : NSObject

/*!
 @brief Interval start in milliseconds.
 */
@property(assign, nonatomic) size_t startTime;

/*!
 @brief Interval start in milliseconds.
 */
@property(assign, nonatomic) size_t endTime;

- (instancetype _Nonnull)initWithStartTime:(size_t)startTime endTime:(size_t)endTime;

@end

__attribute__((visibility("default")))
/*!
 @interface AudioInterval
 @brief Represents an audio interval.
 */
@interface AudioInterval : NSObject

/*!
 @brief Interval start in samples.
 */
@property(assign, nonatomic) long startSample;

/*!
 @brief Interval start in samples.
 */
@property(assign, nonatomic) long endSample;

/*!
 @brief Interval start in milliseconds.
 */
@property(assign, nonatomic) long startTime;

/*!
 @brief Interval start in milliseconds.
 */
@property(assign, nonatomic) long endTime;

/*!
 @brief Sample rate of corresponding audio.
 */
@property(assign, nonatomic) int sampleRate;

- (instancetype _Nonnull)initWithStartSample:(long)startSample
                                   endSample:(long)endSample
                                   startTime:(long)startTime
                                     endTime:(long)endTime
                                  sampleRate:(int)sampleRate;

@end

/*!
 @brief An enumeration for audio source labeling during voice template creation
 */
typedef NS_ENUM(NSInteger, ChannelType) { MIC = 1, TEL = 2, MIXED = 3 };

__attribute__((visibility("default")))
/*!
 @interface VoiceTemplate
 @brief Represents voice template.
 */
@interface VoiceTemplate : NSObject

- (instancetype _Nonnull)init;

/*!
 @brief Initializes voice template with contents of file created with [saveToFile] method..
 @param path path to voice template file
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithPath:(NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Initializes voice template with contents of NSData obtained with [serialize] method.
 @param bytes NSData containing serialized template
 @param error pointer to NSError for error reporting
 */
- (instancetype _Nullable)initWithBytes:(NSData* _Nonnull)bytes error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Serializes voice template into NSData.
 @param error pointer to NSError for error reporting
 @return NSData object containing serialized template.
 */
- (NSData* _Nullable)serialize:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Saves voice template to file.
 @param path path to voice template file
 @param error pointer to NSError for error reporting
 @return True on success, false otherwise.
 */
- (BOOL)saveToFile:(NSString* _Nonnull)path error:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Checks if voice template is valid.
 @return Boolean flag (true if template is valid or false if it is not).
 */
- (VoiceSdkBool* _Nullable)isValid:(NSError* _Nullable* _Nullable)error;

/*!
 @brief Returns ID of the init data, which was used to create the template.
 @param error pointer to NSError for error reporting
 @return A string containing init data ID.
 */
- (NSString* _Nullable)getInitDataId:(NSError* _Nullable* _Nullable)error;

@end
