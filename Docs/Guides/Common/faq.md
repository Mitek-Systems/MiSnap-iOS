# Frequently Asked Questions (FAQs)

## GitHub doesn't have a preview for HTML so how can API documentation be viewed?

Use [GitHub & BitBucket HTML Preview](https://htmlpreview.github.io) tool. 

For example, to view MiSnap API documentation navigate to Docs/API/MiSnap/MiSnap and open `index.html`. Copy its URL, paste it in `GitHub & BitBucket HTML Preview` and click `Preview`.

Similarly you can view API documentation for all other SDKs and their components.

<br>

- - -

<br>

## Is there an easy way of sending data output by the SDK to a back end?

You can use [MitekRequest](../../../SDKs/Common/MitekRequest) utility that simplifies creating a URL request for MobileVerify and MiPass.

Usage for `MobileVerify`

```Swift
// Create a MobileVerify request and add all necessary inputs
let mvRequest = MobileVerifyRequest()
if let encodedFrontImage = encodedFrontImage {
    mvRequest.addFrontEvidence(withData: encodedFrontImage, qrCode: qrCode)
}
if let encodedBackImage = encodedBackImage {
    mvRequest.addBackEvidence(withData: encodedBackImage, pdf417: pdf417)
}
if let nfcRequestDictionary = nfcRequestDictionary as? [String : Any] {
    mvRequest.addNfcEvidence(from: nfcRequestDictionary)
}
if let encodedFaceImage = encodedFaceImage {
    mvRequest.addSelfieEvidence(withData: encodedFaceImage)
    mvRequest.addVerifications([.faceComparison, .faceLiveness])
}

// Check for errors
if let errors = mvRequest.errors {
    print("Errors generating MobileVerifyRequest:")
    for (idx, error) in errors.enumerated() {
        print("\(idx + 1). \(error.description)")
    }
    return
}

// Get request dictionary that can be serialized to JSON data for URLRequest httpBody
guard let requestDictionary = mvRequest.dictionary else { return }
```

Usage for `MiPass`
```Swift
// Create a MobileVerify request and add all necessary inputs
// This is an example for `enrollment` flow but `verification` is supported too
let miPassRequest = MiPassRequest(for: .enrollment)
        
if let enrollmentId = enrollmentId {
    miPassRequest.addEnrollmentId(enrollmentId)
}

if let voiceResults = voiceResults {
    var voiceSamples: [Data] = []
    for voiceResult in voiceResults {
        guard let data = voiceResult.data else { continue }
        voiceSamples.append(data)
    }
    miPassRequest.addVoiceFeatures(voiceSamples)
}

if let faceResult = faceResult, let encodedSelfieImage = faceResult.encodedImage {
    miPassRequest.addEncodedSelfieImage(encodedSelfieImage)
}

// Check for errors
if let errors = miPassRequest.errors {
    print("Errors generating MiPassRequest for Enrollment:")
    for (idx, error) in errors.enumerated() {
        print("\(idx + 1). \(error.description)")
    }
    return
}

// Get request dictionary that can be serialized to JSON data for URLRequest httpBody
guard let requestDictionary = miPassRequest.dictionary else { return }
```

:warning: If you would like to send a request directly to MobileVerify or MiPass instead of your app server you can use [MitekPlatform](../../../SDKs/Common/MitekRequest) utility.

Set credentials and other necessary configuration inputs. `AppDelegate`'s `application(_:, didFinishLaunchingWithOptions:)` is a good place for this.
```Swift
let configuration = MitekPlatformConfiguration(withClientId: "your_client_id_here",
                                               clientSecret: "your_client_secret_here")
    .withMobileVerifyConfiguration { mobileVerify in
        mobileVerify.tokenUrl = "your_mobile_verify_token_url_here"
        mobileVerify.url = "your_mobile_verify_url_here"
        mobileVerify.scope = "your_mobile_verify_scope_here"
    }
    .withMiPassConfiguration { miPass in
        miPass.tokenUrl = "your_mipass_token_url_here"
        miPass.baseUrl = "your_mipass_base_url_here"
        miPass.scope = "your_mipass_scope_here"
    }
MitekPlatform.shared.set(configuration: configuration)
```
For `MobileVerify`
```Swift
MitekPlatform.shared.authenticate(requestDictionary) { rawResponse, error in
    // Check if there's an error and handle MobileVerify response
}
```
For `MiPass` enrollmentment
```Swift
MitekPlatform.shared.enroll(requestDictionary) { rawResponse, error in
    // Check if there's an error and handle MiPass Enrollment response
}
```

For `MiPass` enrollmentment deletion
```Swift
MitekPlatform.shared.deleteEnrollment(withId: id) { rawResponse, error in
    // Check if there's an error and handle MiPass Enrollment deletion response 
}
```

For `MiPass` verification
```Swift
MitekPlatform.shared.verify(requestDictionary) { rawResponse, error in
    // Check if there's an error and handle MiPass Verification response
}
```
