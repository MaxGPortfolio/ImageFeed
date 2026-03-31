//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Максим on 01.04.2026.
//

@testable import ImageFeed
import XCTest

@MainActor
final class ProfileTests: XCTestCase {

    // MARK: - Helpers

    private func makeProfile() -> Profile {
        Profile(
            result: ProfileResult(
                username: "test_user",
                firstName: "Максим",
                lastName: "Иванов",
                bio: "iOS developer"
            )
        )
    }

    // MARK: - ViewController

    func testViewControllerCallsPresenterViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()

        viewController.presenter = presenter

        viewController.loadViewIfNeeded()

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewControllerCallsPresenterViewWillAppear() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()

        viewController.presenter = presenter

        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()

        XCTAssertTrue(presenter.viewWillAppearCalled)
    }

    // MARK: - Presenter

    func testPresenterUpdatesProfileDetailsOnViewDidLoad() {
        let profileService = ProfileServiceSpy()
        profileService.profile = makeProfile()

        let profileImageService = ProfileImageServiceSpy()
        let logoutService = ProfileLogoutServiceSpy()

        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: logoutService
        )
        let view = ProfileViewControllerSpy()
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(view.updateProfileDetailsCalled)
        XCTAssertEqual(view.receivedName, "Максим Иванов")
        XCTAssertEqual(view.receivedUsername, "@test_user")
        XCTAssertEqual(view.receivedBio, "iOS developer")
    }

    func testPresenterUpdatesAvatarOnViewDidLoad() {
        let profileService = ProfileServiceSpy()
        profileService.profile = makeProfile()

        let profileImageService = ProfileImageServiceSpy()
        profileImageService.avatarURL = "https://example.com/avatar.jpg"

        let logoutService = ProfileLogoutServiceSpy()

        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: logoutService
        )
        let view = ProfileViewControllerSpy()
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(view.updateAvatarCalled)
        XCTAssertEqual(view.receivedAvatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }

    func testPresenterShowsPlaceholderAvatarWhenURLIsNil() {
        let profileService = ProfileServiceSpy()
        profileService.profile = makeProfile()

        let profileImageService = ProfileImageServiceSpy()
        profileImageService.avatarURL = nil

        let logoutService = ProfileLogoutServiceSpy()

        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: logoutService
        )
        let view = ProfileViewControllerSpy()
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(view.updateAvatarCalled)
        XCTAssertNil(view.receivedAvatarURL)
    }

    func testPresenterShowsLogoutAlertWhenLogoutButtonTapped() {
        let presenter = ProfilePresenter(
            profileService: ProfileServiceSpy(),
            profileImageService: ProfileImageServiceSpy(),
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        let view = ProfileViewControllerSpy()
        presenter.view = view

        presenter.didTapLogoutButton()

        XCTAssertTrue(view.showLogoutAlertCalled)
    }

    func testPresenterLogsOutAndSwitchesToSplash() {
        let logoutService = ProfileLogoutServiceSpy()

        let presenter = ProfilePresenter(
            profileService: ProfileServiceSpy(),
            profileImageService: ProfileImageServiceSpy(),
            profileLogoutService: logoutService
        )
        let view = ProfileViewControllerSpy()
        presenter.view = view

        presenter.didConfirmLogout()

        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(view.switchToSplashViewControllerCalled)
    }
}
