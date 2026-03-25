//
//  AudioPlayerCardView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Combine

final class AudioPlayerCardView: UIView {
    private static weak var currentlyPlayingCard: AudioPlayerCardView?

    private let audioData: Data
    private let player = AudioPlayer()
    private var cancellables = Set<AnyCancellable>()

    private let ringContainerView = UIView()
    private let titleLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private let backgroundRingLayer = CAShapeLayer()
    private let progressRingLayer = CAShapeLayer()

    init(audioData: Data, label: String) {
        self.audioData = audioData
        super.init(frame: .zero)
        setupViews(label: label)
        setupLayout()
        bindPlayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cleanup()
    }

    func cleanup() {
        player.cleanup()
        if AudioPlayerCardView.currentlyPlayingCard === self {
            AudioPlayerCardView.currentlyPlayingCard = nil
        }
    }

    private func setupViews(label: String) {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true

        ringContainerView.translatesAutoresizingMaskIntoConstraints = false
        ringContainerView.backgroundColor = .clear

        backgroundRingLayer.strokeColor = UIColor.systemGray3.cgColor
        backgroundRingLayer.fillColor = UIColor.clear.cgColor
        backgroundRingLayer.lineWidth = 3
        ringContainerView.layer.addSublayer(backgroundRingLayer)

        progressRingLayer.strokeColor = UIColor.systemBlue.cgColor
        progressRingLayer.fillColor = UIColor.clear.cgColor
        progressRingLayer.lineWidth = 3
        progressRingLayer.lineCap = .round
        progressRingLayer.strokeEnd = 0
        ringContainerView.layer.addSublayer(progressRingLayer)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.text = label

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        playButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        playButton.tintColor = .systemBlue
        playButton.setPreferredSymbolConfiguration(.init(pointSize: 50, weight: .regular), forImageIn: .normal)

        addSubview(ringContainerView)
        ringContainerView.addSubview(playButton)
        addSubview(titleLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            ringContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            ringContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            ringContainerView.widthAnchor.constraint(equalToConstant: 60),
            ringContainerView.heightAnchor.constraint(equalToConstant: 60),

            playButton.centerXAnchor.constraint(equalTo: ringContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: ringContainerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: ringContainerView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 1.5
        let circleRect = ringContainerView.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(ovalIn: circleRect).cgPath
        backgroundRingLayer.path = path
        progressRingLayer.path = path
        backgroundRingLayer.frame = ringContainerView.bounds
        progressRingLayer.frame = ringContainerView.bounds
        progressRingLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
    }

    private func bindPlayer() {
        player.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.updatePlayingState(isPlaying)
            }
            .store(in: &cancellables)

        player.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressRingLayer.strokeEnd = progress
            }
            .store(in: &cancellables)
    }

    @objc private func togglePlayback() {
        if player.isPlaying {
            player.stop()
            if AudioPlayerCardView.currentlyPlayingCard === self {
                AudioPlayerCardView.currentlyPlayingCard = nil
            }
        } else {
            AudioPlayerCardView.currentlyPlayingCard?.player.stop()
            AudioPlayerCardView.currentlyPlayingCard = self
            player.play(data: audioData)
        }
    }

    private func updatePlayingState(_ isPlaying: Bool) {
        let imageName = isPlaying ? "stop.circle.fill" : "play.circle.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
