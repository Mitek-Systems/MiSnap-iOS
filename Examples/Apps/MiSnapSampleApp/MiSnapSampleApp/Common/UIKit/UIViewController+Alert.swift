//
//  UIViewController+Alert.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(from config: AlertConfig) {
        let alertController = UIAlertController(
            title: config.title,
            message: config.message,
            preferredStyle: .alert
        )

        switch (config.primaryButton, config.secondaryButton) {
        case let (.some(primary), .some(secondary)):
            alertController.addAction(UIAlertAction(title: primary.title, style: .default) { _ in
                primary.action()
            })
            alertController.addAction(UIAlertAction(title: secondary.title, style: .cancel) { _ in
                secondary.action()
            })
        case let (.some(primary), .none):
            alertController.addAction(UIAlertAction(title: primary.title, style: .default) { _ in
                primary.action()
            })
        default:
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
        }

        present(alertController, animated: true)
    }
}
