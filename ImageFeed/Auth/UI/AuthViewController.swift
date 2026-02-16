//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Максим on 29.01.2026.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let showWebViewSegueIdentifier = "ShowWebView"
        static let backArrowImageName = "Backward_Black"
        static let navigationTintColorName = "ypBlack"
    }

    // MARK: - Private Properties
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage.shared

    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.showWebViewSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard
            let webViewViewController = segue.destination as? WebViewViewController
        else {
            assertionFailure("Failed to prepare for \(Constants.showWebViewSegueIdentifier)")
            return
        }
        webViewViewController.delegate = self
    }

    // MARK: - Private
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: Constants.backArrowImageName)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: Constants.backArrowImageName)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(named: Constants.navigationTintColorName)
    }

    private func closeWebView(_ viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController.dismiss(animated: true)
        }
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchAuthToken(code: code) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let token):
                self.tokenStorage.token = token
                print("✅ saved token:", self.tokenStorage.token ?? "nil")
                closeWebView(vc)
                delegate?.didAuthenticate(self)
            case .failure(let error):
                print("❌ Failed to fetch token:", error)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        closeWebView(vc)
    }
}
