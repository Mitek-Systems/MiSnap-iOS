# Customization Guide

:warning: This guide is only applicable if you've integrated `MiSnapUX`. Use this [starter custom view controller](../../../Examples/Snippets/MiSnap/CustomViewController.swift) when building your own UX/UI.

Please refer to [MiSnapCustomizationSampleApp](../../../Examples/Apps/MiSnap/MiSnapCustomizationSampleApp) as a working customization example.

## Table of Contents
* [Overview](#overview)
* [UX Parameters](#ux-parameters)
* [Localization](#localization)
* [Image assets](#image-assets)
* [Introductory Instruction Screen](#introductory-instruction-screen)
* [Review Screen](#review-screen)
* [Help and Timeout Screens](#help-and-timeout-screens)
* [Capture Screen](#capture-screen)
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
    * [ID Back Mode](#id-back-mode)
    * [Document Type Name](#document-type-name)
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

# Image Assets

Go to a place where you copied images into during integration process and replace existing resources with new ones but make sure to keep the same names.

By default, it's expected that images are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps:

Create a template configuration (if it doesn't exist) and chain `.withCustomAssetLocation`. Refer to a snippet below.

```Swift
let template = MiSnapConfiguration()
    .withCustomAssetLocation { assetLocation in
        assetLocation.bundle = // Your bundle where image assets are located
    }
```

# Introductory Instruction Screen

By default, an introductory instruction screen is presented.

If you prefer to use your own introductory instruction screen or would like not to show it at all (not recommended) use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showIntroductoryInstructionScreen = false
    }
```

# Review Screen

By default, a review screen is presented only after a session is completed in Manual mode. If you'd like to present it for both Auto and Manual sessions use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.reviewMode = .autoAndManual
    }
```

If you prefer to use your own review screen or would like not to show it at all (only recommended for legal purposes) use the following snippet:

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showReviewScreen = false
    }
```

# Help and Timeout Screens

A default Help screen is presented when a user presses Help button and a default Timeout screen is presented when an Auto session times out. If you'd like to present your own custom Help and/or Timeout screen(s) follow these steps:

### 1. Create custom Help and/or Timeout screen(s)
Use this [starter custom view controller](../../../Examples/Snippets/MiSnap/CustomTutorialViewController.swift).

### 2. Disable default Help and/or Timeout screen(s)

```Swift
let template = MiSnapConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showHelpScreen = false
        uxParameters.showTimeoutScreen = false
    }
```
### 3. Present custom Help and/or Timeout screen(s)

After disabling a default Help and/or Timeout screen(s) subscribe to `MiSnapViewControllerDelegate`'s optional callbacks `miSnapHelpAction(_ :)` and/or `miSnapTimeoutAction(_ :)` respectively and present your custom screen(s).

```Swift
func miSnapHelpAction(_ messages: [String]) {
    guard let misnapVC = misnapVC else { return }

    let helpVC = CustomTutorialViewController(for: .help, delegate: misnapVC, messages: messages)
    misnapVC.present(helpVC, animated: true)
}

func miSnapTimeoutAction(_ messages: [String]) {
    guard let misnapVC = misnapVC else { return }

    let timeoutVC = CustomTutorialViewController(for: .timeout, delegate: misnapVC, messages: messages)
    misnapVC.present(timeoutVC, animated: true)
}
```

# Capture Screen

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

## ID Back Mode
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        // When an image quality is not important and only a decoded barcode string is required use this mode
        parameters.science.idBackMode = .acceptableImageOptionalBarcodeRequired
        
        // When both a good quality image and a decoded barcode string is required use this mode
        parameters.science.idBackMode = .acceptableImageRequiredBarcodeRequired
    }
```

For more details and all available ID Back modes see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnapScience/Enums/MiSnapScienceIdBackMode.html).

## Document type name
Create a configuration for a specific document type and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapConfiguration(for: documentType)
    .withCustomParameters { parameters in
        // Custom document type name displayed at the top of a Capture screen
        parameters.science.documentTypeName = "Your custom document type name"
    }
```

## Other

:warning: It's not recommended to customize other SDK parameters without consulting with Mitek representative.

For other SDK parameters customization options refer to this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnap/Classes/MiSnapParameters.html).




