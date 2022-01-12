//
//  MiSnapGlareView.swift
//  MiSnapDevApp
//
//  Created by Mitek Engineering on 2/26/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit

public class MiSnapGlareView: UIView {
    public var config = MiSnapGlareViewConfiguration()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with configuration: MiSnapGlareViewConfiguration? = nil) {
        if let configuration = configuration {
            config = configuration
        }
        
        // IMPORTANT: For customization go to `MiSnapGlareViewConfiguration`
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = config.backgroundColor
        layer.borderColor = config.borderColor.cgColor
        layer.borderWidth = config.borderWidth
        layer.cornerRadius = config.cornerRadius
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
        // Customize minSize go to `MiSnapGlareViewConfiguration`
        if rect.width >= config.minSize && rect.height >= config.minSize {
            return rect
        }
        
        let glareRectCenter = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let normalizedRect = CGRect(x: rect.width < config.minSize ? glareRectCenter.x - config.minSize / 2 : rect.origin.x,
                                    y: rect.height < config.minSize ? glareRectCenter.y - config.minSize / 2 : rect.origin.y,
                                    width: rect.width < config.minSize ? config.minSize : rect.width,
                                    height: rect.height < config.minSize ? config.minSize : rect.height)
        return normalizedRect
    }
}

