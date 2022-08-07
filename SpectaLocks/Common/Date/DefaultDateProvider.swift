//
//  DefaultDateProvider.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class DefaultDateProvider: DateProvider {
    func getCurrentDate() -> Date {
        Date()
    }
}
