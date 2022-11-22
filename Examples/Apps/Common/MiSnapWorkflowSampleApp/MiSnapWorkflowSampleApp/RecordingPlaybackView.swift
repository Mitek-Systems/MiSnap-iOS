//
//  RecordingView.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 8/3/21.
//

import UIKit
import AVFoundation

class RecordingPlaybackView: UIView {
    private var controlLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    
    private var controlRect: CGRect = .zero
    private var progressRect: CGRect = .zero
    
    private var playing: Bool = false
    
    private var player = AVAudioPlayer()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(with data: Data, index: Int, frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.868627451, green: 0.868627451, blue: 0.868627451, alpha: 1)
        
        configureSubviews(with: index)
        configurePlayer(with: data)
    }
    
    deinit {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement)
    }
}

// MARK: Private views configuration functions
extension RecordingPlaybackView {
    private func configureSubviews(with index: Int) {
        let controlMultiplier: CGFloat = 0.2
        controlRect = CGRect(x: 0, y: 0, width: frame.width * controlMultiplier, height: frame.width * controlMultiplier)
        
        controlLayer.path = playPath(for: controlRect).cgPath
        controlLayer.fillColor = #colorLiteral(red: 0.668627451, green: 0.668627451, blue: 0.668627451, alpha: 1)
        
        let controlView = UIView(frame: controlRect)
        controlView.translatesAutoresizingMaskIntoConstraints = false
        controlView.backgroundColor = .clear
        controlView.layer.addSublayer(controlLayer)
        
        let spacing: CGFloat = 5
        let lineWidth: CGFloat = 3
        let progressViewSideLength = controlRect.width * sqrt(2) + 2 * spacing + 2 * lineWidth
        progressRect = CGRect(x: 0, y: 0, width: progressViewSideLength, height: progressViewSideLength)
        
        progressLayer.strokeColor = #colorLiteral(red: 0.668627451, green: 0.668627451, blue: 0.668627451, alpha: 1)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 3
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        progressLayer.path = circlePath(for: progressRect, lineWidth: progressLayer.lineWidth).cgPath
        
        let progressView = UIView(frame: progressRect)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.backgroundColor = .clear
        progressView.layer.addSublayer(progressLayer)
        progressView.clipsToBounds = true
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = index > 1 ? "recording \(index)" : "recording"
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .black
        
        addSubview(progressView)
        addSubview(controlView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            
            controlView.widthAnchor.constraint(equalToConstant: controlView.frame.width),
            controlView.heightAnchor.constraint(equalToConstant: controlView.frame.height),
            controlView.centerXAnchor.constraint(equalTo: centerXAnchor),
            controlView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            progressView.widthAnchor.constraint(equalToConstant: progressView.frame.width),
            progressView.heightAnchor.constraint(equalToConstant: progressView.frame.height),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.widthAnchor.constraint(equalTo: widthAnchor),
            label.heightAnchor.constraint(equalToConstant: label.frame.height),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tap.numberOfTapsRequired = 1
        
        addGestureRecognizer(tap)
    }
    
    private func circlePath(for rect: CGRect, lineWidth: CGFloat = 5.0) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0),
                                radius: (rect.width - lineWidth) / 2.0,
                                startAngle: radians(fromDegrees: -90),
                                endAngle: radians(fromDegrees: 270),
                                clockwise: true)
        
        return path
    }
    
    private func radians(fromDegrees degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
    
    private func playPath(for rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.height / 2.0 * sqrt(3.0), y: rect.height / 2.0))
        path.addLine(to: CGPoint(x: rect.height / 2.0 * sqrt(3.0), y: rect.height / 2.0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        return path
    }
    
    private func stopPath(for rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(rect: rect)
        return path
    }
    
    @objc private func tapAction() {
        playing = !playing
        configure(for: playing)
    }
    
    private func configure(for playing: Bool) {
        let controlAnimation = CABasicAnimation(keyPath: "path")
        controlAnimation.duration = 0.35
        controlAnimation.repeatCount = 0
        controlAnimation.isRemovedOnCompletion = false
        controlAnimation.fillMode = .forwards
        
        if playing {
            controlAnimation.fromValue = playPath(for: controlRect).cgPath
            controlAnimation.toValue = stopPath(for: controlRect).cgPath

            let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeEndAnimation.fromValue = 0.0
            strokeEndAnimation.toValue = 1.0
            strokeEndAnimation.duration = player.duration
            strokeEndAnimation.repeatCount = 0
            strokeEndAnimation.isRemovedOnCompletion = false
            strokeEndAnimation.fillMode = .forwards
            progressLayer.removeAllAnimations()
            progressLayer.add(strokeEndAnimation, forKey: "strokeEndAnimation")
            
            player.prepareToPlay()
            player.play()
        } else {
            controlAnimation.fromValue = stopPath(for: controlRect).cgPath
            controlAnimation.toValue = playPath(for: controlRect).cgPath

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1.0
            opacityAnimation.toValue = 0.0
            opacityAnimation.duration = 0.15
            opacityAnimation.repeatCount = 0
            opacityAnimation.isRemovedOnCompletion = false
            opacityAnimation.fillMode = .forwards
            progressLayer.add(opacityAnimation, forKey: "opacityAnimation")
            
            player.stop()
            player.currentTime = 0
        }
        
        controlLayer.add(controlAnimation, forKey: "pathAnimation")
    }
}

// MARK: audio player functions
extension RecordingPlaybackView: AVAudioPlayerDelegate {
    private func configurePlayer(with data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(data: data)
            player.delegate = self
        } catch {
            print("Couldn't configure player")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        tapAction()
    }
}
