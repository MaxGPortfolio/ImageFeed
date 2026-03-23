//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Максим on 12.03.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Shared
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Public
    
    func logout() {
        tokenStorage.token = nil
        profileService.cleanProfile()
        profileImageService.cleanAvatar()
        imagesListService.cleanImagesList()
        
        cleanCookies()
    }
    
    // MARK: - Private
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
