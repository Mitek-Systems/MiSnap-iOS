# Frequently Asked Questions (FAQs)

## MiSnap 5.6.0 has a lot of deprecations. How to migrate to a new API?

First of all, deprecations aren't breaking changes. Calling deprecated API should still work as expected but our recommendation is to switch to a new API when possible to get benefits.

1. Rationale for deprecating `idBackMode` in `MiSnapScienceParameters` and how to migrate

Starting with 5.6.0 there's a new trigger that allows to acquire an image as soon as MRZ is detected regardless of an image quality. `idBackMode` with image and barcode optionality became obsolete with addition of this trigger. Either `idBackMode` had to be updated to handle all possible permutations (8) or split each trigger in its own property. We went with the latter approach since it's more straightforward.

Here's how to migrate:

```Swift
// Change this
parameters.science.idBackMode = .acceptableImageRequiredBarcodeOptional
// To this
parameters.science.iqaRequired = true
parameters.science.barcodeRequired = false

// Change this
parameters.science.idBackMode = .acceptableImageRequiredBarcodeRequired
// To this
parameters.science.iqaRequired = true
parameters.science.barcodeRequired = true

// Change this
parameters.science.idBackMode = .acceptableImageOptionalBarcodeRequired
// To this
parameters.science.iqaRequired = false
parameters.science.barcodeRequired = true
```

2. Rationale for deprecating `showIntroductoryInstructionScreen`, `showTimeoutScreen`, `showHelpScreen`, and `showReviewScreen` in `MiSnapUxParameters` and how to migrate:

Starting with 5.6.0 there's a new callback in MiSnapViewController called `miSnapCustomTutorial(_:::::)` which enables customization of all 4 tutorial modes (introductory instruction, help, timeout, and review) using one tutorial view controller whereas only help and timeout screens were available for customization. This callback is much more flexible than `miSnapHelpAction` and `miSnapTimeoutAction` because it returns a document type, tutorial mode, mode (Auto or Manual), quality analysis statuses that can be mapped to a specific localized message, and an image. With this change a new property was introduces and the old four were deprecated.

Here's how to migrate:

```Swift
// Change this
uxParameters.showIntroductoryInstructionScreen = false
uxParameters.showHelpScreen = false
uxParameters.showTimeoutScreen = false
uxParameters.showReviewScreen = false

// To this
uxParameters.useCustomTutorials = true

// Instead of implementing these
func miSnapHelpAction(_ messages: [String]) {
    // Your help screen imlementation
}
func miSnapTimeoutAction(_ messages: [String]) {
    // Your timeout screen imlementation
}

// Implement this
func miSnapCustomTutorial(_ documentType: MiSnapScienceDocumentType,
                          tutorialMode: MiSnapUxTutorialMode,
                          mode: MiSnapMode,
                          statuses: [NSNumber]?,
                          image: UIImage?) {
    // Your tutorial screen imlementation that handles all four tutorial modes
}
```

Note, overridding `useCustomTutorials` to `true` will result in `miSnapCustomTutorial(_:::::)` callback being sent for all four tutorial screens therefore it's an integrator responsibility to implement all of them. In case you don't want to show the introductory instruction or the review screens for some reasons then additionally apply this snippet:

```Swift
// Disable introductory instruction screen
uxParameters.instructionMode = .noInstruction

// Disable review screen
uxParameters.reviewMode = .noReview
```

Please refer to this [updated starter tutorial view controller](../../../Examples/Snippets/MiSnap/CustomTutorialViewController.swift) for implementing your custom tutorials.

3. Rationale for deprecating `hintUpdatePeriod` in `MiSnapUxParameters` and how to migrate
`hintUpdatePeriod` allowed very little control over hint animation timing. Specifically, it only controlled time between two subsequent hints. For a greater control over hint timing `MiSnapHintParameters` was introduces in 5.6.0 which controls how long a hint is displayed to a user, hint transition times (fade in and out), and time between two subsequent hints.

How to migrate:

```Swift
// Change this
uxParameters.hintUpdatePeriod = // your update period time in seconds

// To this
uxParameters.hint.displayTime = // how long a hint should be presented to a user in seconds
uxParameters.hint.transitionTime = // a transition time (fade in and out) in seconds
uxParameters.hint.betweenTime = // how long before the next hint is shown after the current one disappears in seconds
```

4. Rationale for deprecating `preset` in `MiSnapCameraParameters` and how to migrate
Given the fact that MiSnap requires at least 1080p for a better acceptance on a backend and addition of a new high resolution feature, `preset` wasn't accurate enough to be used going forward.

How to migrate:
```Swift
// Change this
parameters.camera.preset = .hd1920x1080

// To this or set a different appropriate resolution from available options
parameters.camera.resolution = .resolution1920x1080
```

## Does MiSnap support TD2 documents (e.g. ROU ID with 2-line MRZ)?

Yes, starting with 5.6.0 there's support for acquiring TD2 documents and extracting info from MRZ in Auto mode. 

Note, invoke `Passport` document type to acquire TD2 documents since they have the same aspect ratio and 2-line MRZ like TD3 documents (Passports). Additionally, you can override document name to avoid confusion:
```Swift
let configuration = MiSnapConfiguration(for: .passport)
    .withCustomParameters { parameters in
        parameters.science.documentTypeName = "ID Front"
    }
```
where, `"ID Front"` is a key in `MiSnapLocalizable.strings` that returns `"Front of ID"` be default.

## Encountering an issue where localization and image assets are not found when upgrading from 5.0.0...5.1.1 version

Refer to [this section](integration_guide.md#sdk-and-uxui) of the Integration guide for updated instructions.

## What is optional data (BSN) redaction feature?

The on-device redaction feature of the MiSnap SDK has been added in version 5.2.0 to aid in compliance with Dutch data protection legislation regarding the Citizen Service Number (BSN) - see section 46 of the Dutch Implementation Act of the GDPR ("UAVG"). Mitek is making its best effort to ensure the BSN is adequately redacted so it is unreadable by human or machine.  Mitek is only redacting the BSN from still images, so the customer or integrator must ensure they are not using the video component of MiSnap if redaction is to take place.

## How does video recording feature work when optional data (BSN) redaction for NLD Passports is enabled?

`Video recording` feature requires no frame processing therefore optional data (BSN) will not be redacted in a recorded video (see the previous question). It is your responsibility to keep `video recording` disabled (default) or disable if enabled in case you enable `optional data redaction` feature.

## How do I handle a new NLD passport with a BSN number on a separate page?

:warning: `ode` and `barcode` features have to be licensed for this feature to work.

Configure and invoke `passport` document type:
```Swift
let configuration = MiSnapConfiguration(for: .passport)
misnapVC = MiSnapViewController(with: configuration, delegate: self)
// Present view controller here
``` 

Check `additionalStep` property of a `result` object returned by `miSnapSuccess(_ result:)` callback.

```Swift
if let extraction = result.extraction, extraction.additionalStep == .passportQr {
    // An additional QR scanning step is required
} else {
    // No additional steps required. Good to proceed to the next step
}
```

Configure and invoke `idBack` to scan QR code only if it's required.

```Swift
let configuration = MiSnapConfiguration(for: .idBack)
    .withCustomParameters { parameters in
        parameters.science.iqaRequired = false
        parameters.science.barcodeRequired = true
        parameters.science.supportedBarcodeTypes = [MiSnapScienceBarcodeType.QR.rawValue]
        parameters.science.orientationMode = .devicePortraitGuidePortrait
        // documentTypeName is going to be used as a key in MiSnapLocalizable.strings
        parameters.science.documentTypeName = "QR Code"
    }
    .withCustomGuide { guide in
        guide.outline.alpha = 0.0
    }
    .withCustomInstruction { instruction in
        instruction.type = .passportQr
    }

misnapVC = MiSnapViewController(with: configuration, delegate: self)
// Present view controller here
```

Check `personalNumber` property of a `result` object returned by `miSnapSuccess(_ result:)` callback.

```Swift
if let extraction = result.extraction, let personalNumber = extraction.personalNumber {
    // Use a personal number extracted from QR code
}
```

Refer to [Integration Guide](integration_guide.md) and [Customization Guide](customization_guide.md) for detailed instructions on proper configuration and customization.
