//
//  StorageMock.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class StorageMock: Storage {
    var storedValues = [StorageKey: Any]()
    
    func get<StoredType>(for key: StorageKey) -> StoredType {
        storedValues[key] as! StoredType
    }
    
    func store(for key: StorageKey, value: Any?) {
        storedValues[key] = value
    }
}
