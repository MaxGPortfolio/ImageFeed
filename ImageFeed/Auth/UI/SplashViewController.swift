//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Максим on 06.02.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = storage.token, !token.isEmpty else {
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
        
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
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
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            guard let token = self.storage.token else { return }
            self.fetchProfile(token: token)
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                let username = profile.username
                profileImageService.fetchProfileImageURL(username: username) { _ in }
                switchToTabBarController()
            case .failure(let error):
                self.storage.token = nil

                 if self.presentedViewController == nil {
                     self.presentAuthViewController()
                 } else {
                     self.dismiss(animated: true) { [weak self] in
                         self?.presentAuthViewController()
                     }
                 }
                print("❌ Profile error:", error)
            }
        }
    }
}

private extension SplashViewController {
    
    func setupUI() {
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
