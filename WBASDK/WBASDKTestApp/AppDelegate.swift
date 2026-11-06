// Copyright © 2024 WBA. All rights reserved.

import UIKit
import WBASDK

#if os(tvOS)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var analytics1: WBASDK = WBASDK()
    var analytics2: WBASDK = WBASDK()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupAnalytics()
        return true
    }

    private func setupAnalytics() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")
        let url = URL(string: "https://wba.wb.ru/m/batch")!
        let apiKey = "TestApiKey1"
        let reciever1 = WBAReceiver(
            apiKey: apiKey,
            analyticsURL: url,
            isFirstLaunch: isFirstLaunch,
            enableAttributionTracking: true,
            loggingOptions: .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug),
            networkTypeProvider: NetworkTypeProviderMock(),
            batchConfig: BatchConfig(),
            delegate: self
        )
        reciever1.setup()
        analytics1.registerReceiver(reciever1)
        let apiKey2 = "TestApiKey2="
        let reciever2 = WBAReceiver(
            apiKey: apiKey2,
            analyticsURL: url,
            isFirstLaunch: isFirstLaunch,
            loggingOptions: .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug),
            networkTypeProvider: NetworkTypeProviderMock(),
            batchConfig: BatchConfig()
        )
        reciever2.setup()
        analytics2.registerReceiver(reciever2)
        analytics1.setUserToken("TEST TOKEN")
    }
}
#else
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var analytics1: WBASDK = WBASDK()
    var analytics2: WBASDK = WBASDK()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        setupAnalytics()
        return true
    }

    private func setupAnalytics() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")

        let url = URL(string: "https://wba.wb.ru/m/batch")!
        let apiKey = "TestApiKey1"

        let reciever1 = WBAReceiver(
            apiKey: apiKey,
            analyticsURL: url,
            isFirstLaunch: isFirstLaunch,
            enableAttributionTracking: true,
            enableAutomaticEvents: true,
            loggingOptions: .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug),
            networkTypeProvider: NetworkTypeProviderMock(),
            batchConfig: BatchConfig(),
            delegate: self
        )

        reciever1.setup()
        analytics1.registerReceiver(reciever1)

        let apiKey2 = "TestApiKey2="
        let reciever2 = WBAReceiver(
            apiKey: apiKey2,
            analyticsURL: url,
            isFirstLaunch: isFirstLaunch,
            loggingOptions: .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug),
            networkTypeProvider: NetworkTypeProviderMock(),
            batchConfig: BatchConfig()
        )

        reciever2.setup()
        analytics2.registerReceiver(reciever2)
        analytics1.setUserToken("TEST TOKEN")
    }
}
#endif

struct NetworkTypeProviderMock: NetworkTypeProviderProtocol {

    func getCurrentNetworkType() -> WBANetworkType {
        .wifi
    }
}

extension AppDelegate: WBADelegateProtocol {
    func didResolveAttributedLink(_ link: URL) {
        print("[Attribution] RESOLVED LINK: \(link)")
    }
}
