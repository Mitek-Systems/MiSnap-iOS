//
//  LoadingController.swift
//  MobileVerifySampleApp
//
//  Created by Jake Welton on 26/10/2017.
//  Copyright © 2017 Mitek. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    let spinner = UIActivityIndicatorView(style: .gray)
    let textLabel = UILabel()

    convenience init(text: String?) {
        self.init(frame: .zero)
        textLabel.text = text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    private func setupSubviews() {
        textLabel.font = UIFont.systemFont(ofSize: 30, weight: .ultraLight)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 4
        
        spinner.startAnimating()

        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        effectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        let stackView = UIStackView(arrangedSubviews: [spinner, textLabel])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        effectView.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
