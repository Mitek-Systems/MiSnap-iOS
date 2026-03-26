//
//  DocumentsViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Combine
import MiSnap
import MiSnapUX

final class DocumentsViewController: UIViewController {
    private let viewModel = DocumentsViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var activeCaptureController: MiSnapViewController?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PresetCardCell.self, forCellWithReuseIdentifier: PresetCardCell.reuseIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Documents"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationManager.shared.setOrientation(.all)
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
    }

    private func presentCapture(for preset: DocumentPreset) {
        let configuration = viewModel.makeConfiguration(for: preset)
        let controller = MiSnapViewController(with: configuration, delegate: self)
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

            let groupHeight = NSCollectionLayoutDimension.estimated(130)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)

            return section
        }
    }
}

extension DocumentsViewController: UICollectionViewDataSource {
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
}

extension DocumentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preset = viewModel.availablePresets[indexPath.item]
        viewModel.selectPreset(preset)
    }
}

extension DocumentsViewController: MiSnapViewControllerDelegate {
    func miSnapLicenseStatus(_ status: MiSnapLicenseStatus) {
        viewModel.handleLicenseStatus(status)
    }

    func miSnapSuccess(_ result: MiSnapResult) {
        viewModel.handleSuccessfulCapture(result)
    }

    func miSnapCancelled(_ result: MiSnapResult) {
        viewModel.handleCancellation(result)
    }

    func miSnapException(_ exception: NSException) {
        viewModel.handleException(exception)
    }

    func miSnapShouldBeDismissed() {
        viewModel.handleDismiss()
        activeCaptureController?.dismiss(animated: true)
        activeCaptureController = nil
    }

    func miSnapCustomTutorial(
        _ documentType: MiSnapScienceDocumentType,
        tutorialMode: MiSnapUxTutorialMode,
        mode: MiSnapMode,
        statuses: [NSNumber]?,
        image: UIImage?
    ) {
        guard let preset = viewModel.selectedPreset else { return }
        let handler = viewModel.handleCustomTutorial(for: preset)
        handler?(documentType, tutorialMode, mode, statuses, image, activeCaptureController)
    }
}
