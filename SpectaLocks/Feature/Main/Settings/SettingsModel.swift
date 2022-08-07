//
//  SettingsModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

struct SettingThemeOption: Equatable {
    let title: String
    let type: ThemeOptionType
    let isSelected: Bool

    static func get(from localization: Localization, selectedThemeOption: ThemeOptionType) -> [SettingThemeOption] {
        [SettingThemeOption(
                title: localization.getText(for: "settings.theme.light"),
                type: .light,
                isSelected: selectedThemeOption == .light),
            SettingThemeOption(
                    title: localization.getText(for: "settings.theme.dark"),
                    type: .dark,
                    isSelected: selectedThemeOption == .dark),
            SettingThemeOption(
                    title: localization.getText(for: "settings.theme.system"),
                    type: .system,
                    isSelected: selectedThemeOption == .system)
        ]
    }
}

struct SettingsItem: Equatable {
    let title: String
    let themeOptionTitle: String
    let themeOptions: [SettingThemeOption]
    let siteTitle: String
    let siteLinkTitle: String
    let siteLink: String
    let contactTitle: String
    let contact: String

    static func get(from localization: Localization, selectedTheme: ThemeOptionType) -> SettingsItem {
        SettingsItem(
                title: localization.getText(for: "settings.title"),
                themeOptionTitle: localization.getText(for: "settings.theme.title"),
                themeOptions: SettingThemeOption.get(from: localization, selectedThemeOption: selectedTheme),

                siteTitle: localization.getText(for: "settings.site.title"),
                siteLinkTitle: localization.getText(for: "settings.site.link.title"),
                siteLink: localization.getText(for: "settings.site.link.urls"),

                contactTitle: localization.getText(for: "settings.contact.title"),
                contact: localization.getText(for: "settings.contact")
        )
    }
}



