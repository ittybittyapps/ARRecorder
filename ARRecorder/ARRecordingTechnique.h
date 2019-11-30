//
//  ARKit
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Value: `com.apple.arkit.session.record.filepath`
extern NSString * const ARSessionRecordingFilePathDefaultsKey;

@class ARRecordingTechnique;

API_AVAILABLE(ios(11.3))
@protocol ARRecordingTechniqueDelegate <NSObject>

/**
 Notifies the recording technique delegate that recording was finished, passing the error if it has occured while finishing recording.
 */
- (void)technique:(ARRecordingTechnique *)technique didFinishWithResult:(nullable NSError *)result;

@end

@interface ARTechnique: NSObject
@end

/**
 Captures sensor data of the session it's executed in to a file on disk, creating a "replay" of it.
 */
@interface ARRecordingTechnique: ARTechnique

/**
 Recording destination file URL this technique was configured with.
 */
@property (nonatomic, strong, readonly) NSURL *outputFileURL;
/**
 If set to YES, the receiver will export the recorded replay to the Photos Library when recording finishes.
 @note Authorization to access Photo Library will be requested automatically, but Info.plist of the application must be configured with the Photo Library Usage Description if this property is set to YES.
 */
@property (nonatomic, assign) BOOL shouldSaveVideoInPhotosLibrary;

/**
 Delegate of the receiver, notified when recording finishes.
 */
@property (nonatomic, weak) id<ARRecordingTechniqueDelegate> recordingTechniqueDelegate API_AVAILABLE(ios(11.3));

/**
 Asynchronously finishes processing and recording the replay, and exports the resulting video file to the Photo Library if `shouldSaveVideoInPhotosLibrary` is set.
 */
- (void)finishRecording;

@end

#pragma mark - Recording Configuration

@interface ARConfiguration ()

/**
 Returns an `ARConfiguration` object that can be used to run an `ARSession` that will record a "replay" of its sensor data (including the video feed) to a file on disk. An `ARRecordingTechnique` object is returned by reference to allow additional customization.

 @param templateConfiguration Configuration object used to define which sensor data will be recorded in the replay.
 @param recordingTechnique Upon return, contains a `ARRecordingTechnique` object created to perform the recording as part of the configuration.
 @param fileURL URL to save the replay file to. If nil, the configuration will use the value of `ARSessionRecordingFilePathDefaultsKey` user default as the destination, or if that's not specified either, a temporary file.
 @return Configuration object which will record a replay of the session it's run on.
 */
+ (ARConfiguration *)recordingConfigurationWithConfiguration:(ARConfiguration *)templateConfiguration recordingTechnique:(ARRecordingTechnique * _Nullable * _Nonnull)recordingTechnique fileURL:(nullable NSURL *)fileURL;
/**
 Calls `+recordingConfigurationWithConfiguration:recordingTechnique:fileURL:` passing nil for `fileURL` parameter.
 */
+ (ARConfiguration *)recordingConfigurationWithConfiguration:(ARConfiguration *)templateConfiguration recordingTechnique:(ARRecordingTechnique * _Nullable * _Nonnull)recordingTechnique;

@end

NS_ASSUME_NONNULL_END
