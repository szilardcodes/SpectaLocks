//
//  StatisticsViewModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import Combine

class StatisticsViewModel {
    let statisticItems = CurrentValueSubject<StatisticItem?, Never>(nil)

    private let persistence: Persistence
    private let localization: Localization
    private var subscriptions = Set<AnyCancellable>()

    init(persistence: Persistence, localization: Localization) {
        self.persistence = persistence
        self.localization = localization
        persistence.changeOccurred
                .sink { [self] in
                    statisticsViewReady()
                }
                .store(in: &subscriptions)
    }

    func statisticsViewReady() {
        statisticItems.send(StatisticItem.get(from: persistence.get(), localization: localization))
    }
}
