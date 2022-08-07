//
//  PrintLogger.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

class PrintLogger: Logger {
    func log(_ message: String, _ type: LogType) {
        let prefix: String
        switch type {
        case .message:
            prefix = "💚"
        case .warning:
            prefix = "⚠️"
        case .error:
            prefix = "🔥"
        }
        print("\(prefix) \(message)")
    }

    func log(_ message: String) {
        log(message, .message)
    }
}
