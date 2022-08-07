//
//  NotificationMock.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

struct NotificationItemMock: Equatable {
    let name: String
    let date: Date
    let category: LockCategory
}

class NotificationMock: Notification {
    var isPermissionRequested = false
    var notifications = [NotificationItemMock]()
    
    func requestPermissionIfNeeded() async {
        isPermissionRequested = true
    }
    
    func notify(at date: Date, named name: String, category: LockCategory) {
        notifications.append(NotificationItemMock(name: name, date: date, category: category))
    }
    
    func removeNotification(named: String, category: LockCategory) {
        notifications.removeAll { $0.name == named && $0.category == category }
    }
}
