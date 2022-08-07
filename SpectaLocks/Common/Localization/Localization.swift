//
//  Localization.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

protocol Localization {
    func initialize() async throws
    func getText(for key: String) -> String
}

