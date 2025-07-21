// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

final class FileLogger: Logger {

    private enum Constants {
        static let maxFileSize: UInt64 = 5 * 1024 * 1024 // 5 MB
        static let logLabel = "FileLogger"
        static let logFileName = "WBAnalytics.log"
        static let queueName = "WBAnalytics.log.FileLoggerQueue"
    }

    private let fileQueue: DispatchQueue
    private var fileHandle: FileHandleProtocol?
    private let fileHandleType: FileHandleProtocol.Type
    private let fileManager: FileManagerProtocol
    private let logger: Logger
    private let apiKey: String

    private lazy var fileURL: URL = {
        let baseURL = (try? fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? URL(fileURLWithPath: "")
        return baseURL.appendingPathComponent(Constants.logFileName)
    }()

    init(
        apiKey: String,
        fileManager: FileManagerProtocol = FileManager.default,
        fileQueue: DispatchQueue = DispatchQueue(label: Constants.queueName),
        fileHandleType: FileHandleProtocol.Type = FileHandle.self,
        logger: Logger
    ) {
        self.apiKey = apiKey
        self.fileManager = fileManager
        self.fileQueue = fileQueue
        self.fileHandleType = fileHandleType
        self.logger = logger

        initializeLogFile()
        do {
            fileHandle = try fileHandleType.init(forWritingTo: fileURL)
            fileHandle?.seekToEndOfFile()
        } catch {
            logger.error(Constants.logLabel, "Failed to open log file: \(error)")
        }
    }

    func log(level: LogLevel, label: String, message: String) {
        guard WBAnalytics.loggingOptions.loggingEnabled,
                WBAnalytics.loggingOptions.logToFile,
                level.rawValue >= WBAnalytics.loggingOptions.level.rawValue else { return }

        let logMessage = "[\(apiKey)][\(Date().asString)][\(label)][\(level)]: \(message)"

        fileQueue.async {
            self.checkFileSizeAndClear()
            self.appendLogToFile(logMessage: logMessage)
        }
    }

    private func initializeLogFile() {
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
    }

    private func checkFileSizeAndClear() {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? UInt64, fileSize >= Constants.maxFileSize {
                clearLogFile()
            }
        } catch {
            logger.log(
                level: .error,
                label: Constants.logLabel ,
                message: "cannot get attributes from path: \(fileURL.path)"
            )
        }
    }

    private func appendLogToFile(logMessage: String) {
        guard let fileHandle else { return }
        if let data = (logMessage + "\n").data(using: .utf8) {
            if #available(iOS 13.4, *) {
                try? fileHandle.write(contentsOf: data)
            } else {
                fileHandle.write(data)
            }
        }
    }
}

// MARK: - LogFileHandling

extension FileLogger: LogFileHandling {

    func logFileURL() -> URL? {
        return fileURL
    }

    func clearLogFile() {
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            logger.log(level: .error, label: Constants.logLabel, message: "failed to remove file at url: \(fileURL)")
        }
        fileManager.createFile(
            atPath: fileURL.path,
            contents: nil,
            attributes: nil
        )
    }
}
