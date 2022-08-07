//
//  NetworkOverwrittenAppInfo.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class NetworkOverwrittenAppInfo: AppInfo {
    var isAppEnabled: Bool!
    var enabledFeatures: [AppInfoFeature]!

    private let networkRequest: NetworkRequest

    init(networkRequest: NetworkRequest) {
        self.networkRequest = networkRequest
    }

    func initialize() async throws {
        let appInfo = try await networkRequest.getAppInfo()
        isAppEnabled = appInfo.isAppEnabled
        enabledFeatures = appInfo.enabledFeatures
    }
}
