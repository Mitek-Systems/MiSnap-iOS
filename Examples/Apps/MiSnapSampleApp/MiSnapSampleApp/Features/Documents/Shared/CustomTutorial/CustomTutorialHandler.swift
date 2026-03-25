//
//  CustomTutorialHandler.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit
import MiSnap
import MiSnapUX

typealias CustomTutorialHandler = (
    _ documentType: MiSnapScienceDocumentType,
    _ tutorialMode: MiSnapUxTutorialMode,
    _ mode: MiSnapMode,
    _ statuses: [NSNumber]?,
    _ image: UIImage?,
    _ viewController: MiSnapViewController?
) -> Void
