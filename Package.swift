// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MiSnap",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MiSnap",
            targets: ["MiSnapUX","MiSnap","MiSnapCamera","MiSnapScience","MobileFlow","MiSnapMibiData","MiSnapBarcodeScanner","MiSnapBarcodeScannerLight","MiSnapLicenseManager"]
            ),
    ],
    targets: [
        .target(
            name: "MiSnapUX"
        ),
        .binaryTarget(
            name: "MiSnap",
            path: "SDKs/MiSnap.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapCamera",
            path: "SDKs/MiSnapCamera.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapScience",
            path: "SDKs/MiSnapScience.xcframework"
           ),
        .binaryTarget(
            name: "MobileFlow",
            path: "SDKs/MobileFlow.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapMibiData",
            path: "SDKs/MiSnapMibiData.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapBarcodeScanner",
            path: "SDKs/MiSnapBarcodeScanner.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapBarcodeScannerLight",
            path: "SDKs/MiSnapBarcodeScannerLight.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapLicenseManager",
            path: "SDKs/MiSnapLicenseManager.xcframework"
        )
    ]
)
