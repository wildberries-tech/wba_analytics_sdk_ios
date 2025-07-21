//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

@testable import WBMAnalytics

final class RequestInterceptorMock: RequestInterceptor {

    // MARK: - intercept(request:)

    private(set) var interceptCallCount = 0
    private(set) var interceptedRequests: [URLRequest] = []
    private(set) var lastModifiedRequest: URLRequest?

    var interceptHandler: ((inout URLRequest) -> Void)?

    func intercept(request: inout URLRequest) {
        interceptCallCount += 1

        interceptedRequests.append(request)
        interceptHandler?(&request)
        lastModifiedRequest = request
    }
}
