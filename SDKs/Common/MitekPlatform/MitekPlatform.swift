//
//  MitekPlatform.swift
//  MitekPlatform
//
//  Created by Mitek Engineering on 7/20/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import Foundation

internal enum MitekPlatformError: Error {
    case error(String)
}

public class MitekPlatformConfiguration: NSObject {
    private(set) var mobileVerify = MobileVerifyConfiguration()
    private(set) var miPass = MiPassConfiguration()
    
    private(set) var clientId: String = ""
    private(set) var clientSecret: String = ""
    
    public override init() {
        super.init()
    }
    
    public init(withClientId clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        super.init()
    }
    
    public func withMobileVerifyConfiguration(completion: (MobileVerifyConfiguration) -> Void) -> MitekPlatformConfiguration {
        completion(mobileVerify)
        return self
    }
    
    public func withMiPassConfiguration(completion: (MiPassConfiguration) -> Void) -> MitekPlatformConfiguration {
        completion(miPass)
        return self
    }
}

public class MobileVerifyConfiguration: NSObject {
    public var tokenUrl: String = ""
    public var url: String = ""
    public var scope: String = ""
    
    public override init() {
        super.init()
    }
}

public class MiPassConfiguration: NSObject {
    public var tokenUrl: String = ""
    public var baseUrl: String = ""
    public var scope: String = ""
    
    public override init() {
        super.init()
    }
}

public class MitekPlatform: NSObject {
    private static var sharedInstance: MitekPlatform?
    
    private var configuration = MitekPlatformConfiguration()
    
    private var dataTask: URLSessionDataTask?
    private var mobileVerifyTokenManager = MitekPlatformTokenManager()
    private var miPassTokenManager = MitekPlatformTokenManager()
    
    var hasValidMobileVerifyConfiguration: Bool {
        if !hasValidCredentials {
            return false
        }
        if configuration.mobileVerify.tokenUrl.isEmpty ||
            configuration.mobileVerify.tokenUrl.contains("your_") ||
            configuration.mobileVerify.url.isEmpty ||
            configuration.mobileVerify.url.contains("your_") ||
            configuration.mobileVerify.scope.isEmpty ||
            configuration.mobileVerify.scope.contains("your_") {
            return false
        }
        return true
    }
    
    var hasValidMiPassConfiguration: Bool {
        if !hasValidCredentials {
            return false
        }
        if configuration.miPass.tokenUrl.isEmpty ||
            configuration.miPass.tokenUrl.contains("your_") ||
            configuration.miPass.baseUrl.isEmpty ||
            configuration.miPass.baseUrl.contains("your_") ||
            configuration.miPass.scope.isEmpty ||
            configuration.miPass.scope.contains("your_") {
            return false
        }
        return true
    }
    
    private var hasValidCredentials: Bool {
        if configuration.clientId.isEmpty ||
            configuration.clientId.contains("your_") ||
            configuration.clientSecret.isEmpty ||
            configuration.clientSecret.contains("your_") {
            return false
        }
        return true
    }
    
    public class var shared: MitekPlatform {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = MitekPlatform()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        return sharedInstance
    }
    
    private override init() {
        super.init()
    }
    
    private func save(_ data: Data, suffix: String) {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
        let timeStamp = formatter.string(from: Date())
        let filename = documentPath.appendingPathComponent("\(timeStamp)_\(suffix)").appendingPathExtension("json")
        
        do {
            try data.write(to: filename, options: .atomic)
        } catch {
            print("wasn't able to write file \"\(filename)\"")
        }
    }
    
    public class func destroyShared() {
        if let sharedInstance = self.sharedInstance {
            sharedInstance.cancel()
            self.sharedInstance = nil
        }
    }
    
    public func cancel() {
        self.dataTask?.cancel()
        URLSession.shared.invalidateAndCancel()
    }
    
    public func set(configuration: MitekPlatformConfiguration) {
        self.configuration = configuration
        mobileVerifyTokenManager.set(url: configuration.mobileVerify.tokenUrl,
                                     id: configuration.clientId,
                                     secret: configuration.clientSecret,
                                     scope: configuration.mobileVerify.scope)
        miPassTokenManager.set(url: configuration.miPass.tokenUrl,
                               id: configuration.clientId,
                               secret: configuration.clientSecret,
                               scope: configuration.miPass.scope)
    }
    
    public func authenticate(_ requestDictionary: [String : Any], completed: @escaping ([String: Any]?, Error?) -> Void) {
        guard !configuration.mobileVerify.url.isEmpty else { fatalError("[MitekPlatform] Url is not set") }
        guard let url = URL(string: configuration.mobileVerify.url) else {
            fatalError("[MitekPlatform] Couldn't initialize URL with string: \(configuration.mobileVerify.url)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let data = try JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
            
            request.httpBody = data
            
            // Uncomment to save request json for debugging purposes
            //save(data, suffix: "request")
            
            mobileVerifyTokenManager.getToken { [unowned self] (token, error) in
                if let error = error {
                    completed(nil, error)
                    return
                }
                
                guard let token = token else { fatalError("[MitekPlatform] token is nil") }
                
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                self.submit(request: request, completed: completed)
            }
        } catch {
            print("[MitekPlatform] couldn't create a request body data: \(error.localizedDescription)")
            completed(nil, error)
        }
    }
    
    public func enroll(_ requestDictionary: [String : Any], completed: @escaping ([String: Any]?, Error?) -> Void) {
        guard !configuration.miPass.baseUrl.isEmpty else { fatalError("[MitekPlatform] Url is not set") }
        guard let url = URL(string: configuration.miPass.baseUrl + "/enroll") else {
            fatalError("[MitekPlatform] Couldn't initialize URL with string: \(configuration.miPass.baseUrl)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let data = try JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
            
            request.httpBody = data
            
            // Uncomment to save request json for debugging purposes
            //save(data, suffix: "request")
            
            miPassTokenManager.getToken { [unowned self] (token, error) in
                if let error = error {
                    completed(nil, error)
                    return
                }
                
                guard let token = token else { fatalError("[MitekPlatform] token is nil") }
                
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                self.submit(request: request, completed: completed)
            }
        } catch {
            print("[MitekPlatform] couldn't create a request body data: \(error.localizedDescription)")
            completed(nil, error)
        }
    }
    
    public func verify(_ requestDictionary: [String : Any], completed: @escaping ([String: Any]?, Error?) -> Void) {
        guard !configuration.miPass.baseUrl.isEmpty else { fatalError("[MitekPlatform] Url is not set") }
        guard let url = URL(string: configuration.miPass.baseUrl + "/verify") else {
            fatalError("[MitekPlatform] Couldn't initialize URL with string: \(configuration.miPass.baseUrl)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let data = try JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted)
            
            request.httpBody = data
            
            // Uncomment to save request json for debugging purposes
            //save(data, suffix: "request")
            
            miPassTokenManager.getToken { [unowned self] (token, error) in
                if let error = error {
                    completed(nil, error)
                    return
                }
                
                guard let token = token else { fatalError("[MitekPlatform] token is nil") }
                
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                self.submit(request: request, completed: completed)
            }
        } catch {
            print("[MitekPlatform] couldn't create a request body data: \(error.localizedDescription)")
            completed(nil, error)
        }
    }
    
    public func deleteEnrollment(withId id: String, completed: @escaping ([String: Any]?, Error?) -> Void) {
        guard !configuration.miPass.baseUrl.isEmpty else { fatalError("[MitekPlatform] MiPass url is not set") }
        guard let url = URL(string: configuration.miPass.baseUrl + "/enroll/" + id) else {
            fatalError("[MitekPlatform] Couldn't initialize MiPass URL with string: \(configuration.miPass.baseUrl)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        miPassTokenManager.getToken { [unowned self] (token, error) in
            if let error = error {
                completed(nil, error)
                return
            }
            
            guard let token = token else { fatalError("[MitekPlatform] token is nil") }
            
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            self.submit(request: request, completed: completed)
        }
    }
    
    private func submit(request: URLRequest, completed: @escaping ([String: Any]?, Error?) -> Void) {
        self.dataTask?.cancel()
        
        print("[MitekPlatform] Submitting request...")
        self.dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var processingTime: Double = 0.0
            
            if let error = error {
                print("[MitekPlatform] An error occured when sending the request to the server")
                completed(nil, error)
                return
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 && httpResponse.statusCode < 600 {
                    print("[MitekPlatform] HTTP error: \(httpResponse.statusCode)")
                    completed(nil, NSError(domain: NSURLErrorDomain, code: httpResponse.statusCode, userInfo: nil))
                    return
                }
                if let allHeaderFields = httpResponse.allHeaderFields as? [String : String] {
                    if let serverProcessingTime = allHeaderFields["mitek-ServerProcessingTime"], let time = TimeInterval(serverProcessingTime) {
                        processingTime = time
                    }
                }
            }
            
            guard let data = data else { fatalError("[MitekPlatform] response data is nil") }
            
            // Uncomment to save response json for debugging purposes
            //self.save(data, suffix: "response")
            
            do {
                guard var jsonResponse = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any] else {
                    throw MitekPlatformError.error("[MitekPlatform] Couldn't serialize server response")
                }
                
                jsonResponse["processingTime"] = processingTime
                
                completed(jsonResponse, nil)
            } catch let error {
                print("[MitekPlatform] An error occured when parsing the response json: \(error.localizedDescription)")
                completed(nil, error)
            }
        }
        
        self.dataTask?.resume()
    }
}
