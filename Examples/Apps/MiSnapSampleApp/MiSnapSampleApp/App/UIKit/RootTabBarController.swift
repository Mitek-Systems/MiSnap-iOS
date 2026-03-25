//
//  RootTabBarController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = makeTabs()
        addTargetBadge()
    }

    private func makeTabs() -> [UIViewController] {
        let documents = DocumentsViewController()
        let face = FaceViewController()
        let voice = VoiceViewController()
        let nfc = NFCViewController()
        let workflow = WorkflowViewController()

        return [
            makeNavigationController(root: documents, title: "Docs", icon: "person.text.rectangle"),
            makeNavigationController(root: face, title: "Face", icon: "faceid"),
            makeNavigationController(root: voice, title: "Voice", icon: "waveform"),
            makeNavigationController(root: nfc, title: "NFC", icon: "dot.radiowaves.left.and.right"),
            makeNavigationController(root: workflow, title: "Workflow", icon: "checklist")
        ]
    }

    private func makeNavigationController(root: UIViewController, title: String, icon: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationBar.tintColor = .label

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundColor = .clear
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        nav.navigationBar.standardAppearance = standardAppearance
        nav.navigationBar.compactAppearance = standardAppearance
        
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: icon))
        return nav
    }
    
    private func addTargetBadge() {
        let badgeContainer = UIView()
        badgeContainer.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.08)
        badgeContainer.layer.cornerRadius = 10
        badgeContainer.layer.masksToBounds = true
        badgeContainer.layer.borderWidth = 0.5
        badgeContainer.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.25).cgColor
        badgeContainer.isUserInteractionEnabled = false
        
        let badgeLabel = UILabel()
        badgeLabel.text = "UIKit"
        let baseCaption = UIFont.preferredFont(forTextStyle: .caption2)
        badgeLabel.font = UIFont.systemFont(ofSize: baseCaption.pointSize, weight: .semibold)
        badgeLabel.textColor = .secondaryLabel
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeContainer.addSubview(badgeLabel)
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 2),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -2),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -8)
        ])
        
        view.addSubview(badgeContainer)
        
        NSLayoutConstraint.activate([
            badgeContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            badgeContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
}
