//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

public protocol URLSessionProtocol: AnyObject {
    var delegate: URLSessionDelegate? { get }
    var delegateQueue: OperationQueue { get }
    func dataTask(with request: URLRequest) -> URLSessionDataTask
    func dataTask(with url: URL) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }
