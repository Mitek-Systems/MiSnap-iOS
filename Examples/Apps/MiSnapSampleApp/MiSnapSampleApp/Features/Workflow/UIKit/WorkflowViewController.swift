//
//  WorkflowViewController.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Combine
import MiSnapCore

final class WorkflowViewController: UIViewController {
    private let viewModel = WorkflowViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var activeWorkflowController: MiSnapWorkflowViewController?

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
        title = "Workflow"
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
        viewModel.$shouldShowWorkflow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShowWorkflow in
                guard
                    let self,
                    shouldShowWorkflow,
                    self.activeWorkflowController == nil
                else {
                    return
                }
                self.presentWorkflow(flow: self.viewModel.selectedFlow, steps: self.viewModel.selectedWorkflowSteps)
            }
            .store(in: &cancellables)

        viewModel.$workflowResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result else { return }
                let controller = ResultViewController(
                    response: result.mibiData,
                    images: result.images,
                    audioData: result.audioData ?? []
                )
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

    private func presentWorkflow(flow: MiSnapWorkflowFlow, steps: [MiSnapWorkflowStep]) {
        let controller = MiSnapWorkflowViewController(for: flow, with: steps, delegate: self)
        controller.modalPresentationStyle = .fullScreen
        activeWorkflowController = controller
        present(controller, animated: true)
    }

    private func makeLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 16
        let sectionInset: CGFloat = 16
        let minimumItemWidth: CGFloat = 160
        let cardHeight: CGFloat = 140

        return UICollectionViewCompositionalLayout { _, environment in
            let availableWidth = environment.container.effectiveContentSize.width - (sectionInset * 2)
            let columns = max(2, Int((availableWidth + spacing) / (minimumItemWidth + spacing)))

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cardHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cardHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset, leading: sectionInset, bottom: sectionInset, trailing: sectionInset)
            return section
        }
    }
}

extension WorkflowViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        WorkflowPreset.allCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PresetCardCell.reuseIdentifier,
            for: indexPath
        ) as? PresetCardCell else {
            return UICollectionViewCell()
        }

        let preset = WorkflowPreset.allCategories[indexPath.item]
        cell.configure(symbolName: preset.symbolName, title: preset.title, details: preset.details)
        return cell
    }
}

extension WorkflowViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preset = WorkflowPreset.allCategories[indexPath.item]
        viewModel.startWorkflow(steps: preset.steps)
    }
}

extension WorkflowViewController: MiSnapWorkflowViewControllerDelegate {
    func miSnapWorkflowLicenseStatus(_ status: MiSnapLicenseStatus) {
        activeWorkflowController = nil
        viewModel.handleLicenseStatus(status)
    }

    func miSnapWorkflowSuccess(_ result: MiSnapWorkflowResult) {
        activeWorkflowController = nil
        viewModel.handleWorkflowSuccess(result)
    }

    func miSnapWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep) {
        viewModel.handleWorkflowIntermediate(result, step: step)
    }

    func miSnapWorkflowCancelled(_ result: MiSnapWorkflowResult) {
        activeWorkflowController = nil
        viewModel.handleWorkflowCancellation(result)
    }

    func miSnapWorkflowError(_ result: MiSnapWorkflowResult) {
        activeWorkflowController = nil
        viewModel.handleWorkflowError(result)
    }

    func miSnapWorkflowOrientationDidChange(_ orientations: UIInterfaceOrientationMask, for step: MiSnapWorkflowStep) {
        OrientationManager.shared.setOrientation(orientations)
    }

#if canImport(MiSnapNFCUX) && canImport(MiSnapNFC)
    func miSnapWorkflowNfcSkipped(_ result: [String : Any]) {
        viewModel.handleNfcSkipped(result)
    }
#endif

#if canImport(MiSnapVoiceCaptureUX) && canImport(MiSnapVoiceCapture)
    func miSnapWorkflowDidSelectPhrase(_ phrase: String) {
        viewModel.handlePhraseSelected(phrase)
    }
#endif
}
