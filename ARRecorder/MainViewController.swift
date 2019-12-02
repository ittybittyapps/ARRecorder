//
//  Copyright © 2018 Itty Bitty Apps Pty Ltd. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class MainViewController: UIViewController, ARSCNViewDelegate, ARReplaySensorDelegate, ReplaySelectionViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints ]

        // Start in Idle state
        self.transition(to: .idle)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.state == .idle {
            // Start the normal session once the view initially appears
            self.transition(to: .normal)
            self.sceneView.session.run(.makeBaseConfiguration())
        }
    }

    // MARK: - State

    fileprivate enum State: Equatable {
        case idle
        case normal
        case recording(ARRecordingTechnique)
        case loadingReplay
        case replaying
        case replayFinished
    }

    private var state = State.idle

    private func transition(to state: State) {
        switch self.state {
        case .recording(let technique):
            // Finish recording a replay when transitioning from Recording state
            technique.finishRecording()
        default:
            break
        }

        self.state = state
        self.title = state.navigationTitle

        // Update bar buttons
        let (left, right) = self.makeBarButtonItems(for: state)
        self.navigationItem.leftBarButtonItems = left
        self.navigationItem.rightBarButtonItems = right
    }

    private func makeBarButtonItems(for state: State) -> (left: [UIBarButtonItem], right: [UIBarButtonItem]) {
        switch state {
        case .idle, .loadingReplay:
            return ([], [])
        case .normal:
            return ([ self.makeStartRecordingButton() ], [ self.makeStartReplayButton() ])
        case .recording:
            return ([ self.makeStopRecordingButton() ], [])
        case .replaying, .replayFinished:
            return ([ self.makeStopReplayButton() ], [])
        }
    }

    // MARK: - Actions

    @objc private func startRecording(_ sender: Any) {
        // Transition to Recording state and start a new session with a recording configuration
        let (configuration, technique) = ARConfiguration.makeRecordingConfiguration()
        self.transition(to: .recording(technique))
        self.sceneView.session.run(configuration, options: [ .resetTracking, .removeExistingAnchors ])
    }

    private func makeStartRecordingButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: NSLocalizedString("Record", comment: "Bar button title"), style: .plain, target: self, action: #selector(startRecording(_:)))
    }

    @objc private func stopRecording(_ sender: Any) {
        // Transition to Normal state to stop recording, and resume the session with a normal configuration without resetting tracking/anchors
        self.transition(to: .normal)
        self.sceneView.session.run(.makeBaseConfiguration())
    }

    private func makeStopRecordingButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: NSLocalizedString("Finish", comment: "Bar button title"), style: .plain, target: self, action: #selector(stopRecording(_:)))
    }

    @objc private func startReplay(_ sender: UIBarButtonItem!) {
        // Instantiate and present the replay selector; selected replay will be started in the delegate callback
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "ReplaySelectionScene") as! UINavigationController
        navigationController.modalPresentationStyle = .popover
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.popoverPresentationController?.barButtonItem = sender

        let replaySelectionViewController = navigationController.viewControllers.first as! ReplaySelectionViewController
        replaySelectionViewController.delegate = self

        self.present(navigationController, animated: true)
    }

    private func makeStartReplayButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: NSLocalizedString("Replay", comment: "Bar button title"), style: .plain, target: self, action: #selector(startReplay(_:)))
    }

    @objc private func stopReplay(_ sender: Any) {
        // Transition back to Normal state to stop the playback, and reset the session with a normal configuration
        self.transition(to: .normal)
        self.sceneView.session.run(.makeBaseConfiguration(), options: [ .resetTracking, .removeExistingAnchors ])
    }

    private func makeStopReplayButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopReplay(_:)))
    }

    // MARK: - Custom anchor placement

    private var exampleAnchor: ARAnchor?

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        // If an anchor already exists, remove it
        if let anchor = self.exampleAnchor {
            self.sceneView.session.remove(anchor: anchor)
            self.exampleAnchor = nil
            return
        }

        // Otherwise, determine a point on an existing or estimated plane via hit-testing the touch location
        guard let point = touches.first?.location(in: self.view) else {
            return
        }
        guard let hitResult = self.sceneView.hitTest(point, types: [ .estimatedHorizontalPlane, .existingPlaneUsingExtent ]).first else {
            return
        }

        // Add an anchor at hit-tested point
        let anchor = ARAnchor(transform: hitResult.worldTransform)
        self.exampleAnchor = anchor
        self.sceneView.session.add(anchor: anchor)
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor == self.exampleAnchor {
            // Represent a custom anchor with a red box
            let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor.red
            node.addChildNode(SCNNode(geometry: box))
        }
    }

    // MARK: - ARReplaySensorDelegate

    func replaySensorDidFinishLoadingFrames(_ framesCount: UInt) {
        // ARReplaySensor calls both this and the "modern" callback on iOS 13; there's no need to handle both
        if #available(iOS 13, *) { return }

        print("Replay sensor loaded \(framesCount) frames.")

        DispatchQueue.main.async {
            guard case .loadingReplay = self.state else {
                return
            }

            // Once replay sensor finishes loading, transition to the Replaying state
            self.transition(to: .replaying)
        }
    }

    func replaySensorDidFinishLoading(withStartTimestamp startTimestamp: TimeInterval, endTimestamp: TimeInterval) {
        print("Replay sensor loaded frames from \(String(format: "%.3f", startTimestamp))s to \(String(format: "%.3f", endTimestamp))s.")

        DispatchQueue.main.async {
            guard case .loadingReplay = self.state else {
                return
            }

            // Once replay sensor finishes loading, transition to the Replaying state
            self.transition(to: .replaying)
        }
    }

    func replaySensorDidFinishReplayingData() {
        print("Replay finished.")

        DispatchQueue.main.async {
            guard case .replaying = self.state else {
                return
            }

            // Once replay data is exhausted, transition to Replay Finished state and pause the session to stop consuming system resources
            self.transition(to: .replayFinished)
            self.sceneView.session.pause()
        }
    }

    // MARK: - ReplaySelectionViewControllerDelegate

    func replaySelectionViewController(_ viewController: ReplaySelectionViewController, didFinishWithReplayURL replayURL: URL?) {
        guard let url = replayURL else {
            return
        }

        let (configuration, sensor) = ARConfiguration.makeReplayConfiguration(replayURL: url)
        sensor.replaySensorDelegate = self

        // Transition to Loading Replay state and start a replay session; delegate callback from the replay sensor will inform when loading finishes
        self.sceneView.session.pause()
        self.transition(to: .loadingReplay)
        self.sceneView.session.run(configuration, options: [ .resetTracking, .removeExistingAnchors ])
    }

}

// MARK: - Private extensions

private extension ARConfiguration {

    static func makeBaseConfiguration() -> ARConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [ .horizontal, .vertical ]

        return configuration
    }

    static func makeRecordingConfiguration(replayURL: URL? = ReplayStorage.makeNewReplayURL()) -> (ARConfiguration, ARRecordingTechnique) {
        var recordingTechnique: ARRecordingTechnique?
        let configuration = self.recordingConfiguration(with: .makeBaseConfiguration(), recordingTechnique: &recordingTechnique, fileURL: replayURL)
        guard let technique = recordingTechnique else {
            preconditionFailure("Expecting recording technique to be returned!")
        }

        return (configuration, technique)
    }

    static func makeReplayConfiguration(replayURL: URL) -> (ARConfiguration, ARReplaySensorProtocol) {
        let replaySensor: ARReplaySensorProtocol
        if #available(iOS 13, *) {
            let modernReplaySensor = ARReplaySensorPublic(sequenceURL: replayURL, manualReplay: false)
            if modernReplaySensor.arkitVersion != nil {
                // This is a replay made on iOS 13 or later
                replaySensor = modernReplaySensor
            } else {
                // This is a replay made on iOS 12 or earlier – have to use the legacy API for it
                replaySensor = ARReplaySensor(sequenceURL: replayURL, manualReplay: false)
            }
        } else {
            replaySensor = ARReplaySensor(sequenceURL: replayURL, manualReplay: false)
        }

        let replayConfiguration = self.replayConfiguration(with: .makeBaseConfiguration(), replaySensor: replaySensor, replayingResultDataClasses: nil)
        return (replayConfiguration, replaySensor)
    }

}

private extension MainViewController.State {

    var navigationTitle: String? {
        switch self {
        case .idle:
            return NSLocalizedString("Session Idle", comment: "Session state title")
        case .normal:
            return nil
        case .recording:
            return NSLocalizedString("RECORDING", comment: "Session state title")
        case .loadingReplay:
            return NSLocalizedString("Loading…", comment: "Session state title")
        case .replaying:
            return NSLocalizedString("REPLAYING", comment: "Session state title")
        case .replayFinished:
            return NSLocalizedString("Replay Finished", comment: "Session state title")
        }
    }

}
