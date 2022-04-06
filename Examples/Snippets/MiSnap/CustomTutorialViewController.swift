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
