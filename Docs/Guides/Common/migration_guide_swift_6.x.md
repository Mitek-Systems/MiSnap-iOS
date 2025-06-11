# Migration guide to Swift 6.x

On September 16, 2024, Xcode 16 with support for a new major Swift version (Swift 6.0) was released.

MiSnap 5.x, being an SDK that’s integrated by hundreds of customers with different needs, has to be compatible with the minimum systems requirements supported by Apple. That’s the reason a minimum OS version is still set at iOS 12. Also, this is the reason a minimum Swift version will have to remain at Swift 5.x. Otherwise, all customers that are still using Swift 5.x (the vast majority) will be blocked from using MiSnap. Nonetheless, it is possible to make MiSnap 5.x compatible with Swift 6.x with minimal changes.

If you're migrating from Swift 5.x to Swift 6.x, follow the recommendations below depending on your intergation option:
* [Using default UX (customized or not)](#using-default-ux-customized-or-not)
* [Built custom UX from scratch](#built-custom-ux-from-scratch)

## Using default UX (customized or not)

### 1. MiSnap:

Add `@preconcurrency` before `MiSnapViewControllerDelegate`.
```Swift
extension ViewController: @preconcurrency MiSnapViewControllerDelegate {
    // Implementation of MiSnapViewControllerDelegate callbacks
}
```

### 2. MiSnapFacialCapture

Add `@preconcurrency` before `MiSnapFacialCaptureViewControllerDelegate`.
```Swift
extension ViewController: @preconcurrency MiSnapFacialCaptureViewControllerDelegate {
    // Implementation of MiSnapFacialCaptureViewControllerDelegate callbacks
}
```

### 3. MiSnapVoiceCapture

Add `@preconcurrency` before `MiSnapVoiceCaptureViewControllerDelegate`.
```Swift
extension ViewController: @preconcurrency MiSnapVoiceCaptureViewControllerDelegate {
    // Implementation of MiSnapVoiceCaptureViewControllerDelegate callbacks
}
```

### 4. MiSnapNFC

Add `@preconcurrency` before `MiSnapNFCViewControllerDelegate`.
```Swift
extension ViewController: @preconcurrency MiSnapNFCViewControllerDelegate {
    // Implementation of MiSnapNFCViewControllerDelegate callbacks
}
```

## Built custom UX from scratch

### 1. MiSnap:

Add `@preconcurrency` before `MiSnapCameraDelegate` and `MiSnapAnalyzerDelegate`.
```Swift
extension CustomViewController: @preconcurrency MiSnapCameraDelegate {
    // Implementation of MiSnapCameraDelegate callbacks
}
extension CustomViewController: @preconcurrency MiSnapAnalyzerDelegate {
    // Implementation of MiSnapAnalyzerDelegate callbacks
}
```

### 2. MiSnapFacialCapture

Add `@preconcurrency` before `MiSnapFacialCaptureCameraDelegate` and `MiSnapFacialCaptureAnalyzerDelegate`.
```Swift
extension CustomFacialCaptureViewController: @preconcurrency MiSnapFacialCaptureCameraDelegate {
    // Implementation of MiSnapFacialCaptureCameraDelegate callbacks
}

extension CustomFacialCaptureViewController: @preconcurrency MiSnapFacialCaptureAnalyzerDelegate {
    // Implementation of MiSnapFacialCaptureAnalyzerDelegate callbacks
}
```

### 3. MiSnapVoiceCapture

Add `@preconcurrency` before `MiSnapVoiceCaptureControllerDelegate`.
```Swift
extension CustomVoiceCaptureViewController: @preconcurrency MiSnapVoiceCaptureControllerDelegate {
    // Implementation of MiSnapVoiceCaptureControllerDelegate callbacks
}
```

### 4. MiSnapNFC

Requires upgrade to `MiSnapNFC` 5.9.0 (planned for late September 2025) or newer.




