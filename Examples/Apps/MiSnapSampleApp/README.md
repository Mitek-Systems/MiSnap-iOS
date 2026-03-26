# MiSnap Sample Apps (SwiftUI + UIKit)

This sample workspace provides one unified sample source tree with two runnable targets that demonstrate the same MiSnap feature set with different UI frameworks:

- `MiSnapSampleAppSwiftUI` target for SwiftUI-first integrations.
- `MiSnapSampleAppUIKit` target for UIKit-first integrations.

Both apps include:

- Document capture
- Face capture
- Voice capture
- NFC reading
- Workflow capture

## Choose a Framework

- **Use SwiftUI** if your app is mostly SwiftUI and you want feature screens as SwiftUI views.
- **Use UIKit** if your app is UIKit-based and you want view-controller-driven integration.

Business logic and feature models are intentionally organized so the integration flow is easy to compare and reuse across both UI stacks.

## Requirements

### Shared

- Xcode 15+
- MiSnap SDK binaries included in this repository
- MiSnap SDK license key (contact your Mitek representative)

### SwiftUI target

- iOS 16.0+
- Swift 5.9+

### UIKit target

- iOS 15.0+

## Quick Start

### 1) Add your license key

Set your key in:

- `MiSnapSampleApp/App/LicenseKey.swift`

```swift
enum LicenseKey {
    static let key = "YOUR_LICENSE_KEY_HERE"
}
```

### 2) Open and run

1. Open `MiSnapSampleApp.xcodeproj` in Xcode.
2. Select one scheme:
   - `MiSnapSampleAppSwiftUI`
   - `MiSnapSampleAppUIKit`
3. Build and run on a device or simulator.
4. Grant requested permissions (camera/microphone when applicable).

## Feature-First Project Structure

The sample is organized so you can locate and extract the files for any single feature without pulling in unrelated code.

```text
MiSnapSampleApp/
└── MiSnapSampleApp/
    ├── App/
    │   ├── LicenseKey.swift
    │   ├── SwiftUI/
    │   └── UIKit/
    ├── Common/{Shared,SwiftUI,UIKit}
    └── Features/
        ├── Documents/
        │   ├── DocumentsViewModel.swift
        │   ├── Shared/
        │   ├── SwiftUI/
        │   └── UIKit/
        ├── Face/
        │   ├── FaceViewModel.swift
        │   ├── Shared/
        │   ├── SwiftUI/
        │   └── UIKit/
        ├── Voice/
        │   ├── Shared/
        │   ├── SwiftUI/
        │   ├── UIKit/
        │   └── VoiceViewModel.swift
        ├── NFC/
        │   ├── NFCViewModel.swift
        │   ├── Shared/
        │   ├── SwiftUI/
        │   └── UIKit/
        └── Workflow/
            ├── Shared/
            ├── SwiftUI/
            ├── UIKit/
            └── WorkflowViewModel.swift
```

## Shared Architecture

- **Feature `Shared`** contains feature-specific logic, presets, result models, and SDK localization assets.
- **Feature UI folders** contain framework-specific presentation:
  - SwiftUI target: views and representables in `Features/<Feature>/SwiftUI`
  - UIKit target: view controllers in `Features/<Feature>/UIKit`
- **`Common/Shared`** contains cross-framework models and utilities.
- **`Common/SwiftUI`** contains SwiftUI-specific shared views (result view, preset cards, etc.).
- **`Common/UIKit`** contains UIKit-specific shared UI helpers.

This keeps the integration flow consistent while making each feature easy to extract independently.

### Localization assets

Each feature's `Shared/Assets/` folder contains directories with localizable strings (e.g., `MiSnapLocalizable.strings` for Documents, `MiSnapFacialCaptureLocalizable.strings` for Face). These are required for the SDK's built-in UI and can be customized to match your app's terminology.

### Navigating a feature

To understand how a feature is integrated, start with its ViewModel in `Features/<Feature>/` (sibling to SwiftUI, UIKit, Shared):

| Feature   | Start here                                   |
|-----------|----------------------------------------------|
| Documents | `Features/Documents/DocumentsViewModel.swift` |
| Face      | `Features/Face/FaceViewModel.swift`          |
| Voice     | `Features/Voice/VoiceViewModel.swift`        |
| NFC       | `Features/NFC/NFCViewModel.swift`            |
| Workflow  | `Features/Workflow/WorkflowViewModel.swift`  |

Each ViewModel shows license setup, permission checks, SDK configuration, and delegate/result handling. From there, see the corresponding SwiftUI view or UIKit view controller for presentation.

## Troubleshooting

### Shared issues

- **License validation fails:** verify the key value in `LicenseKey.swift`.
- **Build cannot resolve SDK modules:** make sure framework references are present and embedded in the selected target.
- **Permissions denied:** confirm Camera/Microphone usage descriptions are present and permissions are granted.

### NFC-specific notes

- NFC requires a physical supported device; simulator does not provide NFC hardware behavior.
- Keep the device close to the chip throughout the read.

### Framework-specific notes

- **SwiftUI:** start from `App/SwiftUI/RootTabView.swift` to trace feature entry points.
- **UIKit:** start from `App/UIKit/RootTabBarController.swift` to trace tab and navigation setup.

## Notes

- This sample is an integration reference, not production-ready app code.
- For production, store license material securely (for example, keychain/server retrieval) and add app-specific hardening and telemetry.
