//
//  MiSnapGuideView.swift
//  MiSnapDevApp
//
//  Created by Stas Tsuprenko on 2/26/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnap

enum MiSnapVignetteStyle: String, Equatable {
    case blur, semitransparent, none
}

enum MiSnapGuideAlignment: String, Equatable {
    case center, top, bottom
}

class MiSnapGuideView: UIVisualEffectView {
    // Vignette color and alpha are only used when `vignetteStyle` is set to `semitransparent` above
    private let vignetteColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private let vignetteAlpha: CGFloat = 0.8
    
    // Vignette blur effect style only used when `vignetteStyle` is set to `blur` above
    private let blurEffectStyle: UIBlurEffect.Style = .light
    
    private let guideBorderColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private var guideBorderWidth: CGFloat {
        switch vignetteStyle {
        case .blur, .semitransparent:   return 0.0
        case .none:                     return 3.0
        }
    }
    
    // Guide corner radius, offset, aspect ratio and rect are calculated automatically for a selected document type
    private var guideCornerRadius: CGFloat!
    private var guideOffset: CGFloat!
    private var guideAspectRatio: CGFloat!
    private(set) var guideRect: CGRect!
    
    private var parameters: MiSnapParameters
    private let vignetteStyle: MiSnapVignetteStyle
    // Alignment is only used when orientation mode of `MiSnapParameters` is set to `Device Portrait Guide Landscape`
    private let alignment: MiSnapGuideAlignment
    
    private var cutoutLayer: CAShapeLayer!
    private var guideLayer: CAShapeLayer?
    
    private var longerSide: CGFloat!
    private var shorterSide: CGFloat!
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with parameters: MiSnapParameters, vignetteStyle: MiSnapVignetteStyle = .blur, alignment: MiSnapGuideAlignment = .center, frame: CGRect, orientation: UIInterfaceOrientation) {
        self.parameters = parameters
        self.vignetteStyle = vignetteStyle
        self.alignment = alignment
        
        switch vignetteStyle {
        case .blur:
            super.init(effect: UIBlurEffect(style: blurEffectStyle))
        case .semitransparent:
            super.init(effect: nil)
            backgroundColor = vignetteColor
            alpha = vignetteAlpha
        case .none:
            super.init(effect: nil)
            backgroundColor = .clear
        }
        
        self.frame = frame
        self.longerSide = frame.width > frame.height ? frame.width : frame.height
        self.shorterSide = frame.width < frame.height ? frame.width : frame.height
        
        translatesAutoresizingMaskIntoConstraints = false
        
        switch self.alignment {
        case .center:   guideOffset = 0.0
        case .top:      guideOffset = 50.0
        case .bottom:   guideOffset = -50.0
        }
        
        switch parameters.documentTypeCategory {
        case .id:       guideCornerRadius = 15.0
        case .deposit:  guideCornerRadius = 0.0
        default:        guideCornerRadius = 0.0
        }
        
        guideAspectRatio = getGuideAspectRatio(for: parameters.documentType)
        update(orientation)
    }
    
    public func update(_ orientation: UIInterfaceOrientation) {
        self.guideRect = self.getGuideRect(for: self.parameters.orientationMode, orientation: orientation, aspectRatio: self.guideAspectRatio)
        self.adjustCutoutLayer(for: orientation)
        self.adjustGuideLayer()
        self.setNeedsDisplay()
    }
}

// MARK: Private functions
extension MiSnapGuideView {
    private func getGuideAspectRatio(for documentType: MiSnapDocumentType) -> CGFloat {
        switch documentType {
        case .none:                     return 1.0
        case .passport:                 return 1.42
        case .anyId, .idFront, .idBack: return 1.59
        case .checkFront, .checkBack:   return 2.17
        default:                        return 1.0
        }
    }
    
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
                
                switch alignment {
                case .center:   y = (longerSide - height) / 2 + guideOffset
                case .top:      y = guideOffset
                case .bottom:   y = longerSide - (longerSide - height) / 2 + guideOffset
                }
            } else if orientationMode == .devicePortraitGuidePortrait {
                height = longerSide * CGFloat(parameters.landscapeFill) * 1.2 / 1000.0
                width = height / aspectRatio
                y = (longerSide - height) / 2
            }
        } else {
            width = UIDevice.current.userInterfaceIdiom == .phone && longerSide / shorterSide > 1.78 ? shorterSide * 16 / 9 : longerSide
            width *= CGFloat(parameters.landscapeFill) * 1.2 / 1000.0
            height = width / aspectRatio
            y = (shorterSide - height) / 2
        }
        
        x = orientation.isPortrait ? shorterSide : longerSide
        x = (x - width) / 2;
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return rect;
    }
    
    private func adjustCutoutLayer(for orientation: UIInterfaceOrientation) {
        let path = UIBezierPath(roundedRect: guideRect, cornerRadius: guideCornerRadius)
        let bounds = orientation.isPortrait ? CGRect(x: 0, y: 0, width: shorterSide, height: longerSide) : CGRect(x: 0, y: 0, width: longerSide, height: shorterSide)
        path.append(UIBezierPath(rect: bounds))
        
        cutoutLayer = CAShapeLayer()
        cutoutLayer.path = path.cgPath
        cutoutLayer.fillRule = .evenOdd
        
        layer.mask = cutoutLayer
    }
    
    private func adjustGuideLayer() {
        if guideBorderWidth > 0.0 {
            guideLayer?.removeFromSuperlayer()
            
            let path = UIBezierPath(roundedRect: guideRect, cornerRadius: guideCornerRadius)
            
            guideLayer = CAShapeLayer()
            guard let guideLayer = guideLayer else { fatalError("Couldn't initialize Guide Layer") }
            guideLayer.path = path.cgPath
            guideLayer.strokeColor = guideBorderColor.cgColor
            guideLayer.lineWidth = guideBorderWidth
            layer.addSublayer(guideLayer)
        }
    }
}
