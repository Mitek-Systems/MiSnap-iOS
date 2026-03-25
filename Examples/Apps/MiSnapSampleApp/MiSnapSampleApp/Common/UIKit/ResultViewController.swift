//
//  ResultViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

final class ResultViewController: UIViewController {
    private let responseText: String
    private let images: [UIImage]
    private let summaryText: String?
    private let audioData: [Data]

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var overlayView: UIView?
    private var audioPlayerCards: [AudioPlayerCardView] = []

    init(response: String, images: [UIImage] = [], summary: String? = nil, audioData: [Data] = []) {
        self.responseText = JSONFormatter.prettyPrint(response)
        self.images = images
        self.summaryText = summary
        self.audioData = audioData
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(response: String, image: UIImage?, summary: String? = nil, audioData: [Data] = []) {
        self.init(response: response, images: image.map { [$0] } ?? [], summary: summary, audioData: audioData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Result"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        setupLayout()
        buildContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayerCards.forEach { $0.cleanup() }
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, constant: -32)
        ])
    }

    private func buildContent() {
        if !images.isEmpty {
            stackView.addArrangedSubview(makeSectionHeader("Images:"))
            stackView.addArrangedSubview(makeImagesRow())
        }

        if !audioData.isEmpty {
            stackView.addArrangedSubview(makeSectionHeader("Recordings:"))
            stackView.addArrangedSubview(makeAudioPlayersView())
        }

        if let summaryText, !summaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            stackView.addArrangedSubview(makeSectionHeader("Summary:"))
            stackView.addArrangedSubview(makeSummaryView(summaryText))
        }

        if !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            stackView.addArrangedSubview(makeSectionHeader("Data:"))
            stackView.addArrangedSubview(makeDataView())
        }
    }

    private func makeSectionHeader(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.text = text
        return label
    }

    private func makeImagesRow() -> UIScrollView {
        let scroller = UIScrollView()
        scroller.showsHorizontalScrollIndicator = false
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.heightAnchor.constraint(equalToConstant: 110).isActive = true

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false

        scroller.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            row.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
            row.heightAnchor.constraint(equalTo: scroller.frameLayoutGuide.heightAnchor)
        ])

        for image in images {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.widthAnchor.constraint(equalToConstant: 100).isActive = true
            container.heightAnchor.constraint(equalToConstant: 100).isActive = true

            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            imageView.isUserInteractionEnabled = true

            let expandIconConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            let expandIconImage = UIImage(systemName: "arrow.down.left.and.arrow.up.right", withConfiguration: expandIconConfig)
            let expandIconImageView = UIImageView(image: expandIconImage)
            expandIconImageView.translatesAutoresizingMaskIntoConstraints = false
            expandIconImageView.contentMode = .scaleAspectFit
            expandIconImageView.tintColor = .label

            let expandIconBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            expandIconBackground.translatesAutoresizingMaskIntoConstraints = false
            expandIconBackground.layer.cornerRadius = 6
            expandIconBackground.clipsToBounds = true
            expandIconBackground.contentView.addSubview(expandIconImageView)

            container.addSubview(imageView)
            container.addSubview(expandIconBackground)
            container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(_:))))

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: container.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

                expandIconBackground.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
                expandIconBackground.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
                expandIconImageView.centerXAnchor.constraint(equalTo: expandIconBackground.contentView.centerXAnchor),
                expandIconImageView.centerYAnchor.constraint(equalTo: expandIconBackground.contentView.centerYAnchor),
                expandIconImageView.leadingAnchor.constraint(equalTo: expandIconBackground.contentView.leadingAnchor, constant: 6),
                expandIconImageView.trailingAnchor.constraint(equalTo: expandIconBackground.contentView.trailingAnchor, constant: -6),
                expandIconImageView.topAnchor.constraint(equalTo: expandIconBackground.contentView.topAnchor, constant: 6),
                expandIconImageView.bottomAnchor.constraint(equalTo: expandIconBackground.contentView.bottomAnchor, constant: -6)
            ])

            row.addArrangedSubview(container)
        }

        return scroller
    }

    private func makeSummaryView(_ text: String) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = text
        label.numberOfLines = 0

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.separator.cgColor
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        return container
    }

    private func makeDataView() -> UIView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.text = responseText
        textView.backgroundColor = .clear
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220).isActive = true

        let copyButton = UIButton(type: .system)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.separator.cgColor
        container.setContentHuggingPriority(.defaultLow, for: .vertical)
        container.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        container.addSubview(textView)
        container.addSubview(copyButton)

        NSLayoutConstraint.activate([
            copyButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            copyButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            copyButton.widthAnchor.constraint(equalToConstant: 28),
            copyButton.heightAnchor.constraint(equalToConstant: 28),

            textView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        return container
    }

    private func makeAudioPlayersView() -> UIView {
        let playersStack = UIStackView()
        playersStack.translatesAutoresizingMaskIntoConstraints = false
        playersStack.axis = .horizontal
        playersStack.alignment = .fill
        playersStack.distribution = .fillEqually
        playersStack.spacing = 12

        audioPlayerCards = audioData.enumerated().map { index, data in
            AudioPlayerCardView(audioData: data, label: "Recording \(index + 1)")
        }

        audioPlayerCards.forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            playersStack.addArrangedSubview(card)
        }

        return playersStack
    }

    @objc private func copyTapped() {
        UIPasteboard.general.string = responseText
        let alert = UIAlertController(title: nil, message: "Copied to clipboard", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }

    @objc private func thumbnailTapped(_ recognizer: UITapGestureRecognizer) {
        let image: UIImage?
        if let imageView = recognizer.view as? UIImageView {
            image = imageView.image
        } else if let container = recognizer.view,
                  let imageView = container.subviews.first as? UIImageView {
            image = imageView.image
        } else {
            image = nil
        }
        guard let image else { return }

        let overlay = UIView(frame: view.bounds)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = .systemBackground

        let fullImage = UIImageView(image: image)
        fullImage.translatesAutoresizingMaskIntoConstraints = false
        fullImage.contentMode = .scaleAspectFit
        fullImage.layer.cornerRadius = 16
        fullImage.layer.masksToBounds = true

        let hintLabel = UILabel()
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.text = "Tap anywhere to dismiss"
        hintLabel.font = .preferredFont(forTextStyle: .footnote)
        hintLabel.textColor = .secondaryLabel

        overlay.addSubview(fullImage)
        overlay.addSubview(hintLabel)
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOverlay)))

        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            fullImage.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 20),
            fullImage.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -20),
            fullImage.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            fullImage.heightAnchor.constraint(lessThanOrEqualTo: overlay.heightAnchor, multiplier: 0.75),

            hintLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])

        overlay.alpha = 0
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1
        }
        overlayView = overlay
    }

    @objc private func dismissOverlay() {
        guard let overlayView else { return }
        UIView.animate(withDuration: 0.15, animations: {
            overlayView.alpha = 0
        }, completion: { _ in
            overlayView.removeFromSuperview()
        })
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.overlayView = nil
    }
}
