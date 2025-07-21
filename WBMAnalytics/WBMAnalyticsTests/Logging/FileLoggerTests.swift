//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest

@testable import WBMAnalytics

final class FileLoggerTests: XCTestCase {

    private var fileQueue: DispatchQueue!
    private var fileHandleMock: FileHandleTypeMock!
    private var fileHandleTypeMock: FileHandleTypeMock.Type!
    private var fileManagerMock: FileManagerMock!
    private var loggerMock: LoggerMock!
    private var testApiKey = "TestApiKey"

    override func setUp() {
        super.setUp()
        fileQueue = .init(label: TestData.queueName)
        fileHandleMock = .init()
        loggerMock = .init()
        fileHandleTypeMock = FileHandleTypeMock.self
        fileManagerMock = .init()
        fileManagerMock.urlStub = TestData.urlPath
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug)
    }

    override func tearDown() {
        fileHandleTypeMock.reset()
        super.tearDown()
    }

    // MARK: Init

    func testDefaultParameterInit() {
        // when
        let logger = FileLogger(apiKey: testApiKey, logger: loggerMock)
        let mirror = Mirror(reflecting: logger)
        // then
        XCTAssertEqual(mirror.fileManager as? FileManager, FileManager.default)
        XCTAssertEqual(mirror.fileQueue.label, TestData.queueName)
        XCTAssertIdentical(mirror.fileHandleType, FileHandle.self)
    }

    func testInitializeLogFileInit() {
        // given
        fileManagerMock.fileExistsStub = true
        // when
        _ = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        // then
        XCTAssertEqual(fileManagerMock.fileExistsWasCalled, 1)
        XCTAssertEqual(fileManagerMock.urlWasCalled, 1)
        XCTAssertEqual(
            fileManagerMock.urlReceivedArguments.directory,
            TestData.urlArgument.directory
        )
        XCTAssertEqual(
            fileManagerMock.urlReceivedArguments.domain,
            TestData.urlArgument.domain
        )
        XCTAssertTrue(
            fileManagerMock.urlReceivedArguments.shouldCreate
        )
        XCTAssertNil(
            fileManagerMock.urlReceivedArguments.appropriateFor
        )
        XCTAssertEqual(fileManagerMock.fileExistsReceivedArguments, TestData.urlPathFull.description)
        XCTAssertEqual(fileManagerMock.createFileWasCalled, 0)
    }

    func testInitializeLogFileFileExistsInit() {
        // given
        // when
        _ = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        // then
        XCTAssertEqual(fileManagerMock.createFileWasCalled, 1)
        XCTAssertEqual(
            fileManagerMock.createFileReceivedArguments?.atPath,
            TestData.urlPathFull.description
        )
        XCTAssertNil(fileManagerMock.createFileReceivedArguments?.contents)
        XCTAssertNil(fileManagerMock.createFileReceivedArguments?.attributes)
    }

    func testFileHandeInit() {
        // given
        fileManagerMock.fileExistsStub = true
        // when
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        let mirror = Mirror(reflecting: logger)
        let fileHandleMock = mirror.fileHandle as? FileHandleTypeMock
        // then
        XCTAssertEqual(fileHandleTypeMock.initReceivedForWritingTo, TestData.urlPathFull)
        XCTAssertEqual(fileHandleTypeMock.initWasCalled, 1)
        XCTAssertNotNil(fileHandleMock)
        XCTAssertEqual(fileHandleMock?.seekToEndOfFileWasCalled, 1)
    }

    func testFileHandeErrorInit() {
        // given
        fileHandleTypeMock.initErrorStub = CustomError.random
        // when
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        let mirror = Mirror(reflecting: logger)
        let fileHandleMock = mirror.fileHandle as? FileHandleTypeMock
        // then
        XCTAssertEqual(fileHandleTypeMock.initReceivedForWritingTo, TestData.urlPathFull)
        XCTAssertEqual(fileHandleTypeMock.initWasCalled, 1)
        XCTAssertNil(fileHandleMock)
        XCTAssertEqual(loggerMock.errorWasCalled, 1)
        XCTAssertEqual(loggerMock.errorReceivedLabel, "FileLogger")
        XCTAssertEqual(loggerMock.errorReceivedMessage, "Failed to open log file: random")
    }

    // MARK: Log

    func testClearLogFileSuccessLog() {
        // given
        fileManagerMock.fileExistsStub = true
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug)
        fileManagerMock.createFileStub = true
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertTrue(WBAnalytics.loggingOptions.loggingEnabled)
        XCTAssertTrue(WBAnalytics.loggingOptions.logToFile)
        XCTAssertEqual(fileManagerMock.attributesOfItemWasCalled, 1)
        XCTAssertEqual(fileManagerMock.attributesOfItemReceivedAtPath, TestData.urlPathFull.description)
        XCTAssertEqual(fileManagerMock.removeItemAtWasCalled, 1)
        XCTAssertEqual(fileManagerMock.removeItemAtReceivedArguments, TestData.urlPathFull)
        XCTAssertEqual(fileManagerMock.createFileWasCalled, 1)
        if #available(iOS 16.0, *) {
            XCTAssertEqual(fileManagerMock.createFileReceivedArguments?.atPath, TestData.urlPathFull.path())
        } else {
            XCTAssertEqual(fileManagerMock.createFileReceivedArguments?.atPath, "path/WBAnalytics.log")
        }
        XCTAssertNil(fileManagerMock.createFileReceivedArguments?.contents)
        XCTAssertNil(fileManagerMock.createFileReceivedArguments?.attributes)
        XCTAssertEqual(loggerMock.logWasCalled, 0)
    }

    func testClearLogFileErrorLog() {
        // given
        fileManagerMock.fileExistsStub = true
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug)
        fileManagerMock.createFileStub = true
        fileManagerMock.removeItemAtStub = CustomError.random
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(fileManagerMock.removeItemAtWasCalled, 1)
        XCTAssertEqual(fileManagerMock.removeItemAtReceivedArguments, TestData.urlPathFull)
        XCTAssertEqual(fileManagerMock.createFileWasCalled, 1)
        if #available(iOS 16.0, *) {
            XCTAssertEqual(fileManagerMock.createFileReceivedArguments?.atPath, TestData.urlPathFull.path())
        } else {
            XCTAssertEqual(fileManagerMock.createFileReceivedArguments?.atPath, "path/WBAnalytics.log")
        }
        XCTAssertNil(fileManagerMock.createFileReceivedArguments?.contents)
        XCTAssertNil(fileManagerMock.createFileReceivedArguments?.attributes)
        XCTAssertEqual(loggerMock.logWasCalled, 1)
        XCTAssertEqual(loggerMock.logReceivedLabel, TestData.logLabel)
        XCTAssertEqual(loggerMock.logReceivedLevel, .error)
        XCTAssertEqual(loggerMock.logReceivedMessage, "failed to remove file at url: \(TestData.urlPathFull)")
    }

    func testMaxFileSizeLog() {
        // given
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemMaxSizeStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        let logMessage = "[\(testApiKey)][\(Date().asString)][\(TestData.label)][\(LogLevel.debug)]: \(TestData.message)\n"
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug)
        fileManagerMock.createFileStub = true
        fileManagerMock.removeItemAtStub = CustomError.random
        let mirror = Mirror(reflecting: logger)
        let fileHandleMock = mirror.fileHandle as? FileHandleTypeMock
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertNotNil(fileHandleMock)
        XCTAssertEqual(fileHandleTypeMock?.writeContentsOfWasCalled, 1)
        // swiftlint:disable non_optional_string_data_conversion
        XCTAssertEqual(
            String(
                data: fileHandleTypeMock!.writeContentsOfReceivedData!,
                encoding: .utf8
            ),
            logMessage
        )
        XCTAssertEqual(fileManagerMock.removeItemAtWasCalled, 0)
    }

    func testLoggingOptionsLoggingEnabledLog() {
        // given
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemMaxSizeStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        WBAnalytics.loggingOptions = .init(loggingEnabled: false, logRequests: true, logToFile: true, level: .debug)
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(fileManagerMock.attributesOfItemWasCalled, 0)
        XCTAssertEqual(fileManagerMock.removeItemAtWasCalled, 0)
    }

    func testCheckFileSizeAndClearCatchLog() {
        // given
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemMaxSizeStub
        fileManagerMock.attributesOfItemErrorStub = CustomError.random
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(fileManagerMock.removeItemWasCalled, 0)
        XCTAssertEqual(loggerMock.logWasCalled, 1)
        XCTAssertEqual(loggerMock.logReceivedLabel, TestData.logLabel)
        if #available(iOS 16.0, *) {
            XCTAssertEqual(
                loggerMock.logReceivedMessage,
                "cannot get attributes from path: \(TestData.urlPathFull.path())"
            )
        } else {
            XCTAssertEqual(
                loggerMock.logReceivedMessage,
                "cannot get attributes from path: path/WBAnalytics.log"
            )
        }

    }

    func testLoggingOptionslogToFileLog() {
        // given
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemMaxSizeStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: false, level: .debug)
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(fileManagerMock.attributesOfItemWasCalled, 0)
        XCTAssertEqual(fileManagerMock.removeItemAtWasCalled, 0)
    }

    func testLoggingOptionsLevelRawValueLog() {
        // given
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemMaxSizeStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        WBAnalytics.loggingOptions = .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .error)
        // when
        logger.log(level: .debug, label: TestData.label, message: TestData.message)
        sleep(milliseconds: 100)
        // then
        XCTAssertEqual(fileManagerMock.attributesOfItemWasCalled, 0)
        XCTAssertEqual(fileManagerMock.removeItemAtWasCalled, 0)
    }

    // MARK: logFileURL

    func testLogFileURL() {
        // given
        fileManagerMock.attributesOfItemStub = TestData.attributesOfItemMaxSizeStub
        let logger = FileLogger(
            apiKey: testApiKey,
            fileManager: fileManagerMock,
            fileQueue: fileQueue,
            fileHandleType: fileHandleTypeMock,
            logger: loggerMock
        )
        // then
        XCTAssertEqual(logger.logFileURL(), TestData.urlPathFull)
    }
}

private extension FileLoggerTests {
    enum TestData {
        static let label = "label"
        static let attributesOfItemStub: [FileAttributeKey: Any] = [.size: UInt64(5 * 1024 * 1024)]
        static let attributesOfItemMaxSizeStub: [FileAttributeKey: Any] = [.size: UInt64(5 * 1024 * 1024 - 1)]
        static let message = "message"
        static let queueName = "WBAnalytics.log.FileLoggerQueue"
        static let logLabel = "FileLogger"
        static let urlPath = URL(string: "path/")!
        static let urlPathFull = URL(string: "path/WBAnalytics.log")!
        static let writeData: Data = (urlPathFull.description + "\n").data(using: .utf8)!
        static let urlArgument: (
            directory: FileManager.SearchPathDirectory,
            domain: FileManager.SearchPathDomainMask,
            appropriateFor: URL?,
            shouldCreate: Bool
        ) = (.cachesDirectory, .userDomainMask, nil, true)
    }

    enum CustomError: Error {
        case random
    }
}

// MARK: - Mirror

private extension FileLoggerTests {

    final class Mirror: MirrorObject {
        // We create a custom init that calls super with the custom object
        init(reflecting counter: FileLogger) {
            super.init(reflecting: counter)
        }

        var fileQueue: DispatchQueue! { extract() }
        var fileHandle: FileHandleProtocol? { extract() }
        var fileHandleType: FileHandle.Type! { extract() }
        var fileManager: FileManagerProtocol! { extract() }
        var logger: Logger! { extract() }
    }
}
