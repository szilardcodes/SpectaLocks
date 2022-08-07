//
//  WelcomeTests.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import XCTest
import Combine

class WelcomeTests: XCTestCase {
    private var welcomeViewModel: WelcomeViewModel!
    private var mockAppInfo: AppInfoMock!
    private var mockLocalization: LocalizationMock!
    private var mockStorage: StorageMock!
    
    override func setUp() {
        mockAppInfo = AppInfoMock()
        mockStorage = StorageMock()
        mockLocalization = LocalizationMock()
        
        welcomeViewModel = WelcomeViewModel(
            appInfo: mockAppInfo,
            localization: mockLocalization,
            storage: mockStorage
        )
    }
    

    func testWhenWelcomeFinishedThenNavigationToMainViewController() {
        let expectation = expectation(description: "Awaiting for navigation event")
        let subscription = welcomeViewModel.navigationToMainViewControllerEvent
            .sink {
                expectation.fulfill()
            }
        mockStorage.storedValues[.isWelcomeFinished] = true
        
        welcomeViewModel.welcomeViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    
    func testWhenWelcomeNotFinishedThenWelcomeItemsReceived(){
        let expectation = expectation(description: "Awaiting for welcome item")
        mockStorage.storedValues = [.isWelcomeFinished: false]
        mockLocalization.keysWithValues = [
            "welcome.greetings.title": "Greeting",
            "welcome.greetings.description": "Greeting description",
            "welcome.greetings.buttonTitle": "Greeting button title",
            
            "welcome.explanatory.title": "Explanatory",
            "welcome.explanatory.description": "Explanatory description",
            "welcome.explanatory.buttonTitle": "Explanatory button title",
            
            "welcome.completion.title": "Completion",
            "welcome.completion.description": "Completion description",
            "welcome.completion.buttonTitle": "Completion button title"
        ]
        
        let expectedItems = [
            WelcomeItem(
                title: "Greeting",
                description: "Greeting description",
                buttonTitle: "Greeting button title"
            ),
            WelcomeItem(
                title: "Explanatory",
                description: "Explanatory description",
                buttonTitle: "Explanatory button title"
            ),
            WelcomeItem(
                title: "Completion",
                description: "Completion description",
                buttonTitle: "Completion button title"
            )
        ]
        
        var actualItems = [WelcomeItem]()
        
        let subscription = welcomeViewModel.items
            .sink { items in
                guard items.count > 0 else { return }
                actualItems = items
                expectation.fulfill()
            }
        
        welcomeViewModel.welcomeViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedItems, actualItems)
    }
    
    func testWhenWelcomeViewReadyAndLocalizationThrowErrorThenFailureEventReceived() {
        mockLocalization.initializeDoThrow(withMessage: "Unable to initialize localization")
        mockLocalization.keysWithValues = [
            "welcome.fail.connectivity.title": "Error title",
            "welcome.fail.connectivity.description": "Error description",
            "welcome.fail.connectivity.retry": "Error retry title"
        ]
        
        var actualAppStartFailureEvent: AppStartFailureEvent!
        let expectedAppStartFailureEvent = AppStartFailureEvent(
            name: "Error title",
            description: "Error description",
            retryText: "Error retry title"
        )
        let expectation = expectation(description: "Awaiting for failure event")
        let subscription = welcomeViewModel.failureEvent
            .sink { event in
                actualAppStartFailureEvent = event
                expectation.fulfill()
            }
        
        welcomeViewModel.welcomeViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedAppStartFailureEvent, actualAppStartFailureEvent)
    }
    
    func testWhenWelcomeViewReadyAndAppInitThrowErrorThenFailureEventReceived() {
        mockAppInfo.initializeDoThrow(withMessage: "Unable to initialize app info")
        mockLocalization.keysWithValues = [
            "welcome.fail.connectivity.title": "Error title",
            "welcome.fail.connectivity.description": "Error description",
            "welcome.fail.connectivity.retry": "Error retry title"
        ]
        
        var actualAppStartFailureEvent: AppStartFailureEvent!
        let expectedAppStartFailureEvent = AppStartFailureEvent(
            name: "Error title",
            description: "Error description",
            retryText: "Error retry title"
        )
        let expectation = expectation(description: "Awaiting for failure event")
        let subscription = welcomeViewModel.failureEvent
            .sink { event in
                actualAppStartFailureEvent = event
                expectation.fulfill()
            }
        
        welcomeViewModel.welcomeViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedAppStartFailureEvent, actualAppStartFailureEvent)
    }
    
    func testWhenWelcomeViewReadyAndAppDisabledThenFailureEventReceived(){
        mockAppInfo.isAppEnabled = false
        mockStorage.storedValues = [
            .isWelcomeFinished: true
        ]
        mockLocalization.keysWithValues = [
            "welcome.fail.disabled.title": "Error title",
            "welcome.fail.disabled.description": "Error description",
            "welcome.fail.disabled.retry": "Error retry title"
        ]
        
        var actualAppStartFailureEvent: AppStartFailureEvent!
        let expectedAppStartFailureEvent = AppStartFailureEvent(
            name: "Error title",
            description: "Error description",
            retryText: "Error retry title"
        )
        
        let expectation = expectation(description: "Awaiting for failure event")
        let subscription = welcomeViewModel.failureEvent
            .sink { event in
                actualAppStartFailureEvent = event
                expectation.fulfill()
            }
     
        welcomeViewModel.welcomeViewReady()
        
        waitForExpectations(timeout: 1)
        subscription.cancel()
        XCTAssertEqual(expectedAppStartFailureEvent, actualAppStartFailureEvent)
    }
    
    func testWhenCompleteInvokedStorageStoresFinishState() {
        welcomeViewModel.complete()
        
        XCTAssertTrue(mockStorage.storedValues[.isWelcomeFinished]! as! Bool)
    }
}
