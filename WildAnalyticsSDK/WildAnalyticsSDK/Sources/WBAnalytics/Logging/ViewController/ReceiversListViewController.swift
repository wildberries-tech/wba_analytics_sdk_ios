//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

import UIKit

class ReceiversListViewController: UITableViewController {

    private let receivers: [String: AnalyticsReceiver]
    private let sortedKeys: [String]

    init(receivers: [String: AnalyticsReceiver]) {
        self.receivers = receivers
        self.sortedKeys = receivers.keys.sorted()
        super.init(style: .plain)
        self.title = "Analytics Receivers"
    }

    init(apiKeys: [String]) {
        self.sortedKeys = apiKeys.sorted()
        self.receivers = [:]
        super.init(style: .plain)
        self.title = "Analytics Receivers"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedKeys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "ReceiverCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
            UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        let key = sortedKeys[indexPath.row]
        cell.textLabel?.text = key
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let key = sortedKeys[indexPath.row]
        var logController: UIViewController
        if let receiver = receivers[key], let controller = receiver.showLogScreen() {
            logController = controller
        } else {
            logController = AnalyticsLogViewController(apiKey: key)
        }

        navigationController?.pushViewController(logController, animated: true)
    }
}
