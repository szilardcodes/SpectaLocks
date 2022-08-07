//
//  SettingsTests.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import XCTest

class SettingsTests: XCTestCase {
    private var settingsViewModel: SettingsViewModel!
    private var localizationMock: LocalizationMock!
    private var storageMock: StorageMock!
    private var appInfoMock: AppInfoMock!

    override func setUp() {
        localizationMock = LocalizationMock()
        storageMock = StorageMock()
        appInfoMock = AppInfoMock()
        settingsViewModel = SettingsViewModel(
            localization: localizationMock,
            storage: storageMock,
            appInfo: appInfoMock
        )
    }
    
    func testWhenSettingsViewReadyThenSettingsItemMappedBasedOnStoredTheme() {
        storageMock.storedValues = [:]
        localizationMock.keysWithValues = [
            "settings.title": "Settings",
            "settings.theme.title": "Display mode",
            "settings.theme.light": "Light",
            "settings.theme.dark": "Dark",
            "settings.theme.system": "System",
            "settings.site.title": "SpectaLocks page",
            "settings.site.link.title": "szilardcodes.github.io/spectalocks",
            "settings.site.link.urls": "https://szilardcodes.github.io/spectalocks",
            "settings.contact.title": "Contact",
            "settings.contact": "Contact the developer at: email"
        ]
        let expectedSettingsItem = SettingsItem(
            title: "Settings",
            themeOptionTitle: "Display mode",
            themeOptions: [
                SettingThemeOption(
                    title: "Light",
                    type: .light,
                    isSelected: false
                ),
                SettingThemeOption(
                    title: "Dark",
                    type: .dark,
                    isSelected: false
                ),
                SettingThemeOption(
                    title: "System",
                    type: .system,
                    isSelected: true
                ),
            ],
            siteTitle: "SpectaLocks page",
            siteLinkTitle:  "szilardcodes.github.io/spectalocks",
            siteLink: "https://szilardcodes.github.io/spectalocks",
            contactTitle: "Contact",
            contact: "Contact the developer at: email"
        )
        let expectation = expectation(description: "Waiting for settings item")
        var actualSettingsItem: SettingsItem?
        let subscription = settingsViewModel.settingsItem
            .sink { item in
                guard let item = item else { return }
                expectation.fulfill()
                actualSettingsItem = item
            }
        
        settingsViewModel.settingsViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedSettingsItem, actualSettingsItem)
    }

    func testWhenSettingsViewReadyAndLightThemeSelectedThenSelectedThemeIsLightInMappedItems() {
        storageMock.storedValues = [.themeSelection : ThemeOptionType.light.rawValue]
        localizationMock.keysWithValues = [
            "settings.theme.light": "Light",
            "settings.theme.dark": "Dark",
            "settings.theme.system": "System"
        ]
        let expectedThemeOptions = [
            SettingThemeOption(
                title: "Light",
                type: .light,
                isSelected: true
            ),
            SettingThemeOption(
                title: "Dark",
                type: .dark,
                isSelected: false
            ),
            SettingThemeOption(
                title: "System",
                type: .system,
                isSelected: false            )
        ]
        var actualThemeOptions = [SettingThemeOption]()
        let expectations = expectation(description: "Waiting for settings item")
        let subscription = settingsViewModel.settingsItem
            .sink { item in
                guard let item = item else { return }
                actualThemeOptions = item.themeOptions
                expectations.fulfill()
            }
        
        settingsViewModel.settingsViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedThemeOptions, actualThemeOptions)
    }
    
    func testWhenThemeSelectedThenThemeStored() {
        let expectedTheme = ThemeOptionType.dark
        
        settingsViewModel.themeSelected(option: .dark)
        
        XCTAssertEqual(expectedTheme.rawValue, storageMock.storedValues.first!.value as! String)
    }
}
