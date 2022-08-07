//
//  StatisticsViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit
import Combine

class StatisticsViewController: UIViewController {

    private let statisticsViewModel: StatisticsViewModel
    private var subscriptions = Set<AnyCancellable>()

    private lazy var graphView: GraphView = {
        let graphView = GraphView()
        graphView.translatesAutoresizingMaskIntoConstraints = false
        return graphView
    }()


    private lazy var hintLabel: UILabel = {
        let hintLabel = UILabel()
        //hintLabel.textColor = UIColor.Stats.hintColor
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.font = UIFont.Dashboard.emptyTitle
        hintLabel.numberOfLines = 0
        return hintLabel
    }()


    init(statisticsViewModel: StatisticsViewModel) {
        self.statisticsViewModel = statisticsViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        view.backgroundColor = UIColor.Main.background
        configureGraphView()

        configureHintLabel()
        subscribeViewModel()
        statisticsViewModel.statisticsViewReady()
    }

    override func viewDidAppear(_ animated: Bool) {
        statisticsViewModel.statisticsViewReady()
    }

    private func subscribeViewModel() {
        statisticsViewModel.statisticItems
                .sink { [self] item in
                    guard let item = item else {
                        return
                    }
                    navigationItem.title = item.title
                    graphView.numberOfBars = item.graphItems.count
                    graphView.dataPoints = item.graphItems.map {
                        DataPoint(
                                headerTitle: $0.headerTitle,
                                footerTitle: $0.footerTitle,
                                percentage: $0.percentage
                        )
                    }
                    hintLabel.text = item.hint
                }
                .store(in: &subscriptions)
    }


    private func configureHintLabel() {
        view.addSubview(hintLabel)
        NSLayoutConstraint.activate([
            hintLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hintLabel.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 10),
            hintLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            hintLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func configureGraphView() {
        view.addSubview(graphView)
        NSLayoutConstraint.activate([
            graphView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            graphView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            graphView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            graphView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
        ])
    }
}

