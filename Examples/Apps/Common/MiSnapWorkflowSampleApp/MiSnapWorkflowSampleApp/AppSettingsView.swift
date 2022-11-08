//
//  AppSettingsView.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 9/12/22.
//

import UIKit

class AppSettingsView: UIView {
    var modeSegmentedControl = CustomSegmentedControl()
    var voiceDataSavingModeSegmentedControl = CustomSegmentedControl()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func removeFromSuperview() {
        modeSegmentedControl.removeFromSuperview()
        voiceDataSavingModeSegmentedControl.removeFromSuperview()
        super.removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureSubviews()
    }
    
    deinit {
        print(String(describing: type(of: self)) + " is deinitialized")
    }
}

// Private views configurations functions
extension AppSettingsView {
    private func configureSubviews() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0.95
        blurView.frame = frame
        blurView.isUserInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapRecognizer.numberOfTapsRequired = 1
        blurView.addGestureRecognizer(tapRecognizer)
        
        addSubview(blurView)
        
        let settingsView = configureSettingsView()
        
        addSubview(settingsView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
            
            settingsView.widthAnchor.constraint(equalToConstant: settingsView.frame.width),
            settingsView.heightAnchor.constraint(equalToConstant: settingsView.frame.height),
            settingsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            settingsView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func configureSettingsView() -> UIView {
        let spacing: CGFloat = 20
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: frame.width * 0.7, height: frame.height))
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 15
        container.clipsToBounds = true
        
        let modeLabel = configureLabel(withText: "Mode")
        container.addSubview(modeLabel)
        
        modeSegmentedControl = CustomSegmentedControl(with: ["Online", "Offline"], delegate: self, frame: frame)
        modeSegmentedControl.selectedIndex = AppSettings.shared.mode.index
        container.addSubview(modeSegmentedControl)
        
        let voiceDataSavingModeLabel = configureLabel(withText: "Voice Saving")
        container.addSubview(voiceDataSavingModeLabel)
        
        voiceDataSavingModeSegmentedControl = CustomSegmentedControl(with: VoiceDataSavingMode.allCases.map { $0.string }, delegate: self, frame: frame)
        voiceDataSavingModeSegmentedControl.selectedIndex = AppSettings.shared.voiceDataSavingMode.index
        container.addSubview(voiceDataSavingModeSegmentedControl)
        
        let height = modeLabel.frame.height + modeSegmentedControl.frame.height + voiceDataSavingModeLabel.frame.height + voiceDataSavingModeSegmentedControl.frame.height + spacing * 3
        container.frame = CGRect(x: container.frame.origin.x, y: container.frame.origin.y, width: container.frame.width, height: height)
        
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: container.frame.width),
            container.heightAnchor.constraint(equalToConstant: container.frame.height),
            
            modeLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: spacing / 2),
            modeLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            modeSegmentedControl.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: spacing / 4),
            modeSegmentedControl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            voiceDataSavingModeLabel.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: spacing * 1.5),
            voiceDataSavingModeLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            voiceDataSavingModeSegmentedControl.topAnchor.constraint(equalTo: voiceDataSavingModeLabel.bottomAnchor, constant: spacing / 4),
            voiceDataSavingModeSegmentedControl.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return container
    }
    
    private func configureLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 1
        label.sizeToFit()
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: label.frame.width),
            label.heightAnchor.constraint(equalToConstant: label.frame.height)
        ])
        
        return label
    }
    
    @objc private func tapAction() {
        removeFromSuperview()
    }
}

extension AppSettingsView: CustomSegmentedControlDelegate {
    func didSelect(_ selectedIndex: Int, customSegemtedControl: CustomSegmentedControl) {
        if customSegemtedControl == modeSegmentedControl {
            AppSettings.shared.mode = AppMode.from(selectedIndex)
        } else if customSegemtedControl == voiceDataSavingModeSegmentedControl {
            AppSettings.shared.voiceDataSavingMode = VoiceDataSavingMode.from(selectedIndex)
        }
    }
}
