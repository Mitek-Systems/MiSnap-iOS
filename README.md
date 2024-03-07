# MiSnap for iOS

![Platform](https://img.shields.io/cocoapods/p/MiSnap.svg?color=darkgray)
![CocoaPods version](https://img.shields.io/cocoapods/v/MiSnap?color=success)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen)
![Carthage](https://img.shields.io/badge/Carthage-incompatible-red)

## Table of Contents
* [Release Notes](#release-notes)
* [System Requirements](#system-requirements)
* [License Key](#license-key)
* [Integration Guides](#integration-guides)
* [Customization Guides](#customization-guides)
* [Workflow](#workflow)
* [SDKs Sizes](#sdks-sizes)
* [Devices Tested](#devices-tested)
* [Known Issues](#known-issues)
* [Frequently Asked Questions (FAQs)](#frequently-asked-questions-faqs)
* [Third-Party Licensing Info](#third-party-licensing-info)

- - -

# Release Notes

See [here](https://github.com/Mitek-Systems/MiSnap-iOS/releases).

- - -

# System Requirements

<center>

| Technology | Min version |
| :--- | :---: |
| Xcode | 15.0 |
| iOS | 12.0 |
| iPhone | 6 |
| iPad | mini (4th generation) |

</center>
Min OS/device combination offers coverage level of 99.89%.

__Note__, `On-Device Classification (ODC)` `beta` feature is only available on devices running iOS 13.0 or newer and powered by A11 or newer chip (iPhone 8 or newer, iPad Mini 5th generation or newer) which offers coverage level of 95.92% as of Q2 2023. `Any ID` document type heavily relies on this feature therefore its support has the same constraints.

__Note__, for `MiSnapNFC SDK` functionality, supported devices are all iPhone 7 and newer that support iOS 13.0 and above.

- - -

# License Key

All iOS SDKs (MiSnap, MiSnapFacialCapture, MiSnapNFC) require a license key.

Supported formats:
* Specific bundle id (e.g. `com.company.AppName`) will be valid for this specific application only
* Wildcard identifiers (e.g. `com.company.*`) will be valid for all applications which bundle ids start with "com.company"
* Multiple identifiers (e.g. `com.company.AppName1, com.company.AppName2` or `com.company.*, com.anotherCompany.*`) will be valid for applications with specified bundle ids and wild card identifiers.

To obtain a license key, please contact your Mitek Solutions Provider or select the "Contact Support" icon from the https://mitek.service-now.com/csm splash page.

Refer to [Integration Guides](#integration-guides) for setting the license key in your application.

- - -

# Integration Guides

* [MiSnap](Docs/Guides/MiSnap/integration_guide.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/integration_guide.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/integration_guide.md)
* [MiSnapVoiceCapture](Docs/Guides/MiSnapVoiceCapture/integration_guide.md)

- - -

# Customization Guides

* [MiSnap](Docs/Guides/MiSnap/customization_guide.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/customization_guide.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/customization_guide.md)
* [MiSnapVoiceCapture](Docs/Guides/MiSnapVoiceCapture/customization_guide.md)

- - -

# Workflow

`MiSnapWorkflow` is a utility that ties any combination of Mitek SDKs together allowing integrators to get up and running with very little effort.

Benefits for integrators:
* Faster deployment to production since there's no need in writing complex custom logic for tying Mitek SDKs together and managing transitions between them
* Faster resolution of issues (if any) since Mitek support team doesn't need to debug your custom workflow

For afore-mentioned reasons it is Mitek's preferred way of building workflows.

See [this guide](Docs/Guides/Common/workflow.md) for `MiSnapWorkflow` integration and customization details.

- - -

# SDKs Sizes

<center>

| Component                        | Compressed, MB | Uncompressed, MB |
| :------------------------------- | :------------: | :--------------: |
| MiSnap                           |  1.40          |  3.70            |
| MiSnap + MiSnapUX                |  2.40          |  5.40            |
| NFC                              |  1.30          |  3.10            |
| NFC + NFCUX                      |  1.70          |  3.90            |
| FacialCapture                    |  0.23          |  0.72            |
| FacialCapture + FacialCaptureUX  |  0.59          |  1.60            |
| VoiceCapture                     |  0.95          |  2.40            |
| VoiceCapture + VoiceCaptureUX    |  1.70          |  3.90            |
| All SDKs (MiSnap + MiSnapNFC + MiSnapFacialCapture + MiSnapVoiceCapture + MiSnapDeviceKit)                   |  3.50          |  8.40            |
| All SDKs + UXs (MiSnapUX + MiSnapNFCUX + MiSnapFacialCaptureUX + MiSnapVoiceCaptureUX)              |  5.00          |  11.30           |

</center>

Sizes are taken from "App Thinning Size Report.txt" of an Xcode distribution package for the latest iOS version where `compressed` is your app download size increase, and `uncompressed` size is equivalent to the size increase of your app once installed on the device. 

In most cases you should be interested in `compressed` size since this is the size increase to your installable on AppStore that has network limitations depending on the size.

Refer to "Create the App Size Report" section of [this article](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size#Create-the-App-Size-Report) for more details.

- - -

# Devices Tested

<center>

| Device                           | Version      |
| :-----                           | :-----:      |
| iPhone 15 Pro                    | 17.3         |
| iPhone 15 Plus                   | 17.0         |
| iPhone 15                        | 17.3.1       |
|                                  | 17.3         |
|                                  | 17.2         |
| iPhone 14 Pro Max                | 17.3         |
|                                  | 17.2         |
|                                  | 17.0.3       |
| iPhone 14 Pro                    | 17.4         |
| iPhone 14 Plus                   | 16.5.1       |
| iPhone 14                        | 17.3         |
|                                  | 16.7.2       |
| iPhone 13 Pro Max                | 17.3.1       |
|                                  | 17.2.1       |
|                                  | 17.3         |
| iPhone 13                        | 17.3.1       |
|                                  | 17.1.2       |
|                                  | 17.0         |
| iPhone 13 mini                   | 17.3.1       |
|                                  | 16.4.1       |
| iPhone 12 Pro Max                | 16.4         |
| iPhone 12                        | 17.3         |
|                                  | 16.3.1       |
|                                  | 14.1         |
| iPhone 12 mini                   | 17.3         |
|                                  | 14.2         |
| iPhone SE (2nd gen)              | 17.3.1       |
|                                  | 17.3         |
|                                  | 14.0         |
| iPhone 11 Pro                    | 17.3         |
|                                  | 16.0         |
| iPhone 11                        | 17.4         |
|                                  | 15.0         |
| iPhone Xs Max                    | 16.6         |
|                                  | 13.3.1       |
| iPhone Xs                        | 17.2.1       |
| iPhone Xr                        | 17.4         |
| iPhone X                         | 16.7         |
| iPhone 8                         | 16.4.1       |
|                                  | 16.3         |
| iPhone SE (1nd gen)              | 13.5.1       |
| iPhone 7                         | 15.8.1       |
|                                  | 15.7.3       |
| iPad Air (4th gen)               | 17.1.2       |
| iPad Air 2                       | 16.7         |
| iPad Air                         | 17.4         |
| iPad Pro  (12.9-inch) (2nd gen)  | 13.1         |
| iPad (10th gen)                  | 16.1.1       |

</center>

- - -

# Known Issues
* MiSnap
    * Check back sometimes can be erroneously acquired when Check Front document type is invoked
* MiSnapNFC
    * Some iPhone 7 devices fail NFC reading of eDriving License regardless of an iOS version
    * Some iPhone XR devices fail NFC reading of some Italian eIDs
    * An intermitten chip connection loss when both a device and a document are held still on newer iPhone models (iPhone 12 series and newer) running newer version of iOS (iOS 16 or newer) caused by OS and/or hardware issues. Note, a user should be able to successfully finish reading a chip upon a retry
* MiSnapFacialCapture
    * On iPhone 7 and earlier, the hint messages take a few seconds to begin appearing. During this time the message label will be blank
* MiSnapVoiceCapture
    * None
* MiSnapWorkflow:
    * An edge case where UI alignment is occasionally broken when transitioning from a Landscape-only to a Portrait-only view controller when a device is held at an approximately 45 degree angle due to a defect in iOS (pre-iOS 16 versions) where a method notifying that transition is happening isn't called in such cases

- - -

# Frequently Asked Questions (FAQs)
* [Common](Docs/Guides/Common/faq.md)
* [MiSnap](Docs/Guides/MiSnap/faq.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/faq.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/faq.md)
* [MiSnapVoiceCapture](Docs/Guides/MiSnapVoiceCapture/faq.md)

- - -

# Third-Party Licensing Info
* MiSnap (no third-party dependencies)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/3rd_party_licensing_info.md)
* MiSnapFacialCapture (no third-party dependencies)
* MiSnapVoiceCapture (no third-party dependencies)

