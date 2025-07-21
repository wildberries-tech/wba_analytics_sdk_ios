// Copyright © 2024 Wildberries. All rights reserved.

import Foundation
import UIKit

public final class AnalyticsLogViewController: UIViewController {

    private let logFileHandling: LogFileHandling
    private var logs: [String] = []
    private var filteredLogs: [String] = []
    private var timer: Timer?
    private var isUserScrolling = false

    private lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search logs"
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        return tableView
    }()

    init(logFileHandling: LogFileHandling) {
        self.logFileHandling = logFileHandling
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateLogs()
        startLogUpdates()
    }

    private func setup() {
        view.backgroundColor = .white

        navigationItem.title = "Analytics logs"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(clearLogs)
            ),
            UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(shareLogs)
            )
        ]

        view.addSubview(searchField)
        view.addSubview(tableView)

        searchField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func startLogUpdates() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateLogs),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func updateLogs() {
        do {
            guard let logFileURL = logFileHandling.logFileURL() else { return }
            let logContent = try String(contentsOf: logFileURL, encoding: .utf8)
            logs = logContent.components(separatedBy: .newlines)
            applySearchFilter()
        } catch {
            print("Failed to read log file: \(error)")
        }
    }

    @objc private func clearLogs() {
        logFileHandling.clearLogFile()
    }

    @objc private func searchFieldDidChange() {
        applySearchFilter()
    }

    private func applySearchFilter() {
        let searchText = searchField.text ?? ""
        if searchText.isEmpty {
            filteredLogs = logs
        } else {
            filteredLogs = logs.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        tableView.reloadData()
        scrollToBottomIfNeeded()
    }

    private func scrollToBottomIfNeeded() {
        if !isUserScrolling && !filteredLogs.isEmpty {
            let lastRowIndex = IndexPath(row: filteredLogs.count - 1, section: 0)
            tableView.scrollToRow(at: lastRowIndex, at: .bottom, animated: true)
        }
    }

    @objc private func shareLogs() {
        guard let logFileURL = logFileHandling.logFileURL() else { return }
        let activityViewController = UIActivityViewController(
            activityItems: [logFileURL],
            applicationActivities: nil
        )
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension AnalyticsLogViewController: UITableViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isUserScrolling = false
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isUserScrolling = false
    }
}

// MARK: - UITableViewDataSource

extension AnalyticsLogViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredLogs.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 11.0)
        cell.textLabel?.text = filteredLogs[indexPath.row]
        return cell
    }
}
