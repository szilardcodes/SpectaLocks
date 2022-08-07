//
//  Entity.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

enum LockCategory: String, CaseIterable {
    case gadget, art, gaming, transportation, household, fitness, health, school, other
}

struct Lock: Equatable {
    let name: String
    let startDate: Date
    let endDate: Date
    let type: LockCategory
}

struct Stat: Equatable {
    let category: LockCategory
    let skipped: Int
    let bought: Int
}

enum ThemeOptionType: String {
    case light, dark, system
}

