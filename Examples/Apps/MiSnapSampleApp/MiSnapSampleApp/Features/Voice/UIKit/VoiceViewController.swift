//
//  VoiceViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Combine
import MiSnapCore
import MiSnapVoiceCapture
import MiSnapVoiceCaptureUX

final class VoiceViewController: UIViewController {
    private let viewModel = VoiceViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var activeCaptureController: MiSnapVoiceCaptureViewController?

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
        title = "Voice"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        configureNavigationItems()
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
                let response = result.flow == .verification ? (result.mibiString ?? "Failed to extract MIBI data.") : ""
                let audioData = result.results.compactMap(\.data)
                let controller = ResultViewController(response: response, summary: result.summary, audioData: audioData)
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

        viewModel.$hasEnrolledPhrase
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureNavigationItems()
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func configureNavigationItems() {
        if viewModel.hasEnrolledPhrase {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "trash"),
                style: .plain,
                target: self,
                action: #selector(resetEnrollment)
            )
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc private func resetEnrollment() {
        viewModel.resetEnrollment()
    }

    private func presentCapture(for preset: VoicePreset) {
        let configuration = viewModel.makeConfiguration(for: preset)
        let controller = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        activeCaptureController = controller
        present(controller, animated: true)
    }

    private func makeLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 16
        let sectionInset: CGFloat = 16

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
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)
            return section
        }
    }

}

extension VoiceViewController: UICollectionViewDataSource {
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
        let isEnabled = viewModel.isEnabled(preset)
        cell.configure(symbolName: preset.symbolName, title: preset.rawValue, isEnabled: isEnabled)
        cell.isUserInteractionEnabled = isEnabled
        cell.accessibilityTraits = isEnabled ? .button : [.button, .notEnabled]
        return cell
    }
}

extension VoiceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let preset = viewModel.availablePresets[indexPath.item]
        return viewModel.isEnabled(preset)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preset = viewModel.availablePresets[indexPath.item]
        viewModel.select(preset)
    }
}

extension VoiceViewController: MiSnapVoiceCaptureViewControllerDelegate {
    func miSnapVoiceCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
        viewModel.handleLicenseStatus(status)
    }

    func miSnapVoiceCaptureDidSelectPhrase(_ phrase: String) {
        viewModel.handlePhraseSelected(phrase)
    }

    func miSnapVoiceCaptureSuccess(_ results: [MiSnapVoiceCaptureResult], for flow: MiSnapVoiceCaptureFlow) {
        viewModel.handleSuccessfulCapture(results, flow)
    }

    func miSnapVoiceCaptureCancelled(_ result: MiSnapVoiceCaptureResult) {
        viewModel.handleCancellation(result)
    }

    func miSnapVoiceCaptureError(_ result: MiSnapVoiceCaptureResult) {
        viewModel.handleError(result)
    }

    func miSnapVoiceCaptureShouldBeDismissed() {
        viewModel.handleDismiss()
        activeCaptureController?.dismiss(animated: true)
        activeCaptureController = nil
    }
}
