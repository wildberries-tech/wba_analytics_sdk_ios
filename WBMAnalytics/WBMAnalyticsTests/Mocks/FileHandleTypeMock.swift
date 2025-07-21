//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class FileHandleTypeMock: FileHandleProtocol {

    static func reset() {
        FileHandleTypeMock.initErrorStub = nil
        initReceivedForWritingTo = nil
        initWasCalled = 0
        writeContentsOfReceivedData = nil
        writeContentsOfWasCalled = 0
        writeContentsOfErrorStub = nil

    }

    private(set) var seekToEndOfFileWasCalled: Int = 0
    var seekToEndOfFileStub: UInt64 = 0

    func seekToEndOfFile() -> UInt64 {
        seekToEndOfFileWasCalled += 1
        return seekToEndOfFileStub
    }

    private(set) var writeWasCalled: Int = 0
    private(set) var writeReceivedData: Data?

    func write(_ data: Data) {
        writeWasCalled += 1
        writeReceivedData = data
    }

    private(set) static var initReceivedForWritingTo: URL?
    private(set) static var initWasCalled: Int = 0
    static var initErrorStub: Error?

    init(forWritingTo url: URL) throws {
        FileHandleTypeMock.initReceivedForWritingTo = url
        FileHandleTypeMock.initWasCalled += 1

        if let error = FileHandleTypeMock.initErrorStub {
            throw error
        }
    }

    private(set) static var writeContentsOfReceivedData: Data?
    private(set) static var writeContentsOfWasCalled: Int = 0
    static var writeContentsOfErrorStub: Error?

    @available(iOS 13.4, *)
    func write<T>(contentsOf data: T) throws where T : DataProtocol {
        FileHandleTypeMock.writeContentsOfReceivedData = Data(data)
        FileHandleTypeMock.writeContentsOfWasCalled += 1

        if let error = FileHandleTypeMock.writeContentsOfErrorStub {
            throw error
        }
    }

    init() { }
}
