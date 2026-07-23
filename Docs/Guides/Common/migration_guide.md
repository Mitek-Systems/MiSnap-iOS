# Migration Guide

Depending on the version you’re upgrading from, you might need to review several sections below.

## Migration guide for 5.12.0 and newer versions
### 1. Update Info.plist and YourAppName.entitlements to add new required entries for specific NFC documents
To enable support for French ID card, add the following entry to `Near Field Communication Tag Reader Session Formats` in YourAppName.entitlements:
* `Password Authenticated Connection Establishment (PACE)`

so that the entire list looks like this:
* `NFC Data Exchange Format (NDEF)`
* `Tag-Specific Data Protocol (TAG)`
* `Password Authenticated Connection Establishment (PACE)`

To enable support for the latest templates of Greek Passport and ID Card add the following entry to `ISO7816 application identifiers for NFC Tag Reader Session` in Info.plist:
* `A000000247`

so that the entire list looks like this:
* `A000000247`
* `A0000002471001`
* `A00000045645444C2D3031`

## Migration guide for 5.10.0 and newer versions

### 1. Accessibility improvements for visually impaired users

Starting with 5.10.0, MiSnap provides enhanced accessibility features when VoiceOver is enabled:
* A new multi-page tutorial is presented to help visually impaired users understand how to capture documents
* Non-unique hints are announced but spaced 5 seconds apart to avoid overwhelming the user
* Some thresholds are made more lenient to improve success rates
* Hints have been updated with clearer wording

These improvements are automatic and require no configuration changes.

### 2. New localizable keys for extended VoiceOver tutorial

The following localizable keys were added to `MiSnapLocalizable.strings`:

| Key | Description |
| :--- | :--- |
| misnap_tutorial_do_not_show_again_extended | Checkbox label for skipping extended instructions |
| misnap_tutorial_continue_extended | Continue button label |
| misnap_tutorial_start_session_extended | Start session button label |
| misnap_tutorial_message_extended_1 | Introduction message |
| misnap_tutorial_message_extended_2 | Lighting instructions |
| misnap_tutorial_message_extended_3 | Document placement instructions |
| misnap_tutorial_message_extended_4 | Device positioning instructions |
| misnap_tutorial_message_extended_5 | Session start instructions |
| misnap_tutorial_message_extended_6 | Distance adjustment instructions |
| misnap_tutorial_message_extended_7 | Troubleshooting instructions |

### 3. Updated hint messages

Several hint message values were updated for clarity. If you have customized these values, review and update as needed:

| MiSnapLocalizable |
| Key | Old value | New value |
| :--- | :--- | :--- |
| misnap_status_too_much_glare | Glare detected | Too much glare on document |
| misnap_status_mrz_obstructed | Bottom text should be visible | Bottom text lines should be visible |
| misnap_status_low_contrast | Not enough contrast | Background not dark enough |
| misnap_status_document_not_found | Not enough contrast | Document not found yet |
| misnap_status_document_not_found_mrz | Bottom text should be visible | Bottom text lines should be visible |
| misnap_status_too_rotated | Document not aligned | Angle too large |
| misnap_status_too_skewed | Document not aligned | Angle too large |
| misnap_status_too_bright | Too bright | Too much light |
| misnap_status_wrong_aspect_ratio | Background too busy | Document not found yet |

### 4. New `skipDefaultTutorial()` API for selective custom tutorials

Starting with 5.10.0, integrators can now selectively override individual tutorial screens while keeping default behavior for others. A new public API `skipDefaultTutorial()` was added to `MiSnapViewController`.

Previously, to use custom tutorials, integrators had to override `useCustomTutorials` to `true` and implement all four tutorial screens (instruction, help, timeout, review). Now, integrators can:
* Implement `miSnapCustomTutorial(_:tutorialMode:mode:statuses:image:)` callback
* Call `skipDefaultTutorial()` only for specific tutorial modes they want to customize
* Let default tutorials be presented for other modes

Note: Existing implementations using `useCustomTutorials = true` are not impacted. For detailed usage examples, see the [Customization Guide](../MiSnap/customization_guide.md#tutorial-callbacks).

## Migration guide for 5.9.0 and newer versions

1. Sharpness algorithm for `.idFront`, `.idBack`, `.passport`, and `.any` document types was updated to reduce a number of visually blurry images with a high sharpness score. As a result, a new sharpness threshold was set. If you've manually modified the default sharpness threshold, you must validate and adjust it to ensure optimal performance. For best results and ongoing compatibility, we strongly recommend reverting to the default threshold, which is optimized for the latest improvements.

2. Several new localizable keys were added to respective SDKs

| MiSnapLocalizable |
| :--- |
| misnap_tutorial_tip |
| misnap_tutorial_tips |
| misnap_tutorial_timeout_header |
| misnap_tutorial_review_check |
| misnap_tutorial_review_document |

| MiSnapFacialCaptureLocalizable |
| :--- |
| misnap_facial_capture_ux_tutorial_review_voiceover_2 |
| misnap_facial_capture_ux_tutorial_tip |
| misnap_facial_capture_ux_tutorial_tips |

| MiSnapNFCLocalizable |
| :--- |
| misnap_nfc_sdk_error_session_invalidated |

3. To better guide users, one default value changed in MiSnapNFCLocalizable

| Key | Old value | New value |
| :--- | :--- | :--- |
| misnap_nfc_sdk_error_system_resource_unavailable | Sorry, there was a system error.\nPlease reboot your device and re-start the flow | Sorry, there was a system error.\nPlease wait 20 seconds then retry.\nReboot your device if error persist. |

## Migration guide for 5.8.0 and newer versions

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
