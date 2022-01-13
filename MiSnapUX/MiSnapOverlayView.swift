//
//  MiSnapOverlayView.swift
//  MiSnap UX
//
//  Created by Mitek Engineering on 2/25/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnap

private enum MiSnapAspectRatio: Int {
    case sixteenByNine, fourByThree, greaterThanSixteenByNine
}

public protocol MiSnapOverlayViewDelegate {
    func cancelButtonAction()
    func helpButtonAction()
    func torchButtonAction()
    func manualSelectionButtonAction()
}

public class MiSnapOverlayView: UIView {
    private var configuration: MiSnapConfiguration
    private var delegate: MiSnapOverlayViewDelegate?
    private var orientation: UIInterfaceOrientation {
        didSet {
            guideView?.update(orientation)
            updateButtonsLocations()
        }
    }
    
    private var longerSide: CGFloat!
    private var shorterSide: CGFloat!
    private var aspectRatio: MiSnapAspectRatio {
        if longerSide / shorterSide > 1.78 {
            return .greaterThanSixteenByNine
        } else if longerSide / shorterSide < 1.77 {
            return .fourByThree
        }
        return .sixteenByNine
    }
    
    private var result: MiSnapResult?
    
    private var guideView: MiSnapGuideView?
    
    private var cancelButton: UIButton!
    private var helpButton: UIButton!
    private var torchButton: UIButton!
    private var manualSelectionButton: UIButton!
    
    private var documentLabel: UILabel!
    
    private var hintView: MiSnapHintView?
    private var glareView: MiSnapGlareView?
    
    private var cornersDebugView: UIView?
    
    private var hintTimer: Timer?
    
    private var uiHidden: Bool = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with configuration: MiSnapConfiguration, delegate: MiSnapOverlayViewDelegate, orientation: UIInterfaceOrientation, frame: CGRect) {
        self.configuration = configuration
        self.delegate = delegate
        self.orientation = orientation
        super.init(frame: frame)
        self.frame = frame
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        longerSide = frame.width > frame.height ? frame.width : frame.height
        shorterSide = frame.width < frame.height ? frame.width : frame.height
        
        update(configuration.parameters.mode)
        
        configureSubviews()
    }
    
    public func update(_ orientation: UIInterfaceOrientation) {
        guard !uiHidden else { return }
        self.orientation = orientation
    }
    
    public func update(_ mode: MiSnapMode) {
        configuration.parameters.mode = mode
        if mode == .manual {
            NotificationCenter.default.addObserver(self, selector: #selector(showManualSelectionButton), name: NSNotification.Name(rawValue: "CameraWasAdjusted"), object: nil)
        }
        
        // Re-add recording UI to make sure a red dot is being animated
        configureRecordingUI()
    }
    
    public func update(for result: MiSnapResult) {
        self.result = result
        showDebugCorners(from: result)
        
        if result.highestPriorityStatus == .good && configuration.parameters.mode == .auto {
            return
        }
        
        if let timer = hintTimer {
            if timer.isValid {
                return
            } else {
                startHintTimer(withInterval: TimeInterval(configuration.parameters.smartHintUpdatePeriod) / 1000.0)
                let hintMessage = MiSnapLocalizer.shared.localizedString(for: MiSnapResult.string(from: result.highestPriorityStatus))
                
                if result.highestPriorityStatus == .tooMuchGlare {
                    showHint(withMessage: hintMessage, boundingBox: result.iqa.glareBoundingBoxNormalized)
                } else {
                    showHint(withMessage: hintMessage)
                }
            }
        } else {
            startHintTimer(withInterval: 1.0)
        }
    }
    
    public func manageTorchButton(hasTorch: Bool) {
        if configuration.parameters.documentCategory == .id { return }
        torchButton.isHidden = !hasTorch
        torchButton.isEnabled = hasTorch
        torchOn(true)
    }
    
    public func torchOn(_ isOn: Bool) {
        let torchButtonImageName = isOn ? "misnap_torch_on_icon" : "misnap_torch_off_icon"
        let torchButtonAccessibilityKey = configuration.parameters.camera.torchMode == .off ? "misnap_overlay_flash_off" : "misnap_overlay_flash_on"
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
        
        update(configuration.parameters.mode)
    }
    
    public func successAnimation(with image: UIImage?) {
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
    
    public func setSelectedImage(_ image: UIImage?) {
        guard let image = image else { return }
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
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
        configureGlareView()
        configureHintView()
        configureCornersDebugView()
    }
    
    private func configureGuideView() {
        guideView = MiSnapGuideView(with: configuration.parameters, configuration: configuration.guide, frame: frame, orientation: orientation)
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
        if !configuration.parameters.camera.recordVideo || !configuration.parameters.camera.showRecordingUI { return }
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
        documentLabel.text = configuration.parameters.documentTypeName
        documentLabel.font = .systemFont(ofSize: 17, weight: .bold)
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
        updateButtonsLocations()
    }
    
    private func configureCancelButton() {
        cancelButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                       accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_cancel_button"),
                                       image: UIImage(named: "misnap_cancel_icon"),
                                       selector: #selector(cancelButtonAction))
        
        addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: cancelButton.frame.width),
            cancelButton.heightAnchor.constraint(equalToConstant: cancelButton.frame.height)
            
        ])
    }
    
    private func configureHelpButton() {
        helpButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                     accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_help_button"),
                                     image: UIImage(named: "misnap_help_icon"),
                                     selector: #selector(helpButtonAction))
        
        addSubview(helpButton)
        
        NSLayoutConstraint.activate([
            helpButton.widthAnchor.constraint(equalToConstant: helpButton.frame.width),
            helpButton.heightAnchor.constraint(equalToConstant: helpButton.frame.height)
        ])
    }
    
    private func configureTorchButton() {
        let torchButtonAccessibilityKey = configuration.parameters.camera.torchMode == .off ? "misnap_overlay_flash_off" : "misnap_overlay_flash_on"
        let torchButtonImageName = configuration.parameters.camera.torchMode == .off ? "misnap_torch_off_icon" : "misnap_torch_on_icon"
        torchButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                      accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: torchButtonAccessibilityKey),
                                      image: UIImage(named: torchButtonImageName),
                                      selector: #selector(torchButtonAction))
        // IMPORTANT: Do not remove or override a value below. Torch button visibility is handled automatically in manageTorchButton(hasTorch:) function
        torchButton.isHidden = true
        torchButton.isEnabled = false
        
        addSubview(torchButton)
        
        NSLayoutConstraint.activate([
            torchButton.widthAnchor.constraint(equalToConstant: torchButton.frame.width),
            torchButton.heightAnchor.constraint(equalToConstant: torchButton.frame.height)
        ])
    }
    
    private func configureManualSelectionButton() {
        let smallerSide = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        let size = smallerSide < 375 ? 45 : 65
        manualSelectionButton = configureButton(withFrame: CGRect(x: 0, y: 0, width: size, height: size),
                                                accessibilityLabel: MiSnapLocalizer.shared.localizedString(for: "misnap_overlay_capture_button"),
                                                image: UIImage(named: "misnap_camera_shutter_icon"),
                                                selector: #selector(manualSelectionButtonAction))
        
        /* IMPORTANT: Do not remove or override `isHidden` and `isEnabled` properties below as it
         might result in undefined behavior.
         It is not recommended to display/enable Manual button in Auto mode since it'll negatively
         impact auto capture rate and therefore server acceptance rate.
         If you still want to display/enable it then uncomment a line at the bottom. */
        manualSelectionButton.isHidden = true
        manualSelectionButton.isEnabled = false
        
        addSubview(manualSelectionButton)
        
        NSLayoutConstraint.activate([
            manualSelectionButton.widthAnchor.constraint(equalToConstant: manualSelectionButton.frame.width),
            manualSelectionButton.heightAnchor.constraint(equalToConstant: manualSelectionButton.frame.height)
        ])
        
        updateButtonsLocations()
        
        // Uncomment line below if you want to display/enable a Manual button in Auto mode (NOT RECOMMENDED)
        //NotificationCenter.default.addObserver(self, selector: #selector(showManualSelectionButton), name: NSNotification.Name(rawValue: "CameraWasAdjusted"), object: nil)
    }
    
    private func updateButtonsLocations() {
        for c in constraints {
            if let _ = c.firstItem as? UIButton {
                removeConstraint(c)
            }
        }
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        
        if orientation.isPortrait {
            switch aspectRatio {
            case .greaterThanSixteenByNine:     offsetY = (longerSide - shorterSide * 16 / 9) / 2
            case .fourByThree:                  offsetX = (shorterSide - longerSide * 9 / 16) / 2
            default: break
            }

            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 10 + offsetY),
                cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20 + offsetX),
                
                helpButton.topAnchor.constraint(equalTo: topAnchor, constant: 10 + offsetY),
                helpButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20 - offsetX),
                
                torchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10 - offsetY),
                torchButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20 + offsetX),
                
                manualSelectionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40 - offsetY),
                manualSelectionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        } else {
            switch aspectRatio {
            case .greaterThanSixteenByNine:     offsetX = (longerSide - shorterSide * 16 / 9) / 2
            case .fourByThree:                  offsetY = (shorterSide - longerSide * 9 / 16) / 2
            default: break
            }
            
            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 10 + offsetY),
                cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20 + offsetX),
                
                helpButton.topAnchor.constraint(equalTo: topAnchor, constant: 10 + offsetY),
                helpButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20 - offsetX),
                
                torchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10 - offsetY),
                torchButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20 + offsetX),
                
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
            guard let weakSelf = self else { return }
            weakSelf.manualSelectionButton.isHidden = false
            weakSelf.manualSelectionButton.isEnabled = true
        }
    }
    
    private func configureHintView() {
        hintView = MiSnapHintView(with: configuration.hint)
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
        glareView = MiSnapGlareView(with: configuration.glare)
        guard let glareView = glareView else { fatalError("Couldn't initialize MiSnap Glare View") }
        addSubview(glareView)
    }
    
    private func configureCornersDebugView() {
        guard configuration.uxParameters.showCorners else { return }
        cornersDebugView = UIView(frame: frame)
        guard let cornersDebugView = cornersDebugView else { return }
        cornersDebugView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cornersDebugView)
        
        NSLayoutConstraint.activate([
            cornersDebugView.topAnchor.constraint(equalTo: topAnchor),
            cornersDebugView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cornersDebugView.leftAnchor.constraint(equalTo: leftAnchor),
            cornersDebugView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
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
    
    private func showDebugCorners(from result: MiSnapResult) {
        guard let points = result.iqa.cornerPointsNormalized as? [CGPoint], points.count == 4, let cornersDebugView = cornersDebugView else { return }
        if let sublayers = cornersDebugView.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        
        let path = UIBezierPath()
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addLine(to: points[2])
        path.addLine(to: points[3])
        path.close()
        
        let cornersLayer = CAShapeLayer()
        cornersLayer.path = path.cgPath
        cornersLayer.lineWidth = 2
        cornersLayer.strokeColor = #colorLiteral(red: 1, green: 0.1592381612, blue: 0, alpha: 1)
        cornersLayer.fillColor = UIColor.clear.cgColor
        
        cornersDebugView.layer.addSublayer(cornersLayer)
    }

    private func hideUI() {
        uiHidden = true
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.guideView?.alpha = 0.0
        } completion: { [weak self] (completed) in
            guard let weakSelf = self else { return }
            if completed {
                weakSelf.guideView?.removeFromSuperview()
            }
        }
        
        hintView?.removeFromSuperview()
        glareView?.removeFromSuperview()
        cornersDebugView?.removeFromSuperview()
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
    }
    
    @objc private func manualSelectionButtonAction() {
        delegate?.manualSelectionButtonAction()
    }
}
