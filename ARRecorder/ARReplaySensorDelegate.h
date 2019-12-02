//
//  ARKit
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ARReplaySensorDelegate <NSObject>
@optional

/**
 Notifies the replay sensor delegate that it finishes loading its metadata and will start the replay shortly.
 @param framesCount Number of frames contained in the replay.
 @note This method is called on an arbitrary thread.
 @deprecated This method is not called by ARReplaySensorPublic and is deprecated. Use `replaySensorDidFinishLoadingWithStartTimestamp:endTimestamp:` on iOS 13 and later instead.
 */
- (void)replaySensorDidFinishLoadingFrames:(NSUInteger)framesCount API_DEPRECATED("This method is only called by ARReplaySensor, not ARReplaySensorPublic.", ios(11.0, 13.0));

/// Notifies the replay sensor delegate that it finishes loading its metadata and will start the replay shortly.
/// @param startTimestamp Timestamp corresponding to the system uptime at the start point of the sensor data replay.
/// @param endTimestamp Timestamp corresponding to the system uptime at the end point of the sensor data replay.
- (void)replaySensorDidFinishLoadingWithStartTimestamp:(NSTimeInterval)startTimestamp endTimestamp:(NSTimeInterval)endTimestamp API_AVAILABLE(ios(13.0));

/**
 Notifies the replay sensor delegate that the replay has been completed.
 @note This method is called on an arbitrary thread.
 */
- (void)replaySensorDidFinishReplayingData;

@end

NS_ASSUME_NONNULL_END
