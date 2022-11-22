//
//  CustomSegmentedController.swift
//  MiSnapWorkflowSampleApp
//
//  Created by Mitek Engineering on 8/29/22.
//

import UIKit

extension Int {
    var stringValue: String {
        switch self {
        case 0:     return "Face and Voice"
        case 1:     return "Face only"
        case 2:     return "Voice only"
        default:    return ""
        }
    }
}

protocol CustomSegmentedControlDelegate: NSObject {
    func didSelect(_ selectedIndex: Int, customSegemtedControl: CustomSegmentedControl)
}

extension CustomSegmentedControlDelegate {
    func didSelect(_ selectedIndex: Int, customSegemtedControl: CustomSegmentedControl) {}
}

class CustomSegmentedControl: UIView {
    private weak var delegate: CustomSegmentedControlDelegate?
    private var buttons: [UIButton] = []
    
    private let colorActive: UIColor = #colorLiteral(red: 0.1135270074, green: 0.6691284776, blue: 0.9192516208, alpha: 1)
    private let colorInactive: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    
    private let minHeight: CGFloat = 30
    private let spacing: CGFloat = 10
    
    var selectedIndex: Int = 0 {
        didSet {
            //print("Selected index: \(selectedIndex)")
            deactivateAll()
            let button = buttons[selectedIndex]
            button.setTitleColor(colorActive, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    init(with options: [String], delegate: CustomSegmentedControlDelegate, frame: CGRect) {
        self.delegate = delegate
        
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = .clear
        
        buttons = getButtonsFrom(options)
        configureSubviews()
    }
    
    override func removeFromSuperview() {
        delegate = nil
        super.removeFromSuperview()
    }
}

// Private configuration functions
extension CustomSegmentedControl {
    private func configureSubviews() {
        var currentButton: UIButton?
        var height: CGFloat = 0.0
        
        for button in buttons {
            addSubview(button)
            
            let yAnchor: NSLayoutYAxisAnchor
            var offset: CGFloat = 0.0
            if let currentElement = currentButton {
                yAnchor = currentElement.bottomAnchor
                offset = spacing
            } else {
                yAnchor = topAnchor
            }
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: yAnchor, constant: offset),
                button.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
            
            currentButton = button
            height += button.frame.height
        }
        
        height += CGFloat(buttons.count - 1) * spacing
        
        frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: frame.width),
            heightAnchor.constraint(equalToConstant: frame.height)
        ])
    }
    
    private func getButtonsFrom(_ options: [String]) -> [UIButton] {
        var buttons: [UIButton] = []
        for option in options {
            guard !option.isEmpty else { continue }
            let button = configureButton(withTitle: option, action: #selector(buttonAction(_:)))
            buttons.append(button)
        }
        return buttons
    }
    
    private func configureButton(withTitle title: String, action: Selector) -> UIButton {
        let button = UIButton(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(colorInactive, for: .normal)
        button.setTitleColor(colorActive.withAlphaComponent(0.4), for: .highlighted)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        var buttonWidth = button.frame.width
        var buttonHeight = button.frame.height
        
        if let titleLabel = button.titleLabel {
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.sizeToFit()
            
            if titleLabel.frame.width <= frame.width / 2 {
                titleLabel.frame = frame
                titleLabel.numberOfLines = 1
                titleLabel.sizeToFit()
            }
            
            buttonWidth = button.frame.width
            buttonHeight = titleLabel.frame.height > minHeight ? titleLabel.frame.height : minHeight
            
            button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: buttonWidth, height: buttonHeight)
        }
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        return button
    }
    
    private func deactivateAll() {
        for button in buttons {
            button.setTitleColor(colorInactive, for: .normal)
        }
    }
}

// Private buttons functions
extension CustomSegmentedControl {
    @objc private func buttonAction(_ button: UIButton) {
        for (idx, b) in buttons.enumerated() where b == button {
            selectedIndex = idx
            delegate?.didSelect(idx, customSegemtedControl: self)
            break
        }
    }
}
