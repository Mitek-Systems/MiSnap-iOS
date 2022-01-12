//
//  MiSnapHintView.swift
//  MiSnapDevApp
//
//  Created by Mitek Engineering on 2/26/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit

public class MiSnapHintView: UIView {
    private var config = MiSnapHintViewConfiguration()
    private var label: UILabel = UILabel()
    private var blurView: UIVisualEffectView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with configuration: MiSnapHintViewConfiguration? = nil) {
        if let configuration = configuration {
            config = configuration
        }
        
        // IMPORTANT: For customization go to `MiSnapHintViewConfiguration`
        super.init(frame: CGRect(x: 0, y: 0, width: config.size.width, height: config.size.height))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.cornerRadius = config.cornerRadius
        clipsToBounds = true
        
        label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = config.textColor
        label.numberOfLines = 2
        label.font = config.font
        label.textAlignment = .center
        label.layer.cornerRadius = config.cornerRadius
        
        switch config.style {
        case .semitransparent:
            label.backgroundColor = config.backgroundColor
            label.layer.borderColor = config.borderColor.cgColor
            label.layer.borderWidth = config.borderWidth
        case .blur:
            label.backgroundColor = .clear
            label.layer.borderWidth = 0.0
            
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: config.blurStyle))
            guard let blurView = blurView else { return }
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = config.cornerRadius
            blurView.frame = frame
            
            addSubview(blurView)
            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
                blurView.leftAnchor.constraint(equalTo: leftAnchor),
                blurView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        alpha = 0.0
    }
    
    public func animate(with hintMessage: String) {
        label.text = hintMessage
        
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
