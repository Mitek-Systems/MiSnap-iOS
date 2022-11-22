//
//  JudgementView.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 6/29/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit

class JudgementView: UIStackView {
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(with title: String, judgementIcon: UIImage, notifications: [String : String]? = nil, frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.axis = .vertical
        self.distribution = .fill
        self.spacing = 5
        
        let titleLabel = ResultLabel(with: title, alignement: .left, bgColor: .clear,
                                     frame: CGRect(x: 0, y: 0, width: self.frame.size.width * 0.7, height: frame.size.height))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: judgementIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width * 0.2, height: frame.size.height)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        let horizontalStackView = UIStackView(arrangedSubviews: [titleLabel, imageView])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 5
        horizontalStackView.distribution = .fill
        
        self.addArrangedSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: frame.size.height),
            imageView.heightAnchor.constraint(equalToConstant: frame.size.height),
            
            titleLabel.heightAnchor.constraint(equalToConstant: frame.size.height),
            
            horizontalStackView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
        
        if let notifications = notifications, !notifications.isEmpty {
            for (_, value) in notifications {
                let label = ResultLabel(with: value, alignement: .left, bgColor: .clear, fontSize: 17, fontWeight: .ultraLight,
                                        frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = "\u{2022} \(value)"
                
                self.addArrangedSubview(label)
            }
        }
    }
}
