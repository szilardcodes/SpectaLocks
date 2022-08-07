//
//  MainViewModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import Combine

class MainViewModel {
    private let localization: Localization
    private let appInfo: AppInfo

    let mainOptions = CurrentValueSubject<[MainOption], Never>([])

    init(appInfo: AppInfo, localization: Localization) {
        self.appInfo = appInfo
        self.localization = localization
    }

    func mainViewReady() {
        let options = appInfo.enabledFeatures.map { enabledFeature in
            MainOption.getOption(from: enabledFeature, with: localization)
        }
        mainOptions.send(options)
    }
}
