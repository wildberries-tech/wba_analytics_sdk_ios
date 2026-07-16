//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WildAnalyticsSDK

final class BatchSenderImplTests: XCTestCase {

    private var queue: DispatchQueue!
    private var batchConfig: BatchConfig!
    private var loggerMock: LoggerMock!
    private var sessionMock: URLSessionMock!
    private var sender: BatchSenderImpl!
    private var requestInterceptorMock: RequestInterceptorMock!

    override func setUp() {
        super.setUp()

        loggerMock = LoggerMock()
        batchConfig = BatchConfig()
        queue = .init(label: TestData.queueLabel)
        sessionMock = .init()
        requestInterceptorMock = .init()
        sender = .init(
            apiKey: TestData.apiKey,
            analyticsURL: TestData.url,
            queue: queue,
            batchConfig: batchConfig,
            logger: loggerMock,
            interceptor: requestInterceptorMock,
            session: sessionMock
        )
    }

    // MARK: Default Init

    func testSessionInit() {
        // given
        let urlSessionMock = URLSession(configuration: .ephemeral)
        // when
        let sender = BatchSenderImpl(
            apiKey: TestData.apiKey,
            analyticsURL: TestData.url,
            queue: queue,
            batchConfig: batchConfig,
            logger: loggerMock,
            interceptor: requestInterceptorMock,
            session: urlSessionMock
        )
        let mirror = BatchSenderImplMirror(reflecting: sender)
        // then
        XCTAssertIdentical(mirror.session, urlSessionMock)

    }

    func testSessionDefaultInit() {
        // given
        let sender: BatchSenderImpl = .init(
            apiKey: TestData.apiKey,
            analyticsURL: TestData.url,
            queue: queue,
            batchConfig: batchConfig,
            logger: loggerMock,
            interceptor: requestInterceptorMock
        )
        let mirror = BatchSenderImplMirror(reflecting: sender)
        // when
        let session = mirror.session as? URLSession
        // then
        XCTAssertEqual(session?.configuration.timeoutIntervalForRequest, batchConfig.requestTimeout)
        XCTAssertEqual(session?.configuration.timeoutIntervalForResource, batchConfig.requestTimeout)
        XCTAssertIdentical(session?.delegate, sender)
        XCTAssertEqual(session?.delegateQueue.underlyingQueue, queue)
    }

    // MARK: SendBatch

    func testSetRequestParametersSendBatch() async {
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertEqual(sessionMock.dataForRequestReceivedRequest?.httpMethod, TestData.httpMethod)
        XCTAssertEqual(
            sessionMock.dataForRequestReceivedRequest?.allHTTPHeaderFields?["Content-Type"],
            TestData.contentType
        )
        XCTAssertEqual(
            sessionMock.dataForRequestReceivedRequest?.value(
                forHTTPHeaderField: TestData.forHTTPHeaderField
            ),
            TestData.apiKey
        )
        XCTAssertEqual(sessionMock.dataForRequestReceivedRequest?.httpBody, TestData.data)
        XCTAssertEqual(sessionMock.dataForRequestWasCalled, 1)
    }

    func testSetCustomHeadersSendBatch() async {
        // given
        sender.setCustomHeaders(TestData.customHeaders)
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertEqual(
            sessionMock.dataForRequestReceivedRequest?.value(forHTTPHeaderField: "X-Custom-One"),
            "valueOne"
        )
        XCTAssertEqual(
            sessionMock.dataForRequestReceivedRequest?.value(forHTTPHeaderField: "X-Custom-Two"),
            "valueTwo"
        )
    }

    func testCustomHeadersDoNotOverrideDefaultHeadersSendBatch() async {
        // given
        sender.setCustomHeaders(TestData.customHeaders)
        // when
        _ = await sender.sendBatch(TestData.data)
        // then default headers are still present alongside custom ones
        XCTAssertEqual(
            sessionMock.dataForRequestReceivedRequest?.value(forHTTPHeaderField: "Content-Type"),
            TestData.contentType
        )
        XCTAssertEqual(
            sessionMock.dataForRequestReceivedRequest?.value(forHTTPHeaderField: TestData.forHTTPHeaderField),
            TestData.apiKey
        )
    }

    func testEmptyCustomHeadersSendBatch() async {
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertNil(
            sessionMock.dataForRequestReceivedRequest?.value(forHTTPHeaderField: "X-Custom-One")
        )
    }

    func testUsedIntercept() async {
        // given
        requestInterceptorMock.interceptHandler = {
            $0.url = TestData.urlTwo
            $0.httpMethod = "GET"
        }
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertEqual(requestInterceptorMock.interceptCallCount, 1)
        XCTAssertEqual(requestInterceptorMock.lastModifiedRequest?.httpMethod, "GET")
        XCTAssertEqual(requestInterceptorMock.lastModifiedRequest?.url, TestData.urlTwo)
        XCTAssertEqual(sessionMock.dataForRequestReceivedRequest?.url, TestData.urlTwo)
    }

    // MARK: Result

    func testSendBatchReturnsTrueOnSuccessStatusCode() async {
        // given
        sessionMock.dataForRequestResponseStub = TestData.response(statusCode: 200)
        // when
        let successfully = await sender.sendBatch(TestData.data)
        // then
        XCTAssertTrue(successfully)
    }

    func testSendBatchReturnsFalseOnServerErrorStatusCode() async {
        // given
        sessionMock.dataForRequestResponseStub = TestData.response(statusCode: 500)
        // when
        let successfully = await sender.sendBatch(TestData.data)
        // then
        XCTAssertFalse(successfully)
    }

    func testSendBatchReturnsFalseOnError() async {
        // given
        sessionMock.dataForRequestErrorStub = CustomError.random
        // when
        let successfully = await sender.sendBatch(TestData.data)
        // then
        XCTAssertFalse(successfully)
    }

    // MARK: Logging

    func testLoggerNotSendBatch() async {
        // given
        WBAnalytics.loggingOptions = .init(
            loggingEnabled: true,
            logRequests: false,
            logToFile: true,
            level: .info
        )
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertFalse(WBAnalytics.loggingOptions.logRequests)
        XCTAssertEqual(loggerMock.debugWasCalled, 0)
    }

    func testLoggerSendBatch() async {
        // given
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .info)
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertTrue(WBAnalytics.loggingOptions.logRequests)
        XCTAssertEqual(loggerMock.debugWasCalled, 1)
        XCTAssertEqual(loggerMock.debugReceivedLabel, TestData.logLabel)
    }

    func testLoggerErrorSendBatch() async {
        // given
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .info)
        sessionMock.dataForRequestErrorStub = CustomError.random
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertEqual(loggerMock.errorReceivedLabel, TestData.logLabel)
        XCTAssertTrue(
            loggerMock.errorReceivedMessage?.contains("failed request error: random") == true
        )
    }

    func testLoggerInfoSendBatch() async {
        // given
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .info)
        sessionMock.dataForRequestResponseStub = TestData.response(statusCode: 200)
        // when
        _ = await sender.sendBatch(TestData.data)
        // then
        XCTAssertEqual(loggerMock.infoReceivedLabel, TestData.logLabel)
        XCTAssertEqual(loggerMock.infoReceivedMessage, "request finished successfully")
    }
}

// MARK: - TestData

private extension BatchSenderImplTests {
    enum TestData {
        static let logLabel = "BatchSender"
        static let apiKey = "apiKey"
        static let queueLabel = "queue"
        static let data = Data()
        static let httpMethod = "POST"
        static let contentType = "application/json; charset=utf-8"
        static let forHTTPHeaderField = "X-Api-Key"
        static let url = URL(string: "https://a.wb.ru/m/batch")!
        static let urlTwo = URL(string: "https://example.com")!
        static let customHeaders = ["X-Custom-One": "valueOne", "X-Custom-Two": "valueTwo"]

        static func response(statusCode: Int) -> HTTPURLResponse {
            HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        }
    }

    enum CustomError: Error {
        case random
    }
}

// MARK: - Mirror

private extension BatchSenderImplTests {

    final class BatchSenderImplMirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: BatchSenderImpl) {
            super.init(reflecting: counter)
        }

        // And then we just declare the properties we want to test:
        var session: URLSessionProtocol! { extract() }
    }
}
