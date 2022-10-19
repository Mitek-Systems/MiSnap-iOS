Please refer to [MiSnapVoiceCaptureCustomizationSampleApp](../../../Examples/Apps/MiSnapVoiceCapture/MiSnapVoiceCaptureCustomizationSampleApp) as a working customization example.

# Customization Guide

:warning: This guide is only applicable if you've integrated `MiSnapVoiceCaptureUX`.

## Table of Contents
* [Overview](#overview)
* [UX Parameters](#ux-parameters)
* [Localization](#localization)
* [Phrase Selection Screen](#phrase-selection-screen)
* [Introductory Instruction Screen](#introductory-instruction-screen)
* [Recording Screen](#review-screen)
* [Parameters](#parameters)

# Overview

In general, there are 2 types of customization available - UX/UI and SDK parameters customization.

To customize UX/UI, a template configuration is created and all necessary customizations are chained one after another.

To customize SDK parameters, a configuration for a specific document type is created and then its SDK parameters can be customized then the UX template configuration is applied.

Note, the same customized template can and should be re-used across Enrollment and Verification flows.

Once desired customization is achieved, a configuration is passed to a `MiSnapVoiceCaptureViewController`.

Example below demonstrates this concept on a high level. 

```Swift
let template = MiSnapVoiceCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        // UX parameters customization here
    }
    .withCustomUxObject... { uxObject in
        // uxObject customization here
    }
    .withCustomUxObjectN... { uxObjectN in
        // uxObjectN customization here
    }

let configuration = MiSnapConfiguration(for: flow)
    .withCustomParameters { parameters in
        // SDK parameters customization here
    }
    .applying(template)

misnapVoiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
```

# UX Parameters
Create a configuration (if it doesn't exist) and chain `.withCustomUxParameters`. Refer to a snippet below.

```Swift
let template = MiSnapVoiceCaptureConfiguration(for: .enrollment)
    .withCustomUxParameters { uxParameters in
        uxParameters.autoDismiss = false
        // Other UX Parameters customizations
    }
```
For all available UX Parameters customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/5.1.0.b1/Docs/API/MiSnapVoiceCapture/MiSnapVoiceCaptureUX/Classes/MiSnapVoiceCaptureUXParameters.html).

# Localization

Copy localization key-value pairs for a given language from [Localization](../../../Localization/MiSnapVoiceCapture) folder and paste them into your Localizable.strings file.

Create a template configuration (if it doesn't exist) and chain `.withCustomLocalization`. Refer to a snippet below.

```Swift
let template = MiSnapVoiceCaptureConfiguration()
    .withCustomLocalization { localization in
        localization.bundle = // Your bundle where localization files are located
        localization.stringsName = // Your localization file name
    }
```

# Phrase Selection Screen

There are 3 customizable elements on this screen:
* `message` - a message at the top
* `phrase` - a phrase in a list (UIPickerView)
* `button` - a button at the bottom

Create a template configuration (if it doesn't exist) and chain `.withCustomPhraseSelection`. Refer to a snippet below.

```Swift
let template = MiSnapVoiceCaptureConfiguration()
    .withCustomPhraseSelection { phraseSelection in
        phraseSelection.message.font = // Your font
        // Other message customizations
        
        phraseSelection.phrase.font = // Your font
        // Other phrase customizations
        
        phraseSelection.button.backgroundColor = // Your background color
        // Other button customizations
    }
```

All 3 elements are of `MiSnapLabelConfiguration` type. For all available customization options see this [API reference](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/5.1.0.b1/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapLabelConfiguration.html).

# Introductory Instruction Screen

By default, an introductory instruction screen is presented for Enrollment flow only.

If you would like not to show it (not recommended) use the following snippet:

```Swift
let template = MiSnapVoiceCaptureConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.showIntroductoryInstructionScreen = false
    }
```

There are 3 customizable elements on this screen:
* `image` - an image at the top
* `instruction` - instruction text that's underneath the image
* `button` - a button at the bottom

```Swift
let template = MiSnapVoiceCaptureConfiguration()
    .withCustomIntroductoryInstruction { introductoryInstruction in
        introductoryInstruction.image = // Your image
        
        introductoryInstruction.instruction.font = // Your font
        // Other instruction customizations
        
        introductoryInstruction.button.backgroundColor = // Your background color
        // Other button customizations
    }
```

`instruction` and `button` are of `MiSnapLabelConfiguration` type. For all available customization options see this [API reference](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/5.1.0.b1/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapLabelConfiguration.html).

# Recording Screen

There are 8 customizable elements on this screen:
* `cancel` - a Cancel button at the top
* `neutral` - a neutral status view
* `success` - a success status view
* `failure` - a falure status view
* `message` - a message that's above the phrase
* `phrase` - a phrase
* `failureMessage` - a message presented to a user when recording is not of sufficient quality
* `failureAcknowledgment` - a button to acknowledge a failure message

```Swift
let template = MiSnapVoiceCaptureConfiguration()
    .withCustomRecording { recording in
        recording.neutral.color = // Your color
        recording.neutral.backgroundColor = // Your background color
        // Other neutral customizations
        
        recording.success.color = // Your color
        recording.success.backgroundColor = // Your background color
        // Other success customizations
        
        recording.failure.color = // Your color
        recording.failure.backgroundColor = // Your background color
        // Other failure customizations
        
        recording.cancel.backgroundColor = // Your background color
        // Other cancel customizations
        
        recording.message.font = // Your font
        // Other message customizations
        
        recording.phrase.font = // Your font
        recording.phrase.color = // Your color
        recording.phrase.backgroundColor = // Your background color
        // Other phrase customizations
        
        recording.failureMessage.font = // Your font
        // Other failureMessage customizations
        
        recording.failureAcknowledgment.backgroundColor = // Your background color
        // Other failureAcknowledgment customizations
    }
```

`neutral`, `success` and `failure` inherit from `MiSnapVoiceCaptureStatusViewConfiguration`. For all available customization options see this [API reference](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/5.1.0.b1/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapVoiceCaptureStatusViewConfiguration.html).

`cancel`, `message`, `phrase`, `failureMessage`, `failureAcknowledgment` are of `MiSnapLabelConfiguration` type. For all available customization options see this [API reference](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Mitek-Systems/MiSnap-iOS/5.1.0.b1/Docs/API/Common/MiSnapAssetManager/Classes/MiSnapLabelConfiguration.html).

# Parameters

:warning: It's not recommended to customize SDK parameters without consulting with Mitek representative.

For all SDK parameters customization options refer to this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/5.1.0.b1/Docs/API/MiSnapVoiceCapture/MiSnapVoiceCapture/Classes/MiSnapVoiceCaptureParameters.html).

```Swift
let configuration = MiSnapVoiceCaptureConfiguration(for: .enrollment)
    .withCustomParameters { parameters in
        parameters.speechLengthMin = // Your value
    }
```


