//
//  MainViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit
import Combine

class MainViewController: UITabBarController {
    private let mainViewModel: MainViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureTabBar() {
        tabBar.unselectedItemTintColor = UIColor.Main.iconTint
        tabBar.tintColor = UIColor.Main.iconSelectionTint
        tabBar.barTintColor = UIColor.Main.background
        tabBar.isTranslucent = false
        delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Main.background
        configureTabBar()
        subscribeViewModel()
        mainViewModel.mainViewReady()
    }

    private func subscribeViewModel() {
        mainViewModel.mainOptions
                .receive(on: RunLoop.main)
                .sink { options in
                    self.process(options: options)
                }
                .store(in: &subscriptions)
    }

    private func configureChild(navBar: inout UINavigationBar) {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        navBar.prefersLargeTitles = true
        navBar.topItem?.largeTitleDisplayMode = .automatic

        navBar.standardAppearance = standardAppearance
        navBar.scrollEdgeAppearance = standardAppearance
        navBar.compactAppearance = standardAppearance

        if #available(iOS 15.0, *) {
            navBar.compactScrollEdgeAppearance = standardAppearance
        }
    }

    private func process(options: [MainOption]) {
        var viewControllers = [UIViewController]()
        options.forEach { option in
            let viewController: UIViewController
            let imageAssetName: String
            switch option.type {
            case .dashboard:
                viewController = DIManager.shared.resolve(DashboardViewController.self)
                imageAssetName = "LockIcon"
            case .statistics:
                viewController = DIManager.shared.resolve(StatisticsViewController.self)
                imageAssetName = "GraphIcon"
            case .settings:
                viewController = DIManager.shared.resolve(SettingsViewController.self)
                imageAssetName = "SettingsIcon"
            }
            let image = UIImage(named: imageAssetName)
            viewController.tabBarItem = UITabBarItem(title: option.title, image: image, selectedImage: image)
            let wrappedViewController = UINavigationController(rootViewController: viewController)
            wrappedViewController.navigationItem.largeTitleDisplayMode = .automatic
            var navBar = wrappedViewController.navigationBar
            configureChild(navBar: &navBar)
            viewControllers.append(wrappedViewController)
        }
        self.viewControllers = viewControllers
    }
}

extension MainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        true;
    }

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TabBarAnimatedTransitioning(parentTabBar: tabBarController)
    }
}

class TabBarAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    private let parentTabBar: UITabBarController

    init(parentTabBar: UITabBarController) {
        self.parentTabBar = parentTabBar
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            return
        }
        guard let startViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let destinationViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        let startIndex = parentTabBar.children.firstIndex(of: startViewController) ?? 0
        let destinationIndex = parentTabBar.children.firstIndex(of: destinationViewController) ?? 0

        let rotation = startIndex < destinationIndex ? 45 : -45

        destinationView.alpha = 0.0
        destinationView.transform = .init(translationX: 0, y: destinationView.frame.height)
                .rotated(by: CGFloat(rotation))
                .scaledBy(x: 0.8, y: 0.8)

        destinationView.layer.masksToBounds = true
        destinationView.layer.borderWidth = 0.5
        destinationView.layer.cornerRadius = destinationView.frame.width / 20

        destinationView.layer.shadowColor = UIColor.black.cgColor
        destinationView.layer.shadowOpacity = 0
        destinationView.layer.shadowOffset = CGSize(width: 10, height: 10)
        destinationView.layer.shadowRadius = 10

        transitionContext.containerView.addSubview(destinationView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.95, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            destinationView.alpha = 1.0
            destinationView.transform = .identity
        }, completion: { [self] _ in
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.05) {
                destinationView.layer.borderWidth = 0
                destinationView.layer.cornerRadius = 0
            } completion: {
                transitionContext.completeTransition($0)
            }
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1
    }
}

