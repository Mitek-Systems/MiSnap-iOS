# Integration Guide

:warning: MiSnapNFC 5.x has breaking API changes therefore to migrate from 1.x series, remove all old MiSnap references from your project.

## 1. Obtain the SDK(s)
MiSnapNFC 5.x is distributed through CocoaPods and Swift Package Manager. For detailed installation instructions refer to:
* [CocoaPods installation guide](https://guides.cocoapods.org/using/using-cocoapods.html)
* [Swift Package Manager installation guide](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

It's highly recommended to use one of these distribution managers but manual integration is still supported.

### SDK and UX/UI
It is Mitek's recommended option to integrated both SDK and UX/UI.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapNFC'
pod 'MiSnapNFCUX'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapNFC` and `MiSnapNFCUX` checkboxes in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapLicenseManager.xcframework
* MiSnapMibiData.xcframework

From [MiSnapNFC](../../../SDKs/MiSnapNFC) copy:
* MiSnapNFC.xcframework
* MiSnapNFCUX.xcframework

Add all copied artifacts to your Xcode project under "Frameworks, Libraries, and Embedded Content". 

Make sure `Embed & Sign` is chosen as Embed option.

Set valid path(s) to copied artifacts in `Framework Search Paths` under `Build Settings` tab.

### SDK only

If you plan only using SDK and building your own UX/UI:

:warning: Use this [starter custom view controller](../../../Examples/Snippets/MiSnapNFC/CustomNFCViewController.swift) to make sure all components are integrated the right way.

#### CocoaPods

Include the following in your Podfile

```Ruby
pod 'MiSnapNFC'
```
#### Swift Package Manager

Add the following repository url:

`https://github.com/Mitek-Systems/MiSnap-iOS.git`

then check `MiSnapNFC` checkbox in a list of Package Products.

#### Manual integration

From [Common](../../../SDKs/Common) copy:
* MiSnapLicenseManager.xcframework
* MiSnapMibiData.xcframework

From [MiSnapNFC](../../../SDKs/MiSnapNFC) copy:
* MiSnapNFC.xcframework

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
import MiSnapNFCUX
import MiSnapNFC
import MiSnapLicenseManager
```
5.2. Configure and present MiSnapNFCViewController:
```Swift
let documentType: MiSnapNFCDocumentType = <your-document-type-here>
let documentNumber = "document-number-here"
let dateOfBirth = "date-of-birth-in-YYMMDD-format-here"
let dateOfExpiry = "date-of-expiry-in-YYMMDD-format-here"
let mrzString = "mrz-string-here"
        
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
