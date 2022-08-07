//
//  WelcomeViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Combine
import UIKit

class WelcomeViewController: UIViewController {
    private let welcomeViewModel: WelcomeViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var isLastItemAnimationReady = false

    private var welcomeItems: [WelcomeItem] {
        welcomeViewModel.items.value
    }

    private var currentScrollIndex = 0 {
        didSet {
            guard !welcomeItems.isEmpty else {
                return
            }
            pageControl.currentPage = currentScrollIndex
            let currentButtonTitle = welcomeItems[currentScrollIndex].buttonTitle
            guard pageControlButton.titleLabel?.text != currentButtonTitle else {
                return
            }
            pageControlButton.titleLabel?.alpha = 0
            UIView.animate(withDuration: 0.5) { [pageControlButton] in
                pageControlButton.setTitle(currentButtonTitle, for: .normal)
                pageControlButton.layoutIfNeeded()
            } completion: { [pageControlButton] _ in
                pageControlButton.titleLabel?.alpha = 1
            }
        }
    }

    private lazy var welcomeScrollView: UIScrollView = {
        let welcomeScrollView = UIScrollView()
        welcomeScrollView.isPagingEnabled = true
        welcomeScrollView.alpha = 0
        welcomeScrollView.showsHorizontalScrollIndicator = false
        welcomeScrollView.translatesAutoresizingMaskIntoConstraints = false
        return welcomeScrollView
    }()

    private lazy var welcomeIcon: UIImageView = {
        let welcomeIcon = UIImageView()
        welcomeIcon.image = UIImage(named: "WelcomeIcon")
        welcomeIcon.alpha = 0
        welcomeIcon.translatesAutoresizingMaskIntoConstraints = false
        return welcomeIcon
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.tintColor = UIColor.Welcome.pageControlTint
        return pageControl
    }()

    private lazy var pageControlButton: UIButton = {
        let pageControlButton: UIButton
        let backgroundColor = UIColor.Welcome.buttonBackground
        let foregroundColor = UIColor.Welcome.buttonForeground

        if #available(iOS 15.0, *) {
            var filled = UIButton.Configuration.filled()
            filled.buttonSize = .large
            filled.baseBackgroundColor = backgroundColor
            filled.baseForegroundColor = foregroundColor
            filled.cornerStyle = .capsule
            pageControlButton = UIButton(configuration: filled)
        } else {
            pageControlButton = UIButton()
            pageControlButton.backgroundColor = backgroundColor
            pageControlButton.setTitleColor(foregroundColor, for: .normal)
            pageControlButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            pageControlButton.layer.cornerRadius = 25
        }
        pageControlButton.alpha = 0
        pageControlButton.translatesAutoresizingMaskIntoConstraints = false
        return pageControlButton
    }()

    init(viewModel: WelcomeViewModel) {
        self.welcomeViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configurePageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pageControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0)
        ])
    }

    private func configureWelcomeIcon() {
        view.addSubview(welcomeIcon)
        NSLayoutConstraint.activate([
            welcomeIcon.widthAnchor.constraint(equalToConstant: 82),
            welcomeIcon.heightAnchor.constraint(equalToConstant: 122),
            welcomeIcon.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            welcomeIcon.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 50)
        ])
    }

    private func configureWelcomeScrollView() {
        view.addSubview(welcomeScrollView)
        welcomeScrollView.pinEdges(to: view.safeAreaLayoutGuide)
        welcomeScrollView.delegate = self
    }

    private func configurePageControlButton() {
        view.addSubview(pageControlButton)
        NSLayoutConstraint.activate([
            pageControlButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
            pageControlButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        pageControlButton.addAction(UIAction(handler: { [self] _ in
            if currentScrollIndex != welcomeItems.count - 1 {
                welcomeScrollView.setContentOffset(CGPoint(x: CGFloat(currentScrollIndex + 1) * view.frame.width, y: 0), animated: true)
            } else {
                welcomeViewModel.complete()
            }
        }), for: .touchDown)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Welcome.background
        configurePageControl()
        configureWelcomeIcon()
        configureWelcomeScrollView()
        configurePageControlButton()
        subscribeViewModel()
        welcomeViewModel.welcomeViewReady()
    }

    private func subscribeViewModel() {
        welcomeViewModel.items
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [self] items in
                    process(items)
                    view.showSubviews(isVisible: !items.isEmpty, isAnimated: true)
                })
                .store(in: &subscriptions)

        welcomeViewModel.failureEvent
                .receive(on: RunLoop.main)
                .sink { [self] event in
                    event.presentAsAlert(on: self) { [weak self] in
                        self?.welcomeViewModel.welcomeViewReady()
                    }
                }
                .store(in: &subscriptions)

        welcomeViewModel.navigationToMainViewControllerEvent
                .receive(on: RunLoop.main)
                .sink { [self] _ in
                    let dashboardViewController = DIManager.shared.resolve(MainViewController.self)
                    dashboardViewController.modalPresentationStyle = .fullScreen
                    present(dashboardViewController, animated: true)
                }
                .store(in: &subscriptions)
    }

    private func process(_ items: [WelcomeItem]) {
        pageControl.numberOfPages = items.count
        welcomeScrollView.contentOffset = .zero
        welcomeScrollView.subviews.forEach { childView in
            childView.removeFromSuperview()
        }

        welcomeScrollView.layoutIfNeeded()

        welcomeScrollView.contentSize = CGSize(
                width: welcomeScrollView.frame.width * CGFloat(items.count),
                height: welcomeScrollView.frame.height
        )

        for i in 0..<items.count {
            let pageView = WelcomePageView()

            pageView.frame = CGRect(
                    x: CGFloat(i) * welcomeScrollView.frame.width,
                    y: 0,
                    width: welcomeScrollView.frame.width,
                    height: welcomeScrollView.frame.height
            )
            pageView.bind(item: items[i])
            welcomeScrollView.addSubview(pageView)
        }
        currentScrollIndex = 0
    }
}

class WelcomePageView: UIView {
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.Welcome.titleTextColor
        titleLabel.font = UIFont.Welcome.title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = UIColor.Welcome.descriptionTextColor
        descriptionLabel.font = UIFont.Welcome.description
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20)

        ])

        addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
        ])
    }

    func bind(item: WelcomeItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
}

extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentScrollIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    }
}

fileprivate extension AppStartFailureEvent {
    func presentAsAlert(on viewController: UIViewController, retrySelected: @escaping () -> ()) {
        let controller = UIAlertController(title: name, message: description, preferredStyle: .alert)
        let action = UIAlertAction(title: retryText, style: .default) { _ in
            retrySelected()
        }
        controller.addAction(action)
        viewController.present(controller, animated: true)
    }
}

