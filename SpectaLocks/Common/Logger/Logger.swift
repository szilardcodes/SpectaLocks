//
//  Logger.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

enum LogType {
    case message, warning, error
}

protocol Logger {
    func log(_ message: String, _ type: LogType)
    func log(_ message: String)
}
