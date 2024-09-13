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
        // Reset a token if a new configuration is set
        self.token = nil
    }
    /**
     Gets a token
     */
    public func getToken(completed: @escaping (String?, MitekPlatformError?) -> Void) {
        if let token = token {
            completed(token, nil)
        } else {
            refreshToken(completed: completed)
        }
    }
    
    private func refreshToken(completed: @escaping (String?, MitekPlatformError?) -> Void) {
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
                return completed(nil, .error(error.localizedDescription, -1))
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 && httpResponse.statusCode < 600 {
                print("[Token Manager] HTTP error: \(httpResponse.statusCode)")
                return completed(nil, .error("Undocumented error with code \(httpResponse.statusCode)", httpResponse.statusCode))
            }
            
            guard let data = data else {
                return completed(nil, .error("Expected token data but got nil", -1))
            }
            
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
                    completed(nil, MitekPlatformError.error("Token is absent in the server response", -1))
                }
            } catch let error {
                print("[Token Manager] An error occured when parsing the response json: \(error.localizedDescription)")
                completed(nil, .error(error.localizedDescription, -1))
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
