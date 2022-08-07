//
//  DashboardModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

enum DashboardLockCategoryType: String, CaseIterable {
    case gadget, art, gaming, transportation, household, fitness, health, school, other

    static func get(from: LockCategory) -> DashboardLockCategoryType {
        DashboardLockCategoryType(rawValue: from.rawValue) ?? .other
    }
}

struct DashboardLockCategory: Hashable {
    let name: String
    let type: DashboardLockCategoryType

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: DashboardLockCategory, rhs: DashboardLockCategory) -> Bool {
        lhs.name == rhs.name
    }

    static func get(form type: LockCategory, _ localization: Localization) -> DashboardLockCategory {
        let type = DashboardLockCategoryType.get(from: type)
        return DashboardLockCategory(
                name: localization.getText(for: "dashboard.lock.category.\(type.rawValue)"),
                type: type
        )
    }
}

struct DashboardLock: Hashable {
    let name: String
    let remainingLabel: String
    let category: DashboardLockCategory
    let startDate: Date
    let endDate: Date
    let dateProvider: DateProvider

    var progressionPercentage: Float {
        let allDistanceMs = Int64(endDate.timeIntervalSince(startDate)) * 1000
        let remainingDistanceMs = Int64(endDate.timeIntervalSince(dateProvider.getCurrentDate())) * 1000
        var result = Float(1 - Float64(remainingDistanceMs) / Float64(allDistanceMs))
        if !(0.0...1.0).contains(result) {
            if result > 1 {
                result = 1
            } else {
                result = 0
            }
        }
        return result
    }

    var remainingTime: TimeInterval {
        dateProvider.getCurrentDate().distance(to: endDate)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(remainingLabel)
        hasher.combine(category)
        hasher.combine(endDate)
    }

    static func == (lhs: DashboardLock, rhs: DashboardLock) -> Bool {
        lhs.name == rhs.name &&
                lhs.remainingLabel == rhs.remainingLabel &&
                lhs.category == rhs.category &&
                lhs.endDate == rhs.endDate
    }

    static func map(from lock: Lock, _ localization: Localization, _ dateProvider: DateProvider) -> DashboardLock {
        let remainingDistanceMs = Int64(lock.endDate.timeIntervalSince(dateProvider.getCurrentDate())) * 1000
        let dayMs = 24 * 60 * 60 * 1000
        let remainingLabel: String
        if remainingDistanceMs <= 0 {
            remainingLabel = ""
        } else if remainingDistanceMs > dayMs {
            let remainingDistanceDays = remainingDistanceMs / 1000 / 60 / 60 / 24
            let remainingDaysPostfix = localization.getText(for: "dashboard.lock.remaining.postfix")
            remainingLabel = "\(remainingDistanceDays) \(remainingDaysPostfix)"
        } else {
            remainingLabel = localization.getText(for: "dashboard.lock.remaining.soon")
        }

        return DashboardLock(
                name: lock.name,
                remainingLabel: remainingLabel,
                category: DashboardLockCategory.get(form: lock.type, localization),
                startDate: lock.startDate,
                endDate: lock.endDate,
                dateProvider: dateProvider
        )
    }

}

struct DashboardUnlock: Equatable {
    let title: String
    let message: String
    let addTitle: String
    let skipTitle: String
    let name: String
    let category: DashboardLockCategoryType

    static func map(from lock: DashboardLock, localization: Localization) -> DashboardUnlock {
        let titlePrefix = localization.getText(for: "dashboard.unlock.title.prefix")
        let titlePostfix = localization.getText(for: "dashboard.unlock.title.postfix")
        return DashboardUnlock(
                title: "\(titlePrefix) \(lock.name) \(titlePostfix)",
                message: localization.getText(for: "dashboard.unlock.message"),
                addTitle: localization.getText(for: "dashboard.unlock.buy"),
                skipTitle: localization.getText(for: "dashboard.unlock.skip"),
                name: lock.name,
                category: lock.category.type
        )
    }
}

struct DashboardItem: Equatable {
    let title: String
    let emptyDashboardHint: String
    let locks: [DashboardLock]
    let unlock: DashboardUnlock?

    static func map(from locks: [Lock], localization: Localization, dateProvider: DateProvider) -> DashboardItem {
        let dashboardLocks = locks.map {
            DashboardLock.map(from: $0, localization, dateProvider)
        }
        var unlock: DashboardUnlock? = nil
        if let unlockedLock = dashboardLocks.filter({ $0.remainingTime <= 0 }).first {
            unlock = DashboardUnlock.map(from: unlockedLock, localization: localization)
        }
        return DashboardItem(
                title: localization.getText(for: "dashboard.title"),
                emptyDashboardHint: localization.getText(for: "dashboard.empty.title"),
                locks: dashboardLocks.filter {
                    $0.remainingTime > 0
                },
                unlock: unlock
        )
    }
}

struct AdderItem: Equatable {
    let title: String
    let doneTitle: String
    let nameTitle: String
    let dateTitle: String
    let categoryTitle: String
    let minimumSelectableDate: Date
    let categories: [DashboardLockCategory]

    static func map(from types: [DashboardLockCategoryType], localization: Localization, dateProvider: DateProvider) -> AdderItem {
        AdderItem(
                title: localization.getText(for: "addLock.title"),
                doneTitle: localization.getText(for: "addLock.add"),
                nameTitle: localization.getText(for: "addLock.form.name"),
                dateTitle: localization.getText(for: "addLock.form.date"),
                categoryTitle: localization.getText(for: "addLock.form.category"),
                minimumSelectableDate: Calendar.current.date(byAdding: .minute, value: 1, to: dateProvider.getCurrentDate())!,
                categories: types.map {
                    DashboardLockCategory(
                            name: localization.getText(for: "dashboard.lock.category.\($0.rawValue)"),
                            type: $0
                    )
                }
        )
    }
}

