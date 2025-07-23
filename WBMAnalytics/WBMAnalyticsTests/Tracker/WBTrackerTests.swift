//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

import XCTest
import Foundation
@testable import WBMAnalytics

// swiftlint:disable all

// MARK: - AttributionData Tests
final class AttributionDataTests: XCTestCase {
    
    func testAttributionDataDecodingWithAllFields() throws {
        // Given
        let json = """
        {
            "counterId": "12345",
            "link": "https://example.com",
            "utm_source": "google",
            "utm_medium": "cpc",
            "custom_param": "value1"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.counterId, "12345")
        XCTAssertEqual(attribution.link, "https://example.com")
        XCTAssertEqual(attribution.parameters?["utm_source"], "google")
        XCTAssertEqual(attribution.parameters?["utm_medium"], "cpc")
        XCTAssertEqual(attribution.parameters?["custom_param"], "value1")
    }
    
    func testAttributionDataDecodingWithOnlyRequiredFields() throws {
        // Given
        let json = """
        {
            "counterId": "67890",
            "link": "https://test.com"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.counterId, "67890")
        XCTAssertEqual(attribution.link, "https://test.com")
        XCTAssertEqual(attribution.parameters?["link"], "https://test.com")
    }
    
    func testAttributionDataDecodingWithNullFields() throws {
        // Given
        let json = """
        {
            "counterId": null,
            "link": null,
            "utm_campaign": "summer2024"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertNil(attribution.counterId)
        XCTAssertNil(attribution.link)
        XCTAssertEqual(attribution.parameters?["utm_campaign"], "summer2024")
    }
    
    func testAttributionDataDecodingEmptyObject() throws {
        // Given
        let json = "{}".data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertNil(attribution.counterId)
        XCTAssertNil(attribution.link)
        XCTAssertNil(attribution.parameters)
    }
}

// MARK: - DeviceFingerprint Tests

final class DeviceFingerprintTests: XCTestCase {
    
    func testDeviceFingerprintCodable() throws {
        // Given
        let fingerprint = DeviceFingerprint(
            screen: "1440x900",
            platform: "MacIntel",
            language: "ru",
            timezone: "Europe/Moscow"
        )
        
        // When
        let encoded = try JSONEncoder().encode(fingerprint)
        let decoded = try JSONDecoder().decode(DeviceFingerprint.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.screen, fingerprint.screen)
        XCTAssertEqual(decoded.platform, fingerprint.platform)
        XCTAssertEqual(decoded.language, fingerprint.language)
        XCTAssertEqual(decoded.timezone, fingerprint.timezone)
    }
    
    func testDeviceFingerprintFromJSON() throws {
        // Given
        let json = """
        {
            "screen": "1920x1080",
            "platform": "iPhone",
            "language": "en",
            "timezone": "America/New_York"
        }
        """.data(using: .utf8)!
        
        // When
        let fingerprint = try JSONDecoder().decode(DeviceFingerprint.self, from: json)
        
        // Then
        XCTAssertEqual(fingerprint.screen, "1920x1080")
        XCTAssertEqual(fingerprint.platform, "iPhone")
        XCTAssertEqual(fingerprint.language, "en")
        XCTAssertEqual(fingerprint.timezone, "America/New_York")
    }
}

// MARK: - DeviceFingerprintCollector Tests

final class DeviceFingerprintCollectorTests: XCTestCase {
    
    private var sut: DeviceFingerprintCollector!
    
    override func setUp() {
        super.setUp()
        sut = DeviceFingerprintCollector()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCollectReturnsValidFingerprint() {
        // When
        let fingerprint = sut.collect()
        
        // Then
        XCTAssertFalse(fingerprint.screen.isEmpty)
        XCTAssertTrue(fingerprint.screen.contains("x"))
        XCTAssertFalse(fingerprint.platform.isEmpty)
        XCTAssertFalse(fingerprint.language.isEmpty)
        XCTAssertFalse(fingerprint.timezone.isEmpty)
    }
    
    func testCollectScreenFormat() {
        // When
        let fingerprint = sut.collect()
        
        // Then
        let screenComponents = fingerprint.screen.split(separator: "x")
        XCTAssertEqual(screenComponents.count, 2)
        XCTAssertNotNil(Int(screenComponents[0]))
        XCTAssertNotNil(Int(screenComponents[1]))
    }
    
    func testCollectLanguageFormat() {
        // When
        let fingerprint = sut.collect()
        
        // Then
        // Language should be 2-3 characters (e.g., "en", "ru", "zh")
        XCTAssertTrue(fingerprint.language.count >= 2)
        XCTAssertTrue(fingerprint.language.count <= 3)
    }
}

// MARK: - UserDefaultsAttributionStorage Tests

final class UserDefaultsAttributionStorageTests: XCTestCase {
    
    private var sut: UserDefaultsAttributionStorage!
    private let testKey = "ru.wba.deviceFingerprint.attribution"
    
    override func setUp() {
        super.setUp()
        sut = UserDefaultsAttributionStorage()
        UserDefaults.standard.removeObject(forKey: testKey)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        sut = nil
        super.tearDown()
    }
    
    func testSaveAndLoadAttribution() {
        // Given
        let attribution = AttributionData(
            isEmpty: false,
            counterId: "123",
            link: "https://test.com",
            parameters: ["utm_source": "test"]
        )
        
        // When
        sut.save(attribution)
        let loaded = sut.load()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.counterId, "123")
        XCTAssertEqual(loaded?.link, "https://test.com")
        XCTAssertEqual(loaded?.parameters?["utm_source"], "test")
    }
    
    func testLoadWhenNoDataSaved() {
        // When
        let loaded = sut.load()
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testSaveOverwritesPreviousData() {
        // Given
        let firstAttribution = AttributionData(isEmpty: false, counterId: "111", link: "https://first.com", parameters: nil)
        let secondAttribution = AttributionData(isEmpty: false, counterId: "222", link: "https://second.com", parameters: nil)

        // When
        sut.save(firstAttribution)
        sut.save(secondAttribution)
        let loaded = sut.load()
        
        // Then
        XCTAssertEqual(loaded?.counterId, "222")
        XCTAssertEqual(loaded?.link, "https://second.com")
    }
}

// MARK: - DeviceFingerprintService Tests

final class DeviceFingerprintServiceTests: XCTestCase {
    
    private var sut: DeviceFingerprintService!
    private var loggerMock: LoggerMock!
    private var collectorMock: DeviceFingerprintCollectorMock!
    private var storageMock: AttributionStorageMock!
    
    override func setUp() {
        super.setUp()
        loggerMock = LoggerMock()
        collectorMock = DeviceFingerprintCollectorMock()
        storageMock = AttributionStorageMock()
        sut = DeviceFingerprintService(
            collector: collectorMock,
            logger: CompositeLogger(loggers: [loggerMock]),
            storage: storageMock
        )
    }
    
    override func tearDown() {
        sut = nil
        loggerMock = nil
        collectorMock = nil
        storageMock = nil
        super.tearDown()
    }
    
    func testCheckAttributionWhenAlreadySaved() {
        // Given
        let existingAttribution = AttributionData(isEmpty: true, counterId: "existing", link: nil, parameters: nil)
        storageMock.attributionData = existingAttribution
        let expectation = expectation(description: "Attribution check completion")
        
        // When
        sut.checkAttribution { result in
            // Then
            switch result {
            case .success(let data):
                XCTAssertNil(data)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(collectorMock.collectCallCount, 0)
    }
    
    func testCheckAttributionWhenNotSaved() {
        // Given
        storageMock.attributionData = nil
        collectorMock.fingerprintToReturn = DeviceFingerprint(
            screen: "1440x900",
            platform: "Test",
            language: "en",
            timezone: "UTC"
        )
        let expectation = expectation(description: "Attribution check completion")
        
        // When
        sut.checkAttribution { result in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(collectorMock.collectCallCount, 1)
    }
}

// MARK: - Mocks

final class DeviceFingerprintCollectorMock: DeviceFingerprintCollector {
    var collectCallCount = 0
    var fingerprintToReturn = DeviceFingerprint(
        screen: "1440x900",
        platform: "TestPlatform",
        language: "en",
        timezone: "UTC"
    )
    
    override func collect() -> DeviceFingerprint {
        collectCallCount += 1
        return fingerprintToReturn
    }
}

final class AttributionStorageMock: AttributionStorageProtocol {

    
    var attributionData: AttributionData?
    var saveCallCount = 0
    var loadCallCount = 0
    var saveAtrributionDidRequestedCallCount = 0
    var loadAtrributionDidRequestedCallCount = 0

    func save(_ response: AttributionData) {
        saveCallCount += 1
        attributionData = response
    }
    
    func load() -> AttributionData? {
        loadCallCount += 1
        return attributionData
    }

    func saveAtrributionDidRequested() {
        saveAtrributionDidRequestedCallCount += 1
    }

    func isAtrributionDidRequested() -> Bool {
        loadCallCount += 1
        return loadCallCount > 0
    }
}
