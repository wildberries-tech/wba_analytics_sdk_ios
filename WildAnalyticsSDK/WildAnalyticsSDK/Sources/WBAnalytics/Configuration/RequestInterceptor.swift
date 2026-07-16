//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

import Foundation

public protocol RequestInterceptor {
    func intercept(request: inout URLRequest) async
}

public final class NoOpInterceptor: RequestInterceptor {
    public func intercept(request: inout URLRequest) async {

    }

    public init() {}
}
