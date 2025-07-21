// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

protocol BatchSender: NSObject {
    func setUserToken(_ token: String?)
    func sendBatch(_ requestData: Data, completion: @escaping (_ successfully: Bool) -> Void)
}

final class BatchSenderImpl: NSObject, BatchSender {

    private enum Constants {
        static let logLabel = "BatchSender"
        static let contentType = "application/json; charset=utf-8"
    }

    private let queue: DispatchQueue
    private let apiKey: String
    private let analyticsURL: URL
    private let batchConfig: BatchConfig
    private let logger: Logger
    private let interceptor: RequestInterceptor
    private var session: URLSessionProtocol?
    private var userToken: String?

    init(
        apiKey: String,
        analyticsURL: URL,
        queue: DispatchQueue,
        batchConfig: BatchConfig,
        logger: Logger,
        interceptor: RequestInterceptor,
        session: URLSessionProtocol? = nil
    ) {
        self.queue = queue
        self.apiKey = apiKey
        self.analyticsURL = analyticsURL
        self.batchConfig = batchConfig
        self.logger = logger
        self.interceptor = interceptor
        self.session = session

        super.init()

        if session == nil {
            self.session = configureSession()
        }
    }

    private var completionForExecutingTaskIdentifier: [Int: (_ successfully: Bool) -> Void] = [:]

    func setUserToken(_ token: String?) {
        self.userToken = token
    }

    func sendBatch(_ requestData: Data, completion: @escaping (_ successfully: Bool) -> Void) {
        var request = URLRequest(url: analyticsURL)
        request.httpMethod = "POST"
        request.addValue(Constants.contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        if let userToken {
            request.addValue(userToken, forHTTPHeaderField: "X-User-Token")
        }
        request.httpBody = requestData
        interceptor.intercept(request: &request)

        guard let task = session?.dataTask(with: request) else { return }
        completionForExecutingTaskIdentifier[task.taskIdentifier] = completion
        task.resume()

        guard WBAnalytics.loggingOptions.logRequests else { return }
        logger.debug(Constants.logLabel, "send request with id: \(task.taskIdentifier) cURL:\n\(request.cURL())")
    }

    private func completeTask(withIdentifier taskIdentifier: Int, successfully: Bool) {
        completionForExecutingTaskIdentifier[taskIdentifier]?(successfully)
        completionForExecutingTaskIdentifier[taskIdentifier] = nil
    }

    private func configureSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = batchConfig.requestTimeout
        configuration.timeoutIntervalForResource = batchConfig.requestTimeout

        let delegateQueue = OperationQueue()
        delegateQueue.underlyingQueue = queue
        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: delegateQueue
        )
    }
}

extension BatchSenderImpl: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let requestFinishedSuccessfully = error == nil
        if WBAnalytics.loggingOptions.logRequests {
            if let error {
                logger.error(
                    Constants.logLabel,
                    "failed request with id: \(task.taskIdentifier) error: \(error)"
                )
            } else {
                logger.info(
                    Constants.logLabel,
                    "request with id: \(task.taskIdentifier) finished successfully"
                )
            }
        }
        completeTask(withIdentifier: task.taskIdentifier, successfully: requestFinishedSuccessfully)
    }
}
