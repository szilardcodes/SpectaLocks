//
//  MainTests.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import XCTest
import Combine

class MainTests: XCTestCase {
    private var mainViewModel: MainViewModel!
    private var mockLocalization: LocalizationMock!
    private var mockAppInfo: AppInfoMock!
    
    override func setUp() {
        mockAppInfo = AppInfoMock()
        mockLocalization = LocalizationMock()
        mainViewModel = MainViewModel(appInfo: mockAppInfo, localization: mockLocalization)
    }
    
    func testWhenMainViewReadyThenMainOptionsReceived() {
        mockAppInfo.enabledFeatures = [.dashboard, .statistic, .settings]
        mockLocalization.keysWithValues = [
            "dashboard.title": "Dashboard title",
            "statistics.title": "Statistics title",
            "settings.title": "Settings title"
        ]
        let expectedOptions = [
            MainOption(type: .dashboard, title: "Dashboard title"),
            MainOption(type: .statistics, title: "Statistics title"),
            MainOption(type: .settings, title: "Settings title"),
        ]
        var actualOptions = [MainOption]()
        
        let expectation = expectation(description: "Waiting for option items")
        let subscription = mainViewModel.mainOptions
            .sink { options in
                guard options.count > 0 else { return }
                actualOptions = options
                expectation.fulfill()
            }
        
        mainViewModel.mainViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedOptions, actualOptions)
    }
}
