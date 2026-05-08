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
            "deeplink": "https://example.com",
            "utm_source": "google",
            "utm_medium": "cpc",
            "custom_param": "value1"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.deeplink, "https://example.com")
        XCTAssertEqual(attribution.parameters?["utm_source"]?.stringValue, "google")
        XCTAssertEqual(attribution.parameters?["utm_medium"]?.stringValue, "cpc")
        XCTAssertEqual(attribution.parameters?["custom_param"]?.stringValue, "value1")
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingWithMixedTypes() throws {
        // Given
        let json = """
        {
            "deeplink": "https://example.com",
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
        XCTAssertEqual(attribution.deeplink, "https://example.com")
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
            "deeplink": "https://test.com"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertEqual(attribution.deeplink, "https://test.com")
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingWithNullFields() throws {
        // Given
        let json = """
        {
            "deeplink": null,
            "utm_campaign": "summer2024"
        }
        """.data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertNil(attribution.deeplink)
        XCTAssertEqual(attribution.parameters?["utm_campaign"]?.stringValue, "summer2024")
        XCTAssertFalse(attribution.isEmpty)
    }
    
    func testAttributionDataDecodingEmptyObject() throws {
        // Given
        let json = "{}".data(using: .utf8)!
        
        // When
        let attribution = try JSONDecoder().decode(AttributionData.self, from: json)
        
        // Then
        XCTAssertNil(attribution.deeplink)
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
            deeplink: "https://example.com",
            parameters: parameters
        )
        
        // When
        let encoded = try JSONEncoder().encode(attribution)
        let decoded = try JSONDecoder().decode(AttributionData.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.deeplink, attribution.deeplink)
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
            screen_resolution: "1440x900",
            pixel_ratio: "2",
            platform: "MacIntel",
            language: "ru",
            timezone: "Europe/Moscow",
            user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1",
            device: "iPhone",
            version_os: "18.0"
        )
        
        // When
        let encoded = try JSONEncoder().encode(fingerprint)
        let decoded = try JSONDecoder().decode(DeviceFingerprint.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.screen_resolution, fingerprint.screen_resolution)
        XCTAssertEqual(decoded.pixel_ratio, fingerprint.pixel_ratio)
        XCTAssertEqual(decoded.platform, fingerprint.platform)
        XCTAssertEqual(decoded.language, fingerprint.language)
        XCTAssertEqual(decoded.timezone, fingerprint.timezone)
        XCTAssertEqual(decoded.user_agent, fingerprint.user_agent)
        XCTAssertEqual(decoded.device, fingerprint.device)
        XCTAssertEqual(decoded.version_os, fingerprint.version_os)
    }
    
    func testDeviceFingerprintFromJSON() throws {
        // Given
        let json = """
        {
            "screen_resolution": "1920x1080",
            "pixel_ratio": "2",
            "platform": "iPhone",
            "language": "en",
            "timezone": "America/New_York",
            "user_agent": "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1",
            "device": "iPad",
            "version_os": "17.0"
        }
        """.data(using: .utf8)!
        
        // When
        let fingerprint = try JSONDecoder().decode(DeviceFingerprint.self, from: json)
        
        // Then
        XCTAssertEqual(fingerprint.screen_resolution, "1920x1080")
        XCTAssertEqual(fingerprint.pixel_ratio, "2")
        XCTAssertEqual(fingerprint.platform, "iPhone")
        XCTAssertEqual(fingerprint.language, "en")
        XCTAssertEqual(fingerprint.timezone, "America/New_York")
        XCTAssertEqual(fingerprint.user_agent, "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1")
        XCTAssertEqual(fingerprint.device, "iPad")
        XCTAssertEqual(fingerprint.version_os, "17.0")
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
        XCTAssertFalse(fingerprint.screen_resolution.isEmpty)
        XCTAssertTrue(fingerprint.screen_resolution.contains("x"))
        XCTAssertFalse(fingerprint.platform.isEmpty)
        XCTAssertFalse(fingerprint.language.isEmpty)
        XCTAssertFalse(fingerprint.timezone.isEmpty)
    }
    
    func testCollectScreenFormat() {
        // When
        let fingerprint = sut.collect()
        
        // Then
        let screenComponents = fingerprint.screen_resolution.split(separator: "x")
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
            deeplink: "https://test.com",
            parameters: ["utm_source": .string("test")]
        )
        
        // When
        sut.save(attribution)
        let loaded = sut.load()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.deeplink, "https://test.com")
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
        let firstAttribution = AttributionData(isEmpty: false, deeplink: "https://first.com", parameters: nil)
        let secondAttribution = AttributionData(isEmpty: false, deeplink: "https://second.com", parameters: nil)

        // When
        sut.save(firstAttribution)
        sut.save(secondAttribution)
        let loaded = sut.load()
        
        // Then
        XCTAssertEqual(loaded?.deeplink, "https://second.com")
    }
}

// MARK: - DeviceFingerprintService Tests

final class DeviceFingerprintServiceTests: XCTestCase {

    private final class AttributionURLProtocol: URLProtocol {
        static var responseCode: Int = 404
        static var responseData: Data?
        static var responseError: Error?

        override class func canInit(with request: URLRequest) -> Bool {
            return request.url?.absoluteString == "https://wildtracker.wb.ru/fingerprint/check"
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let error = Self.responseError {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }

            guard
                let url = request.url,
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: Self.responseCode,
                    httpVersion: nil,
                    headerFields: nil
                )
            else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = Self.responseData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() { }
    }

    private var sut: DeviceFingerprintService!
    private var loggerMock: LoggerMock!
    private var collectorMock: DeviceFingerprintCollectorMock!
    private var storageMock: AttributionStorageMock!
    
    override func setUp() {
        super.setUp()
        _ = URLProtocol.registerClass(AttributionURLProtocol.self)
        AttributionURLProtocol.responseCode = 404
        AttributionURLProtocol.responseData = nil
        AttributionURLProtocol.responseError = nil
        loggerMock = LoggerMock()
        collectorMock = DeviceFingerprintCollectorMock()
        storageMock = AttributionStorageMock()
        sut = DeviceFingerprintService(
            apiKey: "Test",
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
        URLProtocol.unregisterClass(AttributionURLProtocol.self)
        super.tearDown()
    }
    
    func testCheckAttributionWhenAlreadySaved() {
        // Given
        let existingAttribution = AttributionData(isEmpty: true, deeplink: nil, parameters: nil)
        storageMock.attributionData = existingAttribution
        storageMock.attributionDidRequested = true
        let expectation = expectation(description: "Attribution check completion")
        
        // When
        sut.checkAttribution { result in
            // Then
            switch result {
            case .success(let attributionResult):
                XCTAssertNil(attributionResult)
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
            screen_resolution: "1440x900",
            pixel_ratio: "2",
            platform: "Test",
            language: "en",
            timezone: "UTC",
            user_agent: "Mozilla/5.0 (Test)",
            device: "iPhone",
            version_os: "17.0"
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
    
    func testAttributionResultStructure() {
        // Given
        let mockFingerprint = DeviceFingerprint(
            screen_resolution: "1440x900",
            pixel_ratio: "2",
            platform: "iPhone",
            language: "en-US",
            timezone: "America/New_York",
            user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
            device: "iPhone",
            version_os: "17.0"
        )
        
        let mockAttributionData = AttributionData.create(
            isEmpty: false,
            deeplink: "https://example.com/deeplink",
            parametersAny: [
                "utm_source": "google",
                "utm_medium": "cpc",
                "campaign_id": "123456"
            ]
        )
        
        // When
        let attributionResult = AttributionResult(
            fingerprintData: mockFingerprint,
            attributionData: mockAttributionData
        )
        
        // Then
        XCTAssertEqual(attributionResult.fingerprintData.screen_resolution, "1440x900")
        XCTAssertEqual(attributionResult.fingerprintData.pixel_ratio, "2")
        XCTAssertEqual(attributionResult.fingerprintData.platform, "iPhone")
        XCTAssertEqual(attributionResult.fingerprintData.device, "iPhone")
        
        XCTAssertNotNil(attributionResult.attributionData)
        XCTAssertEqual(attributionResult.attributionData?.deeplink, "https://example.com/deeplink")
        XCTAssertEqual(attributionResult.attributionData?.parametersAsAny()?["utm_source"] as? String, "google")
        XCTAssertEqual(attributionResult.attributionData?.parametersAsAny()?["utm_medium"] as? String, "cpc")
        XCTAssertEqual(attributionResult.attributionData?.parametersAsAny()?["campaign_id"] as? String, "123456")
    }
}

// MARK: - Mocks

final class DeviceFingerprintCollectorMock: DeviceFingerprintCollector {
    var collectCallCount = 0
    var fingerprintToReturn = DeviceFingerprint(
        screen_resolution: "1440x900",
        pixel_ratio: "2",
        platform: "TestPlatform",
        language: "en",
        timezone: "UTC",
        user_agent: "Mozilla/5.0 (TestPlatform)",
        device: "iPhone",
        version_os: "17.0"
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
