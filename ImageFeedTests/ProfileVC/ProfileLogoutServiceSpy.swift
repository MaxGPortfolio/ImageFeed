//
//  ProfileLogoutServiceSpy.swift
//  ImageFeed
//
//  Created by Максим on 01.04.2026.
//

@testable import ImageFeed
import Foundation

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled = false

    func logout() {
        logoutCalled = true
    }
}
