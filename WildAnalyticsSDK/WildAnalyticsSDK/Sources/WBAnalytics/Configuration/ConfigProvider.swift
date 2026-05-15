//  Copyright © 2024 Wildberries LLC. All rights reserved.

import Foundation

final class ConfigProvider {

    private enum Constants {
        static let logLabel = "ConfigProvider"
        static let configFilename = "default_config"
        static let configType = "json"
    }

    private let logger: Logger
    private(set) var currentConfig: Config
    private let bundle: Bundle

    init(logger: Logger, bundle: Bundle? = nil) {
        self.bundle = bundle ?? Bundle(for: Self.self)
        self.logger = logger
        currentConfig = DefaultConfig()
        if let config = self.readConfigFile() {
            currentConfig = config
        }
    }

    private func readConfigFile() -> Config? {
        if let path = bundle.path(forResource: Constants.configFilename, ofType: Constants.configType) {
            return readConfig(from: path)
        } else {
            logger.log(level: .error, label: Constants.logLabel, message: "Can't locate config file path")
        }
        return nil
    }

    private func readConfig(from path: String) -> Config? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return decodeConfig(data: data)
        } catch {
            logger.log(level: .error, label: Constants.logLabel, message: "Can't read config from file path: \(path)")
        }
        return nil
    }

    private func decodeConfig(data: Data) -> Config? {
        do {
            let config = try JSONDecoder().decode(DefaultConfig.self, from: data)
            return config
        } catch {
            logger.log(level: .error, label: Constants.logLabel, message: "Can't decode config data")
        }
        return nil
    }
}

// MARK: - For Unit tests

#if DEBUG
extension ConfigProvider {
    public static func forTestInit(logger: Logger = FileLogger(apiKey: "", logger: ConsoleLogger(apiKey: "")), bundle: Bundle? = nil) -> ConfigProvider {
        return ConfigProvider(logger: logger, bundle: bundle)
    }
}
#endif
