# Integration Guide

:warning: MiSnapFacialCapture 5.x has breaking API changes therefore to migrate from 3.x series, remove all old MiSnapFacialCapture references from your project.

## 1. Obtain the SDK(s)
MiSnapFacialCapture 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

### SDK and UX/UI
It is Mitek's recommended option to integrated both SDK and UX/UI which is highly customizable.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapFacialCapture', '5.0.0.b1'
pod 'MiSnapFacialCaptureUX', '5.0.0.b1'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapFacialCapture` and `MiSnapFacialCaptureUX` checkboxes in a list of Package Products.

### SDK only

If you plan only using SDK and building your own UX/UI:

:warning: Use this [starter custom view controller](../../../Examples/Snippets/MiSnapFacialCapture/CustomFacialCaptureViewController.swift) to make sure all components are integrated the right way.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapFacialCapture', '5.0.0.b1'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapFacialCapture` checkbox in a list of Package Products.

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

3.1. `Privacy - Camera Usage Description` with a reasonable description on why your app needs access to a camera.

3.2. `Privacy - Microphone Usage Description` with a reasonable description on why your app needs access to a microphone, in case a video recording with audio is required.

## 4. Setup and launch MiSnapFacialCaptureViewController (optional)

When both `MiSnapFacialCapture` and `MiSnapFacialCaptureUX` are integrated:

4.1. Add necessary imports
```Swift
import MiSnapFacialCaptureUX
import MiSnapFacialCapture
import MiSnapLicenseManager
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
func miSnapShouldBeDismissed() {
    // Dismiss MiSnapFacialCaptureViewController here
}
```
