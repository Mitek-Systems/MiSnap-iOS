# Frequently Asked Questions (FAQs)

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

## How does video recording feature work when optional data (BSN) redaction for NLD Passports is enabled?

`Video recording` feature requires no frame processing therefore optional data (BSN) will not be redacted in a recorded video. It is your responsibility to keep `video recording` disabled (default) or disable if enabled in case you enable `optional data redaction` feature.
