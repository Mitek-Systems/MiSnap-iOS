//
//  CustomTutorialViewController.swift
//
//  Created by Mitek Engineering on 2/23/22.
//

import UIKit
import MiSnapUX

/*
 Custom UI should be added in the dedicated extension below
 */
class CustomTutorialViewController: UIViewController {
    private let mode: MiSnapUxTutorialMode
    private weak var delegate: MiSnapTutorialViewControllerDelegate?
    private let messages: [String]
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(for mode: MiSnapUxTutorialMode, delegate: MiSnapTutorialViewControllerDelegate, messages: [String]) {
        self.mode = mode
        self.delegate = delegate
        self.messages = messages
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
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
    
    deinit {
        print("\(String(describing: type(of: self))) is deinitialized")
    }
}

// MARK: Custom UI
extension CustomTutorialViewController {
    private func configureSubviews() {
        // Implement your UI here
        
        /* IMPORTANT:
         When implementing Cancel, Retry, Continue/Manual buttons make sure to call `addTarget(_ :action:for:)`
         and pass cancelButtonAction, retryButtonAction, continueButtonAction selectors respectively
         that'll properly notify MiSnapViewController
         */
        
        let messagesStackView = UIStackView()
        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 10
        
        view.addSubview(messagesStackView)
        
        for message in messages {
            messagesStackView.addArrangedSubview(configureLabel(withText: message))
        }
                
        let cancelButton = configureButton(withTitle: "Cancel", selector: #selector(cancelButtonAction), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        let continueButton = configureButton(withTitle: mode == .timeout ? "Manual" : "Continue", selector: #selector(continueButtonAction), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
        
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
        
        if mode == .timeout {
            let retryButton = configureButton(withTitle: "Retry", selector: #selector(retryButtonAction), frame: CGRect(x: 0, y: 0, width: 90, height: 40))
            
            view.addSubview(retryButton)
            
            NSLayoutConstraint.activate([
                retryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset),
                retryButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ])
        }
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
    @objc private func cancelButtonAction() {
        delegate?.tutorialCancelButtonAction()
    }
    
    @objc private func continueButtonAction() {
        delegate?.tutorialContinueButtonAction(for: mode)
    }
    
    @objc private func retryButtonAction() {
        delegate?.tutorialRetryButtonAction?()
    }
}
