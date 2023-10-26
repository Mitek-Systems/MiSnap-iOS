# Frequently Asked Questions (FAQs)

## Encountering an issue where localization and image assets are not found when upgrading from 5.0.0...5.1.1 version

Refer to [this section](integration_guide.md#sdk-and-uxui) of the Integration guide for updated instructions.

## How to increase probability of NFC step to be presented for NLD DL?
For NFC step to be presented 1-line MRZ should be extracted from the front of DL. In versions before 5.3.3 an extraction success rate was around 50-60%. In 5.3.3 there was an improvement made that increased the rate to around 90%. 

To further increase extraction chances add QR-code scanning for `.idBack` that'll get 1-line MRZ value from a QR-code on the NLD DL back. To do this chain the following customization to your `.idBack` configuration:

```Swift
.withCustomParameters { parameters in
    parameters.science.supportedBarcodeTypes = [MiSnapScienceBarcodeType.PDF417.rawValue, MiSnapScienceBarcodeType.QR.rawValue]
}
```

Starting with 5.4.0 if you're using `MiSnapWorkfkow` no additional changes are needed. If you're not using `MiSnapWorkfkow` in your logic when a success result is returned assign a barcode string to an `mrzString` value that'll be later validated (just like for the front of DL) to determine whether NFC step needs to be presented:

```Swift
if let extraction = result.extraction {
    if let mrzString = extraction.mrzString {
        // mrzString will be returned if 1-line MRZ was successfully extracted from the front of DL 
        self.mrzString = mrzString
    } else if let barcodeString = extraction.barcodeString {
        // barcodeString will be returned if MRZ was successfully extracted from QR code in the back of DL 
        self.mrzString = barcodeString
    }
    if let documentNumber = extraction.documentNumber {
        // documentNumber will be returned if 1-line MRZ was successfully extracted from the front of DL
        self.documentNumber = documentNumber
    }
    if let dateOfBirth = extraction.dateOfBirth {
        // dateOfBirth will be returned if 1-line MRZ was successfully extracted from the front of DL
        self.dateOfBirth = dateOfBirth
    }
    if let dateOfExpiry = extraction.expirationDate {
        // dateOfExpiry will be returned if 1-line MRZ was successfully extracted from the front of DL
        self.dateOfExpiry = dateOfExpiry
    }
}
...
<your_logic_for_validating_inputs_to_determine_whether_NFC_step_should_be_presented>
```

## What countries and documents are supported?
See a list of contries and documents with full and beta support [here](supported_geos.md).

