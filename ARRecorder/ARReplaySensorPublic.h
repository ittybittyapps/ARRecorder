//
//  ARKit
//  Copyright © 2016-2017 Apple Inc. All rights reserved.
//

#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Value: `com_apple_arkit_replay_filepath_advanceFramesPerSecondMultiplier`
extern NSString * const ARReplaySensorFilePathAdvanceFramesPerSecondMultiplierUserDefaultsKey;
/// Value: `com.apple.arkit.replaySensor.synchronousMode`
extern NSString * const ARReplaySensorSynchronousModeUserDefaultsKey;
/// Value: `com_apple_arkit_replay_filepath_advanceToFrame`
extern NSString * const ARReplaySensorFilePathAdvanceToFrameUserDefaultsKey;

@protocol ARReplaySensorDelegate <NSObject>
@optional

/**
 Notifies the replay sensor delegate that it finishes loading its metadata and will start the replay shortly.
 @param framesCount Number of frames contained in the replay.
 @note This method is called on an arbitrary thread.
 */
- (void)replaySensorDidFinishLoadingFrames:(NSUInteger)framesCount;
/**
 Notifies the replay sensor delegate that the replay has been completed.
 @note This method is called on an arbitrary thread.
 */
- (void)replaySensorDidFinishReplayingData;

@end

/**
 Reads a "replay" of previously captured sensor data and intermediate processing results from a file on disk, and poses as a sensor that produces this data in a session.
 @note This is a partial interface of this class: more functionality is available internally.
 */
@interface ARReplaySensor : NSObject

/**
 Returns whether the sensor was initialized in manual replay mode.
 */
@property (nonatomic, assign, readonly, getter=isReplayingManually) BOOL replayingManually API_AVAILABLE(ios(11.3));
/**
 Returns whether the sensor was initialized in synchronous (deterministic) replay mode.
 */
@property (nonatomic, assign, readonly, getter=isSynchronousMode) BOOL synchronousMode API_AVAILABLE(ios(12.0));

/**
 Defines the speed at which manual sensor replay advances to the current target frame (after a call to `advanceToFrameIndex:`) as a multiplier of normal speed. If set to 1 or a non-positive value, replay advances at normal speed. Default value is taken from `ARReplaySensorFilePathAdvanceFramesPerSecondMultiplierUserDefaultsKey` if it's specified. Has no effect if the sensor is not configured for manual replay.
 */
@property (nonatomic, assign) float advanceFramesPerSecondMultiplier API_AVAILABLE(ios(11.3));

/**
 Returns whether the sensor currently simulates an interruption in data stream.
 */
@property (nonatomic, assign, readonly) BOOL interrupted API_AVAILABLE(ios(11.3));

/**
 Delegate object notified of the changes in replay state.
 */
@property (nonatomic, weak) id<ARReplaySensorDelegate> replaySensorDelegate;

/**
 Initializes a replay sensor with recorded data at the specified location.
 @param filePath Path to the recorded replay data file.
 @discussion On iOS 11.3+ this initializer delegates to `initWithSequenceURL:manualReplay:` passing NO for `manualReplay` parameter.
 */
- (instancetype)initWithDataFromFile:(NSString *)filePath;

/**
 Initializes a replay sensor with recorded data at the specified location.
 @param sequenceURL URL of the recorded replay data file.
 @param manualReplay If YES, enables a "manual" mode where replay needs to be advanced by calling `advanceFrame` and/or `advanceToFrameIndex:` methods instead of it automatically playing to the end.
 @discussion On iOS 12.0+ this initializer delegates to `initWithSequenceURL:manualReplay:synchronousMode:` passing a default value for `synchronousMode` taken from `ARReplaySensorSynchronousModeUserDefaultsKey` if it's set, and NO otherwise.
 */
- (instancetype)initWithSequenceURL:(NSURL *)sequenceURL manualReplay:(BOOL)manualReplay API_AVAILABLE(ios(11.3));

/**
 Initializes a replay sensor with recorded data at the specified location.
 @param sequenceURL URL of the recorded replay data file.
 @param manualReplay If YES, enables a "manual" mode where replay needs to be advanced by calling `advanceFrame` and/or `advanceToFrameIndex:` methods instead of it automatically playing to the end.
 @param synchronousMode If YES, forces the session into a "deterministic" mode which (presumably) gathers session technique results at specific time intervals, which makes session behavior and output more predictable and repeatable.
 */
- (instancetype)initWithSequenceURL:(NSURL *)sequenceURL manualReplay:(BOOL)manualReplay synchronousMode:(BOOL)synchronousMode API_AVAILABLE(ios(12.0));

/**
 Advances the replay to the next frame.
 @discussion Has no effect if the sensor is not configured for manual replay.
 */
- (void)advanceFrame API_AVAILABLE(ios(11.3));
/**
 Automatically advances the replay to the frame with the specified index, then pauses.
 @discussion This method can be called immediately after the receiver is initialized. If `ARReplaySensorFilePathAdvanceToFrameUserDefaultsKey` is set, this is done automatically with the value of that user default. The speed at which the replay is advanced is controlled by `advanceFramesPerSecondMultiplier` property; by default, the replay is advanced at the speed it was recorded with. Has no effect if the sensor is not configured for manual replay.
 */
- (void)advanceToFrameIndex:(NSInteger)frameIndex API_AVAILABLE(ios(11.3));

/**
 Simulates an interruption in sensor data stream. Called automatically when application enters background.
 */
- (void)interrupt API_AVAILABLE(ios(11.3));
/**
 Resumes the sensor data stream after simulating its interruption. Called automatically when application enters foreground.
 */
- (void)endInterruption API_AVAILABLE(ios(11.3));

/**
 Finishes replaying the sensor data.
 */
- (void)endReplay API_AVAILABLE(ios(11.3));

@end

#pragma mark - Replay Configuration

@interface ARConfiguration ()

/**
 Returns an `ARConfiguration` object that can be used to run an `ARSession` that will "replay" previously recorded sensor data (including the video feed) instead of using real hardware.

 @param templateConfiguration Configuration object used to define which sensor data from the replay will be used. Data required by this configuration must be a subset of the data required and provided by the template configuration that the replay was originally recorded with. Ideally, these configurations should be identical.
 @param replaySensor `ARReplaySensor` instance providing the sensor data to replay.
 @param resultClasses Allows customizing the technique result classes that will be replayed. This requires having access to these (private) classes, so pass nil for this parameter to get default behavior.
 @return Configuration object which will replay sensor data in the session it's run on.
 */
+ (ARConfiguration *)replayConfigurationWithConfiguration:(ARConfiguration *)templateConfiguration replaySensor:(ARReplaySensor *)replaySensor replayingResultDataClasses:(nullable NSSet<Class> *)resultClasses API_AVAILABLE(ios(11.3));

@end

NS_ASSUME_NONNULL_END
