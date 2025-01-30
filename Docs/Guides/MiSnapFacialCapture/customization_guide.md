# Customization Guide

:warning: This guide is only applicable if you've integrated `MiSnapFacialCaptureUX`. Use this [starter custom view controller](../../../Examples/Snippets/MiSnapFacialCapture/CustomFacialCaptureViewController.swift) when building your own UX/UI.

Please refer to [MiSnapFacialCaptureCustomizationSampleApp](../../../Examples/Apps/MiSnapFacialCapture/MiSnapFacialCaptureCustomizationSampleApp) as a working customization example.

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
    * [Camera Shutter (Manual) Button](#manual-button)
    * [Countdown View](#countdown-view)
    * [Guide View](#guide-view)
    * [Recording Indicator](#recording-indicator)
    * [Success Checkmark View](#success-view)
* [Parameters](#parameters)
    * [Enable Smile](#enable-smile)
    * [Video Recording](#video-recording)
    * [AI-based RTS](#ai-based-rts)
    * [Other](#other)

# Overview

In general, there are 2 types of customization available - UX/UI and SDK parameters customization.

All necessary customizations are chained one after another.

Once desired customization is achieved, a configuration is passed to a `MiSnapFacialCaptureViewController`.

Example below demonstrates this concept on a high level.

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomParameters { parameters in
        // SDK parameters customization here
    }
    .withCustomUxObject... { uxObject in
        // uxObject customization here
    }
    .withCustomUxObjectN... { uxObjectN in
        // uxObjectN customization here
    }

misnapFacialCaptureVC = MiSnapFacialCaptureViewController(with: configuration, delegate: self)
```

# UX Parameters
Create a configuration (if it doesn't exist) and chain `.withCustomUxParameters`. Refer to a snippet below.

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.timeout = 25.0
        // Other UX Parameters customizations
    }
```
For all available UX Parameters customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnapFacialCapture/MiSnapFacialCaptureUX/Classes/MiSnapFacialCaptureUXParameters.html).

# Localization

Go to a localizable strings file that was added to your project during integration process and adjust values for a desired language as needed.

By default, it's expected that localizable files are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps: 

Create a configuration (if it doesn't exist) and chain `.withCustomLocalization`. Refer to a snippet below.

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomLocalization { localization in
        localization.bundle = // Your bundle where localization files are located
    }
```

By default, it's aslo expected that localizable file name is `MiSnapFacialCaptureLocalizable` but if you changed its name or moved localization key-pairs to your own localizable file then you can specify a new file name by following next steps:

Create a configuration (if it doesn't exist) and chain `.withCustomLocalization` (if it doesn't exist). Refer to a snippet below.

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomLocalization { localization in
        localization.stringsName = // Your localization file name
    }
```

# Image Assets

Go to a place where you copied images into during integration process and replace existing resources with new ones but make sure to keep the same names.

By default, it's expected that images are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps:

Create a configuration (if it doesn't exist) and chain `.withCustomAssetLocation`. Refer to a snippet below.

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomAssetLocation { assetLocation in
        assetLocation.bundle = // Your bundle where image assets are located
    }
```

# Introductory Instruction Screen

By default, an introductory instruction screen is presented.

If you prefer to use your own introductory instruction screen or would like not to show it at all (not recommended) use the following snippet:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showIntroductoryInstructionScreen = false
    }
```

# Review Screen

By default, a review screen is presented only after a session is completed in Manual mode. If you'd like to present it for both Auto and Manual sessions use the following snippet:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.reviewMode = .autoAndManual
    }
```

If you prefer to use your own review screen or would like not to show it at all (not recommended) use the following snippet:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showReviewScreen = false
    }
```

# Help and Timeout Screens

A default Help screen is presented when a user presses Help button and a default Timeout screen is presented when an Auto session times out. If you'd like to present your own custom Help and/or Timeout screen(s) follow these steps:

### 1. Create custom Help and/or Timeout screen(s)
Use this [starter custom view controller](../../../Examples/Snippets/MiSnapFacialCapture/CustomFacialCaptureTutorialViewController.swift).

### 2. Disable default Help and/or Timeout screen(s)

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showHelpScreen = false
        uxParameters.showTimeoutScreen = false
    }
```
### 3. Present custom Help and/or Timeout screen(s)

After disabling a default Help and/or Timeout screen(s) subscribe to `MiSnapFacialCaptureViewControllerDelegate`'s optional callbacks `miSnapFacialCaptureHelpAction()` and/or `miSnapFacialCaptureTimeoutAction()` respectively and present your custom screen(s).

```Swift
func miSnapFacialCaptureHelpAction() {
    guard let misnapFacialCaptureVC = misnapFacialCaptureVC else { return }

    let helpVC = CustomFacialCaptureTutorialViewController(for: .help, delegate: faceVC)
    faceVC.presentVC(helpVC)
}

func miSnapFacialCaptureTimeoutAction() {
    guard let misnapFacialCaptureVC = misnapFacialCaptureVC else { return }

    let timeoutVC = CustomFacialCaptureTutorialViewController(for: .timeout, delegate: faceVC)
    faceVC.presentVC(timeoutVC)
}
```

# Capture Screen

## Cancel Button

Create a configuration (if it doesn't exist) and chain `.withCustomCancel`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomCancel { cancel in
        cancel.color = .lightGray
        // Other Cancel button customizations
    }
```
For all available Cancel button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapCancelViewConfiguration.html).

## Help Button

Create a configuration (if it doesn't exist) and chain `.withCustomHelp`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomHelp { help in
        help.color = .lightGray
        // Other Help button customizations
    }
```
For all available Help button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapHelpViewConfiguration.html).

## Camera Shutter (Manual) Button

Create a configuration (if it doesn't exist) and chain `.withCustomCameraShutter`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomCameraShutter { cameraShutter in
        cameraShutter.color = .lightGray
        // Other Camera shutter button customizations
    }
```
For all available Camera shutter button customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapCameraShutterViewConfiguration.html).

## Countdown View

Create a configuration (if it doesn't exist) and chain `.withCustomCountdown`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomCountdown { countdown in
        countdown.size = countdown.size.scaled(by: 1.25)
        // Other Countdown view customizations
    }
```

For all available Countdown view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapFacialCaptureCountdownViewConfiguration.html).

## Guide View

Create a configuration (if it doesn't exist) and chain `.withCustomGuide`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomGuide { guide in
        guide.vignette.style = .blur
        guide.vignette.alpha = 0.9
        // Other Guide vignette view customizations
        
        guide.outline.alpha = 0.9
        // Other Guide outline view customizations
    }
```
For all available Guide vignette view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapFacialCaptureVignetteConfiguration.html).

For all available Guide outline view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapFacialCaptureOutlineConfiguration.html).

## Recording Indicator View

Create a configuration (if it doesn't exist) and chain `.withCustomRecordingIndicator`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomRecordingIndicator { recordingIndicator in
        recordingIndicator.backgroundColor = .lightGray.withAlphaComponent(0.5)
        // Other Recording Indicator view customizations
    }
```
For all available Recording Indicator view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapRecordingIndicatorViewConfiguration.html).

## Success Checkmark View

Create a configuration (if it doesn't exist) and chain `.withCustomSuccessCheckmark`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomSuccessCheckmark { successCheckmark in
        successCheckmark.color = .systemGreen
        // Other Success Checkmark view customizations
    }
```
For all available Success Checkmark view customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapSuccessCheckmarkViewConfiguration.html).

# Parameters

## Enable Smile

By default the SDK is using a countdown trigger to acquire a selfie. A countdown view is displayed when a frame passes all Image Quality Analysis (IQA) checks. Countdown stops if any IQA error occurs. A selfie is acquired when time is counted down. 

If you'd like to acquire a selfie on a smile trigger instead refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomParameters { parameters in
        parameters.selectOnSmile = true
    }
```

## Video recording
Create a configuration (if it doesn't exist) and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomParameters { parameters in
        parameters.camera.recordVideo = true

        // Optionally, enable video recording with audio if required
        parameters.camera.recordAudio = true 
    }
```

## AI-based RTS
Create a configuration (if it doesn't exist) and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapFacialCaptureConfiguration()
    .withCustomParameters { parameters in
        parameters.aiBasedRtsEnabled = true
    }
```

Note, this feature has a dependency on an optional library. You'll get an exception with a verbose explanation if you attempt to run the application without the library. To add this library:
* SPM: add `MiSnapIAD` package
* CocoaPods: add `pod 'MiSnapIAD'` to your Podfile
* Manual: add `IDLiveFaceIAD.xcframework` to your Xcode project:
    * Under `Frameworks, Libraries, and Embedded Content` with `Embed & Sign` option in `General` tab
    * Add a valid path to the library in `Framework Search Paths` in `Build Settings` tab

## Other

:warning: It's not recommended to customize other SDK parameters without consulting with Mitek representative.

For other SDK parameters customization options refer to this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnapFacialCapture/MiSnapFacialCapture/Classes/MiSnapFacialCaptureParameters.html).


