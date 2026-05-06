//
//  CustomTutorialViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnap
import MiSnapUX

final class CustomTutorialViewController: UIViewController {
    private let documentType: MiSnapScienceDocumentType
    private let tutorialMode: MiSnapUxTutorialMode
    private let mode: MiSnapMode
    private let statuses: [NSNumber]?
    private let image: UIImage?
    private weak var delegate: MiSnapTutorialViewControllerDelegate?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        for documentType: MiSnapScienceDocumentType,
        tutorialMode: MiSnapUxTutorialMode,
        mode: MiSnapMode,
        statuses: [NSNumber]?,
        image: UIImage?,
        delegate: MiSnapTutorialViewControllerDelegate
    ) {
        self.documentType = documentType
        self.tutorialMode = tutorialMode
        self.mode = mode
        self.statuses = statuses
        self.image = image
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.view.subviews.forEach { $0.removeFromSuperview() }
            self?.configureSubviews()
        })
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
//   so the SDK can properly handle Cancel, Continue/Manual, and Retry/Retake.
private extension CustomTutorialViewController {
    func configureSubviews() {
        switch tutorialMode {
        case .instruction: configureForInstruction()
        case .help:        configureForHelp()
        case .timeout:     configureForTimeout()
        case .review:      configureForReview()
        default:           break
        }
    }

    // MARK: - Mode Layouts

    func configureForInstruction() {
        layout(
            symbolName: "doc.text.viewfinder",
            title: "Before you begin",
            subtitle: "Place your \(documentTypeName) on a dark, flat surface with good lighting and align it in the guide.",
            buttons: [
                makeFilledButton(title: "Continue", selector: #selector(continueTapped)),
                makePlainButton(title: "Cancel", selector: #selector(cancelTapped))
            ]
        )
    }

    func configureForHelp() {
        let subtitle = mode == .auto
            ? "Make sure the \(documentTypeName) is flat, well-lit, and fits within the guide. We'll capture automatically."
            : "Make sure the \(documentTypeName) is flat and well-lit, then tap the shutter button."
        layout(
            symbolName: "questionmark.circle",
            title: "Need some help?",
            subtitle: subtitle,
            buttons: [
                makeFilledButton(title: mode == .auto ? "Continue" : "Manual", selector: #selector(continueTapped)),
                makePlainButton(title: "Cancel", selector: #selector(cancelTapped))
            ]
        )
    }

    func configureForTimeout() {
        layout(
            symbolName: "clock.badge.exclamationmark",
            title: "Time's up",
            subtitle: "Ensure the \(documentTypeName) is flat, fully visible, and well-lit, then try again.",
            buttons: [
                makeFilledButton(title: "Retry", selector: #selector(retryTapped)),
                makeFilledButton(title: "Manual", selector: #selector(continueTapped)),
                makePlainButton(title: "Cancel", selector: #selector(cancelTapped))
            ]
        )
    }

    func configureForReview() {
        let previewView = makePreview()
        previewView.translatesAutoresizingMaskIntoConstraints = false

        let hasWarnings = statuses?.isEmpty == false
        let textStack = makeTextStack(
            title: "Review your photo",
            subtitle: hasWarnings
                ? "There may be some quality issues. Retake for a better result."
                : "Looking good!"
        )
        let buttonStack = makeButtonStack([
            makeFilledButton(title: "Use This", selector: #selector(continueTapped)),
            makePlainButton(title: "Retake", selector: #selector(retryTapped))
        ])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(previewView)
        view.addSubview(textStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            previewView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.55),

            textStack.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 16),
            textStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            buttonStack.topAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor, constant: 16),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Shared Layout Helper
    func layout(symbolName: String, title: String, subtitle: String, buttons: [UIButton]) {
        let symbolView = makeSymbol(symbolName)
        let textStack  = makeTextStack(title: title, subtitle: subtitle)

        let contentStack = UIStackView(arrangedSubviews: [symbolView, textStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .center

        let buttonStack = makeButtonStack(buttons)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        let topSpacer = UIView()
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        let bottomSpacer = UIView()
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topSpacer)
        view.addSubview(contentStack)
        view.addSubview(bottomSpacer)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            topSpacer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topSpacer.bottomAnchor.constraint(equalTo: contentStack.topAnchor),

            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            bottomSpacer.topAnchor.constraint(equalTo: contentStack.bottomAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: buttonStack.topAnchor),
            bottomSpacer.heightAnchor.constraint(equalTo: topSpacer.heightAnchor),

            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Computed Properties

    var documentTypeName: String {
        switch documentType {
        case .idFront, .idBack:       return "ID"
        case .passport:               return "passport"
        case .checkFront, .checkBack: return "check"
        case .anyId:                  return "document"
        default:                      return "document"
        }
    }

    // MARK: - View Factories

    func makeSymbol(_ name: String) -> UIImageView {
        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .thin)
        let imageView = UIImageView(image: UIImage(systemName: name, withConfiguration: config))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func makePreview() -> UIView {
        if let image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 12
            imageView.layer.masksToBounds = true
            imageView.backgroundColor = .secondarySystemBackground
            return imageView
        }
        return makeSymbol("photo.badge.exclamationmark")
    }

    func makeTextStack(title: String, subtitle: String) -> UIStackView {
        let titleLabel    = makeLabel(title, font: .systemFont(ofSize: 26, weight: .semibold))
        let subtitleLabel = makeLabel(subtitle, font: .preferredFont(forTextStyle: .body), textColor: .secondaryLabel)
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }

    func makeButtonStack(_ buttons: [UIButton]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 12
        return stack
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
private extension CustomTutorialViewController {
    /// Cancels the capture session entirely.
    @objc func cancelTapped() {
        delegate?.tutorialCancelButtonAction()
    }

    /// Resumes capture (instruction/help), switches to manual (timeout), or accepts the image (review).
    @objc func continueTapped() {
        delegate?.tutorialContinueButtonAction(for: tutorialMode)
    }

    /// Restarts the capture session (timeout) or discards and retakes the image (review).
    @objc func retryTapped() {
        delegate?.tutorialRetryButtonAction?()
    }
}
