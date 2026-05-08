import UIKit
import WBMAnalytics

struct TestActions {
    static func addEvent() {
        AppDelegate.shared.analytics1.trackUserEngagement(UserEngagement(screenName: "Screen_name", textSize: nil, authType: "noAuth"), receiverIdentifier: "")
        AppDelegate.shared.analytics1.trackEvent(name: "add_to_cart_test", parameters: [
            "param1": "value1",
            "param2": "param2"
        ])
        AppDelegate.shared.analytics2.trackEvent(name: "add_to_cart_test_2", parameters: [
            "param1": "value1",
            "param2": "param2"
        ])
    }

    static func startEventTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            AppDelegate.shared.analytics1.trackEvent(name: "add_to_cart_test", parameters: [
                "param1": "value1",
                "param2": "param2"
            ])
            AppDelegate.shared.analytics2.trackEvent(name: "add_to_cart_test_2", parameters: [
                "param1": "value1",
                "param2": "param2"
            ])
        }
    }

    static func sendSyncEvent() {
        do {
            try AppDelegate.shared.analytics2.trackEventWithCompletion(
                name: "add_to_cart_fake",
                parameters: [
                    "card":"visa",
                    "pay": 123
                ],
                completion: {
                    print("add_to_cart_fake send with result \($0)")
                }
            )
        } catch {
            print(error)
        }
    }

    static func presentLogs(from presenter: UIViewController) {
//        let logVC = AppDelegate.shared.analytics1.showLogsViewController()
        let logVC = WBAnalytics.logsViewController(apiKeys: ["TestApiKey1","TestApiKey2="])
        let navVC = UINavigationController(rootViewController: logVC)
        presenter.present(navVC, animated: true)
    }
}
