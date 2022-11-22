//
//  ResultLabel.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 6/26/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit

class ResultLabel: UILabel {
    private var lightModeBackgroundColor: UIColor?
    private var darkModeBackgroundColor: UIColor?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(with title: String, alignement: NSTextAlignment = .center, bgColor: UIColor? = nil, fontSize: CGFloat = 19, fontWeight: UIFont.Weight = .light, cornerRadius: CGFloat? = 10, frame: CGRect) {
        super.init(frame: frame)
        self.text = title
        self.textAlignment = alignement
        self.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        self.numberOfLines = 3
        
        if let radius = cornerRadius {
            self.layer.cornerRadius = radius
            self.clipsToBounds = true
        }
        
        if let bgColor = bgColor {
            self.backgroundColor = bgColor
        } else {
            lightModeBackgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
            darkModeBackgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
            setColors()
        }
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
}

extension ResultLabel {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
    
    private func setColors() {
        guard let lightColor = lightModeBackgroundColor, let darkColor = darkModeBackgroundColor else { return }
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            self.backgroundColor = darkColor
        } else {
            self.backgroundColor = lightColor
        }
    }
}
