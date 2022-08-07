//
//  DashboardViewModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import Combine

class DashboardViewModel {
    let dashboardItem = CurrentValueSubject<DashboardItem?, Never>(nil)
    let adderItem = CurrentValueSubject<AdderItem?, Never>(nil)

    private let localization: Localization
    private let persistence: Persistence
    private let notification: Notification
    private let dateProvider: DateProvider
    private var refreshTask: Task<(), Never>?
    private var subscriptions = Set<AnyCancellable>()

    init(
            localization: Localization,
            persistence: Persistence,
            notification: Notification,
            dateProvider: DateProvider
    ) {
        self.localization = localization
        self.persistence = persistence
        self.notification = notification
        self.dateProvider = dateProvider
        persistence.changeOccurred
                .sink {
                    self.dashboardViewReady()
                }
                .store(in: &subscriptions)
    }

    func dashboardViewReady() {
        refreshTask?.cancel()
        refreshTask = Task { [self] in
            dashboardItem.send(
                    DashboardItem.map(
                            from: persistence.get(),
                            localization: localization,
                            dateProvider: dateProvider
                    )
            )
            await notification.requestPermissionIfNeeded()
        }
    }

    func adderViewReady() {
        adderItem.send(
                AdderItem.map(
                        from: DashboardLockCategoryType.allCases,
                        localization: localization,
                        dateProvider: dateProvider
                )
        )
    }

    func addLock(
            name: String?,
            endDate: Date?,
            category: DashboardLockCategoryType?
    ) {
        let currentDate = dateProvider.getCurrentDate()
        guard let name = name,
              let endDate = endDate,
              let category = category,
              !name.isEmpty,
              currentDate.distance(to: endDate) > 0
        else {
            return
        }

        persistence.store(
                item: Lock(
                        name: name,
                        startDate: currentDate,
                        endDate: endDate,
                        type: LockCategory(rawValue: category.rawValue)!
                )
        )
        notification.notify(at: endDate, named: name, category: LockCategory(rawValue: category.rawValue)!)
    }

    func removeLock(_ item: DashboardLock) {
        let entityLockCategoryType = LockCategory(rawValue: item.category.type.rawValue)!
        persistence.remove(name: item.name, category: entityLockCategoryType)
        notification.removeNotification(named: item.name, category: entityLockCategoryType)
    }

    func unlock(_ unlockedItem: DashboardUnlock, isBought: Bool) {
        let entityLockCategoryType = LockCategory(rawValue: unlockedItem.category.rawValue)!
        persistence.remove(name: unlockedItem.name, category: entityLockCategoryType)
        notification.removeNotification(named: unlockedItem.name, category: entityLockCategoryType)
        persistence.increaseStat(for: entityLockCategoryType, isBought: isBought)
    }
}

