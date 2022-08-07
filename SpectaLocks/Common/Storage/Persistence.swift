//
//  Persistence.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit
import Combine

protocol Persistence {
    var changeOccurred: PassthroughSubject<Void, Never> { get }
    func store(item: Lock)
    func get() -> [Lock]
    func remove(name: String, category: LockCategory)
    func get() -> [Stat]
    func increaseStat(for category: LockCategory, isBought: Bool)
}
