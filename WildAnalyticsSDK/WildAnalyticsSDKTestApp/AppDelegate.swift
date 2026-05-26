// Copyright © 2024 Wildberries. All rights reserved.

import UIKit
import WildAnalyticsSDK

#if os(tvOS)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static var shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var analytics1: WildAnalyticsSDK = WildAnalyticsSDK()
    var analytics2: WildAnalyticsSDK = WildAnalyticsSDK()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupAnalytics()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TestableViewControllerTV(testableViewIdentifier: "")
        window?.makeKeyAndVisible()
        return true
    }

    private func setupAnalytics() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")
        let url = URL(string: "https://wba.wb.ru/m/batch")!
        let apiKey = "TestApiKey1"
        let reciever1 = WildAnalyticsReceiver(
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
        let reciever2 = WildAnalyticsReceiver(
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

    var window: UIWindow?

    var analytics1: WildAnalyticsSDK = WildAnalyticsSDK()
    var analytics2: WildAnalyticsSDK = WildAnalyticsSDK()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        setupAnalytics()

        window = UIWindow()
        window?.rootViewController = TestableViewController(testableViewIdentifier: "")
        window?.makeKeyAndVisible()
        return true
    }

    private func setupAnalytics() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")

        let url = URL(string: "https://wba.wb.ru/m/batch")!
        let apiKey = "TestApiKey1"

        let reciever1 = WildAnalyticsReceiver(
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
        let reciever2 = WildAnalyticsReceiver(
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

    func getCurrentNetworkType() -> WildNetworkType {
        .wifi
    }
}

extension AppDelegate: WildAnalyticsDelegateProtocol {
    func didResolveAttributedLink(_ link: URL) {
        print("[Attribution] RESOLVED LINK: \(link)")
    }
}
