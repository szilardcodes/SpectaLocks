//
//  PersistenceMock.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import Combine

class PersistenceMock: Persistence {
    var changeOccurred: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    var storedLocks = [Lock]()
    var storedStats = LockCategory.allCases.map { Stat(category: $0, skipped: 0, bought: 0) }
    
    func store(item: Lock) {
        storedLocks.append(item)
        changeOccurred.send()
    }
    
    func get() -> [Lock] {
        storedLocks
    }
    
    func remove(name: String, category: LockCategory) {
        storedLocks.removeAll { $0.name == name && $0.type == category }
        changeOccurred.send()
    }
    
    func get() -> [Stat] {
        storedStats
    }
    
    func increaseStat(for category: LockCategory, isBought: Bool) {
        let statIndex = storedStats.firstIndex { $0.category == category }!
        let stat = storedStats[statIndex]
        var skipped = stat.skipped
        var bought = stat.bought
        if isBought {
            bought += 1
        } else {
            skipped += 1
        }
        storedStats[statIndex] = Stat(
            category: stat.category,
            skipped: skipped,
            bought:bought
        )
        changeOccurred.send()
    }
}
