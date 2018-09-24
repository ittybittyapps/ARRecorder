//
//  Copyright © 2018 Itty Bitty Apps Pty Ltd. All rights reserved.
//

import Foundation

struct ReplayStorage {

    static var location: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    static func findReplayOverlays() throws -> [URL] {
        return try FileManager.default
            .contentsOfDirectory(at: self.location, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension.caseInsensitiveCompare(self.replayFileExtension) == .orderedSame }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    static func makeNewReplayURL() -> URL {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        return self.location.appendingPathComponent(timestamp).appendingPathExtension(self.replayFileExtension)
    }

    static func deleteReplay(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    private static let replayFileExtension = "mov"

}
