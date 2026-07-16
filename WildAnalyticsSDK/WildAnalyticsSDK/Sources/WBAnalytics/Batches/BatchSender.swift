// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

protocol BatchSender: NSObject {
    func setUserToken(_ token: String?)
    func setCustomHeaders(_ headers: [String: String])
    func sendBatch(_ requestData: Data) async -> Bool
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
    private let sessionDelegate: URLSessionDelegate?
    private var session: URLSessionProtocol?
    private var userToken: String?
    private var customHeaders: [String: String] = [:]

    init(
        apiKey: String,
        analyticsURL: URL,
        queue: DispatchQueue,
        batchConfig: BatchConfig,
        logger: Logger,
        interceptor: RequestInterceptor,
        sessionDelegate: URLSessionDelegate? = nil,
        session: URLSessionProtocol? = nil
    ) {
        self.queue = queue
        self.apiKey = apiKey
        self.analyticsURL = analyticsURL
        self.batchConfig = batchConfig
        self.logger = logger
        self.interceptor = interceptor
        self.sessionDelegate = sessionDelegate
        self.session = session

        super.init()

        if session == nil {
            self.session = configureSession()
        }
    }

    func setUserToken(_ token: String?) {
        self.userToken = token
    }

    func setCustomHeaders(_ headers: [String: String]) {
        self.customHeaders = headers
    }

    func sendBatch(_ requestData: Data) async -> Bool {
        var request = URLRequest(url: analyticsURL)
        request.httpMethod = "POST"
        request.addValue(Constants.contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        if let userToken {
            request.addValue(userToken, forHTTPHeaderField: "X-User-Token")
        }
        for (key, value) in customHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = requestData
        await interceptor.intercept(request: &request)

        guard let session else { return false }

        if WBAnalytics.loggingOptions.logRequests {
            logger.debug(Constants.logLabel, "send request cURL:\n\(request.cURL())")
        }

        do {
            let (_, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let successfully = (200..<400).contains(statusCode)
            if WBAnalytics.loggingOptions.logRequests {
                if successfully {
                    logger.info(Constants.logLabel, "request finished successfully")
                } else {
                    logger.error(Constants.logLabel, "request failed with status code: \(statusCode)")
                }
            }
            return successfully
        } catch {
            if WBAnalytics.loggingOptions.logRequests {
                logger.error(Constants.logLabel, "failed request error: \(error)")
            }
            return false
        }
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

    /// Forwards session-level authentication challenges (e.g. SSL pinning) to the host-provided delegate.
    /// Falls back to default handling when the host does not handle the challenge.
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            let sessionDelegate,
            sessionDelegate.responds(to: #selector(URLSessionDelegate.urlSession(_:didReceive:completionHandler:)))
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        sessionDelegate.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
    }

    /// Forwards task-level authentication challenges to the host-provided delegate.
    /// Falls back to default handling when the host does not handle the challenge.
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            let taskDelegate = sessionDelegate as? URLSessionTaskDelegate,
            taskDelegate.responds(to: #selector(URLSessionTaskDelegate.urlSession(_:task:didReceive:completionHandler:)))
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        taskDelegate.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
}
