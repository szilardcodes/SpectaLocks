//
//  LocalNotification.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import NotificationCenter

class LocalNotification: Notification {
    private let localization: Localization
    private let dateProvider: DateProvider

    init(localization: Localization, dateProvider: DateProvider) {
        self.localization = localization
        self.dateProvider = dateProvider
    }

    func requestPermissionIfNeeded() async {
        await withUnsafeContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, error in
                continuation.resume()
            }
        }
    }

    func notify(at endDate: Date, named lockName: String, category lockCategory: LockCategory) {
        let currentDate = dateProvider.getCurrentDate()
        let titlePostfix = localization.getText(for: "dashboard.unlock.notification.title.postfix")
        let content = UNMutableNotificationContent()
        content.title = "\(lockName) \(titlePostfix)"
        content.body = localization.getText(for: "dashboard.unlock.notification.message")
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: currentDate.distance(to: endDate), repeats: false)
        let request = UNNotificationRequest(identifier: "\(lockName)\(lockCategory.rawValue)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removeNotification(named lockName: String, category lockCategory: LockCategory) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(lockName)\(lockCategory.rawValue)"])
    }
}

