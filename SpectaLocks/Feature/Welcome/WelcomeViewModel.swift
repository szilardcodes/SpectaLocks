//
//  WelcomeViewModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Combine
import Foundation

class WelcomeViewModel {
    private let appInfo: AppInfo
    private let localization: Localization
    private let storage: Storage

    let items = CurrentValueSubject<[WelcomeItem], Never>([])
    let failureEvent = PassthroughSubject<AppStartFailureEvent, Never>()
    let navigationToMainViewControllerEvent = PassthroughSubject<Void, Never>()

    init(appInfo: AppInfo, localization: Localization, storage: Storage) {
        self.appInfo = appInfo
        self.localization = localization
        self.storage = storage
    }

    func welcomeViewReady() {
        Task.detached { [self] in
            do {
                try await localization.initialize()
                try await appInfo.initialize()
                if appInfo.isAppEnabled {
                    if storage.get(for: .isWelcomeFinished) {
                        navigationToMainViewControllerEvent.send()
                    } else {
                        requestWelcomeItems()
                    }
                } else {
                    failureEvent.send(AppStartFailureEvent.buildDisabledApp(with: localization))
                }
            } catch {
                failureEvent.send(AppStartFailureEvent.buildConnectivity(with: localization))
            }
        }
    }

    func complete() {
        storage.store(for: .isWelcomeFinished, value: true)
        navigationToMainViewControllerEvent.send()
    }

    private func requestWelcomeItems() {
        items.send([
            WelcomeItem.buildGreetings(with: localization),
            WelcomeItem.buildExplanatory(with: localization),
            WelcomeItem.buildCompletion(with: localization)
        ])
    }
}
