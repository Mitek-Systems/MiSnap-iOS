//
//  CustomTutorialViewController.swift
//
//  Created by Stas Tsuprenko on 7/26/24.
//

import UIKit
import MiSnapUX
import MiSnap
import MiSnapAssetManager

/*
 Custom UI should be added in the dedicated extension below
 */
class CustomTutorialViewController: UIViewController {
    private let documentType: MiSnapScienceDocumentType
    private let tutorialMode: MiSnapUxTutorialMode
    private let mode: MiSnapMode
    private var statuses: [MiSnapStatus] = []
    private let image: UIImage?
    private weak var delegate: MiSnapTutorialViewControllerDelegate?
    private let bundle: Bundle
    private let stringsName: String
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(for documentType: MiSnapScienceDocumentType,
         tutorialMode: MiSnapUxTutorialMode,
         mode: MiSnapMode,
         statuses: [NSNumber]?,
         image: UIImage?,
         delegate: MiSnapTutorialViewControllerDelegate) {
        self.documentType = documentType
        self.tutorialMode = tutorialMode
        self.mode = mode
        self.image = image
        self.delegate = delegate
        /*
         By default, it's assumed that this class and localizable strings are in the same bundle.
         If it's not the case then replace `type(of: self)` with a correct class that's in the same bundle as localizable strings
         */
        self.bundle = Bundle(for: type(of: self))
        /*
         By default, MiSnap localizable strings file is called "MiSnapLocalizable".
         Provide a correct name below if you renamed the file or moved strings into a different one
         */
        self.stringsName = "MiSnapLocalizable"
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
        
        self.statuses = getMiSnapStatuses(from: statuses)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Implement your UI inside `configureSubviews`
        configureSubviews()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        delegate = nil
        super.dismiss(animated: flag, completion: completion)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.configureSubviews()
        }, completion: nil)
    }
    
    deinit {
        print("\(String(describing: type(of: self))) is deinitialized")
    }
}

// MARK: Private utilities
extension CustomTutorialViewController {
    private func getMiSnapStatuses(from statuses: [NSNumber]?) -> [MiSnapStatus] {
        guard let statuses = statuses else { return [] }
        var miSnapStatuses: [MiSnapStatus] = []
        for status in statuses {
            guard let miSnapStatus = MiSnapStatus(rawValue: status.intValue) else { continue }
            miSnapStatuses.append(miSnapStatus)
        }
        return miSnapStatuses
    }
    
    private func getLocalizedMessages(from statuses: [MiSnapStatus]) -> [String] {
        var messages: [String] = []
        /*
         In default UX up to two most frequent messages are displayed so that a user is not overwhelmed
         Tweak this number to your liking
         */
        let maxNumber: Int = 2
        for (idx, status) in statuses.enumerated() {
            if idx >= maxNumber { break }
            let key = MiSnapResult.string(from: status) + "_timeout"
            let message = localizedString(for: key)
            messages.append(message)
        }
        // Different statuses can be mapped to the same message therefore get only unique messages
        if let uniqueMessages = NSOrderedSet(array: messages).array as? [String] {
            messages = uniqueMessages
        }
        return messages
    }
    
    private func localizedString(for key: String) -> String {
        bundle.localizedString(forKey: key, value: key, table: stringsName)
    }
}

// MARK: Custom UI
extension CustomTutorialViewController {
    private func configureSubviews() {
        // Implement your UI here
        
        removeAllSubviews()
        configureCommonSubviews()
        
        switch tutorialMode {
        case .instruction:  configureForInstruction()
        case .help:         configureForHelp()
        case .timeout:      configureForTimeout()
        case .review:       configureForReview()
        default:            break
        }
    }
    
    private func removeAllSubviews() {
        for v in view.subviews {
            v.removeFromSuperview()
        }
    }
    
    private func configureCommonSubviews() {
        // Implemenent common UI for all tutorials here or delete this function if there's no common UI
    }
    
    private func configureForInstruction() {
        /* 
         Implement your instruction tutorial here
         
         Note:
            * `documentType` is available so that messages can be tailored for each document type if needed
            * `mode` is available so that messages can be tailored for each mode if needed
         
         IMPORTANT:
         
         When implementing Cancel, Retry, Continue/Manual buttons make sure to call `addTarget(_:action:for:)`
         and pass cancelButtonAction(_:), retryButtonAction(_:), continueButtonAction(_:) selectors respectively
         that'll properly notify MiSnapViewController
         */
    }
    
    private func configureForHelp() {
        /*
         Implement your help tutorial here
         
         Note:
            * `documentType` is available so that messages can be tailored for each document type if needed
            * `mode` is available so that messages can be tailored for each mode if needed
         
         IMPORTANT:
         
         When implementing Cancel, Retry, Continue/Manual buttons make sure to call `addTarget(_:action:for:)`
         and pass cancelButtonAction(_:), retryButtonAction(_:), continueButtonAction(_:) selectors respectively
         that'll properly notify MiSnapViewController
         */
        let messages = [
            "Center the document on a dark surface, provide ample light. Align document.",
            mode == .auto ? "We will take the photo for you." : "Tap the capture button when ready."
        ]
        
        let messagesStackView = UIStackView()
        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 10
        
        view.addSubview(messagesStackView)
        
        for message in messages {
            messagesStackView.addArrangedSubview(configureLabel(withText: message))
        }
                
        let cancelButton = configureButton(withTitle: "Cancel", selector: #selector(cancelButtonAction(_:)), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        let continueButton = configureButton(withTitle: "Continue", selector: #selector(continueButtonAction(_:)), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        
        view.addSubview(cancelButton)
        view.addSubview(continueButton)
        
        let offset: CGFloat = 30.0
        
        NSLayoutConstraint.activate([
            messagesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messagesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset),
            cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: offset),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset),
            continueButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -offset)
        ])
    }
    
    private func configureForTimeout() {
        /*
         Implement your timeout tutorial here
         
         Note:
            * `statuses` of type `[MiSnapStatus]` is available with ordered statuses from the most to the least frequent
            * `documentType` is available so that messages can be tailored for each document type if needed
         
         IMPORTANT:
         
         When implementing Cancel, Retry, Continue/Manual buttons make sure to call `addTarget(_:action:for:)`
         and pass cancelButtonAction(_:), retryButtonAction(_:), continueButtonAction(_:) selectors respectively
         that'll properly notify MiSnapViewController
         */
        
        /* Uncomment to get MiSnap localized messages for given `statuses`.
         Alternatively, create your own map from `[MiSnapStatus]` to a `[String]` */
        let messages = getLocalizedMessages(from: statuses)
        
        let messagesStackView = UIStackView()
        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 10
        
        view.addSubview(messagesStackView)
        
        for message in messages {
            messagesStackView.addArrangedSubview(configureLabel(withText: message))
        }
                
        let cancelButton = configureButton(withTitle: "Cancel", selector: #selector(cancelButtonAction(_:)), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        let continueButton = configureButton(withTitle: "Manual", selector: #selector(continueButtonAction(_:)), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        let retryButton = configureButton(withTitle: "Retry", selector: #selector(retryButtonAction(_:)), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        
        view.addSubview(cancelButton)
        view.addSubview(continueButton)
        view.addSubview(retryButton)
        
        let offset: CGFloat = 30.0
        
        NSLayoutConstraint.activate([
            messagesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messagesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset),
            cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: offset),
            
            retryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset),
            retryButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset),
            continueButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -offset)
        ])
    }
    
    private func configureForReview() {
        /*
         Implement your review tutorial here
         
         Note:
            * `statuses` of type `[MiSnapStatus]` is available with ordered warnings from the highest to the lowest priority.
                * an image passed all image quality analysis checks if `statuses` is an empty array
            * `image` is available for preview
            * `documentType` is available so that messages can be tailored for each document type if needed
         
         IMPORTANT:
         
         When implementing Cancel, Retry, Continue/Manual buttons make sure to call `addTarget(_:action:for:)`
         and pass cancelButtonAction(_:), retryButtonAction(_:), continueButtonAction(_:) selectors respectively
         that'll properly notify MiSnapViewController
         */
        
        /* Uncomment to get MiSnap localized messages for given `statuses`.
         Alternatively, create your own map from `[MiSnapStatus]` to a `[String]` */
        //let messages = getLocalizedMessages(from: statuses)
    }
    
    private func configureButton(withTitle title: String, selector: Selector, frame: CGRect) -> UIButton {
        let button = UIButton(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 19.0, weight: .bold)
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: button.frame.width),
            button.heightAnchor.constraint(equalToConstant: button.frame.height)
        ])
        
        return button
    }
    
    private func configureLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: 100))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 3
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: label.frame.width),
            label.heightAnchor.constraint(equalToConstant: label.frame.height)
        ])
        
        return label
    }
}

// MARK: Buttons actions
extension CustomTutorialViewController {
    @objc private func cancelButtonAction(_ button: UIButton) {
        delegate?.tutorialCancelButtonAction()
    }
    
    @objc private func continueButtonAction(_ button: UIButton) {
        delegate?.tutorialContinueButtonAction(for: tutorialMode)
    }
    
    @objc private func retryButtonAction(_ button: UIButton) {
        delegate?.tutorialRetryButtonAction?()
    }
}
