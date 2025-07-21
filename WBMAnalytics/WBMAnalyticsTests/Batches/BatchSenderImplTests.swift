//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

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
        let urlSessionDataTaskMock = URLSession(configuration: .default)
            .dataTask(with: .init(url: TestData.url))
        sessionMock.dataTaskWithRequestStub = urlSessionDataTaskMock
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

    func testDefaultParametrInit() {
        // given
        let mirror = BatchSenderImplMirror(reflecting: sender)
        // then
        XCTAssertTrue(mirror.completionForExecutingTaskIdentifier.isEmpty)
    }

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

    func testSetRequestParametersSendBatch() {
        // when
        sender.sendBatch(TestData.data) { _ in
        }
        // then
        XCTAssertEqual(sessionMock.dataTaskWithRequestReceivedRequest?.httpMethod, TestData.httpMethod)
        XCTAssertEqual(
            sessionMock.dataTaskWithRequestReceivedRequest?.allHTTPHeaderFields?["Content-Type"],
            TestData.contentType
        )
        XCTAssertEqual(
            sessionMock.dataTaskWithRequestReceivedRequest?.value(
                forHTTPHeaderField: TestData.forHTTPHeaderField
            ),
            TestData.apiKey
        )
        XCTAssertEqual(sessionMock.dataTaskWithRequestReceivedRequest?.httpBody, TestData.data)
        XCTAssertEqual(sessionMock.dataTaskWithRequestWasCalled, 1)
    }

    func testUsedIntercept() {
        // given
        requestInterceptorMock.interceptHandler = {
            $0.url = TestData.urlTwo
            $0.httpMethod = "GET"
        }
        // when
        sender.sendBatch(TestData.data) { _ in
        }
        // then
        XCTAssertEqual(requestInterceptorMock.interceptCallCount, 1)
        XCTAssertEqual(requestInterceptorMock.lastModifiedRequest?.httpMethod, "GET")
        XCTAssertEqual(requestInterceptorMock.lastModifiedRequest?.url, TestData.urlTwo)
        XCTAssertEqual(
            requestInterceptorMock.lastModifiedRequest?.value(forHTTPHeaderField: "Content-Type"),
            TestData.contentType
        )
    }

    func testSetCompletionParametersSendBatch() {
        // given
        let urlSessionDataTaskMock = URLSession(configuration: .default)
            .dataTask(with: .init(url: TestData.url))
        sessionMock.dataTaskWithRequestStub = urlSessionDataTaskMock
        let mirror = BatchSenderImplMirror(reflecting: sender)
        var completionWasCalled = 0
        var completionReceivedBool: Bool?
        let completion: (_ successfully: Bool) -> Void = { value in
            completionWasCalled += 1
            completionReceivedBool = value
        }
        sender.sendBatch(TestData.data, completion: completion)
        XCTAssertEqual(completionWasCalled, 0)
        XCTAssertNil(completionReceivedBool)
        // when
        mirror.completionForExecutingTaskIdentifier[urlSessionDataTaskMock.taskIdentifier]?(true)
        // then
        XCTAssertEqual(completionWasCalled, 1)
        XCTAssertEqual(completionReceivedBool, true)
    }

    func testLoggerNotSendBatch() {
        // given
        let sender: BatchSenderImpl = .init(
            apiKey: TestData.apiKey,
            analyticsURL: TestData.url,
            queue: queue,
            batchConfig: batchConfig,
            logger: loggerMock,
            interceptor: requestInterceptorMock
        )
        WBAnalytics.loggingOptions = .init(
            loggingEnabled: true,
            logRequests: false,
            logToFile: true,
            level: .info
        )
        // when
        sender.sendBatch(TestData.data) { _ in
        }
        // then
        XCTAssertFalse(WBAnalytics.loggingOptions.logRequests)
        XCTAssertEqual(loggerMock.debugWasCalled, 0)
    }

    func testLoggerSendBatch() {
        // given
        let sender: BatchSenderImpl = .init(
            apiKey: TestData.apiKey,
            analyticsURL: TestData.url,
            queue: queue,
            batchConfig: batchConfig,
            logger: loggerMock,
            interceptor: requestInterceptorMock
        )
        // when
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .info)
        sender.sendBatch(TestData.data) { _ in
        }
        // then
        XCTAssertTrue(WBAnalytics.loggingOptions.logRequests)
        XCTAssertEqual(loggerMock.debugWasCalled, 1)
        XCTAssertEqual(loggerMock.debugReceivedLabel, TestData.logLabel)
    }

    // MARK: UrlSession

    func testCompletionTrueUrlSessionTask() {
        // given
        let urlSessionDataTaskMock = URLSession(configuration: .default)
            .dataTask(with: .init(url: TestData.url))
        sessionMock.dataTaskWithRequestStub = urlSessionDataTaskMock
        let mirror = BatchSenderImplMirror(reflecting: sender)
        var completionWasCalled = 0
        var completionReceivedBool: Bool?
        let completion: (_ successfully: Bool) -> Void = { value in
            completionWasCalled += 1
            completionReceivedBool = value
        }
        sender.sendBatch(TestData.data, completion: completion)
        // when
        sender.urlSession(URLSession(configuration: .default), task: urlSessionDataTaskMock, didCompleteWithError: nil)
        // then
        XCTAssertEqual(loggerMock.debugWasCalled, 0)
        XCTAssertEqual(completionWasCalled, 1)
        XCTAssertEqual(completionReceivedBool, true)
        XCTAssertNil(mirror.completionForExecutingTaskIdentifier[urlSessionDataTaskMock.taskIdentifier])
    }

    func testCompletionFalseUrlSessionTask() {
        // given
        let urlSessionDataTaskMock = URLSession(configuration: .default)
            .dataTask(with: .init(url: TestData.url))
        sessionMock.dataTaskWithRequestStub = urlSessionDataTaskMock
        let mirror = BatchSenderImplMirror(reflecting: sender)
        var completionWasCalled = 0
        var completionReceivedBool: Bool?
        let completion: (_ successfully: Bool) -> Void = { value in
            completionWasCalled += 1
            completionReceivedBool = value
        }
        WBAnalytics.loggingOptions = .init(loggingEnabled: false, logRequests: false, logToFile: false, level: .info)
        sender.sendBatch(TestData.data, completion: completion)
        // when
        sender.urlSession(URLSession(configuration: .default), task: urlSessionDataTaskMock, didCompleteWithError: CustomError.random)
        // then
        XCTAssertEqual(loggerMock.debugWasCalled, 0)
        XCTAssertEqual(completionWasCalled, 1)
        XCTAssertEqual(completionReceivedBool, false)
        XCTAssertNil(mirror.completionForExecutingTaskIdentifier[urlSessionDataTaskMock.taskIdentifier])
    }

    func testLoggerErrorUrlSessionTask() {
        // given
        let urlSessionDataTaskMock = URLSession(configuration: .default)
            .dataTask(with: .init(url: TestData.url))
        // when
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .info)
        sender.urlSession(URLSession(configuration: .default), task: urlSessionDataTaskMock, didCompleteWithError: CustomError.random)
        // then
        XCTAssertEqual(loggerMock.debugWasCalled, .zero)
        XCTAssertEqual(loggerMock.errorReceivedLabel, TestData.logLabel)
        XCTAssertTrue(
            loggerMock.errorReceivedMessage?.contains("failed request with id: 1 error: random") == true
        )
    }

    func testLoggerInfoUrlSessionTask() {
        // given
        let urlSessionDataTaskMock = URLSession(configuration: .default)
            .dataTask(with: .init(url: TestData.url))
        // when
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .info)
        sender.urlSession(URLSession(configuration: .default), task: urlSessionDataTaskMock, didCompleteWithError: nil)
        // then
        XCTAssertEqual(loggerMock.debugWasCalled, .zero)
        XCTAssertEqual(loggerMock.infoReceivedLabel, TestData.logLabel)
        XCTAssertEqual(
            loggerMock.infoReceivedMessage,
            "request with id: \(urlSessionDataTaskMock.taskIdentifier) finished successfully"
        )
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
        var completionForExecutingTaskIdentifier: [Int: (_ successfully: Bool) -> Void]! { extract() }
    }
}
