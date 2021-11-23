//
//  MiSnapHintView.swift
//  MiSnapDevApp
//
//  Created by Stas Tsuprenko on 2/26/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit

class MiSnapHintView: UILabel {
    // CUSTOMIZATION: change values below to customize look and feel of Hint View
    private let hintSize: CGSize = CGSize(width: 320, height: 100)
    private let hintBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.7)
    private let hintBorderColor: UIColor = UIColor.white.withAlphaComponent(1.0)
    private let hintBorderWidth: CGFloat = 0
    private let hintCornerRadius: CGFloat = 15
    private let hintTextColor: UIColor = UIColor.darkText.withAlphaComponent(1.0)
    private let hintFont: UIFont = .systemFont(ofSize: 28, weight: .regular)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        // IMPORTANT: DO NOT customize anything in this init
        super.init(frame: CGRect(x: 0, y: 0, width: hintSize.width, height: hintSize.height))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = hintBackgroundColor
        layer.borderColor = hintBorderColor.cgColor
        layer.borderWidth = hintBorderWidth
        layer.cornerRadius = hintCornerRadius
        clipsToBounds = true
        textColor = hintTextColor
        numberOfLines = 2
        font = hintFont
        textAlignment = .center
        alpha = 0.0
    }
    
    public func animate(with hintMessage: String) {
        text = hintMessage
        
        // IMPORTANT: Make sure MiSnapGlareView has the same timing so they're in sync
        let animationTime: TimeInterval = 0.3
        let animationDelay: TimeInterval = 1.0
        
        UIView.animate(withDuration: animationTime,
                       delay: 0.0,
                       options: .curveLinear) {
            self.alpha = 1.0
        } completion: { (completed) in
            if completed {
                UIView.animate(withDuration: animationTime,
                               delay: animationDelay,
                               options: .curveLinear,
                               animations: {
                                self.alpha = 0.0
                               }, completion: nil)
            }
        }

    }
}
