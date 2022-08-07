//
//  DashboardTests.swift
//  SpectaLocksTests
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import XCTest
import Combine

class DashboardTests: XCTestCase {
    private var dashboardViewModel: DashboardViewModel!
    private var localizationMock: LocalizationMock!
    private var persistenceMock: PersistenceMock!
    private var notificationMock: NotificationMock!
    private var dateProviderMock: DateProviderMock!
    
    override func setUp() {
        localizationMock = LocalizationMock()
        persistenceMock = PersistenceMock()
        notificationMock = NotificationMock()
        dateProviderMock = DateProviderMock()
        
        dashboardViewModel = DashboardViewModel(
            localization: localizationMock,
            persistence: persistenceMock,
            notification: notificationMock,
            dateProvider: dateProviderMock
        )
    }
    
    func testWhenDashboardViewReadyThenLocksMappedToDashboardItem() {
        let startDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        dateProviderMock.currentDate = Date(timeIntervalSince1970: 1659312000) // Monday, 1 August 2022 00:00:00
        let endDate = Date(timeIntervalSince1970: 1659398401) // Tuesday, 2 August 2022 00:00:01 (1 day and 1 sec diff soo it's more than 1 day)
        
        persistenceMock.storedLocks = [
            Lock(
                name: "Test lock",
                startDate: startDate,
                endDate: endDate,
                type: .other
            )
        ]
        localizationMock.keysWithValues = [
            "dashboard.title": "Title",
            "dashboard.empty.title": "Empty title",
            "dashboard.lock.remaining.postfix": "day(s) left",
            "dashboard.lock.category.other": "Other"
        ]
        
        let expectedDashboardItem = DashboardItem(
            title: "Title",
            emptyDashboardHint: "Empty title",
            locks: [
                DashboardLock(
                    name: "Test lock",
                    remainingLabel: "1 day(s) left",
                    category: DashboardLockCategory(
                        name: "Other",
                        type: .other
                    ),
                    startDate: startDate,
                    endDate: endDate,
                    dateProvider: dateProviderMock
                )
            ],
            unlock: nil
        )
        var actualDashboardItem: DashboardItem!
        
        let expectation = expectation(description: "Waiting for dashboard item")
        let subscription = dashboardViewModel.dashboardItem
            .sink { item in
                guard let item = item else { return }
                expectation.fulfill()
                actualDashboardItem = item
            }
        
        dashboardViewModel.dashboardViewReady()
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(expectedDashboardItem, actualDashboardItem)
        subscription.cancel()
    }
    
    
    func testWhenDashboardViewReadyThenUnlocksMappedToDashboardItem() {
        let startDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        let endDate = Date(timeIntervalSince1970: 1659312000) // Monday, 1 August 2022 00:00:00
        dateProviderMock.currentDate = Date(timeIntervalSince1970: 1659398400) // Tuesday, 2 August 2022 00:00:00
        
        persistenceMock.storedLocks = [
            Lock(
                name: "Test lock",
                startDate: startDate,
                endDate: endDate,
                type: .other
            )
        ]
        
        localizationMock.keysWithValues = [
            "dashboard.unlock.title.prefix": "Congrats!",
            "dashboard.unlock.title.postfix": "is unlocked.",
            "dashboard.title": "My locks",
            "dashboard.unlock.message": "Do you plan to buy this?",
            "dashboard.unlock.buy": "Yes",
            "dashboard.unlock.skip": "No"
        ]
        
        let expectedUnlock =
            DashboardUnlock(
                title: "Congrats! Test lock is unlocked.",
                message: "Do you plan to buy this?",
                addTitle: "Yes",
                skipTitle: "No",
                name: "Test lock",
                category: .other
            )
        
        
        var actualUnlock: DashboardUnlock?
        let expectation = expectation(description: "Waiting for dashboard item")
        let subscription = dashboardViewModel.dashboardItem
            .sink { item in
                guard let item = item else { return }
                expectation.fulfill()
                actualUnlock = item.unlock
            }
        
        dashboardViewModel.dashboardViewReady()
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(expectedUnlock, actualUnlock)
        subscription.cancel()
    }
    
    func testWhenAdderViewReadyThenAdderItemReceived() {
        localizationMock.keysWithValues = [
            "addLock.title": "Add lock",
            "addLock.add": "Add",
            "addLock.form.name": "Name",
            "addLock.form.date": "Date",
            "addLock.form.category": "Category",
            
            "dashboard.lock.category.gadget": "Gadgets",
            "dashboard.lock.category.art": "Art",
            "dashboard.lock.category.gaming": "Gaming",
            "dashboard.lock.category.transportation": "Transportation",
            "dashboard.lock.category.household": "Household",
            "dashboard.lock.category.fitness": "Fitness",
            "dashboard.lock.category.health": "Health",
            "dashboard.lock.category.school": "School",
            "dashboard.lock.category.other": "Other",
        ]
        dateProviderMock.currentDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        
        let expectedAdderItem = AdderItem(
            title: "Add lock",
            doneTitle: "Add",
            nameTitle: "Name",
            dateTitle: "Date",
            categoryTitle: "Category",
            minimumSelectableDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00 (1 minute later)
            categories: [
                DashboardLockCategory(name: "Gadgets", type: .gadget),
                DashboardLockCategory(name: "Art", type: .art),
                DashboardLockCategory(name: "Gaming", type: .gaming),
                DashboardLockCategory(name: "Transportation", type: .transportation),
                DashboardLockCategory(name: "Household", type: .household),
                DashboardLockCategory(name: "Fitness", type: .fitness),
                DashboardLockCategory(name: "Health", type: .health),
                DashboardLockCategory(name: "School", type: .school),
                DashboardLockCategory(name: "Other", type: .other)
            ]
        )
        
        var actualAdderItem: AdderItem!
        
        let expectation = expectation(description: "Waiting for adder item")
        let subscriptions =  dashboardViewModel.adderItem
            .sink { item in
                guard let item = item else { return }
                actualAdderItem = item
                expectation.fulfill()
            }
        
        dashboardViewModel.adderViewReady()
        
        waitForExpectations(timeout: 1)
        subscriptions.cancel()
       
        XCTAssertEqual(expectedAdderItem, actualAdderItem)
    }
    
    func testWhenAddInvalidLockThenPersistenceStoreNotCalled() {
        dateProviderMock.currentDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        let invalidLockEndDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        let validLockEndDate = Date(timeIntervalSince1970: 1659225660) // Sunday, 31 July 2022 00:01:00
        
        dashboardViewModel.addLock(name: nil, endDate: nil, category: nil)
        dashboardViewModel.addLock(name: "", endDate: validLockEndDate, category: .gadget)
        dashboardViewModel.addLock(name: "Some name", endDate: invalidLockEndDate, category: .gadget)
        
        XCTAssertTrue(persistenceMock.storedLocks.isEmpty)
    }
    
    func testWhenAddValidLockThenPersistenceCalledToStoreIt() {
        dateProviderMock.currentDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        
        let expectedLock = Lock(
            name: "Some name",
            startDate: Date(timeIntervalSince1970: 1659225600), // Sunday, 31 July 2022 00:00:00
            endDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
            type: .gadget
        )
        
        dashboardViewModel.addLock(
            name: "Some name",
            endDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
            category: .gadget
        )
        
        XCTAssertEqual(expectedLock, persistenceMock.storedLocks.first)
    }
    
    func testWhenAddValidLockThenNotificationIsSet() {
        dateProviderMock.currentDate = Date(timeIntervalSince1970: 1659225600) // Sunday, 31 July 2022 00:00:00
        let expectedNotification = NotificationItemMock(
            name: "Some name",
            date: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
            category: .gadget
        )
        dashboardViewModel.addLock(
            name: "Some name",
            endDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
            category: .gadget
        )
        
        XCTAssertEqual(expectedNotification, notificationMock.notifications.first)
    }
    
    func testWhenRemoveLockThenPersistenceAndNotificationRemoveLock() {
        persistenceMock.storedLocks = [
            Lock(
                name: "Some name",
                startDate: Date(timeIntervalSince1970: 1659225600), // Sunday, 31 July 2022 00:00:00
                endDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
                type: .gadget
            )
        ]
        notificationMock.notifications = [
            NotificationItemMock(
                name: "Some name",
                date: Date(timeIntervalSince1970: 1659225600), // Sunday, 31 July 2022 00:00:00
                category: .gadget
            )
        ]
        
        dashboardViewModel.removeLock(
            DashboardLock(
                name: "Some name",
                remainingLabel: "Some remaining label",
                category: DashboardLockCategory(name: "Some category name", type: .gadget),
                startDate: Date(timeIntervalSince1970: 1659225600), // Sunday, 31 July 2022 00:00:00
                endDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
                dateProvider: dateProviderMock
            )
        )
        
        XCTAssertTrue(persistenceMock.storedLocks.isEmpty)
        XCTAssertTrue(notificationMock.notifications.isEmpty)
    }
    
    func testWhenUnlockLockThenPersistenceAndNotificationRemoveLockAndStatStored() {
        persistenceMock.storedLocks = [
            Lock(
                name: "Some name",
                startDate: Date(timeIntervalSince1970: 1659225600), // Sunday, 31 July 2022 00:00:00
                endDate: Date(timeIntervalSince1970: 1659225660), // Sunday, 31 July 2022 00:01:00
                type: .gadget
            )
        ]
        notificationMock.notifications = [
            NotificationItemMock(
                name: "Some name",
                date: Date(timeIntervalSince1970: 1659225600), // Sunday, 31 July 2022 00:00:00
                category: .gadget
            )
        ]
        
        let expectedStat = (type: LockCategory.gadget, numberOfBough: 1)
        
        dashboardViewModel.unlock(
            DashboardUnlock(
                title: "Some title",
                message: "Some message",
                addTitle: "Some add title",
                skipTitle: "Some skip title",
                name: "Some name",
                category: .gadget
            ),
            isBought: true
        )
        
        XCTAssertTrue(persistenceMock.storedLocks.isEmpty)
        XCTAssertTrue(notificationMock.notifications.isEmpty)
        XCTAssertEqual(expectedStat.numberOfBough, persistenceMock.storedStats.first{ $0.category == .gadget }!.bought)
    }
}
