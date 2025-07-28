// Copyright © 2024 Wildberries. All rights reserved.

import UIKit
import WBMAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var window: UIWindow?

    var analytics1: WBMAnalytics = WBMAnalytics()
    var analytics2: WBMAnalytics = WBMAnalytics()

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

        let url = URL(string: "https://a.wb.ru/m/batch")!
        let apiKey = "ZAAAAAAAAAA="

        let reciever1 = WBAnalyticsReceiver(
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

        let apiKey2 = "hAMAAAAAAAA="
        let reciever2 = WBAnalyticsReceiver(
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

struct NetworkTypeProviderMock: NetworkTypeProviderProtocol {

    func getCurrentNetworkType() -> WBMNetworkType {
        .wifi
    }
}

extension AppDelegate: WBAnalyticsDelegateProtocol {
    func didResolveAttributedLink(_ link: URL) {
        print("[Attribution] RESOLVED LINK: \(link)")
    }
}
