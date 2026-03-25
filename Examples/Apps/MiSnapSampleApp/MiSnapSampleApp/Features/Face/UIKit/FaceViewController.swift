//
//  FaceViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Combine
import MiSnapFacialCapture
import MiSnapFacialCaptureUX

final class FaceViewController: UIViewController {
    private let viewModel = FaceViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var activeCaptureController: MiSnapFacialCaptureViewController?
    private weak var controlsHeaderView: FaceControlsHeaderView?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PresetCardCell.self, forCellWithReuseIdentifier: PresetCardCell.reuseIdentifier)
        collectionView.register(
            FaceControlsHeaderView.self,
            forSupplementaryViewOfKind: FaceControlsHeaderView.elementKind,
            withReuseIdentifier: FaceControlsHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Face"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationManager.shared.setOrientation(iPhone: .portrait, iPad: .all)
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
                let response = result.mibiString ?? "Failed to extract MIBI data."
                let controller = ResultViewController(response: response, image: result.image)
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

        viewModel.$aiBasedRtsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self else { return }
                self.controlsHeaderView?.configure(isAiBasedRtsEnabled: isEnabled, cameraPosition: self.viewModel.cameraPosition)
            }
            .store(in: &cancellables)

        viewModel.$cameraPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] position in
                self?.controlsHeaderView?.configure(isAiBasedRtsEnabled: self?.viewModel.aiBasedRtsEnabled ?? false, cameraPosition: position)
            }
            .store(in: &cancellables)
    }

    private func presentCapture(for preset: FacePreset) {
        let configuration = viewModel.makeConfiguration(for: preset)
        let controller = MiSnapFacialCaptureViewController(with: configuration, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        activeCaptureController = controller
        present(controller, animated: true)
    }

    private func makeLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 16
        let sectionInset: CGFloat = 16
        let minimumItemWidth: CGFloat = 160

        return UICollectionViewCompositionalLayout { _, environment in
            let availableWidth = environment.container.effectiveContentSize.width - (sectionInset * 2)
            let columns = max(2, Int((availableWidth + spacing) / (minimumItemWidth + spacing)))

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(130)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(130)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(96)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: FaceControlsHeaderView.elementKind,
                alignment: .top
            )
            header.contentInsets = NSDirectionalEdgeInsets(top: sectionInset, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}

extension FaceViewController: UICollectionViewDataSource {
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
        cell.configure(symbolName: preset.symbolName, title: preset.rawValue)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == FaceControlsHeaderView.elementKind,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FaceControlsHeaderView.reuseIdentifier,
                for: indexPath
            ) as? FaceControlsHeaderView
        else {
            return UICollectionReusableView()
        }

        header.configure(isAiBasedRtsEnabled: viewModel.aiBasedRtsEnabled, cameraPosition: viewModel.cameraPosition)
        header.onAiBasedRtsChanged = { [weak self] isEnabled in
            self?.viewModel.aiBasedRtsEnabled = isEnabled
        }
        header.onCameraPositionChanged = { [weak self] position in
            self?.viewModel.cameraPosition = position
        }
        controlsHeaderView = header
        return header
    }
}

extension FaceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preset = viewModel.availablePresets[indexPath.item]
        viewModel.selectPreset(preset)
    }
}

extension FaceViewController: MiSnapFacialCaptureViewControllerDelegate {
    func miSnapFacialCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
        viewModel.handleLicenseStatus(status)
    }

    func miSnapFacialCaptureSuccess(_ result: MiSnapFacialCaptureResult) {
        viewModel.handleSuccessfulCapture(result)
    }

    func miSnapFacialCaptureCancelled(_ result: MiSnapFacialCaptureResult) {
        viewModel.handleCancellation(result)
    }

    func miSnapException(_ exception: NSException) {
        viewModel.handleException(exception)
    }

    func miSnapFacialCaptureShouldBeDismissed() {
        viewModel.handleDismiss()
        activeCaptureController?.dismiss(animated: true)
        activeCaptureController = nil
    }
}
