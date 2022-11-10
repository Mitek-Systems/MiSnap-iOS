# Integration Guide

[MiSnapVoiceCaptureSampleApp](../../../Examples/Apps/MiSnapVoiceCapture/MiSnapVoiceCaptureSampleApp) was created by following steps below. Please refer to this project as a working example.

## 1. Obtain the SDK(s)
MiSnapVoiceCapture 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

It's highly recommended to use one of these distribution managers but manual integration is still supported.

### SDK and UX/UI
It is Mitek's recommended option to integrated both SDK and UX/UI which is highly customizable.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapVoiceCapture'
pod 'MiSnapVoiceCaptureUX'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapVoiceCapture` and `MiSnapVoiceCaptureUX` checkboxes in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapLicenseManager.xcframework
* MiSnapMibiData.xcframework
* MiSnapAssetManager.xcframework

From [MiSnapVoiceCapture](../../../SDKs/MiSnapVoiceCapture) copy:
* MiSnapVoiceCapture.xcframework
* MiSnapVoiceCaptureUX.xcframework
* VoiceSdk.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

### SDK only

If you plan only using SDK and building your own UX/UI:

:warning: Use this [starter custom view controller](../../../Examples/Snippets/MiSnapVoiceCapture/CustomVoiceCaptureViewController.swift) to make sure all components are integrated the right way.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapVoiceCapture'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapVoiceCapture` checkbox in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapLicenseManager.xcframework
* MiSnapMibiData.xcframework

From [MiSnapVoiceCapture](../../../SDKs/MiSnapVoiceCapture) copy:
* MiSnapVoiceCapture.xcframework
* VoiceSdk.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

## 2. Add license key to your project

In your project's `AppDelegate`:

2.1. Import licensing SDK:
```Swift
import MiSnapLicenseManager
```
2.2. Set the license key in `application(_ :, didFinishLaunchingWithOptions:)`

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    MiSnapLicenseManager.shared().setLicenseKey("your-license-key-here")
    return true
}
```

## 3. Add required keys to your project's Info.plist

3.1. `Privacy - Microphone Usage Description` with a reasonable description on why your app needs access to a microphone.

## 4. Setup and launch MiSnapVoiceCaptureViewController (optional)

When both `MiSnapVoiceCapture` and `MiSnapVoiceCaptureUX` are integrated:

4.1. Add necessary imports
```Swift
import MiSnapVoiceCaptureUX
import MiSnapVoiceCapture
import MiSnapLicenseManager
```
4.2. Configure and present MiSnapVoiceCaptureViewController for Enrollment or Verification

4.2.1. Configure for Enrollment

4.2.1.1. Allowing an end user to choose an enrollment phrase from a list (recommended)
```Swift
let configuration = MiSnapVoiceCaptureConfiguration(for: .enrollment)
misnapVoiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
// Present view controller here
```
where,

`configuration` is a configuration for a default UX/UI. If you'd like to customize it, refer to [MiSnapVoiceCapture Customization Guide](customization_guide.md).

4.2.1.2. Using a predetermined phrase (not recommended)

```Swift
let configuration = MiSnapVoiceCaptureConfiguration(for: .enrollment, phrase: phrase)
misnapVoiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
// Present view controller here
```
where,

`configuration` is a configuration for a default UX/UI. If you'd like to customize it, refer to [MiSnapVoiceCapture Customization Guide](customization_guide.md).

`phrase` is a hardcoded phrase that should be used for Enrollment

4.2.2. Configure for Verification with an enrollment phrase

```Swift
let configuration = MiSnapVoiceCaptureConfiguration(for: .verification, phrase: phrase)
misnapVoiceCaptureVC = MiSnapVoiceCaptureViewController(with: configuration, delegate: self)
// Present view controller here
```
where,

`configuration` is a configuration for a default UX/UI. If you'd like to customize it, refer to [MiSnapVoiceCapture Customization Guide](customization_guide.md).

`phrase` is the exact phrase used for Enrollment

:warning: a `phrase` is required for `verification` flow. A `miSnapVoiceCaptureError(_:)` callback is returned if it's not provided.

4.3. Implement required callbacks to conform to `MiSnapVoiceCaptureViewControllerDelegate`

```Swift
// Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
func miSnapVoiceCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
    // Handle a license status here
}

func miSnapVoiceCaptureDidSelectPhrase(_ phrase: String) {
    /*
    Handle a phrase selected by a user in an Enrollment flow.
    
    It's highly recommended not only store the phrase in UserDefaults but also in a database on a server side to be able to retrieve it if a user switches a device or re-installs the app.
    
    For security purposes you might even cosider storing the phrase on a server side only and retrieve it for each verification.
    
    Note, this exact phrase will need to be passed in a configuration for a Verification flow.
    */
}

func miSnapVoiceCaptureSuccess(_ results: [MiSnapVoiceCaptureResult], for type: MiSnapVoiceCaptureActivity) {
    // Handle successful session results here for a configured activity type (Enrollment, Verification)
    // For Enrollment, `results` will always contain 3 `MiSnapVoiceCaptureResult`s
    // For Verification, `results` will always contain 1 `MiSnapVoiceCaptureResult`
}

func miSnapVoiceCaptureCancelled(_ result: MiSnapVoiceCaptureResult) {
    // Handle cancelled session results here 
}

func miSnapVoiceCaptureError(_ result: MiSnapVoiceCaptureResult) {
    // Handle an SDK error here 
}
```
Note, if `autoDismiss` of `MiSnapVoiceCaptureUXParameters` is overridden to `false`, a parent view controller that presented `MiSnapVoiceCaptureViewController` is responsible for dismissing it. Implement the following optional callback to achive this:
```Swift
func miSnapVoiceCaptureShouldBeDismissed() {
    // Dismiss MiSnapVoiceCaptureViewController here
}
```
