//
//  InfoView.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 6/29/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit

class InfoView: UIStackView {
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(with title: String, titleSize: CGFloat = 17, titleWeight:UIFont.Weight = .light, values: [String]?, valueSize: CGFloat = 17, valueWeight:UIFont.Weight = .light, split: CGFloat? = nil, frame: CGRect, valuesSelectable: Bool = false) {
        super.init(frame: frame)
        self.frame = frame
        self.axis = .horizontal
        self.distribution = .fill
        self.spacing = 5
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var titleAlignement: NSTextAlignment = .left
        if let values = values, values.count > 1 {
            titleAlignement = .center
        }
        
        let titleLabel = ResultLabel(with: title, alignement: titleAlignement, bgColor: .clear, fontSize: titleSize, fontWeight: titleWeight,
                                     frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: frame.size.height)
        ])
        
        guard let values = values else {
            return
        }
        
        let valueAlignement: NSTextAlignment = values.count > 1 ? .center : .right
        var widthConstant: CGFloat = 0
        if values.count == 1 {
            var s: CGFloat = 1
            if let split = split {
                s = split
            } else {
                if title.count < values[0].count - 5 {
                    s = 3 / 7
                } else if title.count > values[0].count + 5 {
                    s = 7 / 3
                }
            }
            widthConstant = frame.size.width / (1 + s) - self.spacing
        } else {
            widthConstant = frame.size.width / (1 + CGFloat(values.count)) - self.spacing
        }
        
        for value in values {
            let valueLabel = ResultLabel(with: value, alignement: valueAlignement, bgColor: .clear, fontSize: valueSize, fontWeight: valueWeight,
                                         frame: CGRect(x: 0, y: 0, width: self.frame.size.width * 0.7, height: frame.size.height),
                                         selectable: valuesSelectable)
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(valueLabel)
            
            NSLayoutConstraint.activate([
                valueLabel.widthAnchor.constraint(equalToConstant: widthConstant),
                valueLabel.heightAnchor.constraint(equalToConstant: frame.size.height)
            ])
        }
    }
}
