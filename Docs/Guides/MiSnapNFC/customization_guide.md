# Customization Guide

:warning: This guide is only applicable if you've integrated `MiSnapNFCUX`. Use this [starter custom view controller](../../../Examples/Snippets/MiSnapNFC/CustomNFCViewController.swift) when building your own UX/UI.

Please refer to [MiSnapNFCCustomizationSampleApp](../../../Examples/Apps/MiSnapNFC/MiSnapNFCCustomizationSampleApp) as a working customization example.

## Table of Contents
* [Overview](#overview)
* [UX Parameters](#ux-parameters)
* [Localization](#localization)
* [Image assets](#image-assets)
* [Parameters](#parameters)
    * [Optional Data Redaction](#optional-data-redaction)
    * [Skip Portrait](#skip-portrait)

# Overview

Create a configuration and make all necessary customizations then pass it to a `MiSnapNFCViewController`.

Example below demonstrates this concept on a high level. 

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomUxObject... { uxObject in
        // uxObject customization here
    }
    .withCustomParameters { parameters in
        // Parameters customization here
    }

nfc = MiSnapNFCViewController(with: configuration, delegate: self)
```

# UX Parameters
Create a configuration (if it doesn't exist) and chain `.withCustomUxParameters`. Refer to a snippet below.

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.autoDismiss = false
        // Other UX Parameters customizations
    }
```

For all available UX Parameters customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnapNFC/MiSnapNFCUX/Classes/MiSnapNFCUxParameters.html).

# Localization

Go to a localizable strings file that was added to your project during integration process and adjust values for a desired language as needed.

By default, it's expected that localizable files are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps: 

Create a configuration (if it doesn't exist) and chain `.withCustomLocalization`. Refer to a snippet below.

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomLocalization { localization in
        localization.bundle = // Your bundle where localization files are located
    }
```

By default, it's aslo expected that localizable file name is `MiSnapNFCLocalizable` but if you changed its name or moved localization key-pairs to your own localizable file then you can specify a new file name by following next steps:

Create a configuration (if it doesn't exist) and chain `.withCustomLocalization` (if it doesn't exist). Refer to a snippet below.

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomLocalization { localization in
        localization.stringsName = // Your localization file name
    }
```

# Image Assets

Go to a place where you copied images into during integration process and replace existing resources with new ones but make sure to keep the same names.

By default, it's expected that images are located in the main bundle (`Bundle.main`) but if you need to change a bundle you can do it by following next steps:

Create a configuration (if it doesn't exist) and chain `.withCustomAssetLocation`. Refer to a snippet below.

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomAssetLocation { assetLocation in
        assetLocation.bundle = // Your bundle where image assets are located
    }
```

# Parameters
## Optional Data Redaction
Create a configuration (if it doesn't exist) and chain `.withCustomParameters`. Refer to a snippet below:

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomParameters { parameters in
        parameters.optionalDataRedactionEnabled = true
        // Other Parameters customizations
    }
```

## Skip Portrait

Starting with 5.6.0 it's possible to skip reading portrait image from NFC chip when your use case doesn't require it. This has two benefits:
* much faster reading time
* significantly reduced probability of intermittent connection loss issue due to iOS (operating system) defect when reading NLD documents

To enable this feature chain the following snippet to your configuration:
```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomParameters { parameters in
        parameters.skipPortrait = true
        // Other Parameters customizations
    }
```

Note, we do not recommend combining this feature with document MRZ only feature (see [here](../MiSnap/customization_guide.md#mrz-only)) since it might result in lower acceptance rate due to a potentially bad quality image being used for face comparison instead of a skipped portait image on a chip.



