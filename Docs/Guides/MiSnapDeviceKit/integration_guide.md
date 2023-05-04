# Integration Guide

:warning: __Note__, when this SDK is integrated and its API is called a collection of device info used for enrollment and verification happens without a user action therefore it's your responsibility to get user's consent and possibly allow to opt out beforehand.

What device info is collected?

It's publicly available non-PII device properties exposed by Apple APIs along with a unique Mitek-specific ID. Note, an ID is unique for every application that has this SDK integrated and its sole purpose is tying a device along with biometrics (face and/or voice) in MiPass, i.e. it's impossible to use it to track any user activity for purposes of creating a user profile for advertisement and/or malicious activities.

## 1. Obtain the SDK(s)
MiSnapDeviceKit 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

It's highly recommended to use one of these distribution managers but manual integration is still supported.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapDeviceKit'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapDeviceKit` checkbox in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapLicenseManager.xcframework

From [MiSnap](../../../SDKs/MiSnapDeviceKit) copy:
* MiSnapDeviceKit.xcframework

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
    MiSnapLicenseManager.shared().setLicenseKey("your_license_key_here")
    return true
}
```

## 3. Access required API

:warning: __Note__, content of `info` property is time sensetive to prevent replay attacks (i.e. intercepting or acquring this property value in other way with an intention to re-use it in the future) making it only one time usable therefore it should be accessed as the last step right before creating a MiPass URL request for every transaction.

3.1. Add necessary imports
```Swift
import MiSnapDeviceKit
```
3.2. Access functionality:
```Swift
let device = MiSnapDevice()
if let info = device.info {
    // Send an encrypted device info to a back end for enrollment or verification
}
```
