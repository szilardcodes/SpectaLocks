//
//  SettingsViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit
import Combine

class SettingsViewController: UIViewController {

    private let settingsViewModel: SettingsViewModel
    private var subscriptions = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var themeTitle: UILabel = {
        let themeTitle = UILabel()
        themeTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        themeTitle.translatesAutoresizingMaskIntoConstraints = false
        themeTitle.numberOfLines = 0
        return themeTitle
    }()

    private var themeSelector: UISegmentedControl!

    private lazy var siteTitle: UILabel = {
        let siteTitle = UILabel()
        siteTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        siteTitle.translatesAutoresizingMaskIntoConstraints = false
        siteTitle.numberOfLines = 0
        return siteTitle
    }()

    private lazy var siteLabel: UnderlinedLabel = {
        let siteLabel = UnderlinedLabel()
        siteLabel.translatesAutoresizingMaskIntoConstraints = false
        return siteLabel
    }()

    private lazy var contactTitleLabel: UILabel = {
        let contactTitleLabel = UILabel()
        contactTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contactTitleLabel.numberOfLines = 0
        contactTitleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        return contactTitleLabel
    }()

    private lazy var contactLabel: UILabel = {
        let contactLabel = UILabel()
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.numberOfLines = 0
        contactLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        return contactLabel
    }()

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.Main.background
        subscribeViewModel()
        settingsViewModel.settingsViewReady()
    }

    private func configureThemeTitle() {
        contentView.addSubview(themeTitle)
        NSLayoutConstraint.activate([
            themeTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            themeTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            themeTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            themeTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }

    private func configureThemeSelector() {
        let themeOptions = settingsViewModel.settingsItem.value!.themeOptions
        themeSelector = UISegmentedControl(items: themeOptions.map {
            $0.title
        })
        if let selectedOptionIndex = themeOptions.firstIndex(where: { $0.isSelected }) {
            themeSelector.selectedSegmentIndex = selectedOptionIndex
        }
        themeSelector.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(themeSelector)
        NSLayoutConstraint.activate([
            themeSelector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            themeSelector.topAnchor.constraint(equalTo: themeTitle.bottomAnchor, constant: 10),
            themeSelector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            themeSelector.heightAnchor.constraint(equalToConstant: 40)
        ])
        themeSelector.backgroundColor = UIColor.Stats.graphBarBackgroundColor
        themeSelector.selectedSegmentTintColor = UIColor.Stats.graphColor
        themeSelector.addAction(UIAction(handler: { [self] _ in
            let selectedType = themeOptions[themeSelector.selectedSegmentIndex].type
            let window = UIApplication.shared.windows.filter {
                        $0.isKeyWindow
                    }
                    .first!
            let interfaceStyle: UIUserInterfaceStyle
            switch selectedType {
            case .light:
                interfaceStyle = UIUserInterfaceStyle.light
            case .dark:
                interfaceStyle = UIUserInterfaceStyle.dark
            case .system:
                interfaceStyle = UIUserInterfaceStyle.unspecified
            }
            window.overrideUserInterfaceStyle = interfaceStyle
            settingsViewModel.themeSelected(option: selectedType)

        }), for: .valueChanged)
    }

    private func subscribeViewModel() {
        settingsViewModel.settingsItem
                .sink { [self] item in
                    guard let item = item else {
                        return
                    }
                    setupScrollViewConstraints()
                    setupContentViewConstraints()
                    configureThemeTitle()
                    configureThemeSelector()
                    configureSiteLabels()
                    configureContactLabels()
                    navigationItem.title = item.title
                    themeTitle.text = item.themeOptionTitle
                    siteTitle.text = item.siteTitle
                    siteLabel.text = item.siteLinkTitle
                    siteLabel.urlToOpen = item.siteLink
                    contactTitleLabel.text = item.contactTitle
                    contactLabel.text = item.contact
                }
                .store(in: &subscriptions)
    }

    private func setupScrollViewConstraints() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func setupContentViewConstraints() {
        scrollView.addSubview(contentView)
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(250)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            heightConstraint,
        ])
    }

    private func configureSiteLabels() {
        contentView.addSubview(siteTitle)
        NSLayoutConstraint.activate([
            siteTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            siteTitle.topAnchor.constraint(equalTo: themeSelector.bottomAnchor, constant: 20),
            siteTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            siteTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])

        contentView.addSubview(siteLabel)
        NSLayoutConstraint.activate([
            siteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            siteLabel.topAnchor.constraint(equalTo: siteTitle.bottomAnchor, constant: 10),
            siteLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10),
            siteLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
    }

    private func configureContactLabels() {
        contentView.addSubview(contactTitleLabel)
        NSLayoutConstraint.activate([
            contactTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contactTitleLabel.topAnchor.constraint(equalTo: siteLabel.bottomAnchor, constant: 20),
            contactTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contactTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])

        contentView.addSubview(contactLabel)
        NSLayoutConstraint.activate([
            contactLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contactLabel.topAnchor.constraint(equalTo: contactTitleLabel.bottomAnchor, constant: 10),
            contactLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contactLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            contactLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

class UnderlinedLabel: UILabel {
    var urlToOpen: String?

    override var text: String? {
        didSet {
            guard let text = text else {
                return
            }
            let textRange = NSRange(location: 0, length: text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: textRange)
            self.attributedText = attributedText
        }
    }

    init() {
        super.init(frame: .zero)
        numberOfLines = 0
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if let urlString = urlToOpen, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

