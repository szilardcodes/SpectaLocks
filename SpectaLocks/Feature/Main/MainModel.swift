//
//  MainModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

enum MainOptionType {
    case dashboard, statistics, settings
}

struct MainOption: Equatable {
    let type: MainOptionType
    let title: String

    static func getOption(from appInfoFeature: AppInfoFeature, with localization: Localization) -> MainOption {
        switch appInfoFeature {
        case .dashboard:
            return MainOption(type: .dashboard, title: localization.getText(for: "dashboard.title"))
        case .statistic:
            return MainOption(type: .statistics, title: localization.getText(for: "statistics.title"))
        case .settings:
            return MainOption(type: .settings, title: localization.getText(for: "settings.title"))
        }
    }
}

