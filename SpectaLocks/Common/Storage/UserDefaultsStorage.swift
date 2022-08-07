//
//  UserDefaultsStorage.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class UserDefaultsStorage: Storage {
    private let userDefault = UserDefaults.standard

    func get<StoredType>(for storageKey: StorageKey) -> StoredType {
        let key = storageKey.rawValue
        switch StoredType.self {
        case is Bool.Type: return userDefault.bool(forKey: key) as! StoredType
        case is String.Type: return userDefault.string(forKey: key) as! StoredType
        case is String?.Type: return userDefault.string(forKey: key) as! StoredType
        case is Int.Type: return userDefault.integer(forKey: key) as! StoredType
        default: fatalError("Unknown stored type")
        }
    }

    func store(for key: StorageKey, value: Any?) {
        userDefault.set(value, forKey: key.rawValue)
    }
}

