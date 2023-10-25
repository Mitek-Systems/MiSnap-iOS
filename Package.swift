// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MiSnap",
    defaultLocalization: "en",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MiSnap",
            targets: ["MiSnap","MiSnapCamera","MiSnapScience","MobileFlow","MiSnapBarcodeScanner","MiSnapCore"]
            ),
        .library(
            name: "MiSnapUX",
            targets: ["MiSnapUX","MiSnapAssetManager"]
        ),
        .library(
            name: "MiSnapFacialCapture",
            targets: ["MiSnapFacialCapture","MiSnapCore"]
        ),
        .library(
            name: "MiSnapFacialCaptureUX",
            targets: ["MiSnapFacialCaptureUX","MiSnapAssetManager"]
        ),
        .library(
            name: "MiSnapVoiceCapture",
            targets: ["MiSnapVoiceCapture","VoiceSdk","MiSnapCore"]
        ),
        .library(
            name: "MiSnapVoiceCaptureUX",
            targets: ["MiSnapVoiceCaptureUX","MiSnapAssetManager"]
        ),
        .library(
            name: "MiSnapNFC",
            targets: ["MiSnapNFC","MiSnapCore"]
        ),
        .library(
            name: "MiSnapNFCUX",
            targets: ["MiSnapNFCUX","MiSnapAssetManager"]
        ),
        .library(
            name: "MiSnapCore",
            targets: ["MiSnapCore"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "MiSnap",
            path: "SDKs/MiSnap/MiSnap.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapCamera",
            path: "SDKs/MiSnap/MiSnapCamera.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapScience",
            path: "SDKs/MiSnap/MiSnapScience.xcframework"
           ),
        .binaryTarget(
            name: "MobileFlow",
            path: "SDKs/MiSnap/MobileFlow.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapBarcodeScanner",
            path: "SDKs/MiSnap/MiSnapBarcodeScanner.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapUX",
            path: "SDKs/MiSnap/MiSnapUX.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapFacialCapture",
            path: "SDKs/MiSnapFacialCapture/MiSnapFacialCapture.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapFacialCaptureUX",
            path: "SDKs/MiSnapFacialCapture/MiSnapFacialCaptureUX.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapVoiceCapture",
            path: "SDKs/MiSnapVoiceCapture/MiSnapVoiceCapture.xcframework"
        ),
        .binaryTarget(
            name: "VoiceSdk",
            path: "SDKs/MiSnapVoiceCapture/VoiceSdk.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapVoiceCaptureUX",
            path: "SDKs/MiSnapVoiceCapture/MiSnapVoiceCaptureUX.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapNFC",
            path: "SDKs/MiSnapNFC/MiSnapNFC.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapNFCUX",
            path: "SDKs/MiSnapNFC/MiSnapNFCUX.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapCore",
            path: "SDKs/Common/MiSnapCore.xcframework"
        ),
        .binaryTarget(
            name: "MiSnapAssetManager",
            path: "SDKs/Common/MiSnapAssetManager.xcframework"
        )
    ]
)
