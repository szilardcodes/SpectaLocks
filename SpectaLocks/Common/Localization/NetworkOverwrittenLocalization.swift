//
//  NetworkOverwrittenLocalization.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class NetworkOverwrittenLocalization: Localization {
    private(set) var isInitialized = false
    private let networkRequest: NetworkRequest
    private var defaultLocalizationMap = [String: String]()
    private var modifiedLocalizationMap = [String: String]()

    init(networkRequest: NetworkRequest) {
        self.networkRequest = networkRequest
    }

    func initialize() async throws {
        guard !isInitialized else {
            return
        }
        let url = Bundle.main.url(forResource: "localization_en", withExtension: "json")
        let data = try Data(contentsOf: url!)
        defaultLocalizationMap = try JSONDecoder().decode([String: String].self, from: data)
        modifiedLocalizationMap = try await networkRequest.getLocalizations()
    }

    func getText(for key: String) -> String {
        modifiedLocalizationMap[key] ?? defaultLocalizationMap[key] ?? ""
    }
}

