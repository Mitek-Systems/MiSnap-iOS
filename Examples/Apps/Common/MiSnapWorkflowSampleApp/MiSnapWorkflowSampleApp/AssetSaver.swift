//
//  AssetSaver.swift
//  MiSnapFacialCaptureSampleApp
//
//  Created by Mitek Engineering on 2/22/21.
//  Copyright © 2021 Mitek Systems Inc. All rights reserved.
//

import UIKit
import Photos

enum VoiceDataSavingMode: Int, CaseIterable {
    case none
    case base64
    case wav
    case wavAndBase64
    
    var index: Int {
        switch self {
        case .none:         return 0
        case .base64:       return 1
        case .wav:          return 2
        case .wavAndBase64: return 3
        }
    }
    
    var string: String {
        switch self {
        case .none:         return "None"
        case .base64:       return "base64 only"
        case .wav:          return ".wav only"
        case .wavAndBase64: return ".wav and base64"
        }
    }
    
    static func from(_ index: Int) -> VoiceDataSavingMode {
        switch index {
        case 0:     return .none
        case 1:     return .base64
        case 2:     return .wav
        case 3:     return .wavAndBase64
        default:    fatalError("There's no VoiceDataSavingMode with index \(index)")
        }
    }
}

class AssetSaver: NSObject {
    public static func save(image: UIImage) {
        AssetSaver.checkPhotoLibraryAdditionsPermission { (granted) in
            guard granted else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(AssetSaver.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc static func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Image wasn't saved to Photo Album\n\(error.localizedDescription)")
        } else {
            print("Image was saved to Photo Album")
        }
    }
    
    public static func save(voiceData: Data?, savingMode: VoiceDataSavingMode, suffix: String? = nil) {
        guard let voiceData = voiceData, let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first, savingMode != .none else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        
        var fileName = "voice_sample_\(formatter.string(from: Date()))"
        if let suffix = suffix {
            fileName += suffix
        }
        
        var base64str: String = ""
        let base64url = URL(fileURLWithPath: documentsDir).appendingPathComponent("\(fileName).txt")
        let wavUrl = URL(fileURLWithPath: documentsDir).appendingPathComponent("\(fileName).wav")
        
        do {
            switch savingMode {
            case .base64:
                base64str = voiceData.base64EncodedString()
                try base64str.write(to: base64url, atomically: true, encoding: .utf8)
                print("Voice sample (base64) was saved to Documents directory")
            case .wav:
                try voiceData.write(to: wavUrl, options: .atomic)
                print("Voice sample (.wav) was saved to Documents directory")
            case .wavAndBase64:
                base64str = voiceData.base64EncodedString()
                try base64str.write(to: base64url, atomically: true, encoding: .utf8)
                try voiceData.write(to: wavUrl, options: .atomic)
                print("Voice sample (.wav and base64) was saved to Documents directory")
            default:
                break
            }
        } catch let error {
            print("voice sample saved to Documents directory\n\(error.localizedDescription)")
        }
    }
    
    public static func voiceDataCleanup() {
        guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
              let allFiles = try? FileManager.default.contentsOfDirectory(atPath: documentsDir) else { return }
        let url = URL(fileURLWithPath: documentsDir)
        
        for file in allFiles.sorted() {
            guard file.contains("voice_sample_") else { continue }
            try? FileManager.default.removeItem(atPath: url.appendingPathComponent(file).path)
        }
    }
    
    public static func save(encodedImage: String) {
        guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
        let url = URL(fileURLWithPath: documentsDir).appendingPathComponent("\(formatter.string(from: Date())).txt")
        
        do {
            try encodedImage.write(to: url, atomically: true, encoding: .utf8)
            print("Encoded image was saved in Documents directory")
        } catch let error {
            print("Encoded image wasn't saved in Documents directory\n\(error.localizedDescription)")
        }
    }
    
    public static func save(video videoData: Data?) {
        AssetSaver.checkPhotoLibraryAdditionsPermission { (granted) in
            guard granted, let videoData = videoData else { return }
            
            // Save a video to a Documents directory temporarily so it can be saved to Photo Album from there
            guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss-SSS"
            let url = URL(fileURLWithPath: documentsDir).appendingPathComponent("\(formatter.string(from: Date())).mp4")
            do {
                try videoData.write(to: url)
            } catch let error {
                print("Couldn't write to Documents directory\n\(error.localizedDescription)")
            }
            
            // Save to Photo Album
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { (success, error) in
                // Delete from a Documents directory
                if FileManager.default.fileExists(atPath: url.path) {
                    do {
                        try FileManager.default.removeItem(atPath: url.path)
                    } catch {}
                }
                if let error = error {
                    print("Video wasn't saved to Photo Album\n\(error.localizedDescription)")
                } else if success {
                    print("Video was saved to Photo Album")
                }
            }
        }
    }
    
    private static func checkPhotoLibraryAdditionsPermission(handler: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .restricted, .denied:
            print("Asset wasn't saved as Photo Library Additions was denied. Enable a permission in Settings to be able to save")
            handler(false)
        case .authorized:
            handler(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                handler(status == .authorized)
            }
        default:
            handler(false)
        }
    }
}
