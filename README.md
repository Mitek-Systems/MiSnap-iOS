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

| Component               | Size, MB                          |
| :---------------------- | :-------------------------------: |
| MiSnap                  |  TODO                             |
| MiSnapUX                |  TODO                             |
| NFC                     |  TODO                             |
| NFCUX                   |  TODO                             |
| FacialCapture           |  TODO                             |
| FacialCaptureUX         |  TODO                             |

</center>
Sizes are taken from "App Thinning Size Report.txt" of an Xcode distribution package for the latest iOS version for compressed size which is the download size of the app on AppStore.

Refer to "Create the App Size Report" section of [this article](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size#Create-the-App-Size-Report) for more details.

- - -

# Devices Tested

<center>

| Device                        | Version |
| :-----:                       | :-----: |
| iPhone 12                     |         |
| iPhone 12 mini                |         |
| iPhone 12 Pro Max             |         |
| iPhone 11                     |         |
| iPhone Xs Max                 |         |
| iPhone 8                      |         |
| iPhone 7                      |         |
| iPhone 6s Plus                |         |
| iPhone SE (2nd generation)    |         |
| iPad Air                      |         |
| iPad mini (5th generation)    |         |
| iPad Pro 2                    |         |

</center>

- - -

# Known Issues

- - -

# Frequently Asked Questions (FAQs)
