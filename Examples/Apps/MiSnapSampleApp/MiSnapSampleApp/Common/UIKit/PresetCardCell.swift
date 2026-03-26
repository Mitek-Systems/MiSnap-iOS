//
//  PresetCardCell.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

final class PresetCardCell: UICollectionViewCell {
    static let reuseIdentifier = "PresetCardCell"

    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let symbolBaseConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }

    func configure(symbolName: String, title: String, details: String? = nil, isEnabled: Bool = true) {
        iconImageView.image = UIImage(systemName: symbolName)
        titleLabel.text = title
        titleLabel.numberOfLines = title.contains(" ") ? 2 : 1
        detailsLabel.text = details
        detailsLabel.isHidden = (details?.isEmpty ?? true)
        applyEnabledState(isEnabled)
    }

    private func setupViews() {
        contentView.backgroundColor = .clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75

        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = .preferredFont(forTextStyle: .caption2)
        detailsLabel.textAlignment = .center
        detailsLabel.numberOfLines = 0
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.adjustsFontSizeToFitWidth = true
        detailsLabel.minimumScaleFactor = 0.7
        detailsLabel.isHidden = true
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        detailsLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailsLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    private func applyEnabledState(_ isEnabled: Bool) {
        containerView.backgroundColor = isEnabled ? .systemGray6 : .systemGray5
        let symbolColor = isEnabled ? UIColor.label : UIColor.tertiaryLabel
        let hierarchicalConfiguration = symbolBaseConfiguration.applying(
            UIImage.SymbolConfiguration(hierarchicalColor: symbolColor)
        )
        iconImageView.preferredSymbolConfiguration = hierarchicalConfiguration
        iconImageView.tintColor = symbolColor
        titleLabel.textColor = isEnabled ? .label : .tertiaryLabel
        detailsLabel.textColor = isEnabled ? .secondaryLabel : .tertiaryLabel
        contentView.alpha = isEnabled ? 1.0 : 0.7
    }
}
