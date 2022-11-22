//
//  MitekPlatformTokenManager.swift
//  MitekPlatform
//
//  Created by Stas Tsuprenko on 7/20/20.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

import UIKit
/**
 Mitek platform token manager
 */
public class MitekPlatformTokenManager {
    private var url: String = ""
    private var id: String = ""
    private var secret: String = ""
    private var scope: String = ""
    
    private var token: String?
    
    private var dataTask: URLSessionDataTask?
    
    private var tokenExpirationTimer: Timer?
    /**
     Sets info necessary for gettign a token
     */
    public func set(url: String, id: String, secret: String, scope: String) {
        self.url = url
        self.id = id
        self.secret = secret
        self.scope = scope
    }
    /**
     Gets a token
     */
    public func getToken(completed: @escaping (String?, Error?) -> Void) {
        if let token = token {
            completed(token, nil)
        } else {
            refreshToken(completed: completed)
        }
    }
    
    private func refreshToken(completed: @escaping (String?, Error?) -> Void) {
        guard !url.isEmpty, !id.isEmpty, !secret.isEmpty, !scope.isEmpty else { fatalError("[Token Manager] url, id, secret and scope are not set") }
        
        guard let url = URL(string: url) else { fatalError("[Token Manager] Couldn't initialize URL with string: \(url)") }
        
        let requestBodyComponents: [String] = [
            "client_id=\(id)",
            "client_secret=\(secret)",
            "scope=\(scope)",
            "grant_type=client_credentials"
        ]
        
        guard let string = requestBodyComponents.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let bodyData = string.data(using: .utf8) else { fatalError("[Token Manager] Couldn't get request body data") }
        
        print("[Token Manager] Getting Token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        dataTask?.cancel()
        
        dataTask = URLSession.shared.dataTask(with: request) { [unowned self] (data, response, error) in
            if let error = error {
                print("[Token Manager] An error occured when sending the request to the server")
                completed(nil, error)
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 && httpResponse.statusCode < 600 {
                print("[Token Manager] HTTP error: \(httpResponse.statusCode)")
                completed(nil, NSError(domain: NSURLErrorDomain, code: httpResponse.statusCode, userInfo: nil))
            }
            
            guard let data = data else { fatalError("[Token Manager] response data is nil") }
            
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any] else { return }
                
                var expirationTimeInterval: Double = 270.0
                if let expiresIn = jsonResponse["expires_in"] as? Double {
                    expirationTimeInterval = expiresIn - 30.0
                }
                
                if let token = jsonResponse["access_token"] as? String {
                    print("[Token Manager] Received token")
                    DispatchQueue.main.async { [unowned self] in
                        self.tokenExpirationTimer = Timer.scheduledTimer(timeInterval: expirationTimeInterval,
                                                                         target: self,
                                                                         selector: #selector(self.tokenExpired),
                                                                         userInfo: nil,
                                                                         repeats: false)
                    }
                    self.token = token
                    completed(token, nil)
                } else {
                    completed(nil, MitekPlatformError.error("Token is absent in the response json"))
                }
            } catch let error {
                print("[Token Manager] An error occured when parsing the response json: \(error.localizedDescription)")
                completed(nil, error)
            }
        }
        
        dataTask?.resume()
    }
    
    @objc private func tokenExpired() {
        if let timer = tokenExpirationTimer {
            timer.invalidate()
            tokenExpirationTimer = nil
        }
        
        self.token = nil
    }
}
