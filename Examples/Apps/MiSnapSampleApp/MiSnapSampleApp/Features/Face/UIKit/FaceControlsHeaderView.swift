//
//  FaceControlsHeaderView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

final class FaceControlsHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "FaceControlsHeaderView"
    static let elementKind = "FaceControlsHeaderViewKind"

    var onAiBasedRtsChanged: ((Bool) -> Void)?
    var onCameraPositionChanged: ((FaceCameraPosition) -> Void)?

    private let rootStack = UIStackView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()

    private let cameraIconView = UIImageView()
    private let cameraTitleLabel = UILabel()
    private let cameraMenuButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        isAiBasedRtsEnabled: Bool,
        cameraPosition: FaceCameraPosition = .front
    ) {
        toggleSwitch.setOn(isAiBasedRtsEnabled, animated: false)
        let effectivePosition: FaceCameraPosition = isAiBasedRtsEnabled ? .front : cameraPosition
        cameraMenuButton.setTitle(effectivePosition == .front ? "Front" : "Back", for: .normal)
        cameraMenuButton.menu = makeCameraMenu(current: effectivePosition)
        cameraMenuButton.isEnabled = !isAiBasedRtsEnabled
    }

    private func setupViews() {
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.axis = .vertical
        rootStack.spacing = 16

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "sparkles")
        iconView.tintColor = .label
        iconView.preferredSymbolConfiguration = .init(pointSize: 18, weight: .semibold)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "AI-based RTS"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)

        cameraIconView.translatesAutoresizingMaskIntoConstraints = false
        cameraIconView.image = UIImage(systemName: "camera")
        cameraIconView.tintColor = .label
        cameraIconView.preferredSymbolConfiguration = .init(pointSize: 18, weight: .semibold)

        cameraTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraTitleLabel.text = "Camera"
        cameraTitleLabel.font = .preferredFont(forTextStyle: .headline)
        cameraTitleLabel.textColor = .label

        cameraMenuButton.translatesAutoresizingMaskIntoConstraints = false
        cameraMenuButton.setTitle("Front", for: .normal)
        cameraMenuButton.semanticContentAttribute = .forceRightToLeft
        cameraMenuButton.showsMenuAsPrimaryAction = true
        cameraMenuButton.changesSelectionAsPrimaryAction = false
        cameraMenuButton.menu = makeCameraMenu(current: .front)

        let rtsRow = UIStackView(arrangedSubviews: [iconView, titleLabel, UIView(), toggleSwitch])
        rtsRow.axis = .horizontal
        rtsRow.alignment = .center
        rtsRow.spacing = 8

        let cameraRow = UIStackView(arrangedSubviews: [cameraIconView, cameraTitleLabel, UIView(), cameraMenuButton])
        cameraRow.axis = .horizontal
        cameraRow.alignment = .center
        cameraRow.spacing = 8

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            cameraIconView.widthAnchor.constraint(equalToConstant: 20),
            cameraIconView.heightAnchor.constraint(equalToConstant: 20)
        ])

        rootStack.addArrangedSubview(rtsRow)
        rootStack.addArrangedSubview(cameraRow)
        addSubview(rootStack)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let width = layoutAttributes.frame.width
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let size = systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.frame.size.height = ceil(size.height)
        return attributes
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        onAiBasedRtsChanged?(sender.isOn)
    }

    private func makeCameraMenu(current: FaceCameraPosition) -> UIMenu {
        UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Front", state: current == .front ? .on : .off) { [weak self] _ in
                self?.onCameraPositionChanged?(.front)
            },
            UIAction(title: "Back", state: current == .back ? .on : .off) { [weak self] _ in
                self?.onCameraPositionChanged?(.back)
            }
        ])
    }
}
