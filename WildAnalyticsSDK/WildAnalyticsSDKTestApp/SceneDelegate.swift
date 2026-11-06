// Copyright © 2026 WildAnalytics. All rights reserved.

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        #if os(tvOS)
        window.rootViewController = TestableViewControllerTV(testableViewIdentifier: "")
        #else
        window.rootViewController = TestableViewController(testableViewIdentifier: "")
        #endif
        window.makeKeyAndVisible()
        self.window = window
    }
}
