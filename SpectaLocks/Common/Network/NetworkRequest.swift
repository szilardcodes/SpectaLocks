//
//  NetworkRequest.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

enum AppInfoFeature: String, Decodable {
    case dashboard, statistic, settings
}

struct AppInfoResponse: Decodable {
    let isAppEnabled: Bool
    let enabledFeatures: [AppInfoFeature]
}

protocol NetworkRequest {
    func getAppInfo() async throws -> AppInfoResponse
    func getLocalizations() async throws -> [String: String]
}

