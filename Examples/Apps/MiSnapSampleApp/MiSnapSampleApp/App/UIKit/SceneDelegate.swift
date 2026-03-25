//
//  SceneDelegate.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnap

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = RootTabBarController()
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()

        showLaunchScreen(over: rootViewController)
    }

    private func showLaunchScreen(over rootViewController: UIViewController) {
        let launchViewController = UIKitLaunchScreenViewController()
        launchViewController.modalPresentationStyle = .overFullScreen
        rootViewController.present(launchViewController, animated: false)

        // Match SwiftUI launch behavior: 1.5s delay, then 0.4s ease-out dismissal.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            launchViewController.dismissAnimated()
        }
    }
}

private final class UIKitLaunchScreenViewController: UIViewController {
    private let logoImageView = UIImageView(image: UIImage(named: "MitekLogo"))
    private let versionLabel = UILabel()
    private let contentContainer = UIView()

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func dismissAnimated() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.view.alpha = 0
            self.contentContainer.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.055, green: 0.129, blue: 0.184, alpha: 1)

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        contentContainer.addSubview(logoImageView)

        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.numberOfLines = 0
        versionLabel.textAlignment = .center
        versionLabel.font = .preferredFont(forTextStyle: .footnote)
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        versionLabel.text = "MiSnap \(MiSnap.version())\nApp v\(appVersion) (\(appBuild))"
        contentContainer.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoImageView.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            logoImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentContainer.leadingAnchor, constant: 40),
            logoImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor, constant: -40),

            versionLabel.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            versionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentContainer.leadingAnchor, constant: 24),
            versionLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor, constant: -24),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
}
