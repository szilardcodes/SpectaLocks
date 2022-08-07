//
//  GraphView.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit

struct DataPoint {
    let headerTitle: String
    let footerTitle: String
    let percentage: Float
}

class GraphView: UIView {
    private let barWidth = 80
    private var barHeightConstraints = [NSLayoutConstraint]()

    private let barTag = 0
    private let barBackgroundTag = 1
    private let headerLabelTag = 2
    private let footerLabelTag = 3

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        return contentStackView
    }()


    var numberOfBars: Int = 0 {
        willSet {
            if newValue != numberOfBars {
                configure(numberOfBars: newValue)
            }
        }
    }

    var dataPoints = [DataPoint]() {
        didSet {
            renderDataPoints()
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    init() {
        super.init(frame: .zero)
        addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        contentStackView.axis = .horizontal
        contentStackView.distribution = .fillEqually
        contentStackView.spacing = 15
        contentStackView.alignment = .bottom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(numberOfBars: Int) {
        contentStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        (0..<numberOfBars).forEach { _ in
            // The container
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(container)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: CGFloat(barWidth)),
                container.topAnchor.constraint(equalTo: contentStackView.topAnchor),
                container.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor)
            ])


            // The footer
            let footerLabel = UILabel()
            footerLabel.textAlignment = .center
            footerLabel.adjustsFontSizeToFitWidth = true
            footerLabel.minimumScaleFactor = 0.5
            footerLabel.translatesAutoresizingMaskIntoConstraints = false
            footerLabel.tag = footerLabelTag
            container.addSubview(footerLabel)
            NSLayoutConstraint.activate([
                footerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                footerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                footerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                footerLabel.heightAnchor.constraint(equalToConstant: 15)
            ])

            // The bar backgroundView
            let barBackgroundView = UIView()
            barBackgroundView.tag = barBackgroundTag
            barBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            barBackgroundView.layer.cornerRadius = 5
            barBackgroundView.backgroundColor = UIColor.Stats.graphBarBackgroundColor
            barBackgroundView.tag = barBackgroundTag
            container.addSubview(barBackgroundView)
            NSLayoutConstraint.activate([
                barBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                barBackgroundView.topAnchor.constraint(equalTo: container.topAnchor, constant: 35),
                barBackgroundView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                barBackgroundView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -35)

            ])

            // The bar
            let bar = UIView()
            bar.tag = barTag
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.layer.cornerRadius = 5
            bar.backgroundColor = UIColor.Stats.graphColor
            container.addSubview(bar)
            let heightConstraint = bar.heightAnchor.constraint(equalTo: contentStackView.heightAnchor, multiplier: 0)
            barHeightConstraints.append(heightConstraint)
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                heightConstraint,
                bar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bar.bottomAnchor.constraint(equalTo: footerLabel.topAnchor, constant: -20),
                heightConstraint
            ])


            // The header
            let headerLabel = UILabel()
            headerLabel.textAlignment = .center
            headerLabel.adjustsFontSizeToFitWidth = true
            headerLabel.minimumScaleFactor = 0.5
            headerLabel.font = .systemFont(ofSize: 9)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.tag = headerLabelTag
            container.addSubview(headerLabel)
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                headerLabel.heightAnchor.constraint(equalToConstant: 15),
                headerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                headerLabel.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -10)
            ])
        }
    }

    private func renderDataPoints() {
        dataPoints.enumerated().forEach { index, dataPoint in
            let container = contentStackView.subviews[index]
            let bar = container.subviews.first {
                $0.tag == barTag
            }!
            let previousHeightConstraint = barHeightConstraints[index]
            previousHeightConstraint.isActive = false

            let backgroundContainer = container.subviews.first {
                $0.tag == barBackgroundTag
            }!
            let currentHeightConstraint = bar.heightAnchor.constraint(
                    equalTo: backgroundContainer.heightAnchor,
                    multiplier: CGFloat(dataPoint.percentage)
            )
            currentHeightConstraint.isActive = true
            barHeightConstraints[index] = currentHeightConstraint
            let headerLabel = container.subviews.first {
                $0.tag == headerLabelTag
            } as! UILabel
            headerLabel.text = dataPoint.headerTitle
            let footerLabel = container.subviews.first {
                $0.tag == footerLabelTag
            } as! UILabel
            footerLabel.text = dataPoint.footerTitle
        }
    }
}

