//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Максим on 29.01.2026.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {

    // MARK: - Constants
    
    private enum Constants {
        static let backArrowImageName = "Backward_Black"
        static let navigationTintColorName = "ypBlack"
    }
    
    private enum UIConstants {
        static let loginFontSize: CGFloat = 17
        static let loginCornerRadius: CGFloat = 16
        static let authLogoImageViewSize: CGFloat = 60
        static let horizontalInsets: CGFloat = 16
        static let verticalInsets: CGFloat = 90
        static let loginButtonHeight: CGFloat = 48
    }

    // MARK: - Private Properties
    
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private lazy var authLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_screen_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor(named: "ypBlack") ?? .black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIConstants.loginFontSize, weight: .bold)
        button.backgroundColor = .ypWhite
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = UIConstants.loginCornerRadius
        return button
    }()
    
    // MARK: - Public Properties
    
    weak var delegate: AuthViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        setupUI()
        setupConstraints()
        setupActions()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
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
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        closeWebView(vc)
        UIBlockingProgressHUD.show()
        
        fetchAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            
            switch result {
            case .success(let token):
                self.tokenStorage.token = token
                print("✅ saved token:", self.tokenStorage.token ?? "nil")
                delegate?.didAuthenticate(self)
            case .failure(let error):
                print("❌ Failed to fetch token:", error)
                self.showAuthErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        closeWebView(vc)
    }
}

extension AuthViewController {
    private func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchAuthToken(code) { result in
            completion(result)
        }
    }
}

private extension AuthViewController {
    
    func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(authLogoImageView)
        view.addSubview(loginButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            authLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authLogoImageView.heightAnchor.constraint(equalToConstant: UIConstants.authLogoImageViewSize),
            authLogoImageView.widthAnchor.constraint(equalToConstant: UIConstants.authLogoImageViewSize),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.horizontalInsets),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.horizontalInsets),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.verticalInsets),
            loginButton.heightAnchor.constraint(equalToConstant: UIConstants.loginButtonHeight)
     ])
    }
    
    private func setupActions() {
        loginButton.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )
    }
    
    @objc
    func didTapLoginButton() {
        let webVC = WebViewViewController()
        webVC.delegate = self
        
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    
    
}
