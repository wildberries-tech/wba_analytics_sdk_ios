//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

class LoggerMock: Logger {
    private(set) var logReceivedLevel: LogLevel?
    private(set) var logReceivedLabel: String?
    private(set) var logReceivedMessage: String?
    private(set) var logWasCalled: Int = 0

    func log(level: LogLevel, label: String, message: String) {
        logReceivedLevel = level
        logReceivedLabel = label
        logReceivedMessage = message
        logWasCalled += 1
    }

    private(set) var debugReceivedLabel: String?
    private(set) var debugReceivedMessage: String?
    private(set) var debugWasCalled: Int = 0

    func debug(_ label: String, _ message: String) {
        debugReceivedLabel = label
        debugReceivedMessage = message
        debugWasCalled += 1
    }

    private(set) var infoReceivedLabel: String?
    private(set) var infoReceivedMessage: String?
    private(set) var infoWasCalled: Int = 0

    func info(_ label: String, _ message: String) {
        infoReceivedLabel = label
        infoReceivedMessage = message
        infoWasCalled += 1
    }

    private(set) var warningReceivedLabel: String?
    private(set) var warningReceivedMessage: String?
    private(set) var warningWasCalled: Int = 0

    func warning(_ label: String, _ message: String) {
        warningReceivedLabel = label
        warningReceivedMessage = message
        warningWasCalled += 1
    }

    private(set) var errorReceivedLabel: String?
    private(set) var errorReceivedMessage: String?
    private(set) var errorWasCalled: Int = 0

    func error(_ label: String, _ message: String) {
        errorReceivedLabel = label
        errorReceivedMessage = message
        errorWasCalled += 1
    }
}
