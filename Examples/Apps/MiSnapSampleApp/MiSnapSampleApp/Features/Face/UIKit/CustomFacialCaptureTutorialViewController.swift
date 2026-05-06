//
//  CustomFacialCaptureTutorialViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

final class CustomFacialCaptureTutorialViewController: UIViewController {
    private let mode: MiSnapFacialCaptureTutorialMode
    private weak var delegate: MiSnapFacialCaptureTutorialViewControllerDelegate?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(for mode: MiSnapFacialCaptureTutorialMode, delegate: MiSnapFacialCaptureTutorialViewControllerDelegate) {
        self.mode = mode
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSubviews()
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // Nil out delegate before dismissal so any in-flight callbacks don't fire
        // after the capture session has already cleaned up.
        delegate = nil
        super.dismiss(animated: flag, completion: completion)
    }

    override var prefersStatusBarHidden: Bool { true }
}

// MARK: - Custom UI
//   The only requirement is that the three action selectors below remain wired to buttons
//   so the SDK can properly handle Cancel, Continue/Manual, and Retry.
private extension CustomFacialCaptureTutorialViewController {
    var symbolName: String {
        switch mode {
        case .help:    return "person.crop.circle.badge.questionmark"
        case .timeout: return "clock.badge.exclamationmark"
        default:       return "questionmark.circle"
        }
    }

    var titleText: String {
        switch mode {
        case .help:    return "Need some help?"
        case .timeout: return "Time's up"
        default:       return ""
        }
    }

    var subtitleText: String {
        switch mode {
        case .help:    return "Make sure your face is well-lit and centered in the oval."
        case .timeout: return "How would you like to proceed?"
        default:       return ""
        }
    }

    func configureSubviews() {
        // SF Symbol illustration
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 72, weight: .thin)
        let symbolView = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: symbolConfig))
        symbolView.translatesAutoresizingMaskIntoConstraints = false
        symbolView.tintColor = .label
        symbolView.contentMode = .scaleAspectFit
        view.addSubview(symbolView)

        // Title
        let titleLabel = makeLabel(titleText, font: .systemFont(ofSize: 26, weight: .semibold))
        view.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = makeLabel(subtitleText, font: .preferredFont(forTextStyle: .body), textColor: .secondaryLabel)
        view.addSubview(subtitleLabel)

        // Vertical button stack — primary action first, cancel last
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 12

        if mode == .timeout {
            buttonStack.addArrangedSubview(makeFilledButton(title: "Retry", selector: #selector(retryTapped)))
        }
        buttonStack.addArrangedSubview(makeFilledButton(title: mode == .timeout ? "Manual" : "Continue", selector: #selector(continueTapped)))
        buttonStack.addArrangedSubview(makePlainButton(title: "Cancel", selector: #selector(cancelTapped)))

        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            symbolView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            symbolView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),

            titleLabel.topAnchor.constraint(equalTo: symbolView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.85),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.85),

            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    func makeFilledButton(title: String, selector: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .capsule
        config.baseForegroundColor = .systemBackground
        config.baseBackgroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var updated = attrs
            updated.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return updated
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    func makePlainButton(title: String, selector: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var updated = attrs
            updated.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            return updated
        }
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    func makeLabel(_ text: String, font: UIFont, textColor: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = font
        label.textColor = textColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
}

// MARK: - Button Actions
// These selectors call back into MiSnapFacialCaptureViewController (via its delegate conformance)
// so the SDK can resume capture, cancel the session, or restart after a timeout.
// Wire your own buttons to these — do not call the delegate methods directly from UI code.
private extension CustomFacialCaptureTutorialViewController {
    /// Cancels the capture session entirely.
    @objc func cancelTapped() {
        delegate?.tutorialCancelButtonAction()
    }

    /// Dismisses the tutorial and resumes capture (help) or switches to manual capture (timeout).
    @objc func continueTapped() {
        delegate?.tutorialContinueButtonAction(for: mode)
    }

    /// Dismisses the tutorial and restarts the capture session. Only relevant for `.timeout` mode.
    @objc func retryTapped() {
        delegate?.tutorialRetryButtonAction?()
    }
}
