//
//  SceneDelegate.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(windowScene: scene)
        window!.rootViewController = DIManager.shared.resolve(WelcomeViewController.self)
        let storage = DIManager.shared.resolve(Storage.self)
        if let selectedThemeOption: String = storage.get(for: .themeSelection),
           let selectedType = ThemeOptionType(rawValue: selectedThemeOption) {
            let interfaceStyle: UIUserInterfaceStyle
            switch selectedType {
            case .light:
                interfaceStyle = UIUserInterfaceStyle.light
            case .dark:
                interfaceStyle = UIUserInterfaceStyle.dark
            case .system:
                interfaceStyle = UIUserInterfaceStyle.unspecified
            }
            window!.overrideUserInterfaceStyle = interfaceStyle
        }
        window!.makeKeyAndVisible()
    }
}
