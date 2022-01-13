//
//  MiSnapConfiguration.swift
//  MiSnapDevApp
//
//  Created by Stas Tsuprenko on 12/1/21.
//

import UIKit
import MiSnap

public class MiSnapConfiguration: NSObject {
    private(set) var parameters: MiSnapParameters
    private(set) var uxParameters: MiSnapUxParameters
    private(set) var guide: MiSnapGuideViewConfiguration
    private(set) var hint: MiSnapHintViewConfiguration
    private(set) var glare: MiSnapGlareViewConfiguration
    
    
    public override init() {
        fatalError("MiSnapConfiguration init() is not implemented. Call init(for:)")
    }
    
    public init(for documentType: MiSnapDocumentType) {
        parameters = MiSnapParameters(for: documentType)
        uxParameters = MiSnapUxParameters()
        guide = MiSnapGuideViewConfiguration(for: documentType)
        hint = MiSnapHintViewConfiguration()
        glare = MiSnapGlareViewConfiguration()
        
        super.init()
        
        /*
         Override `parameters` properties to achieve desired SDK configuration.
         See `MiSnapParameters.h` of `MiSnap` framework for all available options
         
         Example:
         parameters.orientationMode = .devicePortraitGuideLandscape
         parameters.applicationVersion = "<YOUR_APPLICATION_VERSION_HERE>"
         parameters.imageQuality = 70
         */
        
        /*
         Override `uxParameters` properties to achieve desired UX configuration.
         See `MiSnapUxParameters` below for all available options
         
         Example:
         uxParameters.shouldDismissOnSuccess = false
         */
        
        /*
         Override `guide` vignette and document outline properties to achieve
         desired Guide View look and feel.
         See `MiSnapVignetteConfiguration` and `MiSnapDocumentOutlineConfiguration` below for all available options
         
         Example:
         guide.vignette.style = .blur
         guide.documentOutline.alpha = 0.0
         */
        
        /*
         Override `hint` properties to achieve desired Hint View look and feel.
         See `MiSnapHintViewConfiguration` below for all available options
         
         Example:
         hint.size = CGSize(width: 240, height: 70)
         hint.font = .systemFont(ofSize: 25, weight: .light)
         hint.backgroundColor = .lightGray.withAlphaComponent(0.7)
         
         or
         
         hint.style = .blur
         */
        
        
        /*
         Override `glare` properties to achieve desired Glare View look and feel.
         See `MiSnapGlareViewConfiguration` below for all available options
         
         Example:
         glare.borderColor = .orange
         */
    }
    
    public convenience init(with parameters: MiSnapParameters) {
        self.init(for: parameters.documentType)
        self.parameters = parameters
    }
}

public class MiSnapUxParameters: NSObject {
    /* Indicates whether MiSnapViewController should be automatically dismissed or
     will be dismissed by presenting view controller */
    public var shouldDismissOnSuccess: Bool = true
    
    /* Indicates whether corner points should be displayed for debugging purposes*/
    public var showCorners: Bool = false
}

public class MiSnapGuideViewConfiguration: NSObject {
    public var vignette = MiSnapVignetteConfiguration()
    public var documentOutline: MiSnapDocumentOutlineConfiguration
    
    public override init() {
        fatalError("MiSnapGuideViewConfiguration init() is not implemented. Call init(for:)")
    }
    
    public init(for documentType: MiSnapDocumentType) {
        documentOutline = MiSnapDocumentOutlineConfiguration(for: documentType)
    }
}

public enum MiSnapVignetteStyle: Int {
    case none               = 0
    case blur               = 1
    case semitransparent    = 2
}

public class MiSnapVignetteConfiguration: NSObject {
    public var style: MiSnapVignetteStyle = .none
    
    // Vignette color is used only when `style` is overridden to `semitransparent`
    public var color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    // Vignette alpha is used only when `style` is overridden to `blur` or `semitransparent`
    public var alpha: CGFloat = 1.0
    
    // Vignette blur style is used only when `style` is overridden to `blur`
    public var blurStyle: UIBlurEffect.Style = .light
}

public enum MiSnapGuideAlignment: Int {
    case center         = 0
    case top            = 1
    case bottom         = 2
}

public class MiSnapDocumentOutlineConfiguration: NSObject {
    // Alignment is used only when orientation mode of `MiSnapParameters` is set to `Device Portrait Guide Landscape`
    public var alignment: MiSnapGuideAlignment = .center {
        didSet {
            offset = getOffset(forAlignment: alignment)
        }
    }
    
    // IMPORTANT: See getOffset(forAlignment:) to adjust default offsets for a given alignment
    public var offset: CGFloat = 0.0
    
    // IMPORTANT: See getCornerRadius(for:) to adjust default corner radii for a given document type
    public var cornerRadius: CGFloat = 0.0
    
    // IMPORTANT: See getAspectRatio(for:) to adjust default guide aspect ratios for a given document type
    public var aspectRatio: CGFloat = 1.0
    
    public var alpha: CGFloat = 0.9
    
    public var mainBorderColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    public var secondaryBorderColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    public var mainBorderWidth: CGFloat = 2.0
    public var secondaryBorderWidth: CGFloat = 1.0
    
    private func getOffset(forAlignment alignment: MiSnapGuideAlignment) -> CGFloat {
        let screenSize = UIScreen.main.bounds.size
        let biggerSide = screenSize.width > screenSize.height ? screenSize.width : screenSize.height
        let smallerSide = screenSize.width < screenSize.height ? screenSize.width : screenSize.height
        let screenAr = biggerSide / smallerSide
        let offset = screenAr < 1.78 ? 0.0 : (biggerSide - smallerSide * 16 / 9) / 2.0
        switch alignment {
        case .center:   return 0.0
        case .top:      return 70.0 + offset
        case .bottom:   return -20.0 - offset
        }
    }
    
    private func getCornerRadius(for documentType: MiSnapDocumentType) -> CGFloat {
        switch documentType {
        case .passport, .anyId, .idFront, .idBack:  return 15.0
        default:                                    return 0.0
        }
    }
    
    private func getAspectRatio(for documentType: MiSnapDocumentType) -> CGFloat {
        switch documentType {
        case .none:                         return 1.0
        case .passport:                     return 1.42
        case .anyId, .idFront, .idBack:     return 1.59
        case .checkFront, .checkBack:       return 2.17
        case .generic:                      return 1.28
        default:                            return 1.0
        }
    }
    
    public override init() {
        fatalError("MiSnapDocumentOutlineConfiguration init() is not implemented. Call init(for:)")
    }
    
    public init(for documentType: MiSnapDocumentType) {
        super.init()
        offset = getOffset(forAlignment: alignment)
        cornerRadius = getCornerRadius(for: documentType)
        aspectRatio = getAspectRatio(for: documentType)
    }
}

public enum MiSnapHintStyle: Int {
    case semitransparent    = 0
    case blur               = 1
}

public class MiSnapHintViewConfiguration: NSObject {
    public var style: MiSnapHintStyle = .semitransparent
    
    // blur style is used only when `style` is overridden to `blur`
    public var blurStyle: UIBlurEffect.Style = .light
    
    // background color, border color and width are used only when `style` is `semitransparent`
    public var backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.7)
    public var borderColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(1.0)
    public var borderWidth: CGFloat = 0.0
    
    public var size: CGSize = CGSize(width: 320, height: 100)
    public var cornerRadius: CGFloat = 15.0
    public var textColor: UIColor = UIColor.darkText.withAlphaComponent(1.0)
    public var font: UIFont = .systemFont(ofSize: 28, weight: .regular)
}

public class MiSnapGlareViewConfiguration: NSObject {
    public var backgroundColor: UIColor = .clear
    public var borderColor: UIColor = .red
    public var borderWidth: CGFloat = 5.0
    public var cornerRadius: CGFloat = 10.0
    // If a glare bounding box has width and/or heigh less than minSize pixels then increase them to at least minSize to improve user experience
    public var minSize: CGFloat = 50.0
}
