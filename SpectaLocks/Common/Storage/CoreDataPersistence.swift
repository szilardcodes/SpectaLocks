//
//  CoreDataPersistence.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import Combine
import CoreData

class CoreDataPersistence: Persistence {
    var changeOccurred: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    func store(item: Lock) {
        let storedItem = CDLock(context: persistentContainer.viewContext)
        storedItem.id = UUID().uuidString
        storedItem.name = item.name
        storedItem.startDate = item.startDate
        storedItem.endDate = item.endDate
        storedItem.category = item.type.rawValue
        saveContext()
    }

    func get() -> [Lock] {
        do {
            let request = CDLock.fetchRequest()
            return try persistentContainer.viewContext
                    .fetch(request)
                    .map {
                        Lock(
                                name: $0.name!,
                                startDate: $0.startDate!,
                                endDate: $0.endDate!,
                                type: LockCategory(rawValue: $0.category!)!
                        )
                    }
        } catch {
            logger.log("Unable to get locks: \(error.localizedDescription)", .error)
            return []
        }
    }

    func remove(name: String, category: LockCategory) {
        do {
            let request = CDLock.fetchRequest()
            request.predicate = NSPredicate(format: "name = %@ AND category = %@", name, category.rawValue)
            let storedLock = try persistentContainer.viewContext.fetch(request)
            persistentContainer.viewContext.delete(storedLock.first!)
            saveContext()
        } catch {
            logger.log("Unable to remove lock (\(name)): \(error.localizedDescription) ", .error)
        }
    }

    func get() -> [Stat] {
        do {
            let request = CDStat.fetchRequest()
            return try persistentContainer.viewContext
                    .fetch(request)
                    .map {
                        Stat(category: LockCategory(rawValue: $0.category!)!, skipped: Int($0.skipped), bought: Int($0.bought))
                    }
        } catch {
            logger.log("Unable to get stats: \(error.localizedDescription)", .error)
            return []
        }
    }

    func increaseStat(for category: LockCategory, isBought: Bool) {
        do {
            let request = CDStat.fetchRequest()
            request.predicate = NSPredicate(format: "category = %@", category.rawValue)
            let storedStats = try persistentContainer.viewContext.fetch(request)
            let stat: CDStat
            if storedStats.isEmpty {
                stat = CDStat(context: persistentContainer.viewContext)
                stat.bought = 0
                stat.skipped = 0
                stat.category = category.rawValue
            } else {
                stat = storedStats.first!
            }
            if isBought {
                stat.bought += 1
            } else {
                stat.skipped += 1
            }
            saveContext()
        } catch {
            logger.log("Unable to increase stat: \(error.localizedDescription)", .error)
        }
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SpectaLocks")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                changeOccurred.send()
            } catch {
                logger.log("Unable to saveContext: \(error.localizedDescription)", .error)
            }
        }
    }
}

