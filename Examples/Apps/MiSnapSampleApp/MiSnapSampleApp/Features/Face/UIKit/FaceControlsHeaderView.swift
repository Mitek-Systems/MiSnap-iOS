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

    func configure(isAiBasedRtsEnabled: Bool, cameraPosition: FaceCameraPosition = .front) {
        toggleSwitch.setOn(isAiBasedRtsEnabled, animated: false)
        let effectivePosition: FaceCameraPosition = isAiBasedRtsEnabled ? .front : cameraPosition
        cameraMenuButton.setTitle(effectivePosition == .front ? "Front" : "Back", for: .normal)
        cameraMenuButton.menu = makeCameraMenu(current: effectivePosition)
        cameraMenuButton.isEnabled = !isAiBasedRtsEnabled
    }

    private func setupViews() {
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

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(toggleSwitch)
        addSubview(cameraIconView)
        addSubview(cameraTitleLabel)
        addSubview(cameraMenuButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            toggleSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            toggleSwitch.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggleSwitch.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            cameraIconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraIconView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            cameraIconView.widthAnchor.constraint(equalToConstant: 20),
            cameraIconView.heightAnchor.constraint(equalToConstant: 20),
            cameraIconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            cameraTitleLabel.leadingAnchor.constraint(equalTo: cameraIconView.trailingAnchor, constant: 8),
            cameraTitleLabel.centerYAnchor.constraint(equalTo: cameraIconView.centerYAnchor),

            cameraMenuButton.leadingAnchor.constraint(greaterThanOrEqualTo: cameraTitleLabel.trailingAnchor, constant: 12),
            cameraMenuButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraMenuButton.centerYAnchor.constraint(equalTo: cameraIconView.centerYAnchor)
        ])
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
