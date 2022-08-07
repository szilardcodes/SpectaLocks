//
//  Storage.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

enum StorageKey: String {
    case isWelcomeFinished, themeSelection
}

protocol Storage {
    func get<StoredType>(for key: StorageKey) -> StoredType
    func store(for key: StorageKey, value: Any?)
}
