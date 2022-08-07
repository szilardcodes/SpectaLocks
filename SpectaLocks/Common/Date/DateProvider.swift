//
//  DateProvider.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

// Using "Date()" to get the current date in business logic is causing testability issues because in that scenario is not possible to mock the current date.
protocol DateProvider {
    func getCurrentDate() -> Date
}
