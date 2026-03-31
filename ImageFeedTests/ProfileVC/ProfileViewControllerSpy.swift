//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Максим on 01.04.2026.
//

@testable import ImageFeed
import Foundation

// MARK: - ProfileViewControllerSpy
@MainActor
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    // MARK: - Public Properties
    var presenter: ProfilePresenterProtocol?

    // MARK: - State
    var updateProfileDetailsCalled = false
    var receivedName: String?
    var receivedUsername: String?
    var receivedBio: String?

    var updateAvatarCalled = false
    var receivedAvatarURL: URL?

    var showLogoutAlertCalled = false
    var switchToSplashViewControllerCalled = false

    // MARK: - Public
    func updateProfileDetails(name: String, username: String, bio: String) {
        updateProfileDetailsCalled = true
        receivedName = name
        receivedUsername = username
        receivedBio = bio
    }

    func updateAvatar(with url: URL?) {
        updateAvatarCalled = true
        receivedAvatarURL = url
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }

    func switchToSplashViewController() {
        switchToSplashViewControllerCalled = true
    }
}
