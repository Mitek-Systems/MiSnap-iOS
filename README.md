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
* [SDKs Sizes](#sdks-sizes)
* [Devices Tested](#devices-tested)
* [Known Issues](#known-issues)
* [Frequently Asked Questions (FAQs)](#frequently-asked-questions-faqs)
* [Third-Party Licensing Info](#third-party-licensing-info)

- - -

# Release Notes

See [here](https://github.com/Mitek-Systems/MiSnap-iOS/releases)

- - -

# System Requirements

<center>

| Technology | Min version |
| :--- | :---: |
| Xcode | 13.0 |
| iOS | 11.0 |
| iPhone | 6 |
| iPad | mini (4th generation) |

</center>
Min OS/device combination offers coverage level of 99.89%.

__Note__, `On-Device Classification (ODC)` feature is only available on devices running iOS 13.0 or newer and powered by A11 or newer chip (iPhone 8 or newer, iPad Mini 5th generation or newer) which offers coverage level of 92.68%.

__Note__, for `MiSnapNFC SDK` functionality, supported devices are all iPhone 7 and newer that support iOS 13.0 and above.

- - -

# License Key

All iOS SDKs (MiSnap, MiSnapFacialCapture, MiSnapNFC) require a license key.

Supported formats:
* Specific bundle id (e.g. `com.company.AppName`) will be valid for this specific application only
* Wildcard identifiers (e.g. `com.company.*`) will be valid for all applications which bundle ids start with "com.company"
* Multiple identifiers (e.g. `com.company.AppName1, com.company.AppName2` or `com.company.*, com.anotherCompany.*`) will be valid for applications with specified bundle ids and wild card identifiers.

To obtain a license key, contact support@miteksystems.com and provide your application(s) bundle identifier(s).

Refer to [Integration Guides](#integration-guides) for setting the license key in your application.

- - -

# Integration Guides

* [MiSnap](Docs/Guides/MiSnap/integration_guide.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/integration_guide.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/integration_guide.md)

- - -

# Customization Guides

* [MiSnap](Docs/Guides/MiSnap/customization_guide.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/customization_guide.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/customization_guide.md)

- - -

# SDKs Sizes

<center>

| Component                        | Compressed, MB | Uncompressed, MB |
| :------------------------------- | :------------: | :--------------: |
| MiSnap                           |  1.20          |  3.10            |
| MiSnap + MiSnapUX                |  1.90          |  4.40            |
| NFC                              |  0.41          |  1.10            |
| NFC + NFCUX                      |  0.68          |  1.50            |
| FacialCapture                    |  0.13          |  0.47            |
| FacialCapture + FacialCaptureUX  |  0.44          |  1.20            |

</center>

Sizes are taken from "App Thinning Size Report.txt" of an Xcode distribution package for the latest iOS version where `compressed` is your app download size increase, and `uncompressed` size is equivalent to the size increase of your app once installed on the device. 

In most cases you should be interested in `compressed` size since this is the size increase to your installable on AppStore that has network limitations depending on the size.

Refer to "Create the App Size Report" section of [this article](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size#Create-the-App-Size-Report) for more details.

- - -

# Devices Tested

<center>

| Device                        | Version      |
| :-----:                       | :-----:      |
| iPhone 13 Pro Max             | 15.5         |
|                               | 15.0.2       |
| iPhone 13                     | 16 beta 2    |
| iPhone 13 Mini                | 15.0         |
| iPhone 12 Pro Max             | 14.7.1       |
| iPhone 12                     | 15.5         |
|                               | 14.1         |
| iPhone 12 Mini                | 14.2         |
| iPhone 11 Pro                 | 15.5         |
|                               | 15.2         |
|                               | 13.5.1       |
| iPhone 11                     | 15.5         |
|                               | 15.0         |
| iPhone Xs Max                 | 13.3.1       |
| iPhone Xs                     | 15.5         |
| iPhone Xr                     | 15.5         |
| iPhone X                      | 15.5         |
| iPhone 8 Plus                 | 15.5         |
| iPhone 8                      | 15.5         |
|                               | 13.1.3       |
| iPhone 7 Plus                 | 15.5         |
|                               | 15.0.1       |
| iPhone 7                      | 15.4.1       |
|                               | 15.3         |
|                               | 15.0         |
|                               | 14.4         |
|                               | 13.1.1       |
| iPhone 6s Plus                | 15.5         |
|                               | 11.4.1       |
| iPhone 6s                     | 15.5         |
|                               | 15.0.1       |
| iPhone SE (2nd gen)           | 15.5         |
|                               | 14.8         |
|                               | 14.0         |
| iPhone SE (1st gen)           | 15.5         |
|                               | 13.5.1       |
| iPhone 5s                     | 12.5.5       |
| iPhone 5c                     | 10.3.3       |
| iPad Pro (2nd gen)            | 13.1         |
| iPad Pro                      | 12.3         |
| iPad mini 3                   | 12.4.3       |
| iPad Air                      | 10.2.1       |

</center>

- - -

# Known Issues
* MiSnap
    * Check back sometimes can be erroneously acquired when Check Front document type is invoked
* MiSnapNFC
    * Some iPhone 7 devices fail NFC reading of eDriving License regardless of an iOS version
* MiSnapFacialCapture
    * On iPhone 7 and earlier, the hint messages take a few seconds to begin appearing. During this time the message label will be blank

- - -

# Frequently Asked Questions (FAQs)
* [MiSnap](Docs/Guides/MiSnap/faq.md)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/faq.md)
* [MiSnapFacialCapture](Docs/Guides/MiSnapFacialCapture/faq.md)

- - -

# Third-Party Licensing Info
* MiSnap (no third-party dependencies)
* [MiSnapNFC](Docs/Guides/MiSnapNFC/3rd_party_licensing_info.md)
* MiSnapFacialCapture (no third-party dependencies)

