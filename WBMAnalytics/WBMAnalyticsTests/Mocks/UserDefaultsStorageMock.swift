//
//  UserDefaultsStorageMock.swift
//  WBMAnalyticsTests
//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class UserDefaultsStorageMock: UserDefaultsStorage {

    init() { }

    private(set) var saveReceivedBatches: [BatchModel]?
    private(set) var saveWasCalled: Int = 0
    var saveError: Error?

    func save(batches: [BatchModel]) throws {
        saveReceivedBatches = batches
        saveWasCalled += 1

        if let saveError = saveError {
            throw saveError
        }
    }

    private(set) var loadBatchesDropCacheWasCalled: Int = 0
    var loadBatchesStub: [BatchModel] = []

    func loadBatches() -> [BatchModel] {
        loadBatchesDropCacheWasCalled += 1
        return loadBatchesStub
    }
}
