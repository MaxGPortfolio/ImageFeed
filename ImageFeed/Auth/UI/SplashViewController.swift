//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Максим on 06.02.2026.
//

import UIKit

// MARK: - Navigation Controller

final class AuthNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}

final class SplashViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let splashLogoImageName = UIImage(resource: .splashScreenLogo)
    }
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Constants.splashLogoImageName
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = tokenStorage.token, !token.isEmpty else {
            if presentedViewController == nil {
                presentAuthViewController()
            }
            return
        }
        fetchProfile(token: token)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Private
    
    private func presentAuthViewController() {
        let authVC = AuthViewController()
        authVC.delegate = self
        
        let navVC = AuthNavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalPresentationCapturesStatusBarAppearance = true
        present(navVC, animated: true)
    }
    
    private func switchToTabBarController() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        guard let token = tokenStorage.token, !token.isEmpty else { return }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            defer { UIBlockingProgressHUD.dismiss() }
            
            switch result {
            case .success(let profile):
                let username = profile.username
                profileImageService.fetchProfileImageURL(username: username) { _ in }
                switchToTabBarController()
            case .failure(let error):
                print("❌ Profile error:", error)
                let isUnauthorized = String(describing: error).contains("401")
                
                if isUnauthorized {
                    tokenStorage.token = nil
                    if presentedViewController == nil {
                        presentAuthViewController()
                    } else {
                        dismiss(animated: true) { [weak self] in
                            self?.presentAuthViewController()
                        }
                    }
                } else {
                    switchToTabBarController()
                }
            }
        }
    }
}

private extension SplashViewController {
    
    func setupViews() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
