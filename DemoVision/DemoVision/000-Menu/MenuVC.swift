//
//  MenuVC.swift
//  Violet
//
//  Created by Tam Nguyen M. on 9/12/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit

final class MenuVC: UIViewController {

    // MARK: - Property
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Menu"
        configTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}

// MARK: - Config
extension MenuVC {
    func configTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Config.cell)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MenuVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DetectType.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = DetectType(rawValue: indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: Config.cell, for: indexPath)
        cell.textLabel?.text = section.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = DetectType(rawValue: indexPath.row) else { return }
        switch type {
        case .textDetect:
            navigationController?.pushViewController(TextDetectVC(), animated: true)
        case .faceDetect:
            navigationController?.pushViewController(FaceDetectVC(), animated: true)
        case .breakfastDetect:
            navigationController?.pushViewController(BreakfastDetectVC(), animated: true)
        case .arIntergrated:
            navigationController?.pushViewController(DetectAndTrackingVC(), animated: true)
        }
    }
}

// MARK: - Definition
extension MenuVC {
    enum DetectType: Int {
        case textDetect
        case faceDetect
        case breakfastDetect
        case arIntergrated

        var title: String {
            switch self {
            case .textDetect: return "Text Detect"
            case .faceDetect: return "Face Detect"
            case .breakfastDetect: return "Breakfast Detect"
            case .arIntergrated: return "AR Intergrated"
            }
        }

        static var count: Int {
            return 4
        }
    }

    struct Config {
        static let cell = "UITableViewCell"
    }
}
