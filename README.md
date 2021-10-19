⚠️ This project is not actively maintained and due to use of private SPI may not work with newer releases of iOS. ⚠️

----

# <img src="icon@2x.png" alt="AR Recorder icon" width="29"> AR Recorder

This project demonstrates how ARKit's private SPI can be used to record and replay AR sessions, thus enabling a convenient development workflow and test automation.

> **Disclaimer:** Functionality exposed and used in this project is private SPI. It's not guaranteed to be reliable or stay available in any form in future versions of ARKit. It definitely cannot be used in production versions of apps distributed on the App Store.

## How to build

Clone the repository and open `ARRecorder.xcodeproj` in Xcode 10 or newer. Configure automatic codesigning by opening project settings, _ARRecorder_ target, _General_, and configuring the _Team_ setting in the _Signing_ section.

## How to use

The app starts a normal AR session once launched. Tap **Record** to start recording the session to a local file. Then tap **Finish** to complete the recording and continue a normal session. To replay a previously recorded session, tap **Replay**, then select the file. To stop the replay at any time, tap **╳**.

During both normal, recording and replay sessions, tap anywhere to place a virtual cube in the scene at the estimated physical location that corresponds to your touch. Note that this won't be recorded into the replay file: you can interact with the session differently during recording and replay.

To delete a recorded file, tap **Replay** and swipe left on a file row, then tap **Delete**. You can also access all session recordings using the Files app by selecting _On My iPhone/iPad_ location, where ARRecorder's documents container will show up. The app is also configured to allow File Sharing via iTunes.

## SPI declaration

Relevant SPI classes and methods are annotated across a few headers like [ARRecordingTechnique.h](ARRecorder/ARRecordingTechnique.h) and [ARReplaySensorProtocol.h](ARRecorder/ARReplaySensorProtocol.h) (please see `ARKit Private API` group in Xcode project for the full list). Their signature and presumed function have been observed as of ARKit 3.0.

Note that depending on the iOS version, either `ARReplaySensor` or `ARReplaySensorPublic` class is used to load replays. See `ARConfiguration.makeReplayConfiguration(replayURL:)` method in [MainViewController.swift](ARRecorder/MainViewController.swift) for an example of how that can be done.

## Supported devices

All iOS 11.3+ devices with A9 chip or newer are supported. This includes:

- iPhone SE
- iPhone 6S, 6S Plus or newer
- iPad (2017, 5th generation) or newer

The project can be modified to support a wider range of hardware by replacing session's world tracking configuration with an orientation tracking configuration.

## Licensing

This work is licensed under a <a rel="license" href="https://opensource.org/licenses/BSD-3-Clause">BSD 3-Clause License</a>.
