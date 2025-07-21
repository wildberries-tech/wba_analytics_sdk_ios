//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class CompositeLoggerTests: XCTestCase {

    private var firstLoggerMock: LogFileHandlingMock!
    private var secondLoggerMock: LoggerMock!
    private var compositeLogger: CompositeLogger!

    override func setUp() {
        super.setUp()
        firstLoggerMock = .init()
        secondLoggerMock = .init()
        compositeLogger = .init(loggers: [firstLoggerMock, secondLoggerMock])
    }

    // MARK: Log

    func testLog() {
        // when
        compositeLogger.log(
            level: TestData.level,
            label: TestData.label,
            message: TestData.message
        )
        // then
        XCTAssertEqual(firstLoggerMock.logReceivedLevel, TestData.level)
        XCTAssertEqual(firstLoggerMock.logReceivedLabel, TestData.label)
        XCTAssertEqual(firstLoggerMock.logReceivedMessage, TestData.message)
        XCTAssertEqual(firstLoggerMock.logWasCalled, 1)
        XCTAssertEqual(secondLoggerMock.logReceivedLevel, TestData.level)
        XCTAssertEqual(secondLoggerMock.logReceivedLabel, TestData.label)
        XCTAssertEqual(secondLoggerMock.logReceivedMessage, TestData.message)
        XCTAssertEqual(secondLoggerMock.logWasCalled, 1)
    }

    // MARK: logFileURL

    func testLogFileURL() {
        // given
        firstLoggerMock.logFileURLStub = TestData.url
        // when
        let url = compositeLogger.logFileURL()
        // then
        XCTAssertEqual(firstLoggerMock.logFileURLWasCalled, 1)
        XCTAssertEqual(url, TestData.url)
    }

    func testUrlEqualNilLogFileURL() {
        // given
        let compositeLogger = CompositeLogger(loggers: [secondLoggerMock])
        // when
        let url = compositeLogger.logFileURL()
        // then
        XCTAssertNil(url)
    }

    // MARK: clearLogFile

    func testClearLogFile() {
        // given
        let compositeLogger = CompositeLogger(loggers: [firstLoggerMock, firstLoggerMock])
        // when
        compositeLogger.clearLogFile()
        // then
        XCTAssertEqual(firstLoggerMock.clearLogFileWasCalled, 2)
    }

}

// MARK: - TestData

private extension CompositeLoggerTests {
    enum TestData {
        static let level: LogLevel = .debug
        static let label = "label"
        static let message = "message"
        static let url = URL(string: "example.com")!
    }
}
