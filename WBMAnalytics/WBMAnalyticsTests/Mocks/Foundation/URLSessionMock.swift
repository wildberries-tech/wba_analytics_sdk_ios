//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

@testable import WBMAnalytics

final class URLSessionMock: URLSessionProtocol {
    // MARK: - Lifecycle

    public init() { }

    // MARK: - delegate

    public private(set) var getDelegateWasCalled: Int = 0
    public private(set) var setDelegateWasCalled: Int = 0
    public var delegateStub: URLSessionDelegate?

    public var delegate: URLSessionDelegate? {
        get {
            getDelegateWasCalled += 1
            return delegateStub
        }
        set {
            setDelegateWasCalled += 1
            delegateStub = newValue
        }
    }

    // MARK: - delegateQueue

    public private(set) var getDelegateQueueWasCalled: Int = 0
    public private(set) var setDelegateQueueWasCalled: Int = 0
    public var delegateQueueStub: OperationQueue!

    public var delegateQueue: OperationQueue {
        get {
            getDelegateQueueWasCalled += 1
            return delegateQueueStub
        }
        set {
            setDelegateQueueWasCalled += 1
            delegateQueueStub = newValue
        }
    }

    // MARK: - dataTask

    public private(set) var dataTaskWithRequestWasCalled: Int = 0
    public private(set) var dataTaskWithRequestReceivedRequest: URLRequest?
    public var dataTaskWithRequestStub: URLSessionDataTask!

    public func dataTask(with request: URLRequest) -> URLSessionDataTask {
        dataTaskWithRequestWasCalled += 1
        dataTaskWithRequestReceivedRequest = request
        return dataTaskWithRequestStub
    }

    // MARK: - dataTask

    public private(set) var dataTaskWithURLWasCalled: Int = 0
    public private(set) var dataTaskWithURLReceivedURL: URL?
    public var dataTaskWithURLStub: URLSessionDataTask!

    public func dataTask(with url: URL) -> URLSessionDataTask {
        dataTaskWithURLWasCalled += 1
        dataTaskWithURLReceivedURL = url
        return dataTaskWithURLStub
    }
}
