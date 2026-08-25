//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class FirstOpenTrackerTests: XCTestCase {

    private var defaults: UserDefaults!
    private var legacyDefaults: UserDefaults!
    private var defaultsSuiteName: String!
    private var legacySuiteName: String!
    private var subject: FirstOpenTracker!

    override func setUp() {
        super.setUp()
        defaultsSuiteName = "FirstOpenTrackerTests-\(UUID().uuidString)"
        legacySuiteName = "FirstOpenTrackerTests-legacy-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)
        legacyDefaults = UserDefaults(suiteName: legacySuiteName)
        // The legacy key is now captured once per process, so each test must start with a
        // clean cache — otherwise behavior would depend on test execution order.
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        subject = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        legacyDefaults.removePersistentDomain(forName: legacySuiteName)
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        super.tearDown()
    }

    func testTracksOnFirstCall() {
        // given
        var trackedCount = 0
        // when
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 1)
    }

    func testDoesNotTrackOnSecondCall() {
        // given
        var trackedCount = 0
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // when
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 1)
    }

    func testTracksSeparatelyForEachApiKey() {
        // given
        var trackedCount = 0
        subject.trackIfNeeded(apiKey: "first") { trackedCount += 1 }
        // when
        subject.trackIfNeeded(apiKey: "second") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 2)
    }

    func testDoesNotTrackWhenSDKAlreadyRanBefore() {
        // given: a previous SDK version already ran on this device. The legacy key must exist
        // BEFORE the tracker is created — the value is captured once, at initialization.
        // setUp() already created an instance with an empty legacy key and cached "doesn't exist" —
        // reset the cache so our instance re-reads defaults from scratch.
        legacyDefaults.set(false, forKey: "WildAnalyticsSDK-isNewLaunch")
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        let subject = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
        var trackedCount = 0
        // when
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 0)
    }

    func testMigrationMarksEventAsSentSoNextLaunchIsSilent() {
        // given: the SDK already ran before — the first instance sees the legacy key and doesn't
        // track, but still marks the apiKey as "already handled". Reset the cache for the same
        // reason as above.
        legacyDefaults.set(false, forKey: "WildAnalyticsSDK-isNewLaunch")
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        let subject = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
        var trackedCount = 0
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // when: the next launch (new process -> new instance) no longer cares about the legacy
        // key — silence is now guaranteed by the persisted "first-open-sent" flag, not the legacy key
        legacyDefaults.removeObject(forKey: "WildAnalyticsSDK-isNewLaunch")
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        let newSubject = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
        newSubject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 0)
    }

    func testNewInstanceReadsPersistedFlag() {
        // given
        var trackedCount = 0
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // when
        let newSubject = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
        newSubject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 1)
    }

    // MARK: - Legacy key snapshot on process

    func testLegacyKeySnapshotIsSharedAcrossInstancesCreatedByDefault() {
        // given: the first tracker in the process is created while the legacy key is still absent
        // (the device never ran the SDK before). Reset the cache so the snapshot is taken from
        // our own legacyDefaults, rather than inherited from the instance created in setUp().
        FirstOpenTracker.resetLegacyLaunchKeyCacheForTesting()
        let firstInstance = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
        // when: a race between multiple receivers — another EventsProcessorImpl (checkOnNewLaunch)
        // manages to write the legacy key AFTER the first instance already took its snapshot
        legacyDefaults.set(true, forKey: "WildAnalyticsSDK-isNewLaunch")
        let secondInstance = FirstOpenTracker(defaults: defaults, legacyDefaults: legacyDefaults)
        var trackedCount = 0
        // then: both instances use the same process-wide snapshot (the key was absent), so the
        // second receiver doesn't lose first_open just because it read the key later
        firstInstance.trackIfNeeded(apiKey: "first") { trackedCount += 1 }
        secondInstance.trackIfNeeded(apiKey: "second") { trackedCount += 1 }
        XCTAssertEqual(trackedCount, 2)
    }

    func testInjectedLegacyLaunchKeyExistsBypassesDefaultsAndCache() {
        // given: the legacy key is absent from defaults, but the test explicitly says it "exists" —
        // the injected value must win, without touching either defaults or the static cache
        let subject = FirstOpenTracker(
            defaults: defaults,
            legacyDefaults: legacyDefaults,
            legacyLaunchKeyExists: true
        )
        var trackedCount = 0
        // when
        subject.trackIfNeeded(apiKey: "key") { trackedCount += 1 }
        // then
        XCTAssertEqual(trackedCount, 0)
    }
}
