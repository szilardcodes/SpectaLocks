//
//  PopupViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit

struct PopupAction {
    let title: String
    let selectionHandler: () -> ()
}

class PopupViewController: UIViewController {
    private let popupTitle: String
    private let message: String
    private let positiveAction: PopupAction
    private let negativeAction: PopupAction
    private let padding = CGFloat(15)

    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.Popup.backgroundColor
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 0.2
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.Popup.buttonTextColor
        titleLabel.font = UIFont.Popup.title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = UIFont.Popup.message
        messageLabel.textColor = UIColor.Popup.messageTextColor
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()

    private lazy var positiveActionButton: UIButton = {
        var positiveActionButton: UIButton
        let backgroundColor = UIColor.Popup.negativeButtonBackgroundColor
        let foregroundColor = UIColor.Popup.buttonTextColor
        if #available(iOS 15.0, *) {
            var filled = UIButton.Configuration.filled()
            filled.buttonSize = .large
            filled.baseBackgroundColor = backgroundColor
            filled.baseForegroundColor = foregroundColor
            filled.cornerStyle = .capsule
            positiveActionButton = UIButton(configuration: filled)
        } else {
            positiveActionButton = UIButton()
            positiveActionButton.backgroundColor = backgroundColor
            positiveActionButton.setTitleColor(foregroundColor, for: .normal)
            positiveActionButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            positiveActionButton.layer.cornerRadius = 15
        }

        positiveActionButton.addAction(UIAction(handler: { [self] _ in
            positiveAction.selectionHandler()
            dismiss(animated: true)
        }), for: .touchUpInside)

        positiveActionButton.translatesAutoresizingMaskIntoConstraints = false
        return positiveActionButton
    }()


    private lazy var negativeActionButton: UIButton = {
        let negativeActionButton: UIButton
        let backgroundColor = UIColor.Popup.positiveButtonBackgroundColor
        let foregroundColor = UIColor.Popup.buttonTextColor
        if #available(iOS 15.0, *) {
            var filled = UIButton.Configuration.filled()
            filled.buttonSize = .large
            filled.baseBackgroundColor = backgroundColor
            filled.baseForegroundColor = foregroundColor
            filled.cornerStyle = .capsule
            negativeActionButton = UIButton(configuration: filled)
        } else {
            negativeActionButton = UIButton()
            negativeActionButton.backgroundColor = backgroundColor
            negativeActionButton.setTitleColor(foregroundColor, for: .normal)
            negativeActionButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            negativeActionButton.layer.cornerRadius = 15
        }

        negativeActionButton.addAction(UIAction(handler: { [self] _ in
            negativeAction.selectionHandler()
            dismiss(animated: true)
        }), for: .touchUpInside)

        negativeActionButton.translatesAutoresizingMaskIntoConstraints = false
        return negativeActionButton
    }()

    init(title popupTitle: String, message: String, positiveAction: PopupAction, negativeAction: PopupAction) {
        self.popupTitle = popupTitle
        self.message = message
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
        super.init(nibName: nil, bundle: nil)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        isModalInPresentation = true
        modalPresentationStyle = .pageSheet
        modalTransitionStyle = .coverVertical
        view.addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(positiveActionButton)
        containerView.addSubview(negativeActionButton)

        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 250)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: padding),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])

        NSLayoutConstraint.activate([
            positiveActionButton.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -10),
            positiveActionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            positiveActionButton.heightAnchor.constraint(equalToConstant: 40),
            positiveActionButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.4)
        ])

        NSLayoutConstraint.activate([
            negativeActionButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 10),
            negativeActionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            negativeActionButton.heightAnchor.constraint(equalToConstant: 40),
            negativeActionButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.4)
        ])


        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: positiveActionButton.topAnchor, constant: padding),
        ])

        titleLabel.text = popupTitle
        messageLabel.text = message
        positiveActionButton.setTitle(positiveAction.title, for: .normal)
        negativeActionButton.setTitle(negativeAction.title, for: .normal)
    }
}

