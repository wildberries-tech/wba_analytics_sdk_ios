// Copyright © 2021 Wildberries. All rights reserved.

import Foundation

/// Type alias for a batch of events
typealias Batch = [String: Any]

/// Extension to add functionality to the Batch type
extension Batch {

    /// Initializer for the Batch type
    /// - Parameters:
    ///   - meta: Meta data for the batch
    ///   - batchNum: - eventNum: incremented event number, starting from 1 and continue growing until the app will be deleted.
    ///   - events: Array of events in the batch
    init(meta: Meta, batchNum: Int, events: [Event]) {
        var meta = meta
        meta[Self.batchNumKey] = batchNum

        self = [
            Self.metaKey: meta,
            Self.eventsKey: events
        ]
    }

    /// Computed property to get the events in the batch
    private var events: [Event] {
        self[Self.eventsKey] as? [Event] ?? []
    }

    /// Property to check if the batch can be split
    var isSplittable: Bool {
        events.count > 1
    }

    /// Property to get the split events in the batch
    var splittedEvents: [[Event]] {
        guard isSplittable else {
            return [events]
        }

        let splitCount = events.count / 2

        let firstPart = [Event](events[..<splitCount])
        let secondPart = [Event](events[splitCount...])
        return [firstPart, secondPart].filter { !$0.isEmpty }
    }
}

// MARK: - Keys
private extension Batch {
    /// Key for the meta data in the batch
    static let metaKey: String = "meta"
    /// Key for the events in the batch
    static let eventsKey: String = "events"
    // Key for the batch number that increased
    static let batchNumKey: String = "batch_num"
}
