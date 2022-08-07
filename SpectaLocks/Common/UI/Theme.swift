//
//  Theme.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import UIKit

extension UIColor {
    enum Welcome {
        static var background = UIColor(named: "WelcomeBackgroundColor")
        static var titleTextColor = UIColor(named: "WelcomeTitleColor")
        static var descriptionTextColor = UIColor(named: "WelcomeDescriptionColor")
        static var pageControlTint = UIColor(named: "WelcomePageControlTint")
        static var buttonBackground = UIColor(named: "WelcomeButtonBackground")
        static var buttonForeground = UIColor(named: "WelcomeButtonForeground")
    }

    enum Main {
        static let iconTint = UIColor(named: "MainIconTint")
        static let iconSelectionTint = UIColor(named: "MainIconSelectionTint")
        static let background = UIColor(named: "DashboardBackgroundColor")
    }

    enum Dashboard {
        static let titleTextColor = UIColor(named: "WelcomeTitleColor")
        static let emptyTitleTextColor = UIColor(named: "EmptyTitleTextColor")
        static let lockTitleTextColor = UIColor(named: "LockTitleTextColor")
        static let categoryTitleTextColor = UIColor(named: "CategoryTitleTextColor")
        static let remainingLabelTextColor = UIColor(named: "RemainingTitleTextColor")
        static let progressTrackColor = UIColor(named: "ProgressTrackColor")
        static let progressColor = UIColor(named: "ProgressColor")
        static let lockAdderBackground = UIColor(named: "LockAdderBackground")
        static let lockAdderForeground = UIColor(named: "LockAdderForeground")
        static let addLockFormTitle = UIColor(named: "AddLockFormTitle")
        static let addLockTitleFormValueBackgroundColor = UIColor(named: "AddLockTitleFormValueBackgroundColor")
    }

    enum Popup {
        static let titleTextColor = UIColor(named: "PopupTitleColor")
        static let messageTextColor = UIColor(named: "PopupMessageColor")
        static let backgroundColor = UIColor(named: "PopupBackgroundColor")
        static let buttonTextColor = UIColor(named: "PopupButtonTextColor")
        static let positiveButtonBackgroundColor = UIColor(named: "PopupPositiveButtonBackgroundColor")
        static let negativeButtonBackgroundColor = UIColor(named: "PopupNegativeButtonBackgroundColor")
    }

    enum Stats {
        static let graphColor = UIColor(named: "StatsGraphColor")
        static let graphBarBackgroundColor = UIColor(named: "StatGraphBarBackgroundColor")
        static let hintColor = UIColor(named: "StatHintColor")
    }
}

extension UIFont {
    enum Welcome {
        static let title = UIFont.boldSystemFont(ofSize: 36)
        static let description = UIFont.preferredFont(forTextStyle: .subheadline)
    }

    enum Dashboard {
        static let title = UIFont.preferredFont(forTextStyle: .title1)
        static let emptyTitle = UIFont.preferredFont(forTextStyle: .headline)
        static let lockTitle = UIFont.preferredFont(forTextStyle: .body)
        static let remainingLabel = UIFont.preferredFont(forTextStyle: .footnote)
        static let categoryTitle = UIFont.preferredFont(forTextStyle: .title2)
        static let addLockFormTitle = UIFont.preferredFont(forTextStyle: .caption1)
    }

    enum Popup {
        static let title = UIFont.preferredFont(forTextStyle: .title2)
        static let message = UIFont.preferredFont(forTextStyle: .body)
    }
}

