//
//  UIViewExtension.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation
import UIKit

extension UIView {
    func pinEdges(
            to other: UIView,
            leadingConstant: CGFloat = 0,
            trailingConstant: CGFloat = 0,
            topConstant: CGFloat = 0,
            bottomConstant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: leadingConstant),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: trailingConstant),
            topAnchor.constraint(equalTo: other.topAnchor, constant: topConstant),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: bottomConstant)
        ])
    }

    func pinEdges(to other: UILayoutGuide) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor),
            trailingAnchor.constraint(equalTo: other.trailingAnchor),
            topAnchor.constraint(equalTo: other.topAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor)
        ])
    }

    func showSubviews(isVisible: Bool, isAnimated: Bool = false) {
        subviews.forEach { subview in
            if isAnimated {
                UIView.animate(withDuration: 1) {
                    subview.alpha = isVisible ? 1 : 0
                }
            } else {
                subview.alpha = isVisible ? 1 : 0
            }
        }
    }
}

