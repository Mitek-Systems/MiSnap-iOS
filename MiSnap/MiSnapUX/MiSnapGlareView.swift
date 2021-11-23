//
//  MiSnapGlareView.swift
//  MiSnapDevApp
//
//  Created by Stas Tsuprenko on 2/26/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit

class MiSnapGlareView: UIView {
    // CUSTOMIZATION: change values below to customize look and feel of Glare View
    private let glareBackgroundColor: UIColor = .clear
    private let glareBorderColor: UIColor = .red
    private let glareBorderWidth: CGFloat = 5.0
    private let glareCornerRadius: CGFloat = 10.0
    // If a glare bounding box has width and/or heigh less than minGlareSize pixels then increase them to at least minGlareSize to improve user experience
    private let minGlareSize: CGFloat = 50
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        // IMPORTANT: DO NOT customize anything in this init
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = glareBackgroundColor
        layer.borderColor = glareBorderColor.cgColor
        layer.borderWidth = glareBorderWidth
        layer.cornerRadius = glareCornerRadius
        clipsToBounds = true
        alpha = 0.0
    }
    
    public func animate(with glareBoundingBox: CGRect) {
        frame = normalizedBoundingBox(from: glareBoundingBox)
        
        // IMPORTANT: Make sure MiSnapHintView has the same timing so they're in sync
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
    
    private func normalizedBoundingBox(from rect: CGRect) -> CGRect {
        // Customize minGlareSize above if needed
        if rect.width >= minGlareSize && rect.height >= minGlareSize {
            return rect
        }
        
        let glareRectCenter = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let normalizedRect = CGRect(x: rect.width < minGlareSize ? glareRectCenter.x - minGlareSize / 2 : rect.origin.x,
                                    y: rect.height < minGlareSize ? glareRectCenter.y - minGlareSize / 2 : rect.origin.y,
                                    width: rect.width < minGlareSize ? minGlareSize : rect.width,
                                    height: rect.height < minGlareSize ? minGlareSize : rect.height)
        return normalizedRect
    }
}

