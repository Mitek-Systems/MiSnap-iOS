//
//  MitekPlatform.swift
//  MitekPlatform
//
//  Created by Stas Tsuprenko on 7/20/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import Foundation

private extension String {
    var isValid: Bool {
        if isEmpty || contains("your_") || contains("your-") { return false }
        return true
    }
}
/**
 Platform error
 */
public enum MitekPlatformError: Error {
    case error(String, Int)
    
    var stringValue: String {
        switch self {
        case .error(let string, let int):
            switch int {
            case 400:   return "Bad Request"
            case 401:   return "Client Authentication Failed"
            case 403:   return "Forbidden"
            case 404:   return "Not Found"
            case 500:   return "Internal Server Error"
            case 502:   return "Bad Gateway"
            default:    return string
            }
        }
    }
}
/**
 API
 */
public enum MitekPlatformAPI: Int {
    case v2 = 0
    case v3 = 1
    
    var stringValue: String {
        switch self {
        case .v2: return "v2"
        case .v3: return "v3"
        }
    }
}
/**
 Agent assist mode
 */
public enum MitekPlatformAgentAssistMode: Int {
    case manual = 0
    case expert = 1
    
    var stringValue: String {
        switch self {
        case .manual: return "Manual"
        case .expert: return "Expert"
        }
    }
}
/**
 HTTP method
 */
public enum MitekPlatformHttpMethod: Int {
    case get        = 0
    case post       = 1
    case put        = 2
    case delete     = 3
    
    var stringValue: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
}
/**
 Mitek platform configuration
 */
public class MitekPlatformConfiguration: NSObject {
    private(set) var url: String = ""
    private(set) var id: String = ""
    private(set) var secret: String = ""
    private(set) var scope = ""
    /**
     Indicates whether a configuration is valid
     */
    public var isValid: Bool {
        var valid = url.isValid
        valid = valid && id.isValid
        valid = valid && secret.isValid
        valid = valid && scope.isValid
        return valid
    }
    /**
     Default initializer
     */
    public override init() {
        super.init()
    }
    /**
     Initializes configuration with credentials
     */
    public init(withUrl url: String, id: String, secret: String, scope: String) {
        self.url = url
        self.id = id
        self.secret = secret
        self.scope = scope
        super.init()
    }
}
/**
 Mitek platform
 */
public class MitekPlatform: NSObject {
    private static var sharedInstance: MitekPlatform?
    
    private(set) var configurationV2 = MitekPlatformConfiguration()
    private(set) var configurationV3 = MitekPlatformConfiguration()
    
    private var dataTaskV2: URLSessionDataTask?
    private var dataTaskV3: URLSessionDataTask?
    private var tokenManagerV2 = MitekPlatformTokenManager()
    private var tokenManagerV3 = MitekPlatformTokenManager()
    
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
    /**
     Destroys shared instance
     */
    public class func destroyShared() {
        if let sharedInstance = self.sharedInstance {
            sharedInstance.cancel()
            self.sharedInstance = nil
        }
    }
    /**
     Cancels any requests in progress
     */
    public func cancel() {
        self.dataTaskV2?.cancel()
        self.dataTaskV3?.cancel()
        URLSession.shared.invalidateAndCancel()
    }
    /**
     Sets a Mitek platform configuration
     */
    public func set(configuration: MitekPlatformConfiguration?, api: MitekPlatformAPI) {
        guard let configuration = configuration, configuration.isValid else { return }
        switch api {
        case .v2:
            self.configurationV2 = configuration
            tokenManagerV2.set(url: configuration.url + "/connect/token",
                               id: configuration.id,
                               secret: configuration.secret,
                               scope: configuration.scope)
        case .v3:
            self.configurationV3 = configuration
            tokenManagerV3.set(url: configuration.url + "/oauth2/token",
                               id: configuration.id,
                               secret: configuration.secret,
                               scope: configuration.scope)
        }
    }
    /**
     MobileVerifyAuto Authentication
     */
    public func authenticateAuto(_ requestDictionary: [String : Any], api: MitekPlatformAPI, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        let path: String
        switch api {
        case .v2:
            guard configurationV2.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer. Got \"\(configurationV2.scope)\"", -1))
            }
            path = "/api/verify/v2/dossier"
        case .v3:
            return completed(nil, .error("V3 API currently doesn't support auto authentication. Please use V2", -1))
        }
        
        submit(requestDictionary: requestDictionary, to: path, method: .post, api: api, completed: completed)
    }
    /**
     MobileVerifyAgentAssist Document Authentication
     */
    public func authenticateDocumentAgentAssist(_ requestDictionary: [String : Any], api: MitekPlatformAPI, mode: MitekPlatformAgentAssistMode, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        let path: String
        switch api {
        case .v2:
            return completed(nil, .error("V2 API currently doesn't support agent assist document athentication. Please use V3 API", -1))
        case .v3:
            guard configurationV3.scope.isValid else {
                return completed(nil, .error("A valid scopeV3 has to be passed into `MitekPlatformConfiguration` initializer. Got \"\(configurationV3.scope)\"", -1))
            }
            switch mode {
            case .manual:
                path = "/identity/verify/v3/id-document/manual"
            case .expert:
                path = "/identity/verify/v3/id-document/expert"
            }
        }
        
        submit(requestDictionary: requestDictionary, to: path, method: .post, api: api, completed: completed)
    }
    /**
     MiPass Face and/or Voice Enrollment
     */
    public func enroll(_ requestDictionary: [String : Any], api: MitekPlatformAPI, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        let path: String
        switch api {
        case .v2:
            guard configurationV2.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer for V2 API. Got \"\(configurationV2.scope)\"", -1))
            }
            path = "/api/biometric/v1/enroll"
        case .v3:
            guard configurationV3.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer for V3 API. Got \"\(configurationV3.scope)\"", -1))
            }
            path = "/identity/biometric/v3/enroll"
        }
        
        submit(requestDictionary: requestDictionary, to: path, method: .post, api: api, completed: completed)
    }
    /**
     MiPass Face and/or Voice Verification against an Enrolled ones
     */
    public func verify(_ requestDictionary: [String : Any], api: MitekPlatformAPI, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        let path: String
        switch api {
        case .v2:
            guard configurationV2.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer for V2 API. Got \"\(configurationV2.scope)\"", -1))
            }
            path = "/api/biometric/v1/verify"
        case .v3:
            guard configurationV3.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer for V3 API. Got \"\(configurationV3.scope)\"", -1))
            }
            path = "/identity/biometric/v3/verify"
        }
        
        submit(requestDictionary: requestDictionary, to: path, method: .post, api: api, completed: completed)
    }
    /**
     MiPass Deletion of enrolled Face and/or Voice
     */
    public func deleteEnrollment(withId id: String, api: MitekPlatformAPI, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        var path: String
        switch api {
        case .v2:
            guard configurationV2.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer for V2 API. Got \"\(configurationV2.scope)\"", -1))
            }
            path = "/api/biometric/v1/enroll/"
        case .v3:
            guard configurationV3.scope.isValid else {
                return completed(nil, .error("A valid scope has to be passed into `MitekPlatformConfiguration` initializer for V3 API. Got \"\(configurationV3.scope)\"", -1))
            }
            path = "/identity/biometric/v3/enroll/"
        }
        path += id
        
        submit(to: path, method: .delete, api: api, completed: completed)
    }
    
    private func submit(requestDictionary: [String : Any]? = nil, to path: String, method: MitekPlatformHttpMethod, api: MitekPlatformAPI, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        let fullPath: String
        switch api {
        case .v2:
            guard configurationV2.url.isValid else {
                return completed(nil, .error("A valid URL has to be passed into `MitekPlatformConfiguration` initializer for V2 API. Got \"\(configurationV2.url)\"", -1))
            }
            guard configurationV2.id.isValid && configurationV2.secret.isValid else {
                return completed(nil, .error("Valid credentials have to be passed into `MitekPlatformConfiguration` initializer for V2 API. Got id: \"\(configurationV2.id)\", secret: \"\(configurationV2.secret)\"", -1))
            }
            fullPath = configurationV2.url + path
        case .v3:
            guard configurationV3.url.isValid else {
                return completed(nil, .error("A valid URL has to be passed into `MitekPlatformConfiguration` initializer for V3 API. Got \"\(configurationV3.url)\"", -1))
            }
            guard configurationV3.id.isValid && configurationV3.secret.isValid else {
                return completed(nil, .error("Valid credentials have to be passed into `MitekPlatformConfiguration` initializer for V3 API. Got id: \"\(configurationV3.id)\", secret: \"\(configurationV3.secret)\"", -1))
            }
            fullPath = configurationV3.url + path
        }
        
        guard let url = URL(string: fullPath) else {
            return completed(nil, .error("Couldn't initialize URL with string: \"\(api == .v2 ? configurationV2.url : configurationV3.url)\"", -1))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.stringValue
        
        if let requestDictionary = requestDictionary {
            guard let data = try? JSONSerialization.data(withJSONObject: requestDictionary, options: .prettyPrinted) else {
                return completed(nil, .error("Couldn't serialize request dictionary", -1))
            }
            
            request.httpBody = data
            
            // Uncomment to save request json for debugging purposes
            //save(data, suffix: "request")
        }
        
        switch api {
        case .v2:
            tokenManagerV2.getToken { [weak self] (token, error) in
                guard let self = self else { return }
                if let error = error {
                    return completed(nil, error)
                }
                
                guard let token = token else {
                    return completed(nil, .error("Wasn't able to get V2 token", -1))
                }
                
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                self.submit(request: request, dataTask: self.dataTaskV2, completed: completed)
            }
        case .v3:
            tokenManagerV3.getToken { [weak self] (token, error) in
                guard let self = self else { return }
                if let error = error {
                    completed(nil, error)
                    return
                }
                
                guard let token = token else {
                    return completed(nil, .error("Wasn't able to get V3 token", -1))
                }
                
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                self.submit(request: request, dataTask: self.dataTaskV3, completed: completed)
            }
        }
    }
    
    private func submit(request: URLRequest, dataTask: URLSessionDataTask?, completed: @escaping ([String: Any]?, MitekPlatformError?) -> Void) {
        var dataTask = dataTask
        dataTask?.cancel()
        
        print("[MitekPlatform] Submitting request...")
        dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var processingTime: Double = 0.0
            
            if let error = error {
                print("[MitekPlatform] An error occured when sending the request to the server")
                completed(nil, .error(error.localizedDescription, -1))
                return
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 && httpResponse.statusCode < 600 {
                    print("[MitekPlatform] HTTP error: \(httpResponse.statusCode)")
                    completed(nil, .error("Server response status", httpResponse.statusCode))
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
            //save(data, suffix: "response")
            
            guard var jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any] else {
                return completed(nil, .error("Couldn't deserialize server response data", -1))
            }
            
            jsonResponse["processingTime"] = processingTime
            
            completed(jsonResponse, nil)
        }
        
        dataTask?.resume()
    }
}
