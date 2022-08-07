//
//  Notification.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

protocol Notification {
    func requestPermissionIfNeeded() async
    func notify(at: Date, named: String, category: LockCategory)
    func removeNotification(named: String, category: LockCategory)
}
