//
//  SettingsViewModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import Combine

class SettingsViewModel {
    private let localization: Localization
    private let storage: Storage
    private let appInfo: AppInfo

    let settingsItem = CurrentValueSubject<SettingsItem?, Never>(nil)

    init(localization: Localization, storage: Storage, appInfo: AppInfo) {
        self.localization = localization
        self.storage = storage
        self.appInfo = appInfo
    }

    func settingsViewReady() {
        let selectedThemeOption: String? = storage.get(for: .themeSelection)
        let selectedTheme: ThemeOptionType
        if let selectedThemeOption = selectedThemeOption {
            selectedTheme = ThemeOptionType(rawValue: selectedThemeOption)!
        } else {
            selectedTheme = .system
        }
        settingsItem.send(SettingsItem.get(from: localization, selectedTheme: selectedTheme))
    }

    func themeSelected(option: ThemeOptionType) {
        storage.store(for: .themeSelection, value: option.rawValue)
    }

}
