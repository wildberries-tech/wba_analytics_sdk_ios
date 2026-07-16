//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

public protocol URLSessionProtocol: AnyObject {
    var delegate: URLSessionDelegate? { get }
    var delegateQueue: OperationQueue { get }
    func dataTask(with request: URLRequest) -> URLSessionDataTask
    func dataTask(with url: URL) -> URLSessionDataTask
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, tvOS 15.0, *) {
            return try await data(for: request, delegate: nil)
        }
        // Backport for deployment targets below iOS 15 / tvOS 15.
        return try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data, let response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            task.resume()
        }
    }
}
