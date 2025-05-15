# Customization Guide

:warning: This guide is only applicable if you've integrated `MiSnapUX`. Use this [starter custom view controller](../../../Examples/Snippets/MiSnap/CustomViewController.swift) when building your own UX/UI.

Please refer to [MiSnapCustomizationSampleApp](../../../Examples/Apps/MiSnap/MiSnapCustomizationSampleApp) as a working customization example.

## Table of Contents
* [Overview](#overview)
* [UX Parameters](#ux-parameters)
* [Localization](#localization)
* [Tutorial screens](#tutorial-screens)
    * [Customizing default tutorial screens](#customizing-default-tutorial-screens)
        * [Graphic assets](#graphic-assets)
    * [Implementing custom tutorial screens](#implementing-custom-tutorial-screens)
* [Session Screen](#session-screen)
    * [Cancel Button](#cancel-button)
    * [Help Button](#help-button)
    * [Torch Button](#torch-button)
    * [Camera Shutter (Manual) Button](#manual-button)
    * [Guide View](#guide-view)
    * [Hint View](#hint-view)
    * [Glare View](#glare-view)
    * [Recording Indicator](#recording-indicator)
    * [Success Checkmark View](#success-view)
* [Parameters](#parameters)
    * [Video Recording](#video-recording)
    * [Optional Data Redaction](#optional-data-redaction)
    * [Enhanced Manual](#enhanced-manual)
    * [Document Type Name](#document-type-name)
    * [Trigger](#trigger)
        * [MRZ only](#mrz-only)
        * [Barcode only](#barcode-only)
    * [Other](#other)

# Overview

In general, there are 2 types of customization available - UX/UI and SDK parameters customization.

To customize UX/UI, a template configuration is created and all necessary customizations are chained one after another.

To customize SDK parameters, a configuration for a specific document type is created and then its SDK parameters can be customized then the UX template configuration is applied.

Note, the same customized template can and should be re-used across all configurations for different document types.

Once desired customization is achieved, a configuration is passed to a `MiSnapViewController`.

Example below demonstrates this concept on a high level. 

```Swift
let template = MiSnapConfiguration()
    .withCustomUxObject... { uxObject in
        // uxObject customization here
    }
    ...
    .withCustomUxObjectN... { uxObjectN in
        // uxObjectN customization here
    }

let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        // SDK parameters customization here
    }
    .applying(template)

misnapVC = MiSnapViewController(with: configuration, delegate: self)
```
where,

`documentType` is of `MiSnapScienceDocumentType` type. Refer to this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnap/Enums/MiSnapScienceDocumentType.html) for all available options.

:warning: DO NOT customize SDK parameters in template by chaining `.withCustomParameters` as template is only for UX/UI customization.

# UX Parameters
Create a template configuration (if it doesn't exist) and chain `.withCustomUxParameters`. Refer to a snippet below.

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.timeout = 25.0
        // Other UX Parameters customizations
    }
```
For all available UX Parameters customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapUxParameters.html).

# Localization

Go to a localizable strings file that was added to your project during integration process and adjust values for a desired language as needed.

By default, it's expected that localizable files are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps: 

Create a template configuration (if it doesn't exist) and chain `.withCustomLocalization`. Refer to a snippet below.

```Swift
let template = MiSnapConfiguration()
    .withCustomLocalization { localization in
        localization.bundle = // Your bundle where localization files are located
    }
```

By default, it's aslo expected that localizable file name is `MiSnapLocalizable` but if you changed its name or moved localization key-pairs to your own localizable file then you can specify a new file name by following next steps:

Create a template configuration (if it doesn't exist) and chain `.withCustomLocalization` (if it doesn't exist). Refer to a snippet below.

```Swift
let template = MiSnapConfiguration()
    .withCustomLocalization { localization in
        localization.stringsName = // Your localization file name
    }
```

# Tutorial screens

## Customizing default tutorial screens
From the SDK perspective introductory instruction, help, timeout and review screens are the same instruction screen with just different messages and/or UI elements.

```Swift
let template = MiSnapConfiguration()
    .withCustomTutorial { tutorial in
        // Your tutorial customizations here
    }
```
where,

`tutorial` is of `MiSnapTutorialConfiguration`.

For all available tutorial customization options see this [API reference](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/main/Docs/API/MiSnap/MiSnapUX/Classes/MiSnapTutorialConfiguration.html).

### Graphic assets

#### Default graphic assets
`MiSnapUX` comes with built-in default tutorial graphics (`UIView`s) that are very small in size and allow colors customization. We ecncourage using these default assets. Especially, if keeping application size minimal is a high priority for you. 

For new integrators there are no additional steps to start using them. For integrators upgrading from 5.7.0 or older, remove MiSnap-related JPGs/PNGs from your project.

#### Custom graphic assets
For new integrators that would like to use their own custom JPGs/PNGs for tutorials add JPGs/PNGs naming them according to a table below. Supported extensions - `jpg`, `jpeg`, `png`, `JPG`, `JPEG`, `PNG`

<center>

| Image name                              | Description    |
| :-----                                  | :-----      |
| misnap_tutorial_id                      | Used for `.idFront` in `.deviceLandscapeGuideLandscape` orientation mode     |
| misnap_tutorial_id_portrait             | Used for `.idFront` in `.devicePortraitGuidePortrait` orientation mode       |
| misnap_tutorial_id_portrait_2           | Used for `.idFront` in `.devicePortraitGuideLandscape` orientation mode      |
| misnap_tutorial_id_back                 | Used for `.idBack` in `.deviceLandscapeGuideLandscape` orientation mode      |
| misnap_tutorial_id_back_portrait        | Used for `.idBack` in `.devicePortraitGuidePortrait` orientation mode        |
| misnap_tutorial_id_back_portrait_2      | Used for `.idBack` in `.devicePortraitGuideLandscape` orientation mode       |
| misnap_tutorial_passport                | Used for `.passport` in `.deviceLandscapeGuideLandscape` orientation mode    |
| misnap_tutorial_passport_portrait       | Used for `.passport` in `.devicePortraitGuidePortrait` orientation mode      |
| misnap_tutorial_passport_portrait_2     | Used for `.passport` in `.devicePortraitGuideLandscape` orientation mode     |
| misnap_tutorial_passport_qr             | Used for Passport QR in `.deviceLandscapeGuideLandscape` orientation mode    |
| misnap_tutorial_passport_qr_portrait    | Used for Passport QR in `.devicePortraitGuidePortrait` orientation mode      |
| misnap_tutorial_passport_qr_portrait_2  | Used for Passport QR in `.devicePortraitGuideLandscape` orientation mode     |
| misnap_tutorial_check_front             | Used for `.checkFront` in `.deviceLandscapeGuideLandscape` orientation mode  |
| misnap_tutorial_check_front_portrait    | Used for `.checkFront` in `.devicePortraitGuidePortrait` orientation mode    |
| misnap_tutorial_check_front_portrait_2  | Used for `.checkFront` in `.devicePortraitGuideLandscape` orientation mode   |
| misnap_tutorial_check_back              | Used for `.checkBack` in `.deviceLandscapeGuideLandscape` orientation mode   |
| misnap_tutorial_check_back_portrait     | Used for `.checkBack` in `.devicePortraitGuidePortrait` orientation mode     |
| misnap_tutorial_check_back_portrait_2   | Used for `.checkBack` in `.devicePortraitGuideLandscape` orientation mode    |
| misnap_tutorial_generic                 | Used for `.generic` in `.deviceLandscapeGuideLandscape` orientation mode     |
| misnap_tutorial_generic_portrait        | Used for `.generic` in `.devicePortraitGuidePortrait` orientation mode       |
| misnap_tutorial_generic_portrait_2      | Used for `.generic` in `.devicePortraitGuideLandscape` orientation mode      |

</center>

For integrators upgrading from 5.7.0 or older that already used JPGs/PNGs, there are no additional steps as `MiSnapUX` first queries JPGs/PNGs based on the names in the table above and only falls back to default `UIView`s if they are not available.

By default, it's expected that images are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps:

Create a template configuration (if it doesn't exist) and chain `.withCustomAssetLocation`. Refer to a snippet below.

```Swift
let template = MiSnapConfiguration()
    .withCustomAssetLocation { assetLocation in
        assetLocation.bundle = // Your bundle where image assets are located
    }
```

## Implementing custom tutorial screens

### 1. Implement custom Introductory instruction, Help, Timeout, and Review screens
Use [CustomTutorialViewController as a starter](../../../Examples/Snippets/MiSnap/CustomTutorialViewController.swift).

### 2. Disable default tutorial screens

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.useCustomTutorials = true
    }
```
### 3. Present custom tutorial screens

After disabling default tutorial screens subscribe to `MiSnapViewControllerDelegate`'s optional callback `miSnapCustomTutorial(_:,:,:,:,:)` and present your custom screens.

```Swift
func miSnapCustomTutorial(_ documentType: MiSnapScienceDocumentType,
                          tutorialMode: MiSnapUxTutorialMode,
                          mode: MiSnapMode,
                          statuses: [NSNumber]?,
                          image: UIImage?) {
    guard let misnapVC = misnapVC else { return }
    
    let tutorialVC = CustomTutorialViewController(for: documentType,
                                                  tutorialMode: tutorialMode,
                                                  mode: mode,
                                                  statuses: statuses,
                                                  image: image,
                                                  delegate: misnapVC)
    misnapVC.present(tutorialVC, animated: true)
}
```

### 4. (Optional) Introductory instruction mode

By default, an introductory instruction screen is presented.

If you prefer not to show it at all (not recommended) use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.instructionMode = .noInstruction
    }
```

### 5. (Optional) Review mode

By default, a review screen is presented only after a session is completed in Manual mode and there's one or more quality issues with an image. 

If you'd like to present it for Manual only sessions use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.reviewMode = .manualOnly
    }
```

If you'd like to present it for both Auto and Manual sessions (not recommended) use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.reviewMode = .autoAndManual
    }
```

If you prefer not to show it at all (only recommended for legal purposes) use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.reviewMode = .noReview
    }
```

# Session Screen

## Cancel Button

Create a template configuration (if it doesn't exist) and chain `.withCustomCancel`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomCancel { cancel in
        cancel.color = .lightGray
        // Other Cancel button customizations
    }
```
For all available Cancel button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapCancelViewConfiguration.html).

## Help Button

Create a template configuration (if it doesn't exist) and chain `.withCustomHelp`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomHelp { help in
        help.color = .lightGray
        // Other Help button customizations
    }
```
For all available Help button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapHelpViewConfiguration.html).

## Torch Button

Create a template configuration (if it doesn't exist) and chain `.withCustomTorch`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomTorch { torch in
        torch.colorOn = .white
        torch.colorOff = .lightGray
        // Other Torch button customizations
    }
```
For all available Torch button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapTorchViewConfiguration.html).

## Camera Shutter (Manual) Button

Create a template configuration (if it doesn't exist) and chain `.withCustomCameraShutter`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomCameraShutter { cameraShutter in
        cameraShutter.color = .lightGray
        // Other Camera shutter button customizations
    }
```
For all available Camera shutter button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapCameraShutterViewConfiguration.html).

## Guide View

Create a template configuration (if it doesn't exist) and chain `.withCustomGuide`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomGuide { guide in
        guide.vignette.style = .blur
        guide.vignette.alpha = 0.9
        // Other Guide vignette view customizations
        
        guide.outline.alpha = 0.9
        // Other Guide outline view customizations
    }
```
For all available Guide vignette view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapVignetteConfiguration.html).

For all available Guide outline view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapDocumentOutlineConfiguration.html).

## Hint View

Create a template configuration (if it doesn't exist) and chain `.withCustomHint`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomHint { hint in
        hint.backgroundColor = .lightGray
        // Other Hint view customizations
    }
```
For all available Hint view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapHintViewConfiguration.html).

## Glare View

Create a template configuration (if it doesn't exist) and chain `.withCustomGlare`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomGlare { glare in
        glare.backgroundColor = .systemOrange.withAlphaComponent(0.5)
        // Other Glare view customizations
    }
```
For all available Glare view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapGlareViewConfiguration.html).

## Recording Indicator View

Create a template configuration (if it doesn't exist) and chain `.withCustomRecordingIndicator`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomRecordingIndicator { recordingIndicator in
        recordingIndicator.backgroundColor = .lightGray.withAlphaComponent(0.5)
        // Other Recording Indicator view customizations
    }
```
For all available Recording Indicator view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapRecordingIndicatorViewConfiguration.html).

## Success Checkmark View

Create a template configuration (if it doesn't exist) and chain `.withCustomSuccessCheckmark`. Refer to a snippet below:

```Swift
let template = MiSnapConfiguration()
    .withCustomSuccessCheckmark { successCheckmark in
        successCheckmark.color = .systemGreen
        // Other Success Checkmark view customizations
    }
```
For all available Success Checkmark view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapSuccessCheckmarkViewConfiguration.html).

# Parameters

## Video Recording
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        parameters.camera.recordVideo = true

        // Optionally, enable video recording with audio if required
        parameters.camera.recordAudio = true 
    }
```

## Optional Data Redaction
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        parameters.science.optionalDataRedactionEnabled = true
    }
```
:warning: `Video Recording` feature requires no frame processing therefore optional data (BSN) will not be redacted in a recorded video. It is your responsibility to keep `Video Recording` disabled (default) or disable if enabled in case you enable `Optional Data Redaction`.

## Enhanced Manual
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        parameters.enhancedManualEnabled = true
    }
```
:warning: If you have to disable a review screen for legal purposes follow instructions outlined [here](#review-screen).

## Document type name
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        // Custom document type name displayed at the top of a Capture screen
        parameters.science.documentTypeName = "Your custom document type name"
    }
```

Note, the value of `documentTypeName` is used as a key in localizable strings. If it's found there then a localized string will be used. Otherwise, the value itself is displayed.

## Trigger
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        /* Only apply this customization if image quality isn't important and 
        one or more additional triggers are enabled (MRZ only or Barcode only flow) */
        parameters.science.iqaRequired = false

        /* Only apply this customization for a flow where a barcode is expected */
        parameters.science.barcodeRequired = true

        /* Only apply this customization for a flow where an MRZ is expected */
        parameters.science.mrzRequired = true
    }
```

### MRZ only
Here's how to configure a trigger for MRZ only flow that significantly reduces friction due to skipping glare, background, corner and other quality checks:

```Swift
.withCustomParameters { parameters in
    parameters.science.iqaRequired = false
    parameters.science.mrzRequired = true
}
```

:warning: Since there's a high probability of an acquired image failing one or more image quality analysis checks, we recommend to use this configuration only when NFC step is required.

:warning: Enabling this configuration for ID Front and/or ID Back document types will result in continuos auto session timeouts for documents that do not have MRZ (e.g. US DL front and back) therefore we recommend having at least one flow for documents that have MRZ that'll utilize this new configuration and another one with default configuration that ensures a document without MRZ can still be acquired (if supported by your use case).

### Barcode only
Here's how to configure a trigger for MRZ only flow that significantly reduces friction due to skipping glare, background, corner and other quality checks:

```Swift
.withCustomParameters { parameters in
    parameters.science.iqaRequired = false
    parameters.science.barcodeRequired = true
    // By deafult PDF417 barcode is enabled. Here's how to override to support QR
    parameters.science.supportedBarcodeTypes = [MiSnapScienceBarcodeType.QR.rawValue]
    // Aditionally you can change a name of a document to a specific barcode
    parameters.science.documentTypeName = // your name for a specific barcode
}
```

## Other

:warning: It's not recommended to customize other SDK parameters without consulting with Mitek representative.

For other SDK parameters customization options refer to this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnap/Classes/MiSnapParameters.html).




