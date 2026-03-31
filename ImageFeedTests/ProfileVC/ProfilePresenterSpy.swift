//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Максим on 01.04.2026.
//

@testable import ImageFeed
import Foundation

// MARK: - ProfilePresenterSpy

@MainActor
final class ProfilePresenterSpy: ProfilePresenterProtocol {
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?

    // MARK: - State
    var viewDidLoadCalled = false
    var viewWillAppearCalled = false
    var didTapLogoutButtonCalled = false
    var didConfirmLogoutCalled = false

    // MARK: - Public
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func viewWillAppear() {
        viewWillAppearCalled = true
    }

    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }

    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
}
