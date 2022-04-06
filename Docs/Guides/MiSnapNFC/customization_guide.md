# Customization Guide

:warning: This guide is only applicable if you've integrated `MiSnapNFCUX`. Use this [starter custom view controller](../../../Examples/Snippets/MiSnapNFC/CustomNFCViewController.swift) when building your own UX/UI.

## Table of Contents
* [Overview](#overview)
* [UX Parameters](#ux-parameters)
* [Localization](#localization)

# Overview

Only UX parameters customization is available.

Create a configuration and make all necessary customizations then pass it to a `MiSnapNFCViewController`.

Example below demonstrates this concept on a high level. 

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomUxObject... { uxObject in
        // uxObject customization here
    }
    .withCustomUxObjectN... { uxObjectN in
        // uxObjectN customization here
    }

nfc = MiSnapNFCViewController(with: configuration, delegate: self)
```

# UX Parameters
Create a configuration (if it doesn't exist) and chain `.withCustomUxParameters`. Refer to a snippet below.

```Swift
let configuration = MiSnapNFCConfiguration()
    .withCustomUxParameters { uxParameters in
        uxParameters.timeout = 25.0
        // Other UX Parameters customizations
    }
```

For all available UX Parameters customization options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnapNFC/MiSnapNFCUX/Classes/MiSnapNFCUxParameters.html).

# Localization

Copy localization key-value pairs for a given language from [Localization](../../../Localization/MiSnapNFC) `(TODO)` folder and paste them into your Localizable.strings file.

Create a template configuration (if it doesn't exist) and chain `.withCustomLocalization`. Refer to a snippet below.

```Swift
let template = MiSnapNFCConfiguration()
    .withCustomLocalization { localization in
        localization.bundle = // Your bundle where localization files are located
        localization.stringsName = // Your localization file name
    }
```




