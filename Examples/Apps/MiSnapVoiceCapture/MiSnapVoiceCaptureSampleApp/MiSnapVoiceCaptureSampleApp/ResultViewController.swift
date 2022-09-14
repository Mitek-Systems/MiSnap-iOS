//
//  ResultViewController.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Mitek Engineering on 3/23/22.
//

import UIKit
import MiSnapVoiceCapture

class ResultViewController: UIViewController {
    private var result: MiSnapVoiceCaptureResult?
    private var configured: Bool = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with result: MiSnapVoiceCaptureResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var backgroundColor: UIColor = .white
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                backgroundColor = .black
            }
        }
        view.backgroundColor = backgroundColor
        
        configureSubviews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: Private views configurations functions
extension ResultViewController {
    private func configureSubviews() {
        guard let result = result, !configured else { return }
        configured = true
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(#colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
        backButton.backgroundColor = .clear
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        //let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.image = result.image
        //imageView.contentMode = .scaleAspectFit
        //imageView.backgroundColor = .clear
        //
        //if result.highestPriorityStatus != .good {
        //    imageView.layer.borderWidth = 3.0
        //    imageView.layer.borderColor = UIColor.orange.cgColor
        //}
        //
        //let imageViewTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapAction))
        //imageViewTap.numberOfTapsRequired = 1
        //imageView.isUserInteractionEnabled = true
        //imageView.addGestureRecognizer(imageViewTap)
        //
        //let highestPriorityStatusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        //highestPriorityStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        //var localizedText = MiSnapFacialCaptureResult.localizeKey(from: result.highestPriorityStatus)
        //
        //var attributes = [
        //    NSAttributedString.Key.foregroundColor: UIColor.orange,
        //    NSAttributedString.Key.font:            UIFont.systemFont(ofSize: 20.0, weight: .bold)
        //]
        //
        //if result.highestPriorityStatus == .good {
        //    localizedText = "Good"
        //
        //    attributes = [
        //        NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2784313725, green: 0.6039215686, blue: 0.3725490196, alpha: 1),
        //        NSAttributedString.Key.font:            UIFont.systemFont(ofSize: 20.0, weight: .bold)
        //    ]
        //}
        //
        //localizedText = "Status: \(localizedText)"
        //
        //let attributedText = NSMutableAttributedString.init(string: localizedText, attributes: attributes)
        //let statusRange = NSString(string: localizedText).range(of: "Status: ")
        //var textColor: UIColor = .black
        //if #available(iOS 13.0, *) {
        //    textColor = .label
        //}
        //attributes = [
        //    NSAttributedString.Key.foregroundColor: textColor,
        //    NSAttributedString.Key.font:            UIFont.systemFont(ofSize: 20.0, weight: .bold)
        //]
        //
        //attributedText.setAttributes(attributes, range: statusRange)
        //
        //highestPriorityStatusLabel.attributedText = attributedText
        //highestPriorityStatusLabel.textAlignment = .center
        //
        //let mibiTextView = UITextView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        //mibiTextView.translatesAutoresizingMaskIntoConstraints = false
        //mibiTextView.backgroundColor = .clear
        //mibiTextView.textColor = textColor
        //mibiTextView.isScrollEnabled = true
        //mibiTextView.isEditable = false
        //mibiTextView.isSelectable = false
        //mibiTextView.bounces = false
        //mibiTextView.showsVerticalScrollIndicator = false
        //mibiTextView.showsHorizontalScrollIndicator = false
        //mibiTextView.text = result.mibiDataString
        //mibiTextView.font = .systemFont(ofSize: 16)
        //mibiTextView.textContainer.lineBreakMode = .byCharWrapping
        
        view.addSubview(backButton)
        //view.addSubview(imageView)
        //view.addSubview(highestPriorityStatusLabel)
        //view.addSubview(mibiTextView)
        //
        //let imageRelativeHeight: CGFloat = 0.35
        //var ar: CGFloat = 1.0
        //if let image = result.image, image.size.width > 0, image.size.height > 0 {
        //    ar = image.size.width / image.size.height
        //}
        
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            backButton.topAnchor.constraint(equalTo: view.topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 60),
        //
        //    imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        //    imageView.widthAnchor.constraint(equalToConstant: view.frame.size.height * imageRelativeHeight * ar),
        //    imageView.heightAnchor.constraint(equalToConstant: view.frame.size.height * imageRelativeHeight),
        //    imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //
        //    highestPriorityStatusLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
        //    highestPriorityStatusLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
        //    highestPriorityStatusLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
        //    highestPriorityStatusLabel.heightAnchor.constraint(equalToConstant: 40),
        //
        //    mibiTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //    mibiTextView.topAnchor.constraint(equalTo: highestPriorityStatusLabel.bottomAnchor, constant: 10),
        //    mibiTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
        //    mibiTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}
