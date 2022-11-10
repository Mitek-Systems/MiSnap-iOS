# MiSnapWorkflow Integration and Customization Guide

Please refer to [MiSnapWorkflowSampleApp](../../../Examples/Apps/Common/MiSnapWorkflowSampleApp) as a working example created by following steps below. 
Specifically, `ViewController.swift` shows how with a few lines of code you can setup and launch `MiSnapWorkflowViewController` for:
* MobileVerify:
    * Passport --> (optional) NFC --> Face
    * ID/DL/RP Front --> ID/DL/RP Back --> (optional) NFC --> Face
* MiPass:
    * Enrollment with both Face and Voice or Face only or Voice only
    * Verification for both Face and Voice or Face only or Voice only

## 1. Integrate necessary SDK(s)

Follow integration guides for individual Mitek SDKs ignoring the last optional step where individual view controllers are set up and launched. Setup will only be performed for `MiSnapWorkflowViewController` in step 3 of this guide.

## 2. Add MiSnapWorkflow files

Download MiSnapWorkflow files from [here](../../../SDKs/Common/MiSnapWorkflow) and add them to a project.

## 3. Setup and launch MiSnapWorkflowViewController

3.1. Configure and present MiSnapWorkflowViewController:

```Swift
let miSnapWorkflowVC = MiSnapWorkflowViewController(with: steps, delegate: self)
// Present view controller here
```
where,

`steps` is an array of `MiSnapWorkflowStep`.

:warning: Do not add `nfc` step as it's automatically added when the workflow determines that a given document is in a list of supported documents and has a chip.

:warning: Do not add `passportQr` step as it's automatically added when necessary.

3.2. Implement required callbacks to conform to `MiSnapWorkflowViewControllerDelegate`

```Swift
// Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
func miSnapWorkflowLicenseStatus(_ status: MiSnapLicenseStatus) {
    // Handle a license status
}

func miSnapWorkflowSuccess(_ result: MiSnapWorkflowResult) {
    // Handle results for all SDKs after workflow successfully finished
}

func miSnapWorkflowError(_ result: MiSnapWorkflowResult) {
    // Handle a result for the SDKs where error occurred
}

func miSnapWorkflowCancelled(_ result: MiSnapWorkflowResult) {
    // Handle a result for an SDK that was active when a user cancelled the whole workflow 
}
```
Implement the following optional callback if you would like to get a result for a step as it's completed instead of waiting for the whole workflow to be successfully completed:
```Swift
func miSnapWorkflowIntermediate(_ result: Any, step: MiSnapWorkflowStep) {
    // Handle a result for a completed step here
}
```
**Note**, that `miSnapWorkflowSuccess(_:)` callback is still returned

Implement the following optional callback if you've integrated `MiSnapNFC` and would like to be notified in case if a user chooses to skip NFC step after unsuccessful chip reading attempt(s):
```Swift
func miSnapWorkflowNfcSkipped(_ result: [String : Any]) {
    // Handle skipped NFC results here
}
```

Implement the following optional callback if you've integrated `MiSnapVoiceCapture`:
```Swift
func miSnapWorkflowDidSelectPhrase(_ phrase: String) {
    /*
    Handle a phrase selected by a user in an Enrollment flow.
    
    It's highly recommended not only store the phrase in UserDefaults but also in a database on a server side to be able to retrieve it if a user switches a device or re-installs the app.
    
    For security purposes you might even cosider storing the phrase on a server side only and retrieve it for each verification.
    
    Note, this exact phrase will need to be passed in a configuration for a Verification flow.
    */
}
```

## 4. Customize individual SDKs managed by MiSnapWorkflow
For customization of individual view controllers managed by `MiSnapWorkflow` go to `MiSnapWorkflowViewControllerFactory.swift` and override default configurations for desired SDKs.