//
//  StatisticsTests.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import XCTest

class StatisticsTests: XCTestCase {
    private var statisticsViewModel: StatisticsViewModel!
    private var persistenceMock: PersistenceMock!
    private var localizationMock: LocalizationMock!
    
    override func setUp() {
        persistenceMock = PersistenceMock()
        localizationMock = LocalizationMock()
        statisticsViewModel = StatisticsViewModel(persistence: persistenceMock, localization: localizationMock)
    }

    func testWhenPersistenceContainsStatThenMappedAsStatItems() {
        persistenceMock.storedStats = [
            Stat(category: .gadget, skipped: 0, bought: 10),
            Stat(category: .art, skipped: 3, bought: 7),
            Stat(category: .gaming, skipped: 5, bought: 5),
            Stat(category: .transportation, skipped: 7, bought: 3),
            Stat(category: .household, skipped: 10, bought: 0)
        ]
        localizationMock.keysWithValues = [
            "statistics.title": "Statistics",
            "statistics.hint.title": "Specta graph",
            "statistics.hint": "The Statistics show the ratio of products purchased after their lock is gone."
        ]
        let expectation = expectation(description: "Waiting for statistic item")
        var actualItem: StatisticItem? = nil
        let expectedItem = StatisticItem(
            title: "Statistics",
            hintTitle: "Specta graph",
            hint: "The Statistics show the ratio of products purchased after their lock is gone.",
            graphItems: [
                StatisticsGraphItem(headerTitle: "100%", footerTitle: "🤖", percentage: 1.0),
                StatisticsGraphItem(headerTitle: "70%", footerTitle: "🎨", percentage: 0.7),
                StatisticsGraphItem(headerTitle: "50%", footerTitle: "🕹", percentage: 0.5),
                StatisticsGraphItem(headerTitle: "30%", footerTitle: "🚙", percentage: 0.3),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🏡", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🏃‍♀️", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🏥", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🎓", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🤷‍♀️", percentage: 0.0)
            ]
        )
        let subscription = statisticsViewModel.statisticItems
            .sink { item in
                guard let item = item else { return }
                actualItem = item
                expectation.fulfill()
            }
        
        statisticsViewModel.statisticsViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedItem, actualItem)
    }

    func testWhenPersistenceChangeOccurredThenNewStatsMappedAsStatItems() {
        persistenceMock.storedStats = []
        let expectation = expectation(description: "Waiting for statistic item")
        var actualGraphItems = [StatisticsGraphItem]()
        let expectedGraphItems = [
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🤖", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🎨", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🕹", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🚙", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🏡", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🏃‍♀️", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🏥", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🎓", percentage: 0.0),
                StatisticsGraphItem(headerTitle: "0%", footerTitle: "🤷‍♀️", percentage: 0.0)
        ]
        
        let subscription = statisticsViewModel.statisticItems
            .sink { item in
                guard let item = item else { return }
                actualGraphItems = item.graphItems
                expectation.fulfill()
            }
        
        persistenceMock.changeOccurred.send()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedGraphItems, actualGraphItems)
    }
}
