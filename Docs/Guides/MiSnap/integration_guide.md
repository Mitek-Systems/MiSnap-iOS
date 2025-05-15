# Integration Guide

:warning: MiSnap 5.x has breaking API changes therefore to migrate from 3.x and 4.x series, remove all old MiSnap references from your project.

[MiSnapSampleApp](../../../Examples/Apps/MiSnap/MiSnapSampleApp) was created by following steps below. Please refer to this project as a working example.

## 1. Obtain the SDK(s)
MiSnap 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

It's highly recommended to use one of these distribution managers but manual integration is still supported.

## 1.1 SDK and UX/UI
It is Mitek's recommended option to integrate both SDK and UX/UI which is highly customizable. Customization was drastically improved comparing to 3.x and 4.x. 

If you'd like to build your own custom UI/UX (not recommended) skip to [1.2](#12-sdk-only).

### Localization files

Regardless of your choise of integration (CocoaPods, Swift Package Manager, manual) the first step should be adding localization files to your Xcode project. Here's how to do this:
* Copy `MiSnap` folder from [here](../../../Assets) into your project's location
* In Xcode, File > Add Files to "YourAppName"...
* Select copied folder and make sure:
    * `Create groups` option is selected in `Added folders` section
    * All necessary targets are checked in `Add to targets` section

### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnap` and `MiSnapUX` checkboxes in a list of Package Products.

### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnap'
pod 'MiSnapUX'
```

### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapCore.xcframework
* MiSnapAssetManager.xcframework

From [MiSnap](../../../SDKs/MiSnap) copy:
* MiSnap.xcframework
* MiSnapBarcodeScanner.xcframework
* MiSnapCamera.xcframework
* MiSnapScience.xcframework
* MobileFlow.xcframework
* MiSnapUX.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

## 1.2. SDK only

Skip to [the next step](#2-add-license-key-to-your-project) if you've followed steps in 1.1.

If you plan only using SDK and building your own UX/UI:

:warning: Use this [starter custom view controller](../../../Examples/Snippets/MiSnap/CustomViewController.swift) to make sure all components are integrated the right way.

### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnap` checkbox in a list of Package Products.

### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnap'
```

### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapCore.xcframework

From [MiSnap](../../../SDKs/MiSnap) copy:
* MiSnap.xcframework
* MiSnapBarcodeScanner.xcframework
* MiSnapCamera.xcframework
* MiSnapScience.xcframework
* MobileFlow.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

## 2. Add license key to your project

In your project's `AppDelegate`:

2.1. Import core SDK:
```Swift
import MiSnapCore
```
2.2. Set the license key in `application(_ :, didFinishLaunchingWithOptions:)`

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    MiSnapLicenseManager.shared.setLicenseKey("your_license_key_here")
    return true
}
```

## 3. Add required keys to your project's Info.plist

3.1. `Privacy - Camera Usage Description` with a reasonable description on why your app needs access to a camera.

3.2. `Privacy - Microphone Usage Description` with a reasonable description on why your app needs access to a microphone, in case a video recording with audio is required.

## 4. Setup and launch MiSnapViewController (optional)

When both `MiSnap` and `MiSnapUX` are integrated:

4.1. Add necessary imports
```Swift
import MiSnapCore
import MiSnap
import MiSnapUX
```
4.2. Configure and present MiSnapViewController:
```Swift
let configuration = MiSnapConfiguration(for: documentType)
misnapVC = MiSnapViewController(with: configuration, delegate: self)
// Present view controller here
```
where,

`documentType` is of `MiSnapScienceDocumentType` type. Refer to [MiSnap API doc](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnap/MiSnap/Enums/MiSnapScienceDocumentType.html) for all available options.

`configuration` is a configuration for a default UX/UI. If you'd like to customize it, refer to [MiSnap Customization Guide](customization_guide.md).

4.3. Implement required callbacks to conform to `MiSnapViewControllerDelegate`

```Swift
// Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
func miSnapLicenseStatus(_ status: MiSnapLicenseStatus) {
    // Handle a license status here
}

func miSnapSuccess(_ result: MiSnapResult) {
    // Handle successful session results here
}

func miSnapCancelled(_ result: MiSnapResult) {
    // Handle cancelled session results here 
}

func miSnapException(_ exception: NSException) {
    // Handle exception that was caught by the SDK here
}
```
Implement the following optional callback if `recordVideo` of `MiSnapCameraParameters` is overridden to `true`:
```Swift
func miSnapDidFinishRecordingVideo(_ videoData: Data?) {
    // Handle recorded video data here
}
```
Note, if `autoDismiss` of `MiSnapUXParameters` is overridden to `false`, a parent view controller that presented `MiSnapViewController` is responsible for dismissing it. Implement the following optional callback to achieve this:
```Swift
func miSnapShouldBeDismissed() {
    // Dismiss MiSnapViewController here
}
```