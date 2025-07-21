//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

public class FileManagerMock: FileManagerProtocol {

    public private(set) var removeItemAtWasCalled = 0
    public private(set) var removeItemAtReceivedArguments: URL!
    public var removeItemAtStub: Error?

    public func removeItem(at path: URL) throws {
        removeItemAtWasCalled += 1
        removeItemAtReceivedArguments = path

        if let error = removeItemAtStub {
            throw error
        }
    }

    public private(set) var urlWasCalled = 0
    public private(set) var urlReceivedArguments: (
        directory: FileManager.SearchPathDirectory,
        domain: FileManager.SearchPathDomainMask,
        appropriateFor: URL?,
        shouldCreate: Bool
    )!

    public var urlStub: URL?
    public var urlErrorStub: Error?

    public func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL {
        urlWasCalled += 1
        urlReceivedArguments = (directory, domain, url, shouldCreate)

        if let urlErrorStub {
            throw urlErrorStub
        } else {
            return urlStub!
        }
    }

    // MARK: - attributesOfItem

    public private(set) var attributesOfItemWasCalled = 0
    public private(set) var attributesOfItemReceivedAtPath: String!
    public var attributesOfItemStub: [FileAttributeKey: Any]?
    public var attributesOfItemErrorStub: Error?

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        attributesOfItemWasCalled += 1
        attributesOfItemReceivedAtPath = path

        if let error = attributesOfItemErrorStub {
            throw error
        } else {
            return attributesOfItemStub!
        }
    }

    // MARK: - createFile

    public private(set) var createFileWasCalled = 0
    public private(set) var createFileReceivedArguments: (
        atPath: String,
        contents: Data?,
        attributes: [FileAttributeKey: Any]?
    )?
    public var createFileStub = false

    public func createFile(
        atPath: String,
        contents: Data?,
        attributes: [FileAttributeKey: Any]?
    ) -> Bool {
        createFileWasCalled += 1
        createFileReceivedArguments = (atPath, contents, attributes)
        return createFileStub
    }

    // MARK: - createDirectory

    public private(set) var createDirectoryWasCalled = 0
    public private(set) var createDirectoryReceivedArguments: (
        url: URL,
        createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    )?

    public func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        createDirectoryWasCalled += 1
        createDirectoryReceivedArguments = (url, createIntermediates, attributes)
    }

    // MARK: - contents

    public private(set) var contentsWasCalled = 0
    public private(set) var contentsReceivedArgument: String?
    public var contentsStub: Data?

    public func contents(atPath path: String) -> Data? {
        contentsWasCalled += 1
        contentsReceivedArgument = path
        return contentsStub
    }

    // MARK: - urls

    public private(set) var urlsWasCalled = 0
    public private(set) var urlsReceivedArguments: (
        directory: FileManager.SearchPathDirectory,
        domainMask: FileManager.SearchPathDomainMask
    )?
    public var urlsStub = [URL]()

    public func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL] {
        urlsWasCalled += 1
        urlsReceivedArguments = (directory, domainMask)
        return urlsStub
    }

    // MARK: - fileExists

    public private(set) var fileExistsWasCalled = 0
    public private(set) var fileExistsReceivedArguments: String?
    public var fileExistsStub = false

    public func fileExists(atPath path: String) -> Bool {
        fileExistsWasCalled += 1
        fileExistsReceivedArguments = path
        return fileExistsStub
    }

    // MARK: - removeItem

    public private(set) var removeItemWasCalled = 0
    public private(set) var removeItemReceivedArguments: String?
    public private(set) var removeItemReceivedArgumentsHistory: [String] = []
    public var removeItemResultStub = false

    public func removeItem(atPath path: String) throws {
        removeItemWasCalled += 1
        removeItemReceivedArguments = path
        removeItemReceivedArgumentsHistory.append(path)
        guard removeItemResultStub else { throw ErrorMock() }
    }

    // MARK: - moveItem

    public private(set) var moveItemAtToThrowableError: Error?
    public private(set) var moveItemAtToWasCalled: Int = 0
    public private(set) var moveItemAtToReceivedArguments: (srcURL: URL, dstURL: URL)?

    public func moveItem(at srcURL: URL, to dstURL: URL) throws {
        if let error = moveItemAtToThrowableError { throw error }
        moveItemAtToWasCalled += 1
        moveItemAtToReceivedArguments = (srcURL: srcURL, dstURL: dstURL)
    }

    // MARK: - copyItem

    public private(set) var copyItemAtToThrowableError: Error?
    public private(set) var copyItemAtToWasCalled: Int = 0
    public private(set) var copyItemAtToReceivedArguments: (srcURL: URL, dstURL: URL)?

    public func copyItem(at srcURL: URL, to dstURL: URL) throws {
        copyItemAtToWasCalled += 1
        copyItemAtToReceivedArguments = (srcURL: srcURL, dstURL: dstURL)
        if let error = copyItemAtToThrowableError { throw error }
    }

    // MARK: - init

    public init() { }
}

class ErrorMock: Error { }
