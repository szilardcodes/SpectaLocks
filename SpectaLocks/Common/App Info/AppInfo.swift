//
//  AppInfo.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

protocol AppInfo {
    var isAppEnabled: Bool! { get }
    var enabledFeatures: [AppInfoFeature]! { get }
    func initialize() async throws
}
