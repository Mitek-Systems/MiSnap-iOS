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
* [Migration Guide](#migration-guide)
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
| iOS | 12.0 * |
| iPhone | 6 |
| iPad | mini (4th generation) |

</center>

`*` when AI based RTS feature is enabled min iOS version is 13.0

Min OS/device combination offers coverage level of 99.9996% as of Q2 2026.

__Note__, `On-Device Classification (ODC)` `beta` feature is only available on devices running iOS 13.0 or newer and powered by A11 or newer chip (iPhone 8 or newer, iPad Mini 5th generation or newer) which offers coverage level of 99.4% as of Q2 2026. `Any ID` document type heavily relies on this feature therefore its support has the same constraints.

__Note__, for `MiSnapNFC` functionality, supported devices are all iPhone 7 and newer that support iOS 13.0 and above.

- - -

# License Key

All iOS SDKs (MiSnap, MiSnapFacialCapture, MiSnapNFC) require a license key.

Supported formats:
* Specific bundle id (e.g. `com.company.AppName`) will be valid for this specific application only
* Wildcard identifiers (e.g. `com.company.*`) will be valid for all applications which bundle ids start with "com.company"
* Multiple identifiers (e.g. `com.company.AppName1, com.company.AppName2` or `com.company.*, com.anotherCompany.*`) will be valid for applications with specified bundle ids and wild card identifiers.

To obtain a license key, please contact your Mitek Solutions Provider or select the "Contact Support" icon from the https://mitek.service-now.com/csm splash page.

Refer to [Integration Guides](#integration-guides) for setting the license key in your application.

:warning: Avoid hard-coding the license in your application. Instead, fetch it from your application server before invoking the SDK. This will allow you to easily switch the license in the future without requiring you to roll out a new version of your app.

- - -

# Integration Guides

* [MiSnap](Docs/Guides/MiSnap/integration_guide.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/integration_guide.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/integration_guide.md)
* [MiSnapVoiceCapture](Docs/Guides/MiSnapVoiceCapture/integration_guide.md)

For integration examples, see [MiSnapSampleApp](Examples/Apps/MiSnapSampleApp).

- - -

# Migration Guide

Use [this migration guide](Docs/Guides/Common/migration_guide.md) when upgrading from the earlier versions.

Use [Swift 6.x migration guide](Docs/Guides/Common/migration_guide_swift_6.x.md) when migrating from Swift 5.x.

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
| MiSnap                           |  1.77          |  4.38            |
| MiSnap + MiSnapUX                |  2.17          |  5.78            |
| NFC                              |  1.87          |  4.78            |
| NFC + NFCUX                      |  2.47          |  6.18            |
| FacialCapture                    |  0.23          |  0.70            |
| FacialCapture + FacialCaptureUX  |  0.66          |  2.08            |
| VoiceCapture                     |  0.92          |  2.28            |
| VoiceCapture + VoiceCaptureUX    |  1.37          |  3.58            |
| All SDKs (MiSnap + MiSnapNFC + MiSnapFacialCapture + MiSnapVoiceCapture)                   |  4.37          |  10.98           |
| All SDKs + UXs (MiSnapUX + MiSnapNFCUX + MiSnapFacialCaptureUX + MiSnapVoiceCaptureUX)              |  5.37          |  13.58           |
| MiSnapIAD + IADCommon (optional)    |  0.68          |  1.98            |
</center>

Sizes are taken from "App Thinning Size Report.txt" of an Xcode distribution package for the latest iOS version where `compressed` is your app download size increase, and `uncompressed` size is equivalent to the size increase of your app once installed on the device. 

In most cases you should be interested in `compressed` size since this is the size increase to your installable on AppStore that has network limitations depending on the size.

Refer to "Create the App Size Report" section of [this article](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size#Create-the-App-Size-Report) for more details.

- - -

# Devices Tested

<center>

| Device                           | Version      |
| :-----                           | :-----:      |
| iPhone 18 Pro                    | 27.0.1       |
| iPhone 17 Pro Max                | 27.0.1       |
|                                  | 27.0         |
|                                  | 26.6.2       |
| iPhone 17 Pro                    | 27.2         |
|                                  | 27.0.1       |
|                                  | 26.6.2       |
| iPhone 17 Air                    | 26.0         |
| iPhone 17                        | 26.7.1       |
|                                  | 26.0         |
| iPhone 17e                       | 26.4         |
| iPhone 16 Pro Max                | 27.2         |
|                                  | 27.0.1       |
|                                  | 26.6         |
| iPhone 16 Pro                    | 27.0         |
|                                  | 26.6.2       |
| iPhone 16 Plus                   | 27.2         |
|                                  | 27.0.1       |
|                                  | 27.0         |
| iPhone 16                        | 27.2         |
|                                  | 26.6.2       |
|                                  | 18.2.1       |
| iPhone 16e                       | 26.6.1       |
|                                  | 26.6         |
|                                  | 26.5         |
|                                  | 18.3         |
| iPhone 15 Pro Max                | 27.0         |
|                                  | 26.7.1       |
|                                  | 26.5.2       |
| iPhone 15 Pro                    | 27.0.1       |
|                                  | 27.0         |
|                                  | 26.5         |
|                                  | 26.3.1       |
| iPhone 15 Plus                   | 17.5.1       |
| iPhone 15                        | 27.0.1       |
|                                  | 27.0         |
|                                  | 26.6.2       |
| iPhone 14 Pro Max                | 17.0.3       |
| iPhone 14 Pro                    | 27.0.1       |
|                                  | 27.0         |
|                                  | 18.7.8       |
| iPhone 14 Plus                   | 27.0.1       |
|                                  | 26.7.1       |
| iPhone 14                        | 27.2         |
|                                  | 27.0.1       |
|                                  | 26.6.2       |
|                                  | 18.5         |
| iPhone 13 Pro Max                | 27.2         |
|                                  | 18.7.8       |
| iPhone 13 Pro                    | 27.0.1       |
| iPhone 13                        | 27.0.1       |
|                                  | 26.6.2       |
|                                  | 26.6.1       |
|                                  | 26.5.2       |
|                                  | 26.3.1       |
|                                  | 26.2.1       |
| iPhone 13 mini                   | 27.0.1       |
|                                  | 27.0         |
| iPhone 12 Pro Max                | 18.3.2       |
|                                  | 26.6.2       |
|                                  | 16.4         |
| iPhone 12 mini                   | 26.2         |
|                                  | 26.5         |
|                                  | 26.6.2       |
| iPhone 12                        | 26.7         |
|                                  | 26.7.1       |
|                                  | 27.0.1       |
| iPhone 11 Pro                    | 27.0.1       |
|                                  | 16.0         |
| iPhone 11                        | 27.2         |
|                                  | 18.7.8       |
| iPhone X                         | 16.7.16      |
| iPhone XR                        | 18.7.10      |
|                                  | 16.3.1       |
| iPhone XS                        | 18.7.9       |
| iPhone 8                         | 16.7.16      |
| iPhone 7                         | 15.7.3       |
| iPhone 6s                        | 15.8.8       |
| iPhone SE (3rd gen)              | 18.7.8       |
|                                  | 17.1.1       |
| iPhone SE (2nd gen)              | 18.6.1       |
| iPhone SE (1st gen)              | 15.8.5       |
| iPad Air (4th gen)               | 27.0         |
| iPad Air (11th gen)              | 18.5         |
| iPad Pro (2nd gen)               | 26.1         |
| iPad (5th gen)                   | 16.7.16      |
| iPad (7th gen)                   | 18.7.9       |

</center>

- - -

# Known Issues
* MiSnap
    * Check back sometimes can be erroneously acquired when Check Front document type is invoked
* MiSnapNFC
    * Some iPhone 7 devices fail NFC reading of eDriving License regardless of an iOS version
    * Some iPhone XR devices fail NFC reading of some Italian eIDs
    * An intermitten chip connection loss when both a device and a document are held still on newer iPhone models (iPhone 11 series and newer) running newer versions of iOS (iOS 16 or newer) when reading NLD documents caused by iOS (operating system) issue. Note, a user should be able to successfully finish reading a chip upon one or multiple retries.
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

