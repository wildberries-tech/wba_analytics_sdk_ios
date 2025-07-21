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

        // Тестовая интеграция WBTracker.checkAttribution
        analytics1.checkAttribution { result in
            switch result {
            case .success(let response):
                guard let response else { return }
                print("[Attribution] Success: \(response)")
            case .failure(let error):
                print("[Attribution] Error: \(error)")
            }
        }

        window = UIWindow()
        window?.rootViewController = TestableViewController(testableViewIdentifier: "")
        window?.makeKeyAndVisible()
        return true
    }

    private func setupAnalytics() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")

        let url = URL(string: "https://a.wb.ru/m/batch")!
        let apiKey = "<apiKey1>"

        let reciever1 = WBAnalyticsReceiver(
            apiKey: apiKey,
            analyticsURL: url,
            isFirstLaunch: isFirstLaunch,
            loggingOptions: .init(loggingEnabled: true, logRequests: true, logToFile: true, level: .debug),
            networkTypeProvider: NetworkTypeProviderMock(),
            batchConfig: BatchConfig()
        )

        reciever1.setup()
        analytics1.registerReceiver(reciever1)

        let apiKey2 = "<apiKey2>"
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
