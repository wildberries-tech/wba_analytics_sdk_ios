//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

class LogFileHandlingMock: LoggerMock, LogFileHandling {

    var logFileURLStub: URL!
    private(set) var logFileURLWasCalled: Int = 0

    func logFileURL() -> URL? {
        logFileURLWasCalled += 1
        return logFileURLStub
    }

    private(set) var clearLogFileWasCalled: Int = 0

    func clearLogFile() {
        clearLogFileWasCalled += 1
    }

}
