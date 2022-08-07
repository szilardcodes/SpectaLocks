//
//  WelcomeItem.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

struct WelcomeItem: Equatable {
    let title: String
    let description: String?
    let buttonTitle: String

    static func buildGreetings(with localization: Localization) -> WelcomeItem {
        WelcomeItem(
                title: localization.getText(for: "welcome.greetings.title"),
                description: localization.getText(for: "welcome.greetings.description"),
                buttonTitle: localization.getText(for: "welcome.greetings.buttonTitle")
        )
    }

    static func buildExplanatory(with localization: Localization) -> WelcomeItem {
        WelcomeItem(
                title: localization.getText(for: "welcome.explanatory.title"),
                description: localization.getText(for: "welcome.explanatory.description"),
                buttonTitle: localization.getText(for: "welcome.explanatory.buttonTitle")
        )
    }

    static func buildCompletion(with localization: Localization) -> WelcomeItem {
        WelcomeItem(
                title: localization.getText(for: "welcome.completion.title"),
                description: localization.getText(for: "welcome.completion.description"),
                buttonTitle: localization.getText(for: "welcome.completion.buttonTitle")
        )
    }
}


struct AppStartFailureEvent: Equatable {
    let name: String
    let description: String
    let retryText: String

    static func buildConnectivity(with localization: Localization) -> AppStartFailureEvent {
        AppStartFailureEvent(
                name: localization.getText(for: "welcome.fail.connectivity.title"),
                description: localization.getText(for: "welcome.fail.connectivity.description"),
                retryText: localization.getText(for: "welcome.fail.connectivity.retry")
        )
    }

    static func buildDisabledApp(with localization: Localization) -> AppStartFailureEvent {
        AppStartFailureEvent(
                name: localization.getText(for: "welcome.fail.disabled.title"),
                description: localization.getText(for: "welcome.fail.disabled.description"),
                retryText: localization.getText(for: "welcome.fail.disabled.retry")
        )
    }
}
