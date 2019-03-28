//
//  MenuVC.swift
//  DemoVision
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
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - Config
extension MenuVC {
    func configTableView() {
        let nib = UINib(nibName: "MenuCell", bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: "MenuCell")
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
        guard let section = DetectType(rawValue: indexPath.row),
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell" , for: indexPath) as? MenuCell else { return UITableViewCell() }
        cell.configView(title: section.title, content: section.description)
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
            break
            // navigationController?.pushViewController(DetectAndTrackingVC(), animated: true)
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

        var description: String {
            switch self {
            case .textDetect: return "Using VNDetectTextRectanglesRequest and VNImageRectForNormalizedRect"
            case .faceDetect: return "Using VNDetectFaceRectanglesRequest/VNDetectFaceLandmarksRequest and VNImageRectForNormalizedRect/VNImagePointForFaceLandmarkPoint"
            case .breakfastDetect: return "Using VNCoreMLModel and VNImageRectForNormalizedRect"
            case .arIntergrated: return "/WIP 😂"
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
