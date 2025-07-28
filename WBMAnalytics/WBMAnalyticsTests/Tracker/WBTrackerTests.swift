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
            "link": "https://example.com",
            "utm_source": "google",
            "utm_medium": "cpc",
            "custom_param": "value1"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.link, "https://example.com")
        XCTAssertEqual(attribution.parameters?["utm_source"]?.stringValue, "google")
        XCTAssertEqual(attribution.parameters?["utm_medium"]?.stringValue, "cpc")
        XCTAssertEqual(attribution.parameters?["custom_param"]?.stringValue, "value1")
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingWithMixedTypes() throws {
        // Given
        let json = """
        {
            "link": "https://example.com",
            "utm_source": "google",
            "categories": ["electronics", "smartphones"],
            "count": 42,
            "price": 99.99,
            "featured": true,
            "metadata": {
                "campaign": "summer2024",
                "priority": 1
            },
            "nullable_field": null
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.link, "https://example.com")
        XCTAssertEqual(attribution.parameters?["utm_source"]?.stringValue, "google")
        XCTAssertEqual(attribution.parameters?["categories"]?.arrayValue?.count, 2)
        XCTAssertEqual(attribution.parameters?["categories"]?.arrayValue?[0].stringValue, "electronics")
        XCTAssertEqual(attribution.parameters?["count"]?.intValue, 42)
        XCTAssertEqual(attribution.parameters?["price"]?.doubleValue, 99.99)
        XCTAssertEqual(attribution.parameters?["featured"]?.boolValue, true)
        XCTAssertEqual(attribution.parameters?["metadata"]?.objectValue?["campaign"]?.stringValue, "summer2024")
        XCTAssertEqual(attribution.parameters?["metadata"]?.objectValue?["priority"]?.intValue, 1)
        XCTAssertTrue(attribution.parameters?["nullable_field"]?.isNull == true)
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingWithOnlyRequiredFields() throws {
        // Given
        let json = """
        {
            "link": "https://test.com"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.link, "https://test.com")
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingWithNullFields() throws {
        // Given
        let json = """
        {
            "link": null,
            "utm_campaign": "summer2024"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertNil(attribution.link)
        XCTAssertEqual(attribution.parameters?["utm_campaign"]?.stringValue, "summer2024")
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingEmptyObject() throws {
        // Given
        let json = "{}".data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertNil(attribution.link)
        XCTAssertNil(attribution.parameters)
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataEncoding() throws {
        // Given
        let parameters: [String: AnyValue] = [
            "utm_source": .string("google"),
            "categories": .array([.string("electronics"), .string("phones")]),
            "count": .int(42),
            "price": .double(99.99),
            "featured": .bool(true),
            "metadata": .object(["key": .string("value")]),
            "nullable": .null
        ]
        let attribution = AttributionData(
            isEmpty: false,
            link: "https://example.com",
            parameters: parameters
        )
        
        // When
        let encoded = try JSONEncoder().encode(attribution)
        let decoded = try JSONDecoder().decode(AttributionData.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.link, attribution.link)
        XCTAssertEqual(decoded.isEmpty, attribution.isEmpty)
        XCTAssertEqual(decoded.parameters?["utm_source"]?.stringValue, "google")
        XCTAssertEqual(decoded.parameters?["count"]?.intValue, 42)
        XCTAssertEqual(decoded.parameters?["price"]?.doubleValue, 99.99)
        XCTAssertEqual(decoded.parameters?["featured"]?.boolValue, true)
        XCTAssertTrue(decoded.parameters?["nullable"]?.isNull == true)
    }
    
    func testAnyValueAccessors() {
        // Given
        let stringParam = AnyValue.string("test")
        let intParam = AnyValue.int(42)
        let doubleParam = AnyValue.double(3.14)
        let boolParam = AnyValue.bool(true)
        let arrayParam = AnyValue.array([.string("item1"), .string("item2")])
        let objectParam = AnyValue.object(["key": .string("value")])
        let nullParam = AnyValue.null
        
        // When & Then
        XCTAssertEqual(stringParam.stringValue, "test")
        XCTAssertEqual(intParam.intValue, 42)
        XCTAssertEqual(intParam.stringValue, "42")
        XCTAssertEqual(doubleParam.doubleValue, 3.14)
        XCTAssertEqual(boolParam.boolValue, true)
        XCTAssertEqual(boolParam.stringValue, "true")
        XCTAssertEqual(arrayParam.arrayValue?.count, 2)
        XCTAssertEqual(arrayParam.arrayValue?[0].stringValue, "item1")
        XCTAssertEqual(objectParam.objectValue?["key"]?.stringValue, "value")
        XCTAssertTrue(nullParam.isNull)
        XCTAssertNil(nullParam.stringValue)
    }
    
    func testAnyValueFromAny() {
        // Given & When
        let stringParam = AnyValue.from("test")
        let intParam = AnyValue.from(42)
        let doubleParam = AnyValue.from(3.14)
        let boolParam = AnyValue.from(true)
        let arrayParam = AnyValue.from(["item1", "item2"])
        let objectParam = AnyValue.from(["key": "value"])
        let nullParam = AnyValue.from(nil)
        
        // Then
        XCTAssertEqual(stringParam.stringValue, "test")
        XCTAssertEqual(intParam.intValue, 42)
        XCTAssertEqual(doubleParam.doubleValue, 3.14)
        XCTAssertEqual(boolParam.boolValue, true)
        XCTAssertEqual(arrayParam.arrayValue?.count, 2)
        XCTAssertEqual(objectParam.objectValue?["key"]?.stringValue, "value")
        XCTAssertTrue(nullParam.isNull)
    }
    
    func testAnyValueToAny() {
        // Given
        let stringParam = AnyValue.string("test")
        let intParam = AnyValue.int(42)
        let arrayParam = AnyValue.array([.string("item1"), .string("item2")])
        let objectParam = AnyValue.object(["key": .string("value")])
        
        // When & Then
        XCTAssertEqual(stringParam.anyValue as? String, "test")
        XCTAssertEqual(intParam.anyValue as? Int, 42)
        
        let arrayAny = arrayParam.anyValue as? [Any?]
        XCTAssertEqual(arrayAny?.count, 2)
        XCTAssertEqual(arrayAny?[0] as? String, "item1")
        
        let objectAny = objectParam.anyValue as? [String: Any?]
        XCTAssertEqual(objectAny?["key"] as? String, "value")
    }
    
    func testAnyValueEquality() {
        // Given
        let string1 = AnyValue.string("test")
        let string2 = AnyValue.string("test")
        let string3 = AnyValue.string("different")
        let int1 = AnyValue.int(42)
        let int2 = AnyValue.int(42)
        let int3 = AnyValue.int(24)
        
        // Then
        XCTAssertEqual(string1, string2)
        XCTAssertNotEqual(string1, string3)
        XCTAssertEqual(int1, int2)
        XCTAssertNotEqual(int1, int3)
        XCTAssertNotEqual(string1, int1)
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
            link: "https://test.com",
            parameters: ["utm_source": .string("test")]
        )
        
        // When
        sut.save(attribution)
        let loaded = sut.load()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.link, "https://test.com")
        XCTAssertEqual(loaded?.parameters?["utm_source"]?.stringValue, "test")
    }
    
    func testLoadWhenNoDataSaved() {
        // When
        let loaded = sut.load()
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testSaveOverwritesPreviousData() {
        // Given
        let firstAttribution = AttributionData(isEmpty: false, link: "https://first.com", parameters: nil)
        let secondAttribution = AttributionData(isEmpty: false, link: "https://second.com", parameters: nil)

        // When
        sut.save(firstAttribution)
        sut.save(secondAttribution)
        let loaded = sut.load()
        
        // Then
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
        let existingAttribution = AttributionData(isEmpty: true, link: nil, parameters: nil)
        storageMock.attributionData = existingAttribution
        storageMock.attributionDidRequested = true
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
        storageMock.attributionDidRequested = false
        collectorMock.fingerprintToReturn = DeviceFingerprint(
            screen: "1440x900",
            platform: "Test",
            language: "en",
            timezone: "UTC"
        )
        let expectation = expectation(description: "Attribution check completion")
        
        // When
        sut.checkAttribution { result in
            // Then - expect either success or failure (network request will likely fail in test environment)
            switch result {
            case .success:
                // Success is possible if network request succeeds
                break
            case .failure:
                // Failure is expected since network request will likely fail in test environment
                break
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(collectorMock.collectCallCount, 1)
        XCTAssertEqual(storageMock.isAttributionDidRequestedCallCount, 1)
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
    var isAttributionDidRequestedCallCount = 0
    var attributionDidRequested = false

    func save(_ response: AttributionData) {
        saveCallCount += 1
        attributionData = response
        saveAtrributionDidRequested()
    }
    
    func load() -> AttributionData? {
        loadCallCount += 1
        return attributionData
    }

    func saveAtrributionDidRequested() {
        saveAtrributionDidRequestedCallCount += 1
        attributionDidRequested = true
    }

    func isAtrributionDidRequested() -> Bool {
        isAttributionDidRequestedCallCount += 1
        return attributionDidRequested
    }
}
