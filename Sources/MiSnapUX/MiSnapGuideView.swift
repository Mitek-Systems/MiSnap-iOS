//
//  MiSnapGuideView.swift
//  MiSnapDevApp
//
//  Created by Mitek Engineering on 2/26/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnap

public class MiSnapGuideView: UIView {
    private var parameters: MiSnapParameters
    private var config: MiSnapGuideViewConfiguration
    
    private var vignetteView: UIVisualEffectView?
    
    private(set) var guideRect: CGRect!
    private var cutoutLayer: CAShapeLayer!
    private var guideLayer: CAShapeLayer?
    
    private let longerSide: CGFloat!
    private let shorterSide: CGFloat!
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with parameters: MiSnapParameters, configuration: MiSnapGuideViewConfiguration? = nil, frame: CGRect, orientation: UIInterfaceOrientation) {
        self.parameters = parameters
        
        if let configuration = configuration {
            config = configuration
        } else {
            config = MiSnapGuideViewConfiguration(for: parameters.documentType)
        }
        
        longerSide = frame.width > frame.height ? frame.width : frame.height
        shorterSide = frame.width < frame.height ? frame.width : frame.height
        
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        configureVignette()
        
        update(orientation)
    }
    
    private func configureVignette() {
        switch config.vignette.style {
        case .blur:             vignetteView = UIVisualEffectView(effect: UIBlurEffect(style: config.vignette.blurStyle))
        case .semitransparent:  vignetteView = UIVisualEffectView(effect: nil)
        case .none:             break
        }
        
        guard let vignetteView = vignetteView else { return }
        
        vignetteView.translatesAutoresizingMaskIntoConstraints = false
        vignetteView.frame = frame
        vignetteView.alpha = config.vignette.alpha
        
        if config.vignette.style == .semitransparent {
            vignetteView.backgroundColor = config.vignette.color
        }
    }
    
    public func update(_ orientation: UIInterfaceOrientation) {
        guideRect = getGuideRect(for: parameters.orientationMode, orientation: orientation, aspectRatio: config.documentOutline.aspectRatio)
        adjustGuideLayer(for: orientation)
        adjustVignetteLayer(for: orientation)
        setNeedsDisplay()
    }
}

// MARK: Private functions
extension MiSnapGuideView {
    private func getGuideRect(for orientationMode: MiSnapOrientationMode, orientation: UIInterfaceOrientation, aspectRatio: CGFloat) -> CGRect {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if orientation.isPortrait {
            if orientationMode == .devicePortraitGuideLandscape {
                width = UIDevice.current.userInterfaceIdiom == .pad ? longerSide * 9 / 16 : shorterSide
                width *= CGFloat(parameters.portraitFill) * 1.15 / 1000.0
                height = width / aspectRatio
                
                switch config.documentOutline.alignment {
                case .center:   y = (longerSide - height) / 2 + config.documentOutline.offset
                case .top:      y = config.documentOutline.offset
                case .bottom:   y = longerSide - (longerSide - height) / 2 + config.documentOutline.offset
                }
            } else if orientationMode == .devicePortraitGuidePortrait {
                height = UIDevice.current.userInterfaceIdiom == .phone && longerSide / shorterSide > 1.78 ? shorterSide * 16 / 9 : longerSide
                let multiplier = parameters.documentCategory == .deposit ? 1.125 : 1.2
                height *= CGFloat(parameters.landscapeFill) * multiplier / 1000.0
                width = height / aspectRatio
                y = (longerSide - height) / 2
            }
        } else {
            width = UIDevice.current.userInterfaceIdiom == .phone && longerSide / shorterSide > 1.78 ? shorterSide * 16 / 9 : longerSide
            let multiplier = parameters.documentCategory == .deposit ? 1.125: 1.2
            width *= CGFloat(parameters.landscapeFill) * multiplier / 1000.0
            height = width / aspectRatio
            y = (shorterSide - height) / 2
        }
        
        x = orientation.isPortrait ? shorterSide : longerSide
        x = (x - width) / 2;
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return rect;
    }
    
    private func adjustVignetteLayer(for orientation: UIInterfaceOrientation) {
        guard let vignetteView = vignetteView else { return }
        let path = UIBezierPath(roundedRect: guideRect, cornerRadius: config.documentOutline.cornerRadius)
        let bounds = orientation.isPortrait ? CGRect(x: 0, y: 0, width: shorterSide, height: longerSide) : CGRect(x: 0, y: 0, width: longerSide, height: shorterSide)
        path.append(UIBezierPath(rect: bounds))
        
        cutoutLayer = CAShapeLayer()
        cutoutLayer.path = path.cgPath
        cutoutLayer.fillRule = .evenOdd
        
        vignetteView.layer.mask = cutoutLayer
        vignetteView.frame = frame
        
        if !vignetteView.isDescendant(of: self) {
            addSubview(vignetteView)

            NSLayoutConstraint.activate([
                vignetteView.topAnchor.constraint(equalTo: topAnchor),
                vignetteView.bottomAnchor.constraint(equalTo: bottomAnchor),
                vignetteView.leftAnchor.constraint(equalTo: leftAnchor),
                vignetteView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
    }
    
    private func adjustGuideLayer(for orientation: UIInterfaceOrientation) {
        guard config.documentOutline.mainBorderWidth > 0.0, config.documentOutline.alpha > 0.0 else { return }
        
        if let vignetteView = vignetteView {
            vignetteView.removeFromSuperview()
        }
        
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }

        let darkRectPath = UIBezierPath(roundedRect: guideRect, cornerRadius: config.documentOutline.cornerRadius)
        
        let darkRectLayer = CAShapeLayer()
        darkRectLayer.path = darkRectPath.cgPath
        darkRectLayer.strokeColor = config.documentOutline.secondaryBorderColor.withAlphaComponent(0.6).cgColor
        darkRectLayer.fillColor = UIColor.clear.cgColor
        darkRectLayer.lineWidth = config.documentOutline.secondaryBorderWidth
        darkRectLayer.opacity = Float(config.documentOutline.alpha)
        
        let lightRectPath = UIBezierPath(roundedRect: CGRect(x: guideRect.origin.x + config.documentOutline.secondaryBorderWidth,
                                                             y: guideRect.origin.y + config.documentOutline.secondaryBorderWidth,
                                                             width: guideRect.width - config.documentOutline.secondaryBorderWidth * 2,
                                                             height: guideRect.height - config.documentOutline.secondaryBorderWidth * 2),
                                         cornerRadius: config.documentOutline.cornerRadius)
        
        let lightRectLayer = CAShapeLayer()
        lightRectLayer.path = lightRectPath.cgPath
        lightRectLayer.strokeColor = config.documentOutline.mainBorderColor.cgColor
        lightRectLayer.fillColor = UIColor.clear.cgColor
        lightRectLayer.lineWidth = config.documentOutline.mainBorderWidth
        lightRectLayer.opacity = Float(config.documentOutline.alpha)
        
        layer.addSublayer(lightRectLayer)
        layer.addSublayer(darkRectLayer)

        let biggerSide = guideRect.height > guideRect.width ? guideRect.height : guideRect.width
        let smallerSide = guideRect.height < guideRect.width ? guideRect.height : guideRect.width

        if parameters.documentType == .passport {
            let text = "P"

            let textFrame = CGRect(x: 0, y: 0, width: biggerSide * 0.068, height: biggerSide * 0.068)
            let font = UIFont.bestFittingFont(for: text, in: textFrame, fontDescriptor: UIFont.systemFont(ofSize: 1).fontDescriptor)

            var position: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.82, y: guideRect.origin.y + guideRect.height * 0.934)
            var rotationAngle: CGFloat = -.pi / 2
            var lineStartPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.79, y: guideRect.origin.y + guideRect.height * 0.005)
            var lineEndPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.79, y: guideRect.origin.y + guideRect.height * 0.995)
            let anchorPoint = CGPoint(x: 0, y: 0)

            if orientation == .landscapeRight || orientation == .landscapeLeft || parameters.orientationMode == .devicePortraitGuideLandscape {
                position = CGPoint(x: guideRect.origin.x + guideRect.width * 0.06, y: guideRect.origin.y + guideRect.height * 0.82)
                rotationAngle = 0
                lineStartPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.005, y: guideRect.origin.y + guideRect.height * 0.8)
                lineEndPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.995, y: guideRect.origin.y + guideRect.height * 0.8)
            }

            let textLayer = CATextLayer()
            textLayer.foregroundColor = config.documentOutline.mainBorderColor.withAlphaComponent(0.888 * config.documentOutline.alpha).cgColor
            textLayer.string = text
            textLayer.font = CGFont(font.fontName as CFString)
            textLayer.fontSize = font.pointSize
            textLayer.frame = textFrame
            textLayer.anchorPoint = anchorPoint
            textLayer.position = position
            textLayer.transform = CATransform3DMakeRotation(rotationAngle, 0, 0, 1)

            let linePath = UIBezierPath()
            linePath.move(to: lineStartPoint)
            linePath.addLine(to: lineEndPoint)

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = config.documentOutline.mainBorderWidth - 0.5
            lineLayer.strokeColor = config.documentOutline.mainBorderColor.withAlphaComponent(config.documentOutline.alpha).cgColor

            let mrzPath = UIBezierPath()
            var mrzPoint: CGPoint = .zero
            if orientation == .landscapeRight || orientation == .landscapeLeft || parameters.orientationMode == .devicePortraitGuideLandscape {
                mrzPoint = CGPoint(x: textLayer.position.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: textLayer.position.y + guideRect.width * 0.016)
                for _ in 0...28 {
                    mrzPath.move(to: CGPoint(x: mrzPoint.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: mrzPoint.y))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x + guideRect.width * 0.0105, y: mrzPoint.y + guideRect.width * 0.0111))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: mrzPoint.y + guideRect.width * 0.0222))

                    mrzPoint = CGPoint(x: mrzPoint.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: mrzPoint.y)
                }

                mrzPoint = CGPoint(x: textLayer.position.x, y: textLayer.position.y + guideRect.width * 0.065)

                for _ in 0...29 {
                    mrzPath.move(to: CGPoint(x: mrzPoint.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: mrzPoint.y))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x + guideRect.width * 0.0105, y: mrzPoint.y + guideRect.width * 0.0111))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: mrzPoint.y + guideRect.width * 0.0222))

                    mrzPoint = CGPoint(x: mrzPoint.x + guideRect.width * 0.0187 + guideRect.width * 0.0105, y: mrzPoint.y)
                }
            } else {
                mrzPoint = CGPoint(x: textLayer.position.x + guideRect.height * 0.04, y: textLayer.position.y - guideRect.height * 0.0187 - guideRect.height * 0.0105)

                for _ in 0...28 {
                    mrzPath.move(to: CGPoint(x: mrzPoint.x, y: mrzPoint.y - guideRect.height * 0.0187 - guideRect.height * 0.0105))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x - guideRect.height * 0.0111, y: mrzPoint.y - guideRect.height * 0.0105))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x - guideRect.height * 0.0222, y: mrzPoint.y - guideRect.height * 0.0187 - guideRect.height * 0.0105))

                    mrzPoint = CGPoint(x: mrzPoint.x, y: mrzPoint.y - guideRect.height * 0.0187 - guideRect.height * 0.0105)
                }

                mrzPoint = CGPoint(x: textLayer.position.x + guideRect.height * 0.085, y: textLayer.position.y)

                for _ in 0...29 {
                    mrzPath.move(to: CGPoint(x: mrzPoint.x, y: mrzPoint.y - guideRect.height * 0.0187 - guideRect.height * 0.0105))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x - guideRect.height * 0.0111, y: mrzPoint.y - guideRect.height * 0.0105))
                    mrzPath.addLine(to: CGPoint(x: mrzPoint.x - guideRect.height * 0.0222, y: mrzPoint.y - guideRect.height * 0.0187 - guideRect.height * 0.0105))

                    mrzPoint = CGPoint(x: mrzPoint.x, y: mrzPoint.y - guideRect.height * 0.0187 - guideRect.height * 0.0105)
                }
            }

            let mrzLayer = CAShapeLayer()
            mrzLayer.path = mrzPath.cgPath
            mrzLayer.lineWidth = 1.5
            mrzLayer.strokeColor = config.documentOutline.mainBorderColor.withAlphaComponent(0.444 * config.documentOutline.alpha).cgColor
            mrzLayer.fillColor = UIColor.clear.cgColor
            mrzLayer.lineCap = .round

            layer.addSublayer(lineLayer)
            layer.addSublayer(textLayer)
            layer.addSublayer(mrzLayer)
        } else if parameters.documentType == .checkFront {
            let text = "#########  ############  #####"

            let textFrame = CGRect(x: 0, y: 0, width: biggerSide * 0.71, height: biggerSide * 0.058)
            let font = UIFont.bestFittingFont(for: text, in: textFrame, fontDescriptor: UIFont.systemFont(ofSize: 1, weight: .bold).fontDescriptor)

            var position: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.17, y: guideRect.origin.y + guideRect.height * 0.04)
            var rotationAngle: CGFloat = .pi / 2
            var lineOneStartPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.21, y: guideRect.origin.y + guideRect.height * 0.04)
            var lineOneEndPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.21, y: guideRect.origin.y + guideRect.height * 0.40)
            var lineTwoStartPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.21, y: guideRect.origin.y + guideRect.height * 0.45)
            var lineTwoEndPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.21, y: guideRect.origin.y + guideRect.height * 0.95)

            if orientation == .landscapeRight || orientation == .landscapeLeft || parameters.orientationMode == .devicePortraitGuideLandscape {
                position = CGPoint(x: guideRect.origin.x + guideRect.width * 0.04, y: guideRect.origin.y + guideRect.height * 0.84)
                rotationAngle = 0
                lineOneStartPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.04, y: guideRect.origin.y + guideRect.height * 0.8)
                lineOneEndPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.40, y: guideRect.origin.y + guideRect.height * 0.8)
                lineTwoStartPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.45, y: guideRect.origin.y + guideRect.height * 0.8)
                lineTwoEndPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.95, y: guideRect.origin.y + guideRect.height * 0.8)
            }

            let textLayer = CATextLayer()
            textLayer.foregroundColor = config.documentOutline.mainBorderColor.withAlphaComponent(0.333 * config.documentOutline.alpha).cgColor
            textLayer.string = text
            textLayer.font = CGFont(font.fontName as CFString)
            textLayer.fontSize = font.pointSize
            textLayer.frame = textFrame
            textLayer.anchorPoint = CGPoint(x: 0, y: 0)
            textLayer.position = position
            textLayer.transform = CATransform3DMakeRotation(rotationAngle, 0, 0, 1)

            let linePath = UIBezierPath()
            linePath.move(to: lineOneStartPoint)
            linePath.addLine(to: lineOneEndPoint)
            linePath.move(to: lineTwoStartPoint)
            linePath.addLine(to: lineTwoEndPoint)

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 5
            lineLayer.strokeColor = config.documentOutline.mainBorderColor.withAlphaComponent(0.333 * config.documentOutline.alpha).cgColor

            layer.addSublayer(lineLayer)
            layer.addSublayer(textLayer)
        } else if parameters.documentType == .checkBack {
            let text = "ENDORSE"

            let textFrame = CGRect(x: 0, y: 0, width: smallerSide * 0.5, height: smallerSide * 0.11)
            let font = UIFont.bestFittingFont(for: text, in: textFrame, fontDescriptor: UIFont.systemFont(ofSize: 1, weight: .bold).fontDescriptor)

            var position: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.1, y: guideRect.origin.y + guideRect.height * 0.16)
            var rotationAngle: CGFloat = 0
            var lineStartPoint: CGPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.1, y: guideRect.origin.y + guideRect.height * 0.15)
            var lineEndPoint: CGPoint = CGPoint(x: guideRect.origin.y + guideRect.width * 0.9, y: guideRect.origin.y + guideRect.height * 0.15)

            if orientation == .landscapeRight || orientation == .landscapeLeft || parameters.orientationMode == .devicePortraitGuideLandscape {
                position = CGPoint(x: guideRect.origin.x + guideRect.width * 0.84, y: guideRect.origin.y + guideRect.height * 0.1)
                rotationAngle = .pi / 2
                lineStartPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.85, y: guideRect.origin.y + guideRect.height * 0.1)
                lineEndPoint = CGPoint(x: guideRect.origin.x + guideRect.width * 0.85, y: guideRect.origin.y + guideRect.height * 0.9)
            }

            let textLayer = CATextLayer()
            textLayer.foregroundColor = config.documentOutline.mainBorderColor.withAlphaComponent(0.555 * config.documentOutline.alpha).cgColor
            textLayer.string = text
            textLayer.font = CGFont(font.fontName as CFString)
            textLayer.fontSize = font.pointSize
            textLayer.frame = textFrame
            textLayer.anchorPoint = CGPoint(x: 0, y: 0)
            textLayer.position = position
            textLayer.transform = CATransform3DMakeRotation(rotationAngle, 0, 0, 1)

            let linePath = UIBezierPath()
            linePath.move(to: lineStartPoint)
            linePath.addLine(to: lineEndPoint)

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 5
            lineLayer.strokeColor = config.documentOutline.mainBorderColor.withAlphaComponent(0.444 * config.documentOutline.alpha).cgColor

            layer.addSublayer(lineLayer)
            layer.addSublayer(textLayer)
        }
    }
}

extension UIFont {
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: bounds.width, height: bounds.height)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            bestFontSize -= 5.0
        }
        return bestFontSize - 4
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}
