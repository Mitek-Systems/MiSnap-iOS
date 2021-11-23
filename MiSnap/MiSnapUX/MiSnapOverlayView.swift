//
//  MiSnapOverlayView.swift
//  MiSnap UX
//
//  Created by Stas Tsuprenko on 2/25/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnap

protocol MiSnapOverlayViewDelegate {
    func cancelButtonAction()
    func helpButtonAction()
    func torchButtonAction()
    func manualSelectionButtonAction()
}

class MiSnapOverlayView: UIView {
    private var parameters: MiSnapParameters
    private var delegate: MiSnapOverlayViewDelegate?
    private var orientation: UIInterfaceOrientation {
        didSet {
            guideView?.update(orientation)
            updateManualSelectionButtonLocation()
        }
    }
    
    private var results: MiSnapResults?
    
    private var guideView: MiSnapGuideView?
    
    private var cancelButton: UIButton!
    private var helpButton: UIButton!
    private var torchButton: UIButton!
    private var manualSelectionButton: UIButton!
    
    private var documentLabel: UILabel!
    
    private var hintView: MiSnapHintView?
    private var glareView: MiSnapGlareView?
    
    private var vignetteStyle: MiSnapVignetteStyle = .blur
    private var alignment: MiSnapGuideAlignment = .center
    
    private var hintTimer: Timer?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with parameters: MiSnapParameters, delegate: MiSnapOverlayViewDelegate, orientation: UIInterfaceOrientation, vignetteStyle: MiSnapVignetteStyle = .blur, alignment: MiSnapGuideAlignment = .center, frame: CGRect) {
        self.parameters = parameters
        self.delegate = delegate
        self.orientation = orientation
        self.vignetteStyle = vignetteStyle
        self.alignment = alignment
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        update(parameters.mode)
        
        configureSubviews()
    }
    
    public func update(_ orientation: UIInterfaceOrientation) {
        self.orientation = orientation
    }
    
    public func update(_ mode: MiSnapMode) {
        parameters.mode = mode
        if mode == .manual {
            NotificationCenter.default.addObserver(self, selector: #selector(showManualSelectionButton), name: NSNotification.Name(rawValue: "CameraWasAdjusted"), object: nil)
        }
        
        // Re-add recording UI to make sure a red dot is being animated
        configureRecordingUI()
    }
    
    public func update(_ results: MiSnapResults) {
        self.results = results
        
        if results.highestPriorityStatus == .good && parameters.mode == .auto {
            return
        }
        
        if let timer = hintTimer {
            if timer.isValid {
                return
            } else {
                startHintTimer(withInterval: TimeInterval(parameters.smartHintUpdatePeriod) / 1000.0)
                let hintMessage = MiSnapLocalizer.shared.localizedString(for: MiSnapResults.string(from: results.highestPriorityStatus))
                
                if results.highestPriorityStatus == .tooMuchGlare {
                    showHint(withMessage: hintMessage, boundingBox: results.glareBoundingBoxNormalized)
                } else {
                    showHint(withMessage: hintMessage)
                }
            }
        } else {
            startHintTimer(withInterval: 1.0)
        }
    }
    
    public func manageTorchButton(hasTorch: Bool) {
        if parameters.documentTypeCategory == .id { return }
        torchButton.isHidden = !hasTorch
        torchButton.isEnabled = hasTorch
    }
    
    public func torchOn(_ isOn: Bool) {
        let torchButtonImageName = isOn ? "misnap_torch_on_icon" : "misnap_torch_off_icon"
        let torchButtonAccessibilityKey = parameters.torchMode == .off ? "misnap_overlay_flash_off" : "misnap_overlay_flash_on"
        torchButton.setImage(UIImage(named: torchButtonImageName), for: .normal)
        torchButton.accessibilityLabel = torchButtonAccessibilityKey
    }
    
    public func addInterruptionView(withMessage message: String) {
        removeInterruptionView()
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = frame
        blurView.tag = 12
        
        let label = UILabel(frame: blurView.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 5
        label.text = message
        label.textColor = .black
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.textAlignment = .center
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.9
        
        blurView.contentView.addSubview(label)
        addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: leftAnchor),
            blurView.rightAnchor.constraint(equalTo: rightAnchor),
            
            label.topAnchor.constraint(equalTo: blurView.topAnchor),
            label.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
            label.leftAnchor.constraint(equalTo: blurView.leftAnchor),
            label.rightAnchor.constraint(equalTo: blurView.rightAnchor)
        ])
    }
    
    public func removeInterruptionView() {
        if let v = viewWithTag(12) {
            v.removeFromSuperview()
        }
        
        update(parameters.mode)
    }
    
    public func successAnimation(with image: UIImage) {
        // TODO: Do we need to disable view animations to resolve an issue where a hint view is animated on top of success view
        hideUI()
        setSelectedImage(image)
        
        var images: [UIImage] = []
        
        for i in 10...26 {
            guard let image = UIImage(named: "wink_\(i)") else { fatalError("there's no image named \"wink_\(i)\"") }
            images.append(image)
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 113, height: 113))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        imageView.image = images.last
        imageView.animationImages = images
        imageView.animationRepeatCount = 1
        imageView.animationDuration = 0.75
        imageView.startAnimating()
        
        let text = MiSnapLocalizer.shared.localizedString(for: "dialog_success")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 55))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 29, weight: .semibold)
        label.numberOfLines = 1
        label.textColor = .black
        
        let backgroundView = UIView(frame: frame)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        backgroundView.layer.cornerRadius = 12.0
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.insertSubview(backgroundView, at: 0)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fill
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: 270),
            stackView.heightAnchor.constraint(equalToConstant: imageView.frame.height),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: stackView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: stackView.rightAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width),
            imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height),
            imageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
        ])
        
        UIAccessibility.post(notification: .announcement, argument: text)
    }
    
    public func setSelectedImage(_ image: UIImage) {
        if let v = viewWithTag(13) { v.removeFromSuperview() }
        
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.tag = 13
        
        insertSubview(imageView, at: 0)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    public func shutdown() {
        delegate = nil
    }
}

// MARK: Private views configurations functions
extension MiSnapOverlayView {
    private func configureSubviews() {
        configureGuideView()
        configureRecordingUI()
        configureButtons()
        configureDocumentLabel()
        configureHintView()
        configureGlareView()
    }
    
    private func configureGuideView() {
        guideView = MiSnapGuideView(with: parameters, vignetteStyle: vignetteStyle, alignment: alignment, frame: frame, orientation: orientation)
        guard let guideView = guideView else { fatalError("Couldn't initialize MiSnap Guide View") }
        
        addSubview(guideView)
        
        NSLayoutConstraint.activate([
            guideView.topAnchor.constraint(equalTo: topAnchor),
            guideView.bottomAnchor.constraint(equalTo: bottomAnchor),
            guideView.leftAnchor.constraint(equalTo: leftAnchor),
            guideView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func configureRecordingUI() {
        if !parameters.cameraParameters.recordVideo || !parameters.cameraParameters.showRecordingUI { return }
        guard let guideView = guideView else { return }
        removeRecordingUI()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 30))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        containerView.tag = 11
        containerView.layer.cornerRadius = containerView.frame.height / 2
        
        let redDotView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        redDotView.translatesAutoresizingMaskIntoConstraints = false
        redDotView.backgroundColor = .red
        redDotView.layer.cornerRadius = redDotView.frame.height / 2
        
        containerView.addSubview(redDotView)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_record")
        label.font = .systemFont(ofSize: 15.0, weight: .light)
        label.textAlignment = .center
        label.textColor = .black

        containerView.addSubview(label)

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: guideView.guideRect.origin.y - containerView.frame.height - 10),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: containerView.frame.width),
            containerView.heightAnchor.constraint(equalToConstant: containerView.frame.height),

            redDotView.widthAnchor.constraint(equalToConstant: redDotView.frame.width),
            redDotView.heightAnchor.constraint(equalToConstant: redDotView.frame.height),
            redDotView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            redDotView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10),

            label.leftAnchor.constraint(equalTo: redDotView.rightAnchor, constant: 5),
            label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: [.autoreverse, .repeat],
                           animations: {
                            redDotView.alpha = 0.0
                           }, completion: nil)
        }
    }
    
    private func removeRecordingUI() {
        if let v = viewWithTag(11) {
            v.removeFromSuperview()
        }
    }
    
    private func configureDocumentLabel() {
        documentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        documentLabel.translatesAutoresizingMaskIntoConstraints = false
        documentLabel.text = parameters.documentTypeName
        documentLabel.font = .systemFont(ofSize: 17)
        documentLabel.textAlignment = .center
        documentLabel.numberOfLines = 1
        
        addSubview(documentLabel)
        
        NSLayoutConstraint.activate([
            documentLabel.leftAnchor.constraint(equalTo: cancelButton.rightAnchor, constant: 5),
            documentLabel.rightAnchor.constraint(equalTo: helpButton.leftAnchor, constant: 5),
            documentLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            documentLabel.heightAnchor.constraint(equalToConstant: documentLabel.frame.height)
        ])
    }
    
    private func configureButtons() {
        configureCancelButton()
        configureHelpButton()
        configureTorchButton()
        configureManualSelectionButton()
    }
    
    private func configureCancelButton() {
        cancelButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                       accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_cancel_button"),
                                       image: UIImage(named: "misnap_cancel_icon"),
                                       selector: #selector(cancelButtonAction))
        
        addSubview(cancelButton)
        
        var topAnchor = self.topAnchor
        var leftAnchor = self.leftAnchor
        if #available(iOS 11.0, *) {
            topAnchor = safeAreaLayoutGuide.topAnchor
            leftAnchor = safeAreaLayoutGuide.leftAnchor
        }
        
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: cancelButton.frame.width),
            cancelButton.heightAnchor.constraint(equalToConstant: cancelButton.frame.height),
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        ])
    }
    
    private func configureHelpButton() {
        helpButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                     accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_help_button"),
                                     image: UIImage(named: "misnap_help_icon"),
                                     selector: #selector(helpButtonAction))
        
        addSubview(helpButton)
        
        var topAnchor = self.topAnchor
        var rightAnchor = self.rightAnchor
        if #available(iOS 11.0, *) {
            topAnchor = safeAreaLayoutGuide.topAnchor
            rightAnchor = safeAreaLayoutGuide.rightAnchor
        }
        
        NSLayoutConstraint.activate([
            helpButton.widthAnchor.constraint(equalToConstant: helpButton.frame.width),
            helpButton.heightAnchor.constraint(equalToConstant: helpButton.frame.height),
            helpButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            helpButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20)
        ])
    }
    
    private func configureTorchButton() {
        let torchButtonAccessibilityKey = parameters.torchMode == .off ? "misnap_overlay_flash_off" : "misnap_overlay_flash_on"
        let torchButtonImageName = parameters.torchMode == .off ? "misnap_torch_off_icon" : "misnap_torch_on_icon"
        torchButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                      accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: torchButtonAccessibilityKey),
                                      image: UIImage(named: torchButtonImageName),
                                      selector: #selector(torchButtonAction))
        // IMPORTANT: Do not remove or override a value below. Torch button visibility is handled automatically in manageTorchButton(hasTorch:) function
        torchButton.isHidden = true
        torchButton.isEnabled = false
        
        addSubview(torchButton)
        
        var bottomAnchor = self.bottomAnchor
        var leftAnchor = self.leftAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = safeAreaLayoutGuide.bottomAnchor
            leftAnchor = safeAreaLayoutGuide.leftAnchor
        }
        
        NSLayoutConstraint.activate([
            torchButton.widthAnchor.constraint(equalToConstant: torchButton.frame.width),
            torchButton.heightAnchor.constraint(equalToConstant: torchButton.frame.height),
            torchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            torchButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        ])
    }
    
    private func configureManualSelectionButton() {
        let manualSelectionButtonSize = MiSnapOrientation.current.isPortrait ? frame.size.height * 0.08 : frame.size.width * 0.08
        manualSelectionButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: manualSelectionButtonSize, height: manualSelectionButtonSize),
                                                accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_capture_button"),
                                                image: UIImage(named: "misnap_camera_shutter_icon"),
                                                selector: #selector(manualSelectionButtonAction))
        
        // TODO: implement a proper way of displaying manual button in Auto mode and add comment how to do enable it here
        // IMPORTANT: Do not remove or override. Manual button visibility is handled automatically in showManualSelectionButton() function
        manualSelectionButton.isHidden = true
        manualSelectionButton.isEnabled = false
        
        addSubview(manualSelectionButton)
        
        NSLayoutConstraint.activate([
            manualSelectionButton.widthAnchor.constraint(equalToConstant: manualSelectionButton.frame.width),
            manualSelectionButton.heightAnchor.constraint(equalToConstant: manualSelectionButton.frame.height)
        ])
        
        updateManualSelectionButtonLocation()
    }
    
    private func updateManualSelectionButtonLocation() {
        for c in constraints {
            if let button = c.firstItem as? UIButton, button == manualSelectionButton {
                removeConstraint(c)
            }
        }
        
        var bottomAnchor = self.bottomAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = safeAreaLayoutGuide.bottomAnchor
        }
        if orientation.isPortrait {
            NSLayoutConstraint.activate([
                manualSelectionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
                manualSelectionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                manualSelectionButton.centerXAnchor.constraint(equalTo: helpButton.centerXAnchor),
                manualSelectionButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
    
    private func configureButton(withFrame frame: CGRect, title: String? = nil, accessibilityLabel: String, image: UIImage? = nil, selector: Selector) -> UIButton {
        let button = UIButton(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if let title = title {
            button.setTitle(title, for: .normal)
            // CUSTOMIZATION: uncomment and set a title color if needed
            //button.setTitleColor(.red, for: .normal)
        }
        
        if let image = image {
            button.setImage(image, for: .normal)
        }
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.isExclusiveTouch = true
        
        return button
    }
    
    @objc private func showManualSelectionButton() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CameraWasAdjusted"), object: nil)
        DispatchQueue.main.async { [weak self] in
            self?.manualSelectionButton.isHidden = false
            self?.manualSelectionButton.isEnabled = true
        }
    }
    
    private func configureHintView() {
        hintView = MiSnapHintView()
        guard let hintView = hintView else { fatalError("Couldn't initialize MiSnap Hint View") }
        addSubview(hintView)
        
        NSLayoutConstraint.activate([
            hintView.widthAnchor.constraint(equalToConstant: hintView.frame.width),
            hintView.heightAnchor.constraint(equalToConstant: hintView.frame.height),
            hintView.centerXAnchor.constraint(equalTo: centerXAnchor),
            hintView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func configureGlareView() {
        glareView = MiSnapGlareView()
        guard let glareView = glareView else { fatalError("Couldn't initialize MiSnap Glare View") }
        addSubview(glareView)
    }
}

// MARK: Other private functions
extension MiSnapOverlayView {
    private func startHintTimer(withInterval interval: TimeInterval) {
        invalidateHintTimer()
        hintTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(invalidateHintTimer), userInfo: nil, repeats: false)
    }
    
    @objc private func invalidateHintTimer() {
        if let timer = hintTimer {
            timer.invalidate()
        }
    }
    
    private func showHint(withMessage message: String, boundingBox: CGRect? = nil) {
        if let hintView = hintView {
            hintView.animate(with: message)
        }
        
        if let glareView = glareView, let box = boundingBox {
            glareView.animate(with: box)
        }
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func hideUI() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear) { [weak self] in
            self?.guideView?.alpha = 0.0
        } completion: { [weak self] (completed) in
            if completed {
                self?.guideView?.removeFromSuperview()
            }
        }
        
        hintView?.removeFromSuperview()
        glareView?.removeFromSuperview()
        cancelButton.removeFromSuperview()
        helpButton.removeFromSuperview()
        torchButton.removeFromSuperview()
        manualSelectionButton.removeFromSuperview()
        documentLabel.removeFromSuperview()
        removeInterruptionView()
        removeRecordingUI()
    }
}

// MARK: Button actions
extension MiSnapOverlayView {
    @objc private func cancelButtonAction() {
        delegate?.cancelButtonAction()
    }
    
    @objc private func helpButtonAction() {
        delegate?.helpButtonAction()
    }
    
    @objc private func torchButtonAction() {
        delegate?.torchButtonAction()
        //TODO: adjust torch button image
    }
    
    @objc private func manualSelectionButtonAction() {
        delegate?.manualSelectionButtonAction()
    }
}
