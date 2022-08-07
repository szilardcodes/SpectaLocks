//
//  DIManager.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

// I suggest to use a ready-to-go DI tool if possible, however, one of the goals of this project is learning and
// experimenting, so in this case, a much simpler but custom DI tool developed
// (inspired by Swinject. https://github.com/Swinject/Swinject).
class DIManager {
    static let shared = DIManager()

    private var dependencyRegisters = Set<DependencyRegister>()
    private var containedDependencies = Set<ContainedDependency>()
    private var numberOfResolveFunctionCallInCurrentResolve = 0
    private let maxNumberOfResolveCall = 200

    init() {
        registerCommonDependencies()
        registerWelcomeDependencies()
        registerMainDependencies()
        registerDashboardDependencies()
        registerLockAdderDependencies()
        registerStatisticsDependencies()
        registerSettingsViewModel()
    }

    func resolve<RequestedDependency>(_ type: RequestedDependency.Type) -> RequestedDependency {
        defer {
            numberOfResolveFunctionCallInCurrentResolve = 0
        }
        let dependencyRegister = dependencyRegisters.first {
            $0.type == type
        }
        guard let dependencyRegister = dependencyRegister else {
            fatalError("No registered method for \(type)!")
        }
        numberOfResolveFunctionCallInCurrentResolve += 1
        guard numberOfResolveFunctionCallInCurrentResolve < maxNumberOfResolveCall else {
            fatalError("Possible circular dependency!")
        }
        if dependencyRegister.scope == .singleton {
            let containedDependency = containedDependencies.first {
                $0.type == type
            }
            if let containedDependency = containedDependency {
                return containedDependency.result as! RequestedDependency
            }
        }
        let newlyCreatedDependency = dependencyRegister.factory(self)
        if dependencyRegister.scope == .singleton {
            containedDependencies.insert(ContainedDependency(type: type, result: newlyCreatedDependency))
        }
        return newlyCreatedDependency as! RequestedDependency
    }


    private func register<Dependency>(
            _ type: Dependency.Type,
            scope: ContainerScope = .singleton,
            factory: @escaping (DIManager) -> Dependency
    ) {
        dependencyRegisters.insert(DependencyRegister(type: type, factory: factory, scope: scope))
    }

    private func registerCommonDependencies() {
        register(Logger.self) { _ in
            PrintLogger()
        }

        register(Environment.self, scope: .singleton) { _ in
            GistUrlEnvironment()
        }

        register(NetworkRequest.self, scope: .singleton) {
            DataTaskNetworkRequest(environment: $0.resolve(Environment.self))
        }

        register(AppInfo.self, scope: .singleton) {
            NetworkOverwrittenAppInfo(networkRequest: $0.resolve(NetworkRequest.self))
        }

        register(DateProvider.self, scope: .singleton) { _ in
            DefaultDateProvider()
        }

        register(Localization.self, scope: .singleton) {
            NetworkOverwrittenLocalization(networkRequest: $0.resolve(NetworkRequest.self))
        }

        register(Storage.self, scope: .singleton) { _ in
            UserDefaultsStorage()
        }

        register(Persistence.self, scope: .singleton) {
            CoreDataPersistence(logger: $0.resolve(Logger.self))
        }

        register(Notification.self, scope: .singleton) {
            LocalNotification(
                    localization: $0.resolve(Localization.self),
                    dateProvider: $0.resolve(DateProvider.self)
            )
        }
    }

    private func registerWelcomeDependencies() {
        register(WelcomeViewModel.self, scope: .factory) {
            WelcomeViewModel(
                    appInfo: $0.resolve(AppInfo.self),
                    localization: $0.resolve(Localization.self),
                    storage: $0.resolve(Storage.self)
            )
        }

        register(WelcomeViewController.self, scope: .factory) {
            WelcomeViewController(viewModel: $0.resolve(WelcomeViewModel.self))
        }
    }

    private func registerMainDependencies() {
        register(MainViewModel.self, scope: .factory) {
            MainViewModel(
                    appInfo: $0.resolve(AppInfo.self),
                    localization: $0.resolve(Localization.self)
            )
        }

        register(MainViewController.self, scope: .factory) {
            MainViewController(mainViewModel: $0.resolve(MainViewModel.self))
        }
    }

    private func registerDashboardDependencies() {
        register(DashboardViewModel.self, scope: .factory) {
            DashboardViewModel(
                    localization: $0.resolve(Localization.self),
                    persistence: $0.resolve(Persistence.self),
                    notification: $0.resolve(Notification.self),
                    dateProvider: $0.resolve(DateProvider.self)
            )
        }

        register(DashboardViewController.self, scope: .factory) {
            DashboardViewController(dashboardViewModel: $0.resolve(DashboardViewModel.self))
        }
    }

    private func registerLockAdderDependencies() {
        register(LockAdderViewController.self, scope: .factory) {
            LockAdderViewController(dashboardViewModel: $0.resolve(DashboardViewModel.self))
        }
    }

    private func registerStatisticsDependencies() {
        register(StatisticsViewModel.self, scope: .factory) {
            StatisticsViewModel(
                    persistence: $0.resolve(Persistence.self),
                    localization: $0.resolve(Localization.self)
            )
        }

        register(StatisticsViewController.self, scope: .factory) {
            StatisticsViewController(statisticsViewModel: $0.resolve(StatisticsViewModel.self))
        }
    }

    private func registerSettingsViewModel() {
        register(SettingsViewModel.self, scope: .factory) {
            SettingsViewModel(
                    localization: $0.resolve(Localization.self),
                    storage: $0.resolve(Storage.self),
                    appInfo: $0.resolve(AppInfo.self)
            )
        }

        register(SettingsViewController.self, scope: .factory) {
            SettingsViewController(settingsViewModel: $0.resolve(SettingsViewModel.self))
        }
    }
}

private enum ContainerScope {
    case factory, singleton
}

private struct DependencyRegister: Hashable {
    let id = UUID().uuidString
    let type: Any.Type
    let factory: (DIManager) -> Any
    let scope: ContainerScope

    static func ==(lhs: DependencyRegister, rhs: DependencyRegister) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type && lhs.scope == rhs.scope
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(scope)
    }
}

private struct ContainedDependency: Hashable {
    let id = UUID().uuidString
    let type: Any.Type
    let result: Any

    static func ==(lhs: ContainedDependency, rhs: ContainedDependency) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
