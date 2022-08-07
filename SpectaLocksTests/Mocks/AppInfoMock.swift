//
//  AppInfoMock.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class AppInfoMock: AppInfo {
    var isAppEnabled: Bool! = true
    var privacyUrl: String! = ""
    var termsUrl: String! = ""
    var enabledFeatures: [AppInfoFeature]! = []
    var initErrorMessage: String?
    
    func initializeDoThrow(withMessage errorMessage: String) {
        initErrorMessage = errorMessage
    }
    
    func initialize() async throws {
        guard let initErrorMessage = initErrorMessage else { return }
        throw MockError.error(message: initErrorMessage)
    }
}
