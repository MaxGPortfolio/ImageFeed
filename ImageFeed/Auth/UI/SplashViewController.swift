//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Максим on 06.02.2026.
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
        static let storyboardName = "Main"
        static let tabBarControllerStoryboardID = "TabBarViewController"
    }

    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard tokenStorage.token != nil else {
            performSegue(withIdentifier: Constants.showAuthenticationScreenSegueIdentifier, sender: nil)
            return
        }
        
        switchToTabBarController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Private

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: Constants.storyboardName, bundle: .main)
            .instantiateViewController(withIdentifier: Constants.tabBarControllerStoryboardID)

        window.rootViewController = tabBarController
    }
}

// MARK: - Navigation
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.showAuthenticationScreenSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? AuthViewController
        else {
            assertionFailure("Failed to prepare for \(Constants.showAuthenticationScreenSegueIdentifier)")
            return
        }
        viewController.delegate = self
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            switchToTabBarController()
        }
    }
}
