//
//  UIViewControllerExt.swift
//  Violet
//
//  Created by Tam Nguyen M. on 12/20/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit

// MARK: - UIViewController Extension
let notificationCenter = NotificationCenter.default

extension UIViewController {
    /// Show alert
    ///
    /// - Parameter message: showing message
    func alert(message: String? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Back", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
