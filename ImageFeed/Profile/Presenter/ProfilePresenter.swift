//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Максим on 31.03.2026.
//
import Foundation
import Logging

// MARK: - ProfilePresenterProtocol
@MainActor
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }

    func viewDidLoad()
    func viewWillAppear()
    func didTapLogoutButton()
    func didConfirmLogout()
}

@MainActor
final class ProfilePresenter: ProfilePresenterProtocol {

    // MARK: - Private Properties

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol

    private var profileImageServiceObserver: NSObjectProtocol?

    private let logger = Logger(label: "ProfilePresenter")

    // MARK: - Public Properties

    weak var view: ProfileViewControllerProtocol?

    // MARK: - Init

    init(
        profileService: ProfileServiceProtocol? = nil,
        profileImageService: ProfileImageServiceProtocol? = nil,
        profileLogoutService: ProfileLogoutServiceProtocol? = nil
    ) {
        self.profileService = profileService ?? ProfileService.shared
        self.profileImageService = profileImageService ?? ProfileImageService.shared
        self.profileLogoutService = profileLogoutService ?? ProfileLogoutService.shared
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        logger.debug("ProfilePresenter viewDidLoad")
        updateProfileDetailsIfNeeded()

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: profileImageService,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.logger.debug("Profile avatar updated via notification")
                self?.updateAvatar()
            }
        }

        updateAvatar()
    }

    // MARK: - Public

    func viewWillAppear() {
        updateProfileDetailsIfNeeded()
    }

    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }

    func didConfirmLogout() {
        logger.info("User confirmed logout")
        profileLogoutService.logout()
        view?.switchToSplashViewController()
    }

    // MARK: - Private

    private func updateProfileDetailsIfNeeded() {
        guard let profile = profileService.profile else { return }

        view?.updateProfileDetails(
            name: profile.name,
            username: profile.loginName,
            bio: profile.bio
        )
    }

    private func updateAvatar() {
        guard
            let avatarURLString = profileImageService.avatarURL,
            let url = URL(string: avatarURLString)
        else {
            view?.updateAvatar(with: nil)
            return
        }

        view?.updateAvatar(with: url)
    }

    deinit {
        logger.debug("ProfilePresenter deinitialized")
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
