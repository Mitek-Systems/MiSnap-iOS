# Integration Guide

:warning: MiSnapFacialCapture 5.x has breaking API changes therefore to migrate from 3.x series, remove all old MiSnapFacialCapture references from your project.

[MiSnapFacialCaptureSampleApp](../../../Examples/Apps/MiSnapFacialCapture/MiSnapFacialCaptureSampleApp) was created by following steps below. Please refer to this project as a working example.

## 1. Obtain the SDK(s)
MiSnapFacialCapture 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

It's highly recommended to use one of these distribution managers but manual integration is still supported.

### SDK and UX/UI
It is Mitek's recommended option to integrated both SDK and UX/UI which is highly customizable.

From 5.2.0 onwards localization and image assets are moved out of `MiSnapFacialCaptureUX` framework to enable easy customization while making sure app size is not ballooned. As such, regardless of your choise of integration (CocoaPods, Swift Package Manager, manual) the first step should be adding assets to your Xcode project. Here's how to do this:
* Copy `MiSnapFacialCapture` folder from [here](../../../Assets) into your project's location
* In Xcode, File > Add Files to "YourAppName"...
* Select copied folder and make sure:
    * `Create groups` option is selected in `Added folders` section
    * All necessary targets are checked in `Add to targets` section

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapFacialCapture'
pod 'MiSnapFacialCaptureUX'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapFacialCapture` and `MiSnapFacialCaptureUX` checkboxes in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapCore.xcframework
* MiSnapAssetManager.xcframework

From [MiSnapFacialCapture](../../../SDKs/MiSnapFacialCapture) copy:
* MiSnapFacialCapture.xcframework
* MiSnapFacialCaptureUX.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

### SDK only

If you plan only using SDK and building your own UX/UI:

:warning: Use this [starter custom view controller](../../../Examples/Snippets/MiSnapFacialCapture/CustomFacialCaptureViewController.swift) to make sure all components are integrated the right way.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapFacialCapture'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapFacialCapture` checkbox in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnaCore.xcframework

From [MiSnapFacialCapture](../../../SDKs/MiSnapFacialCapture) copy:
* MiSnapFacialCapture.xcframework

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

## 4. Setup and launch MiSnapFacialCaptureViewController (optional)

When both `MiSnapFacialCapture` and `MiSnapFacialCaptureUX` are integrated:

4.1. Add necessary imports
```Swift
import MiSnapCore
import MiSnapFacialCapture
import MiSnapFacialCaptureUX
```
4.2. Configure and present MiSnapFacialCaptureViewController:
```Swift
let configuration = MiSnapFacialCaptureConfiguration()
misnapFacialCaptureVC = MiSnapFacialCaptureViewController(with: configuration, delegate: self)
// Present view controller here
```
where,

`configuration` is a configuration for a default UX/UI. If you'd like to customize it, refer to [MiSnapFacialCapture Customization Guide](customization_guide.md).

4.3. Implement required callbacks to conform to `MiSnapFacialCaptureViewControllerDelegate`

```Swift
// Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
func miSnapFacialCaptureLicenseStatus(_ status: MiSnapLicenseStatus) {
    // Handle a license status here
}

func miSnapFacialCaptureSuccess(_ result: MiSnapFacialCaptureResult) {
    // Handle successful session results here
}

func miSnapFacialCaptureCancelled(_ result: MiSnapFacialCaptureResult) {
    // Handle cancelled session results here 
}
```
Implement the following optional callback if `recordVideo` of `MiSnapFacialCaptureCameraParameters` is overridden to `true`:
```Swift
func miSnapFacialCaptureDidFinishRecordingVideo(_ videoData: Data?) {
    // Handle recorded video data here
}
```
Note, if `autoDismiss` of `MiSnapFacialCaptureUXParameters` is overridden to `false`, a parent view controller that presented `MiSnapFacialCaptureViewController` is responsible for dismissing it. Implement the following optional callback to achive this:
```Swift
func miSnapFacialCaptureShouldBeDismissed() {
    // Dismiss MiSnapFacialCaptureViewController here
}
```
