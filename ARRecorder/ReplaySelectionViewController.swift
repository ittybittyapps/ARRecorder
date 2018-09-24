//
//  Copyright © 2018 Itty Bitty Apps Pty Ltd. All rights reserved.
//

import UIKit

protocol ReplaySelectionViewControllerDelegate: class {

    func replaySelectionViewController(_ viewController: ReplaySelectionViewController, didFinishWithReplayURL replayURL: URL?)

}

final class ReplaySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet var tableView: UITableView!

    weak var delegate: ReplaySelectionViewControllerDelegate?

    private var fileURLs = try! ReplayStorage.findReplayOverlays()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.popoverPresentationController?.delegate = self
    }

    @IBAction func dismiss(_ sender: Any) {
        self.delegate?.replaySelectionViewController(self, didFinishWithReplayURL: nil)
        self.presentingViewController?.dismiss(animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fileURLs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        cell.textLabel!.text = self.fileURLs[indexPath.row].lastPathComponent
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let url = self.fileURLs.remove(at: indexPath.row)
        try! ReplayStorage.deleteReplay(at: url)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.fileURLs[indexPath.row]
        self.delegate?.replaySelectionViewController(self, didFinishWithReplayURL: url)
        self.presentingViewController?.dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // MARK: - UIPopoverPresentationControllerDelegate

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.delegate?.replaySelectionViewController(self, didFinishWithReplayURL: nil)
        return true
    }

}
