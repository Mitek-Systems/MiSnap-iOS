# Frequently Asked Questions (FAQs)

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
        parameters.science.supportedBarcodeTypes = [MiSnapScienceBarcodeType.QR.rawValue]
        parameters.science.idBackMode = .acceptableImageOptionalBarcodeRequired
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
