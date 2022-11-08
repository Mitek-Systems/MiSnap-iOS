//
//  ResultViewController.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 11/4/22.
//  Copyright © 2022 Mitek Systems Inc. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    private(set) var result: MiSnapWorkflowResult
    private let loadingView: LoadingView = LoadingView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with result: MiSnapWorkflowResult) {
        self.result = result
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
        handleResults()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
    
    func handleResults() {}
    
    func configureSubviews() {
        let backButton = configureBackButton()
        view.addSubview(backButton)
        
        let resultView = configureResultView()
        view.addSubview(resultView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            
            resultView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            resultView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            resultView.leftAnchor.constraint(equalTo: view.leftAnchor),
            resultView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func configureResultView() -> UIStackView {
        return UIStackView()
    }
    
    func addLoadingView(text: String) {
        loadingView.textLabel.text = text
        loadingView.alpha = 1.0
        if !loadingView.spinner.isAnimating {
            loadingView.spinner.startAnimating()
        }
        
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func removeLoadingView(animated: Bool = false, delay: TimeInterval = 0.0) {
        if animated {
            UIView.animate(withDuration: 1.0, delay: delay, animations: {
                self.loadingView.alpha = 0.0
            }) { (completed) in
                if completed {
                    if self.loadingView.spinner.isAnimating {
                        self.loadingView.spinner.stopAnimating()
                    }
                    self.loadingView.removeFromSuperview()
                }
            }
        } else {
            if loadingView.spinner.isAnimating {
                loadingView.spinner.stopAnimating()
            }
            loadingView.removeFromSuperview()
        }
    }
    
    func removeLoadingView(with message: String) {
        self.loadingView.textLabel.text = message
        self.loadingView.spinner.isHidden = true
        self.removeLoadingView(animated: true, delay: 6.0)
    }
    
    func messageFrom(_ errorCode: Int) -> String {
        switch errorCode {
        case 400: return "Bad Request"
        case 401: return "Client authentication failed"
        case 403: return "Forbidden"
        case 404: return "Not found"
        case 500: return "Internal server error"
        case 502: return "Bad Gateway"
        default: return "Unknown Error"
        }
    }
}

extension ResultViewController {
    private func configureBackButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemBlue.withAlphaComponent(0.3), for: .highlighted)
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 19.0, weight: .bold)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: button.frame.width),
            button.heightAnchor.constraint(equalToConstant: button.frame.height)
        ])
        
        return button
    }
    
    @objc private func backButtonAction() {
        MitekPlatform.shared.cancel()
        dismiss(animated: true)
    }
}
