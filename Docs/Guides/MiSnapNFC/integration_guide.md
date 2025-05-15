# Integration Guide

:warning: MiSnapNFC 5.x has breaking API changes therefore to migrate from 1.x series, remove all old MiSnap references from your project.

[MiSnapNFCSampleApp](../../../Examples/Apps/MiSnapNFC/MiSnapNFCSampleApp) was created by following steps below. Please refer to this project as a working example.

## 1. Obtain the SDK(s)
MiSnapNFC 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

It's highly recommended to use one of these distribution managers but manual integration is still supported.

## 1.1 SDK and UX/UI
It is Mitek's recommended option to integrated both SDK and UX/UI.

If you'd like to build your own custom UI/UX (not recommended) skip to [1.2](#12-sdk-only).

### Localization files

Regardless of your choise of integration (CocoaPods, Swift Package Manager, manual) the first step should be adding localization files to your Xcode project. Here's how to do this:
* Copy `MiSnapNFC` folder from [here](../../../Assets) into your project's location
* In Xcode, File > Add Files to "YourAppName"...
* Select copied folder and make sure:
    * `Create groups` option is selected in `Added folders` section
    * All necessary targets are checked in `Add to targets` section

### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapNFC` and `MiSnapNFCUX` checkboxes in a list of Package Products.

### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapNFC'
pod 'MiSnapNFCUX'
```

### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapCore.xcframework

From [MiSnapNFC](../../../SDKs/MiSnapNFC) copy:
* MiSnapNFC.xcframework
* MiSnapNFCUX.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

## 1.2. SDK only

Skip to [the next step](#2-add-license-key-to-your-project) if you've followed steps in 1.1.

If you plan only using SDK and building your own UX/UI:

:warning: Use this [starter custom view controller](../../../Examples/Snippets/MiSnapNFC/CustomNFCViewController.swift) to make sure all components are integrated the right way.

### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapNFC` checkbox in a list of Package Products.

### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapNFC'
```

### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapCore.xcframework

From [MiSnapNFC](../../../SDKs/MiSnapNFC) copy:
* MiSnapNFC.xcframework

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

3.1. `Privacy - NFC Scan Usage Description` with a reasonable description on why your app needs access to an NFC antenna.

3.2. `ISO7816 application identifiers for NFC Tag Reader Session` with the following items:
* `A0000002471001`
* `A00000045645444C2D3031`

## 4. Add a required capability

In Xcode go to "Signing & Capabilities" tab, click "+ Capability", type "Near Field Communication Tag Reading" in a search field and select the capability.

## 5. Setup and launch MiSnapNFCViewController (optional)

When both `MiSnapNFC` and `MiSnapNFCUX` are integrated:

5.1. Add necessary imports
```Swift
import MiSnapCore
import MiSnapNFC
import MiSnapNFCUX
```
5.2. Configure and present MiSnapNFCViewController:
```Swift
let documentType: MiSnapNFCDocumentType = <your_document_type_here>
let documentNumber = "document_number_here"
let dateOfBirth = "date_of_birth_in_YYMMDD_format_here"
let dateOfExpiry = "date_of_expiry_in_YYMMDD_format_here"
let mrzString = "mrz_string_here"
        
let chipLocation = MiSnapNFCChipLocator.chipLocation(mrzString: mrzString,
                                                     documentNumber: documentNumber,
                                                     dateOfBirth: dateOfBirth,
                                                     dateOfExpiry: dateOfExpiry)

if (chipLocation == .noChip && (documentType == .id || documentType == .passport)) ||
    (documentType == .dl && mrzString.isEmpty) {
    /* 
    There is no chip in a document with provided 
    information or a document is not supported yet
    */
} else {
    let configuration = MiSnapNFCConfiguration()
        .withInputs { inputs in
            inputs.documentNumber = documentNumber
            inputs.dateOfBirth = dateOfBirth
            inputs.dateOfExpiry = dateOfExpiry
            inputs.mrzString = mrzString
            inputs.documentType = documentType
            inputs.chipLocation = chipLocation
        }
    
    misnapNFCVC = MiSnapNFCViewController(with: configuration, delegate: self)
    
    // Present view controller here
}
```
where,

`configuration` is a configuration for a default UX/UI. If you'd like to customize it, refer to [MiSnapNFC Customization Guide](customization_guide.md).

`documentType` is of type `MiSnapNFCDocumentType`. For all available ENUM options see this [API reference](https://htmlpreview.github.io/?https://github.com/Mitek-Systems/MiSnap-iOS/blob/main/Docs/API/MiSnapNFC/MiSnapNFC/Enums/MiSnapNFCDocumentType.html).

5.3. Implement required callbacks to conform to `MiSnapNFCViewControllerDelegate`

```Swift
// Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
func miSnapNfcLicenseStatus(_ status: MiSnapLicenseStatus) {
    // Handle a license status here
}

func miSnapNfcSuccess(_ result: [String : Any]) {
    // Handle successful session results here
}

func miSnapNfcCancelled(_ result: [String: Any]) {
    // Handle cancelled session results here
}

func miSnapNfcSkipped(_ result: [String: Any]) {
    // Handle skipped session results here
}
```
Note, if `autoDismiss` of `MiSnapNFCUxParameters` is overridden to `false`, a parent view controller that presented `MiSnapNFCViewController` is responsible for dismissing it. Implement the following optional callback to achive this:
```Swift
func miSnapNfcShouldBeDismissed() {
    // Dismiss MiSnapNFCViewController here
}
```
