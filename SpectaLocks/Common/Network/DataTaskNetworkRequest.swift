//
//  DataTaskNetworkRequest.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class DataTaskNetworkRequest: NetworkRequest {
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func getAppInfo() async throws -> AppInfoResponse {
        let url = URL(string: environment.appInfoUrl)!
        let decoder = JSONDecoder()
        if #available(iOS 15.0, *) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try decoder.decode(AppInfoResponse.self, from: data)
        } else {
            return try await withUnsafeThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: url) { [continuation] data, response, error in
                            guard let data = data else {
                                continuation.resume(throwing: error!)
                                return
                            }

                            do {
                                let appInfoResponse = try decoder.decode(AppInfoResponse.self, from: data)
                                continuation.resume(returning: appInfoResponse)
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                        .resume()
            }
        }
    }

    func getLocalizations() async throws -> [String: String] {
        let url = URL(string: environment.localizationsUrl)!
        let decoder = JSONDecoder()
        if #available(iOS 15.0, *) {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            return try decoder.decode([String: String].self, from: data)
        } else {
            return try await withUnsafeThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: url) { [continuation] data, response, error in
                            guard let data = data else {
                                continuation.resume(throwing: error!)
                                return
                            }

                            do {
                                let localizationsResponse = try decoder.decode([String: String].self, from: data)
                                continuation.resume(returning: localizationsResponse)
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                        .resume()
            }
        }
    }
}

