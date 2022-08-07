//
//  DateProviderMock.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class DateProviderMock: DateProvider {
    var currentDate: Date?
    
    func getCurrentDate() -> Date {
        guard let currentDate = currentDate else {
            return Date()
        }
        return currentDate
    }
}
