//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим on 06.02.2026.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Constants
    private enum Constants {
        static let tokenKey = "OAuthToken"
    }
    
    // MARK: - Shared
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Token
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Constants.tokenKey)
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: Constants.tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Constants.tokenKey)
            }
        }
    }
}
