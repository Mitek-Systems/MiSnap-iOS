//
//  NFCViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Combine
import MiSnapCore
import MiSnapNFC
import MiSnapNFCUX

final class NFCViewController: UIViewController {
    private let viewModel = NFCViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var activeCaptureController: MiSnapNFCViewController?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(PresetCardCell.self, forCellWithReuseIdentifier: PresetCardCell.reuseIdentifier)
        collectionView.register(
            NFCInputsHeaderView.self,
            forSupplementaryViewOfKind: NFCInputsHeaderView.elementKind,
            withReuseIdentifier: NFCInputsHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NFC"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        setupLayout()
        setupKeyboardDismiss()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationManager.shared.setOrientation(.portrait)
    }

    private func setupLayout() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingIfNeeded))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func bindViewModel() {
        viewModel.$shouldShowCapture
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShowCapture in
                guard let self, shouldShowCapture, let preset = self.viewModel.selectedPreset else { return }
                self.presentCapture(for: preset)
            }
            .store(in: &cancellables)

        viewModel.$captureResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result else { return }
                let response = result.nfcData?.formattedNFCString ?? ""
                let controller = ResultViewController(response: response, images: result.images ?? [])
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .pageSheet
                self.present(nav, animated: true)
            }
            .store(in: &cancellables)

        viewModel.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                guard let self, let alert else { return }
                self.presentAlert(from: alert)
            }
            .store(in: &cancellables)
    }

    private func presentCapture(for preset: MiSnapNFCDocumentType) {
        let configuration = viewModel.makeConfiguration(for: preset)
        let controller = MiSnapNFCViewController(with: configuration, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        activeCaptureController = controller
        present(controller, animated: true)
    }

    private func makeLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 12
        let sectionInset: CGFloat = 16
        let headerBottomSpacing: CGFloat = 16

        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(130)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(130)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(240)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: NFCInputsHeaderView.elementKind,
                alignment: .top
            )
            header.contentInsets = NSDirectionalEdgeInsets(
                top: sectionInset,
                leading: 0,
                bottom: sectionInset + headerBottomSpacing,
                trailing: 0
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
    }

    @objc private func endEditingIfNeeded() {
        view.endEditing(true)
    }
}

extension NFCViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.availablePresets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PresetCardCell.reuseIdentifier,
            for: indexPath
        ) as? PresetCardCell else {
            return UICollectionViewCell()
        }

        let preset = viewModel.availablePresets[indexPath.item]
        cell.configure(symbolName: preset.symbolName, title: preset.displayName)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == NFCInputsHeaderView.elementKind,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NFCInputsHeaderView.reuseIdentifier,
                for: indexPath
            ) as? NFCInputsHeaderView
        else {
            return UICollectionReusableView()
        }

        header.configure(
            documentNumber: viewModel.documentNumber,
            dateOfBirth: viewModel.dateOfBirth,
            dateOfExpiry: viewModel.dateOfExpiry,
            mrzString: viewModel.mrzString
        )
        header.onDocumentNumberChanged = { [weak self] value in
            self?.viewModel.documentNumber = value
        }
        header.onDateOfBirthChanged = { [weak self] value in
            self?.viewModel.dateOfBirth = value
        }
        header.onDateOfExpiryChanged = { [weak self] value in
            self?.viewModel.dateOfExpiry = value
        }
        header.onMrzChanged = { [weak self] value in
            self?.viewModel.mrzString = value
        }
        return header
    }
}

extension NFCViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        let preset = viewModel.availablePresets[indexPath.item]
        viewModel.selectPreset(preset)
    }
}

extension NFCViewController: MiSnapNFCViewControllerDelegate {
    func miSnapNfcLicenseStatus(_ status: MiSnapLicenseStatus) {
        viewModel.handleLicenseStatus(status)
    }

    func miSnapNfcSuccess(_ result: [String : Any]) {
        viewModel.handleSuccessfulCapture(result)
    }

    func miSnapNfcCancelled(_ result: [String : Any]) {
        viewModel.handleCancellation(result)
    }

    func miSnapNfcSkipped(_ result: [String : Any]) {
        viewModel.handleSkipped(result)
    }

    func miSnapNfcShouldBeDismissed() {
        viewModel.handleDismiss()
        activeCaptureController?.dismiss(animated: true)
        activeCaptureController = nil
    }
}
