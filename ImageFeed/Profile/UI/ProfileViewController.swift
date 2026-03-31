//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим on 16.01.2026.
//

import UIKit
import Kingfisher

@MainActor
protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateProfileDetails(name: String, username: String, bio: String)
    func updateAvatar(with url: URL?)
    func showLogoutAlert()
    func switchToSplashViewController()
}

@MainActor
final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let avatarSize: CGFloat = 70
        static let avatarTopInset: CGFloat = 32
        
        static let horizontalInset: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
        
        static let logoutButtonSize: CGFloat = 44
        static let logoutImage = UIImage(resource: .exit)
        static let logoutButtonIdentifier = "logoutButton"
        
        static let nameLabelFontSize: CGFloat = 23
        static let nameLabelIdentifier = "nameLabel"
        
        static let usernameLabelIdentifier = "usernameLabel"
        
        static let secondaryFontSize: CGFloat = 13
        static let placeholderImage = UIImage(resource: .userPic)
    }
    
    // MARK: - Public Properties
    
    var presenter: ProfilePresenterProtocol?
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Private Properties
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.indicatorType = .activity
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.nameLabelFontSize, weight: .bold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = Constants.nameLabelIdentifier
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.secondaryFontSize, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = Constants.usernameLabelIdentifier
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.secondaryFontSize, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Constants.logoutImage.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = Constants.logoutButtonIdentifier
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupActions()
        configureUI()
        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAvatarCornerRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.avatarTopInset),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalInset),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Constants.verticalSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalInset),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.verticalSpacing),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Constants.verticalSpacing),
            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalInset),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.logoutButtonSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.logoutButtonSize),
        ])
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        logoutButton.addTarget(
            self,
            action: #selector(didTapLogoutButton),
            for: .touchUpInside
        )
    }
    
    // MARK: - Configuration
    
    private func configureUI() {
        view.backgroundColor = .ypBlack
    }
    
    // MARK: - Private Helpers
    
    private func updateAvatarCornerRadius() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    private func applyAvatar(with url: URL?) {
        guard let url else {
            profileImageView.image = Constants.placeholderImage
            return
        }
        
        profileImageView.kf.setImage(
            with: url,
            placeholder: Constants.placeholderImage,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ]
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLogoutButton() {
        presenter?.didTapLogoutButton()
    }
}

@MainActor
extension ProfileViewController: ProfileViewControllerProtocol {
    func updateProfileDetails(name: String, username: String, bio: String) {
        nameLabel.text = name
        usernameLabel.text = username
        bioLabel.text = bio
    }
    
    func updateAvatar(with url: URL?) {
        applyAvatar(with: url)
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.didConfirmLogout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    
    func switchToSplashViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
