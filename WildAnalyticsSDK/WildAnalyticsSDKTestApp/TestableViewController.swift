// Copyright © 2024 Wildberries. All rights reserved.

import UIKit
import WildAnalyticsSDK

final class TestableViewController: UIViewController {

    private let testableViewIdentifier: String
    private var timer: Timer?

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Event", for: .normal)
        button.addTarget(self, action: #selector(addEventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var enableTimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable events sending timer", for: .normal)
        button.addTarget(self, action: #selector(enableEventsendingButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var sendSyncButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send sync", for: .normal)
        button.addTarget(self, action: #selector(sendSyncEvent), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var showLogsPanelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show logs panel", for: .normal)
        button.addTarget(self, action: #selector(showLogsPanelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(testableViewIdentifier: String) {
        self.testableViewIdentifier = testableViewIdentifier
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButtons()
    }

    private func setupButtons() {
        view.addSubview(button)
        view.addSubview(enableTimerButton)
        view.addSubview(sendSyncButton)
        view.addSubview(showLogsPanelButton)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            enableTimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enableTimerButton.topAnchor.constraint(equalTo: button.bottomAnchor),

            sendSyncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendSyncButton.topAnchor.constraint(equalTo: enableTimerButton.bottomAnchor),

            showLogsPanelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showLogsPanelButton.topAnchor.constraint(equalTo: sendSyncButton.bottomAnchor),
        ])
    }

    @objc private func addEventButtonTapped() {
        TestActions.addEvent()
    }

    @objc private func enableEventsendingButtonTapped() {
        timer?.invalidate()
        timer = TestActions.startEventTimer()
    }

    @objc private func sendSyncEvent() {
        TestActions.sendSyncEvent()
    }

    @objc private func showLogsPanelButtonTapped() {
        TestActions.presentLogs(from: self)
    }
}
