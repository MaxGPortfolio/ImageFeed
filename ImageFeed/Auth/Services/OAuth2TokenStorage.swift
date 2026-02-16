//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим on 06.02.2026.
//

import Foundation

final class OAuth2TokenStorage {

    // MARK: - Constants
    private enum Constants {
        static let tokenKey = "OAuthToken"
    }

    // MARK: - Shared
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Init
    
    private init() {}

    // MARK: - Token
    var token: String? {
        get {
            userDefaults.string(forKey: Constants.tokenKey)
        }
        set {
            if let token = newValue {
                userDefaults.set(token, forKey: Constants.tokenKey)
            } else {
                userDefaults.removeObject(forKey: Constants.tokenKey)
            }
        }
    }
}

