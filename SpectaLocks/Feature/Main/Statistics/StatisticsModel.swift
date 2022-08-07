//
//  StatisticsModel.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

struct StatisticsGraphItem: Equatable {
    let headerTitle: String
    let footerTitle: String
    let percentage: Float

    private static func getFooter(from category: LockCategory) -> String {
        let footerTitle: String
        switch category {
        case .gadget: footerTitle = "🤖"
        case .art: footerTitle = "🎨"
        case .gaming: footerTitle = "🕹"
        case .transportation: footerTitle = "🚙"
        case .household: footerTitle = "🏡"
        case .fitness: footerTitle = "🏃‍♀️"
        case .health: footerTitle = "🏥"
        case .school: footerTitle = "🎓"
        case .other: footerTitle = "🤷‍♀️"
        }
        return footerTitle
    }

    static func get(from category: LockCategory) -> StatisticsGraphItem {
        StatisticsGraphItem(
                headerTitle: "0%",
                footerTitle: getFooter(from: category),
                percentage: 0
        )
    }

    static func get(from stat: Stat) -> StatisticsGraphItem {
        let percentage = Float(stat.bought) / Float(stat.skipped + stat.bought)
        let headerTitle = "\(Int(percentage * 100))%"

        return StatisticsGraphItem(
                headerTitle: headerTitle,
                footerTitle: getFooter(from: stat.category),
                percentage: percentage
        )
    }
}

struct StatisticItem: Equatable {
    let title: String
    let hintTitle: String
    let hint: String
    let graphItems: [StatisticsGraphItem]

    static func get(from: [Stat], localization: Localization) -> StatisticItem {
        var graphItems = from.map {
            StatisticsGraphItem.get(from: $0)
        }
        LockCategory.allCases.forEach { category in
            if !from.contains(where: { $0.category == category }) {
                graphItems.append(StatisticsGraphItem.get(from: category))
            }
        }

        return StatisticItem(
                title: localization.getText(for: "statistics.title"),
                hintTitle: localization.getText(for: "statistics.hint.title"),
                hint: localization.getText(for: "statistics.hint"),
                graphItems: graphItems
        )
    }
}

