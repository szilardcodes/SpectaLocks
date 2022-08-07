//
//  LocalizationMock.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class LocalizationMock: Localization {
    var keysWithValues = [String:String]()
    var isThrown = false
    var errorMessage: String?
    
    func initializeDoThrow(withMessage errorMessage: String) {
        isThrown = true
        self.errorMessage = errorMessage
    }
    
    func initialize() async throws {
        if isThrown {
            throw MockError.error(message: errorMessage!)
        }
    }
    
    func getText(for key: String) -> String {
        keysWithValues[key] ?? key
    }
}
