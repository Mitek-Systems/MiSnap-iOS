//
//  MiSnapTutorialViewController.swift
//  MiSnap UX
//
//  Created by Mitek Engineering on 2/25/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnap

protocol MiSnapTutorialViewControllerDelegate {
    func tutorialContinueButtonAction(for tutorialMode: MiSnapTutorialMode)
    func tutorialRetryButtonAction()
    func tutorialCancelButtonAction()
}

class MiSnapTutorialViewController: UIViewController {
    private var parameters: MiSnapParameters
    private var tutorialMode: MiSnapTutorialMode
    private var messages: [String] = []
    private var delegate: MiSnapTutorialViewControllerDelegate?
    private var supportedOrientation: UIInterfaceOrientationMask = .all
    
    private var cancelButton: UIButton!
    private var retryButton: UIButton!
    private var continueButton: UIButton!
    
    private var buttonsContainerView: UIView!
    private var messagesStackView: UIStackView!
    private var doNotShowStackView: UIStackView!
    
    private var orientation: UIInterfaceOrientation = .unknown {
        didSet {
            configureSubviews()
        }
    }
    
    // CUSTOMIZATION: change values below to customize look and feel of Buttons
    private let buttonHeight: CGFloat = 60
    private let buttonTextColor: UIColor = .white
    private let buttonBackgroundColor: UIColor = .black

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with parameters: MiSnapParameters, tutorialMode: MiSnapTutorialMode, messages: [String], delegate: MiSnapTutorialViewControllerDelegate, supportedOrientation: UIInterfaceOrientationMask) {
        self.parameters = parameters
        self.tutorialMode = tutorialMode
        self.messages = NSOrderedSet(array: messages).array as! [String]
        self.delegate = delegate
        self.supportedOrientation = supportedOrientation
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        orientation = MiSnapOrientation.current
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            guard let weakSelf = self else { return }
            weakSelf.orientation = MiSnapOrientation.current
        }, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientation
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: Public functions
extension MiSnapTutorialViewController {
    public func shutdown() {
        delegate = nil
    }
}

// MARK: Private objects configuration functions
extension MiSnapTutorialViewController {
    private func configureSubviews() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        configureButtons()
        configureTutorial()
        configureDoNotShowAgain()
    }
    
    private func configureButtons() {
        if let v = view.viewWithTag(16) { v.removeFromSuperview() }
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width / 3 - 15, height: buttonHeight)
        cancelButton = configureTutorialButton(withFrame: frame, title: MiSnapLocalizer.shared.localizedString(for: "misnap_tutorial_cancel"), selector: #selector(cancelButtonAction))
        retryButton = configureTutorialButton(withFrame: frame, title: MiSnapLocalizer.shared.localizedString(for: "misnap_tutorial_try_again"), selector: #selector(retryButtonAction))
        
        var continueButtonLocalizeKey = "misnap_tutorial_continue"
        if tutorialMode == .timeout || (parameters.mode == .manual && (tutorialMode == .instruction || tutorialMode == .help)) {
            continueButtonLocalizeKey = "misnap_tutorial_capture_manually"
        }
        continueButton = configureTutorialButton(withFrame: frame, title: MiSnapLocalizer.shared.localizedString(for: continueButtonLocalizeKey), selector: #selector(continueButtonAction))
        
        buttonsContainerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight))
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.backgroundColor = buttonBackgroundColor
        buttonsContainerView.tag = 16
        
        buttonsContainerView.addSubview(cancelButton)
        if tutorialMode == .timeout && parameters.mode == .auto {
            buttonsContainerView.addSubview(retryButton)
        }
        buttonsContainerView.addSubview(continueButton)
        
        view.addSubview(buttonsContainerView)
        
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        
        NSLayoutConstraint.activate([
            buttonsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
        
        if tutorialMode == .timeout && parameters.mode == .auto {
            NSLayoutConstraint.activate([
                retryButton.centerYAnchor.constraint(equalTo: buttonsContainerView.centerYAnchor),
                retryButton.centerXAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor),
                retryButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.3),
                retryButton.heightAnchor.constraint(equalTo: buttonsContainerView.heightAnchor),
                
                cancelButton.centerYAnchor.constraint(equalTo: buttonsContainerView.centerYAnchor),
                cancelButton.centerXAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: -buttonsContainerView.frame.width * 0.3),
                cancelButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.3),
                cancelButton.heightAnchor.constraint(equalTo: buttonsContainerView.heightAnchor),
                
                continueButton.centerYAnchor.constraint(equalTo: buttonsContainerView.centerYAnchor),
                continueButton.centerXAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: buttonsContainerView.frame.width * 0.3),
                continueButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.3),
                continueButton.heightAnchor.constraint(equalTo: buttonsContainerView.heightAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                cancelButton.centerYAnchor.constraint(equalTo: buttonsContainerView.centerYAnchor),
                cancelButton.centerXAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: -buttonsContainerView.frame.width * 0.25),
                cancelButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.5),
                cancelButton.heightAnchor.constraint(equalTo: buttonsContainerView.heightAnchor),
                
                continueButton.centerYAnchor.constraint(equalTo: buttonsContainerView.centerYAnchor),
                continueButton.centerXAnchor.constraint(equalTo: buttonsContainerView.centerXAnchor, constant: buttonsContainerView.frame.width * 0.25),
                continueButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.5),
                continueButton.heightAnchor.constraint(equalTo: buttonsContainerView.heightAnchor),
            ])
        }
    }
    
    private func configureTutorialButton(withFrame frame: CGRect, title: String, selector: Selector) -> UIButton {
        let button = UIButton(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(title, for: .normal)
        button.accessibilityLabel = title
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(buttonTextColor, for: .normal)
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.isExclusiveTouch = true
        
        return button
    }
    
    private func configureDoNotShowAgain() {
        if parameters.documentCategory != .id || tutorialMode != .instruction { return }
        if let v = view.viewWithTag(18) { v.removeFromSuperview() }
        
        let checkboxImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
        checkboxImageView.contentMode = .scaleAspectFit
        checkboxImageView.image = UIImage(named: "misnap_checkbox_unchecked")
        
        let doNotShowLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 20))
        doNotShowLabel.translatesAutoresizingMaskIntoConstraints = false
        doNotShowLabel.text = MiSnapLocalizer.shared.localizedString(for: "misnap_tutorial_do_not_show_again")
        doNotShowLabel.font = .systemFont(ofSize: 16.0, weight: .regular)
        doNotShowLabel.textColor = .black
        doNotShowLabel.textAlignment = .center
        let minRect = getMinRect(for: doNotShowLabel, maxWidth: view.frame.width * 0.95)

        doNotShowStackView = UIStackView(arrangedSubviews: [checkboxImageView, doNotShowLabel])
        doNotShowStackView.translatesAutoresizingMaskIntoConstraints = false
        doNotShowStackView.axis = .horizontal
        doNotShowStackView.spacing = 3.0
        doNotShowStackView.distribution = .fill
        doNotShowStackView.tag = 18
        
        view.addSubview(doNotShowStackView)
        
        NSLayoutConstraint.activate([
            checkboxImageView.widthAnchor.constraint(equalToConstant: 15.0),
            checkboxImageView.centerYAnchor.constraint(equalTo: doNotShowStackView.centerYAnchor),
            
            doNotShowStackView.widthAnchor.constraint(equalToConstant: minRect.width + 5 + 15 + 3),
            doNotShowStackView.heightAnchor.constraint(equalToConstant: minRect.size.height + 30),
            doNotShowStackView.bottomAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            doNotShowStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doNotShowTapAction))
        tap.numberOfTapsRequired = 1
        doNotShowStackView.addGestureRecognizer(tap)
    }
    
    private func configureTutorial() {
        if let v = view.viewWithTag(17) { v.removeFromSuperview() }
        if parameters.documentCategory == .id && tutorialMode == .instruction {
            configureTutorialWithImage()
        } else {
            configureTutorialWithText()
        }
    }
    
    private func configureTutorialWithImage() {
        var imageName: String = ""
        
        switch parameters.documentType {
        case .passport:
            imageName = orientation.isPortrait ? parameters.orientationMode == .devicePortraitGuideLandscape ? "misnap_tutorial_passport_portrait_2" : "misnap_tutorial_passport_portrait" : "misnap_tutorial_passport"
        case .idFront, .anyId:
            imageName = orientation.isPortrait ? parameters.orientationMode == .devicePortraitGuideLandscape ? "misnap_tutorial_id_portrait_2" : "misnap_tutorial_id_portrait" : "misnap_tutorial_id"
        case .idBack:
            imageName = orientation.isPortrait ? parameters.orientationMode == .devicePortraitGuideLandscape ? "misnap_tutorial_id_back_portrait_2" : "misnap_tutorial_id_back_portrait" : "misnap_tutorial_id_back"
        default: break
        }
        
        guard let image = UIImage(named: imageName + ".jpg") else { fatalError("there's no tutorial image for \"\(parameters.documentTypeName)\"") }
        let imageView = UIImageView(frame: view.frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.tag = 17
        
        view.insertSubview(imageView, belowSubview: buttonsContainerView)
        
        var topAnchor = view.topAnchor
        var bottomAnchor = view.bottomAnchor
        var leftAnchor = view.leftAnchor
        var rightAnchor = view.rightAnchor
        if #available(iOS 11.0, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            leftAnchor = view.safeAreaLayoutGuide.leftAnchor
            rightAnchor = view.safeAreaLayoutGuide.rightAnchor
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func configureTutorialWithText() {
        if messages.isEmpty { return }
        
        let messagesStackView = UIStackView()
        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 10
        messagesStackView.distribution = .equalCentering
        messagesStackView.tag = 17
        
        var messagesStackViewHeight: CGFloat = 0
        
        for messageKey in messages {
            let message = MiSnapLocalizer.shared.localizedString(for: messageKey)
            
            let arrowImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            arrowImageView.contentMode = .scaleAspectFit
            arrowImageView.image = UIImage(named: "misnap_tutorial_red_arrow")
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 100))
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = message
            messageLabel.numberOfLines = 6
            messageLabel.font = .systemFont(ofSize: 35, weight: .regular)
            messageLabel.textAlignment = .left
            
            let widthMultiplier: CGFloat = orientation.isPortrait ? 0.835 : 0.9
            var minRect = getMinRect(for: messageLabel, maxWidth: view.frame.width * widthMultiplier)
            // Height should be at least 100 pixels
            minRect = CGRect(x: minRect.origin.x, y: minRect.origin.y, width: floor(minRect.width), height: ceil(minRect.height > 100 ? minRect.height : 100))
            
            let horizontalStackView = UIStackView(arrangedSubviews: [arrowImageView, messageLabel])
            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
            horizontalStackView.spacing = 10
            horizontalStackView.distribution = .fill
            
            messagesStackView.addArrangedSubview(horizontalStackView)
            
            NSLayoutConstraint.activate([
                arrowImageView.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor, multiplier: orientation.isPortrait ? 0.125 : 0.065),
                arrowImageView.centerYAnchor.constraint(equalTo: horizontalStackView.centerYAnchor),
                
                messageLabel.heightAnchor.constraint(equalToConstant: minRect.height)
            ])
            
            messagesStackViewHeight += minRect.height
        }
        
        view.addSubview(messagesStackView)
        
        var leftAnchor = view.leftAnchor
        var rightAnchor = view.rightAnchor
        if #available(iOS 11.0, *) {
            leftAnchor = view.safeAreaLayoutGuide.leftAnchor
            rightAnchor = view.safeAreaLayoutGuide.rightAnchor
        }
        
        NSLayoutConstraint.activate([
            messagesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -buttonHeight / 2),
            messagesStackView.heightAnchor.constraint(equalToConstant: messagesStackViewHeight + 10 * (CGFloat(messages.count) - 1)),
            messagesStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            messagesStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
        ])
    }
}

// MARK: Private methods
extension MiSnapTutorialViewController {
    private func getMinRect(for label: UILabel, maxWidth: CGFloat) -> CGRect {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: label.font!
        ]
        guard let text = label.text else { return CGRect.zero }
        let minRect = text.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        return CGRect(x: minRect.origin.x, y: minRect.origin.y, width: ceil(minRect.size.width), height: ceil(minRect.size.height))
    }
    
    private func updateCheckBox(with checked: Bool) {
        for v in doNotShowStackView.arrangedSubviews {
            if let imageView = v as? UIImageView {
                let imageName = checked ? "misnap_checkbox_checked" : "misnap_checkbox_unchecked"
                imageView.image = UIImage(named: imageName)
            }
        }
    }
}

// MARK: Button actions
extension MiSnapTutorialViewController {
    @objc private func cancelButtonAction() {
        delegate?.tutorialCancelButtonAction()
    }
    
    @objc private func retryButtonAction() {
        delegate?.tutorialRetryButtonAction()
    }
    
    @objc private func continueButtonAction() {
        delegate?.tutorialContinueButtonAction(for: tutorialMode)
    }
    
    @objc private func doNotShowTapAction() {
        let key = "instruction_for_\(parameters.documentType.rawValue)"
        
        var show: Bool = true
        if let _ = UserDefaults.standard.value(forKey: key) {
            show = UserDefaults.standard.bool(forKey: key)
        }
        
        UserDefaults.standard.setValue(!show, forKey: key)
        UserDefaults.standard.synchronize()
        updateCheckBox(with: show)
    }
}
