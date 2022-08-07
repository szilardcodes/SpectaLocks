//
//  LockAdderViewController.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit
import Combine

class LockAdderViewController: UIViewController {

    private let dashboardViewModel: DashboardViewModel

    private var regularConstraints = [NSLayoutConstraint]()
    private var compactConstraints = [NSLayoutConstraint]()

    private lazy var backgroundControl: UIControl = {
        let backgroundControl = UIControl()
        backgroundControl.translatesAutoresizingMaskIntoConstraints = false
        return backgroundControl
    }()

    private func addBackgroundControl() {
        view.addSubview(backgroundControl)
        backgroundControl.pinEdges(to: view.safeAreaLayoutGuide)
    }

    private lazy var lockNameTitle: UILabel = {
        let lockNameTitle = UILabel()
        lockNameTitle.font = UIFont.Dashboard.addLockFormTitle
        lockNameTitle.textColor = UIColor.Dashboard.addLockFormTitle
        lockNameTitle.translatesAutoresizingMaskIntoConstraints = false
        return lockNameTitle
    }()

    private lazy var lockNameTextField: UITextField = {
        let lockNameTextField = UITextField()
        lockNameTextField.font = UIFont.Dashboard.addLockFormTitle
        lockNameTextField.borderStyle = .roundedRect
        lockNameTextField.backgroundColor = UIColor.Dashboard.addLockTitleFormValueBackgroundColor
        lockNameTextField.textColor = UIColor.Dashboard.lockTitleTextColor
        lockNameTextField.translatesAutoresizingMaskIntoConstraints = false
        return lockNameTextField
    }()

    private func addNameField() {
        view.addSubview(lockNameTitle)
        view.addSubview(lockNameTextField)

        regularConstraints.append(contentsOf: [
            lockNameTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            lockNameTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            lockNameTitle.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),

            lockNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            lockNameTextField.topAnchor.constraint(equalTo: lockNameTitle.bottomAnchor, constant: 5),
            lockNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            lockNameTitle.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])

        compactConstraints.append(contentsOf: [
            lockNameTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            lockNameTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),

            lockNameTextField.topAnchor.constraint(equalTo: lockNameTitle.bottomAnchor, constant: 5),
            lockNameTextField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            lockNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
        ])
    }

    private lazy var lockDateTitle: UILabel = {
        let lockDateTitle = UILabel()
        lockDateTitle.font = UIFont.Dashboard.addLockFormTitle
        lockDateTitle.textColor = UIColor.Dashboard.addLockFormTitle
        lockDateTitle.translatesAutoresizingMaskIntoConstraints = false
        return lockDateTitle
    }()

    private lazy var lockDatePicker: UIDatePicker = {
        let lockDatePicker = UIDatePicker()
        lockDatePicker.preferredDatePickerStyle = .compact

        lockDatePicker.datePickerMode = .dateAndTime

        lockDatePicker.tintColor = UIColor.Dashboard.lockAdderBackground
        lockDatePicker.setValue(UIColor.Dashboard.lockAdderBackground, forKeyPath: "textColor")
        lockDatePicker.locale = Locale(identifier: "en")
        lockDatePicker.translatesAutoresizingMaskIntoConstraints = false
        return lockDatePicker
    }()


    private func addDateField() {
        view.addSubview(lockDateTitle)
        view.addSubview(lockDatePicker)

        regularConstraints.append(contentsOf: [
            lockDateTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            lockDateTitle.topAnchor.constraint(equalTo: lockNameTextField.bottomAnchor, constant: 30),

            lockDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            lockDatePicker.topAnchor.constraint(equalTo: lockDateTitle.bottomAnchor, constant: 5),
        ])

        compactConstraints.append(contentsOf: [
            lockDateTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            lockDateTitle.leadingAnchor.constraint(equalTo: lockNameTextField.trailingAnchor, constant: 15),

            lockDatePicker.leadingAnchor.constraint(equalTo: lockDateTitle.leadingAnchor),
            lockDatePicker.topAnchor.constraint(equalTo: lockDateTitle.bottomAnchor, constant: 5)
        ])
    }

    private lazy var lockCategoryTitle: UILabel = {
        let lockDateTitle = UILabel()
        lockDateTitle.font = UIFont.Dashboard.addLockFormTitle
        lockDateTitle.textColor = UIColor.Dashboard.addLockFormTitle
        lockDateTitle.translatesAutoresizingMaskIntoConstraints = false
        return lockDateTitle
    }()

    private lazy var lockCategoryPicker: UIPickerView = {
        let lockCategoryPicker = UIPickerView()
        lockCategoryPicker.translatesAutoresizingMaskIntoConstraints = false
        return lockCategoryPicker
    }()

    private func addCategoryField() {
        view.addSubview(lockCategoryTitle)
        view.addSubview(lockCategoryPicker)

        regularConstraints.append(contentsOf: [
            lockCategoryTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            lockCategoryTitle.topAnchor.constraint(equalTo: lockDatePicker.bottomAnchor, constant: 30),

            lockCategoryPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            lockCategoryPicker.topAnchor.constraint(equalTo: lockCategoryTitle.bottomAnchor, constant: 5),
            lockCategoryPicker.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        compactConstraints.append(contentsOf: [
            lockCategoryTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            lockCategoryTitle.topAnchor.constraint(equalTo: lockNameTextField.bottomAnchor, constant: 30),
            lockDateTitle.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            lockCategoryTitle.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),

            lockCategoryPicker.leadingAnchor.constraint(equalTo: lockCategoryTitle.leadingAnchor),
            lockCategoryPicker.topAnchor.constraint(equalTo: lockCategoryTitle.bottomAnchor, constant: 15),
            lockCategoryPicker.trailingAnchor.constraint(equalTo: lockCategoryTitle.trailingAnchor)
        ])

        lockCategoryPicker.delegate = self
        lockCategoryPicker.dataSource = self
    }

    func layoutTrait(traitCollection: UITraitCollection) {
        if traitCollection.verticalSizeClass == .compact /* && traitCollection.verticalSizeClass == .regular */ {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }

    init(dashboardViewModel: DashboardViewModel) {
        self.dashboardViewModel = dashboardViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem()
        doneButton.tintColor = UIColor.Dashboard.lockAdderBackground
        return doneButton
    }()

    private func addDoneButton() {
        doneButton.target = self
        doneButton.action = #selector(dismissPanel)
        navigationItem.setRightBarButton(doneButton, animated: false)
    }

    private var subscriptions = Set<AnyCancellable>()

    private func subscribeViewModel() {
        dashboardViewModel.adderItem
                .sink { [self] adderItem in
                    guard let adderItem = adderItem else {
                        return
                    }
                    title = adderItem.title
                    doneButton.title = adderItem.doneTitle
                    lockNameTitle.text = adderItem.nameTitle
                    lockDateTitle.text = adderItem.dateTitle
                    lockDatePicker.minimumDate = adderItem.minimumSelectableDate
                    lockCategoryTitle.text = adderItem.categoryTitle
                    lockCategoryPicker.reloadAllComponents()
                }
                .store(in: &subscriptions)
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.Main.background
        addBackgroundControl()
        addDoneButton()
        addNameField()
        addDateField()
        addCategoryField()

        backgroundControl.addAction(UIAction(handler: { action in
            self.view.endEditing(true)
        }), for: .touchUpInside)

        layoutTrait(traitCollection: traitCollection)
        subscribeViewModel()
        dashboardViewModel.adderViewReady()
    }

    @objc private func dismissPanel(sender: UIButton) {
        dashboardViewModel.addLock(
                name: lockNameTextField.text,
                endDate: lockDatePicker.date,
                category: dashboardViewModel.adderItem.value?.categories[lockCategoryPicker.selectedRow(inComponent: 0)].type
        )

        navigationController!.presentationController!.delegate!.presentationControllerDidDismiss?(navigationController!.presentationController!)
        dismiss(animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard traitCollection.userInterfaceStyle == previousTraitCollection?.userInterfaceStyle else {
            return
        }
        layoutTrait(traitCollection: traitCollection)
    }
}

extension LockAdderViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dashboardViewModel.adderItem.value?.categories.count ?? 0
    }
}

extension LockAdderViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var viewForRow: CategoryCell
        if let label = view as? CategoryCell {
            viewForRow = label
        } else {
            viewForRow = CategoryCell()
        }
        guard let categories = dashboardViewModel.adderItem.value?.categories else {
            return viewForRow
        }
        viewForRow.bind(labelText: categories[row].name)
        viewForRow.sizeToFit()
        return viewForRow
    }
}

class CategoryCell: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(labelText: String) {
        label.text = labelText
    }
}

