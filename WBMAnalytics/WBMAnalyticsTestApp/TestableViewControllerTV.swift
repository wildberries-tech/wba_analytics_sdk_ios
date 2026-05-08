import UIKit
import WBMAnalytics

final class TestableViewControllerTV: UIViewController {

    private let testableViewIdentifier: String
    private var timer: Timer?

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Event", for: .normal)
        button.addTarget(self, action: #selector(addEventButtonTapped), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var enableTimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable events sending timer", for: .normal)
        button.addTarget(self, action: #selector(enableEventsendingButtonTapped), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var sendSyncButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send sync", for: .normal)
        button.addTarget(self, action: #selector(sendSyncEvent), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var showLogsPanelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show logs panel (iOS only)", for: .normal)
        button.addTarget(self, action: #selector(presentLogs), for: .primaryActionTriggered)
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
        view.backgroundColor = .black
        setupButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }

    private func setupButtons() {
        let stack = UIStackView(arrangedSubviews: [button, enableTimerButton, sendSyncButton, showLogsPanelButton])
        stack.axis = .vertical
        stack.spacing = 48
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        // Style buttons for tvOS focus visibility
        [button, enableTimerButton, sendSyncButton, showLogsPanelButton].forEach { style(button: $0) }

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [button]
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

    @objc private func presentLogs() {
        TestActions.presentLogs(from: self)
    }

    // MARK: - Focus styling

    private func style(button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.6)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 22, left: 44, bottom: 22, right: 44)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.isUserInteractionEnabled = true
        button.alpha = 0.9
    }

    private func applyFocus(_ focused: Bool, to button: UIButton, coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            button.transform = focused ? CGAffineTransform(scaleX: 1.06, y: 1.06) : .identity
            button.backgroundColor = focused ? UIColor.systemBlue : UIColor.systemBlue.withAlphaComponent(0.6)
            button.alpha = focused ? 1.0 : 0.9
            button.layer.shadowOpacity = focused ? 0.45 : 0.3
            button.layer.shadowRadius = focused ? 16 : 12
        }, completion: nil)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if let previous = context.previouslyFocusedView as? UIButton {
            applyFocus(false, to: previous, coordinator: coordinator)
        }
        if let next = context.nextFocusedView as? UIButton {
            applyFocus(true, to: next, coordinator: coordinator)
        }
    }
}
