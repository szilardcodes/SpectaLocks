//
//  DasboardViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit
import Combine

// MARK: UIViewController
class DashboardViewController: UITableViewController {

    private let dashboardViewModel: DashboardViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var dataSource: DashboardDataSource!
    private var foregroundObserver: NSObjectProtocol?

    private var dashboardLocks: [DashboardLock] {
        dashboardViewModel.dashboardItem.value?.locks ?? []
    }

    private var dashboardCategories: [DashboardLockCategory] {
        var result = [DashboardLockCategory]()
        NSOrderedSet(array: dashboardLocks.map {
            $0.category
        })
                .forEach {
                    result.append($0 as! DashboardLockCategory)
                }
        return result
    }

    init(dashboardViewModel: DashboardViewModel) {
        self.dashboardViewModel = dashboardViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var dashboardTitleLabel: UILabel = {
        let dashboardTitleLabel = UILabel()
        dashboardTitleLabel.textColor = UIColor.Dashboard.titleTextColor
        dashboardTitleLabel.font = UIFont.Dashboard.title
        dashboardTitleLabel.alpha = 0
        dashboardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return dashboardTitleLabel
    }()

    private lazy var emptyImageView: UIImageView = {
        let emptyImage = UIImageView()
        emptyImage.image = UIImage(named: "SafeIcon")
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        return emptyImage
    }()

    private lazy var emptyTitleLabel: UILabel = {
        let emptyTitleLabel = UILabel()
        emptyTitleLabel.font = UIFont.Dashboard.emptyTitle
        emptyTitleLabel.numberOfLines = 3
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.textColor = UIColor.Dashboard.emptyTitleTextColor
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return emptyTitleLabel
    }()

    private func addEmptyImageView() {
        view.addSubview(emptyImageView)
        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -15),
            emptyImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 50),
            emptyImageView.widthAnchor.constraint(equalToConstant: 137),
            emptyImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func addEmptyTitleLabel() {
        view.addSubview(emptyTitleLabel)
        NSLayoutConstraint.activate([
            emptyTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            emptyTitleLabel.bottomAnchor.constraint(equalTo: emptyImageView.topAnchor, constant: -15),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ])
    }

    private func update() {
        emptyImageView.isHidden = !dashboardLocks.isEmpty
        emptyTitleLabel.isHidden = !dashboardLocks.isEmpty
        var snapshot = NSDiffableDataSourceSnapshot<DashboardLockCategory, DashboardLock>()

        snapshot.appendSections(dashboardCategories)
        dashboardCategories.forEach { category in
            let locksInTheCategory = dashboardLocks.filter {
                $0.category == category
            }
            snapshot.appendItems(locksInTheCategory, toSection: category)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func subscribeViewModel() {
        dashboardViewModel.dashboardItem
                .receive(on: DispatchQueue.main)
                .sink { [self] item in
                    guard let item = item else {
                        return
                    }
                    navigationItem.title = item.title
                    emptyTitleLabel.text = item.emptyDashboardHint
                    update()
                    if let unlockedItem = item.unlock {
                        let alertViewController = PopupViewController(
                                title: unlockedItem.title,
                                message: unlockedItem.message,
                                positiveAction: PopupAction(title: unlockedItem.addTitle, selectionHandler: {
                                    self.dashboardViewModel.unlock(unlockedItem, isBought: true)
                                }),
                                negativeAction: PopupAction(title: unlockedItem.skipTitle, selectionHandler: {
                                    self.dashboardViewModel.unlock(unlockedItem, isBought: false)
                                })
                        )
                        present(alertViewController, animated: true)
                    }
                }
                .store(in: &subscriptions)
    }

    @objc private func showAdderPanel(sender: UIButton) {
        let adderViewController = DIManager.shared.resolve(LockAdderViewController.self)
        let navigationController = UINavigationController(rootViewController: adderViewController)

        if #available(iOS 15.0, *) {
            navigationController.modalPresentationStyle = .formSheet
            if let sheets = navigationController.sheetPresentationController {
                sheets.detents = [.medium(), .large()]
            }
        } else {
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.modalTransitionStyle = .coverVertical
        }
        navigationController.presentationController?.delegate = self
        present(navigationController, animated: true)
    }


    override func viewDidLoad() {
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main, using: { [unowned self] notification in
            dashboardViewModel.dashboardViewReady()
        })

        view.backgroundColor = UIColor.Main.background
        navigationController?.view.backgroundColor = UIColor.Main.background
        let adderButton = UIBarButtonItem()
        adderButton.title = "Add"
        adderButton.tintColor = UIColor.Dashboard.lockAdderBackground
        adderButton.target = self
        adderButton.action = #selector(showAdderPanel)
        navigationItem.setRightBarButton(adderButton, animated: false)

        addEmptyImageView()
        addEmptyTitleLabel()

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(LockCell.self, forCellReuseIdentifier: LockCell.reuseIdentifier)
        tableView.register(HeaderCell.self, forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIdentifier)
        dataSource = DashboardDataSource(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, item: DashboardLock) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: LockCell.reuseIdentifier) as! LockCell
            cell.bind(item) {
                self.dashboardViewModel.dashboardViewReady()
            }
            return cell
        }
        subscribeViewModel()
        dashboardViewModel.dashboardViewReady()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        LockCell.rowHeight
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        HeaderCell.rowHeight
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIdentifier)
        (view as! HeaderCell).bind(dashboardCategories[section])
        return view
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
            let item = dashboardLocks.filter {
                dashboardCategories[indexPath.section] == $0.category
            }[indexPath.row]
            dashboardViewModel.removeLock(item)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    deinit {
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }

}

extension DashboardViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dashboardViewModel.dashboardViewReady()
    }
}

class DashboardDataSource: UITableViewDiffableDataSource<DashboardLockCategory, DashboardLock> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

class LockCell: UITableViewCell {
    static let rowHeight = CGFloat(50)
    static let reuseIdentifier = "LockId"
    private var widthConstraint: NSLayoutConstraint?
    private var timerDisposable: AnyCancellable?

    private let lockNameLabel: UILabel = {
        let lockNameLabel = UILabel()
        lockNameLabel.font = UIFont.Dashboard.lockTitle
        lockNameLabel.textColor = UIColor.Dashboard.lockTitleTextColor
        lockNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return lockNameLabel
    }()

    private let remainingLabel: UILabel = {
        let remainingLabel = UILabel()
        remainingLabel.font = UIFont.Dashboard.remainingLabel
        remainingLabel.textColor = UIColor.Dashboard.remainingLabelTextColor
        remainingLabel.translatesAutoresizingMaskIntoConstraints = false
        return remainingLabel
    }()

    private let progressBackgroundView: UIView = {
        let progressBackgroundView = UIView()
        progressBackgroundView.backgroundColor = UIColor.Dashboard.progressTrackColor
        progressBackgroundView.layer.cornerRadius = 5
        progressBackgroundView.layer.shadowColor = UIColor.black.cgColor
        progressBackgroundView.layer.shadowOffset = CGSize(width: 2, height: 2)
        progressBackgroundView.layer.shadowRadius = 5
        progressBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        return progressBackgroundView
    }()

    private let progressView: UIView = {
        let progressView = UIView()
        progressView.backgroundColor = UIColor.Dashboard.progressColor
        progressView.layer.cornerRadius = 5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()

    private func addLockNameLabel() {
        addSubview(lockNameLabel)
        NSLayoutConstraint.activate([
            lockNameLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
            lockNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            lockNameLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            lockNameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func addRemainingLabel() {
        addSubview(remainingLabel)
        NSLayoutConstraint.activate([
            remainingLabel.topAnchor.constraint(equalTo: lockNameLabel.topAnchor),
            remainingLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            remainingLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func addProgressView() {
        addSubview(progressBackgroundView)
        addSubview(progressView)
        NSLayoutConstraint.activate([
            progressBackgroundView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
            progressBackgroundView.topAnchor.constraint(equalTo: lockNameLabel.bottomAnchor, constant: 5),
            progressBackgroundView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            progressBackgroundView.heightAnchor.constraint(equalToConstant: 10),
            progressView.leadingAnchor.constraint(equalTo: progressBackgroundView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: progressBackgroundView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor),
        ])
    }

    func bind(_ item: DashboardLock, progressReadyHandler: @escaping () -> ()) {
        lockNameLabel.text = item.name
        remainingLabel.text = item.remainingLabel
        progressView.layer.removeAllAnimations()
        widthConstraint?.isActive = false
        widthConstraint = progressView.widthAnchor.constraint(equalTo: progressBackgroundView.widthAnchor, multiplier: CGFloat(item.progressionPercentage))
        widthConstraint?.isActive = true
        layoutIfNeeded()
        timerDisposable?.cancel()
        timerDisposable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [self] _ in
                    let percentage = item.progressionPercentage
                    widthConstraint?.isActive = false
                    widthConstraint = progressView.widthAnchor.constraint(
                            equalTo: progressBackgroundView.widthAnchor,
                            multiplier: CGFloat(percentage)
                    )
                    widthConstraint?.isActive = true
                    UIView.animate(withDuration: 2) { [self] in
                        layoutIfNeeded()
                    }
                    if percentage == 1 {
                        timerDisposable?.cancel()
                        progressReadyHandler()
                    }
                }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        addLockNameLabel()
        addProgressView()
        addRemainingLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // No selection required
    }
}

// MARK: HeaderCell
class HeaderCell: UITableViewHeaderFooterView {
    static let rowHeight = CGFloat(50)
    static let reuseIdentifier = "HeaderCell"

    private let categoryNameLabel: UILabel = {
        let categoryNameLabel = UILabel()
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.font = UIFont.Dashboard.categoryTitle
        return categoryNameLabel
    }()

    private let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        separatorView.alpha = 0.2
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()

    private func addCategoryNameLabel() {
        addSubview(categoryNameLabel)
        NSLayoutConstraint.activate([
            categoryNameLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            categoryNameLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            categoryNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            categoryNameLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func addSeparatorView() {
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            separatorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addCategoryNameLabel()
        addSeparatorView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ item: DashboardLockCategory) {
        categoryNameLabel.text = item.name
    }
}


