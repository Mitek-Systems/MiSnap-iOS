# Migration guide for 5.8.0 and newer versions

The primary focus of MiSnap 5.8.0 is to bring it into conformance to the European Accessibility Act (EAA). This required extensive UI adjustments. While making these changes, our goal was to keep the public API as intact as possible, introducing deprecations only when the existing API could not support EAA compliance.

Note, if you haven't integrated default UX (`MiSnapUX`, `MiSnapFacialCaptureUX`, `MiSnapVoiceCaptureUX`, `MiSnapNFCUX`), i.e. built your own custom UX then:
* it is your responsibility to bring your own UX into conformance to EAA
* you can stop reading this guide

Below are steps to ensure a smooth migration to MiSnap 5.8.0 or newer for customers that have integrated `MiSnapUX`, `MiSnapFacialCaptureUX`, `MiSnapVoiceCaptureUX`, `MiSnapNFCUX`:

1. Localizable files for all UXs (document, face, voice, nfc) have been udpated therefore we recommend using diffing tools (e.g. `opendiff` that comes with Xcode Command Line Tools) to determine which old key-value pairs were removed and which new ones were added. Files can be found [here](../../../Assets).
    * It is safe to delete removed key-value pairs from your project
    * Make sure to add new key-value pairs to your project
        * In case they're not added, users will see `key` instead of a `value` in UI
        * If you decide to update values for newly added keys try to keep wording as consise as possible to make sure there are no layout issues when a user uses Larger Text feature on the biggest setting


If you've created your own tutorials (introductory instruction, timeout, help, review) and passed them to `MiSnapUX`, `MiSnapFacialCaptureUX` through dedicated callbacks instead of customizing default tutorials delivered in MiSnapUX using `.withCustomTutorial`:
* it is your responsibility to bring your own tutorials into conformance to EAA
* you can stop reading this guide at this point

2. Graphic assets for `MiSnapUX`, `MiSnapFacialCaptureUX`, and `MiSnapVoiceCaptureUX` have been updated to use native `UIView`s instead of JPGs or PNGs.

If you would like to use new default graphic assets (recommended option) you simply need to remove all existing MiSnap-related JPG and PNG assets from your project.

If you would like to keep using your own assets, no changes required on your end since default UX will first attempt to use existing JPG/PNG assets and only fall back to newly added `UIView`s if those are not available. The only recommendation here is to convert JPGs to PNGs with a transparent background so that assets can be re-used for both Light and Dark modes.
    
3. Tutorial buttons configurations in all UXs (document, face, voice, nfc) have been modified where old properties were deprecated and replaced with `primary` and `secondary` properties. Also, default primary and secondary colors are now set for both light and dark modes. It means now you'll need to explicitly override for both modes.

We recommend defining your own primary and secondary colors for both modes (if not done so already) and applying them across all SDKs for consistency.

Here's an example for document UX but the same idea applies for migrating all other UXs

Before:
```Swift
.withCustomTutorial { tutorial in
    tutorial.buttons.cancel.color = <your_color_for_cancel_button>
    tutorial.buttons.retry.color = <your_color_for_retry_button>
    tutorial.buttons.proceed.color = <your_color_for_proceed_button>
}
```

After:
```Swift
.withCustomTutorial { tutorial in
    // Primary
    // Light mode
    tutorial.buttons.primary.color = <your_primary_text_color_for_light_mode>
    tutorial.buttons.primary.backgroundColor = <your_primary_background_color_for_light_mode>
    // Dark mode
    tutorial.buttons.primary.colorDarkMode = <your_primary_text_color_for_dark_mode>
    tutorial.buttons.primary.backgroundColorDarkMode = <your_primary_background_color_for_dark_mode>
    
    // Secondary
    // Light mode
    tutorial.buttons.secondary.color = <your_secondary_text_color_for_light_mode>
    tutorial.buttons.secondary.backgroundColor = <your_secondary_background_color_for_light_mode>
    tutorial.buttons.secondary.borderColor = <your_secondary_border_color_for_light_mode>
    // Dark mode
    tutorial.buttons.secondary.colorDarkMode = <your_secondary_text_color_for_dark_mode>
    tutorial.buttons.secondary.backgroundColorDarkMode = <your_secondary_background_color_for_dark_mode>
    tutorial.buttons.secondary.borderColorDarkMode = <your_secondary_border_color_for_dark_mode>
}
```
