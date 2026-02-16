//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим on 16.01.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let avatarSize: CGFloat = 70
        static let avatarTopInset: CGFloat = 32
        static let horizontalInset: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
        static let logoutButtonSize: CGFloat = 44
        static let nameFontSize: CGFloat = 23
        static let secondaryFontSize: CGFloat = 13
    }
    
    // MARK: - Models
    
    struct Profile {
        let name: String
        let username: String
        let bio: String
        let avatarImageName: String
    }
    
    // MARK: - Private Properties
  
    private let profile = Profile(
        name: "Екатерина Новикова",
        username: "@ekaterina_nov",
        bio: "Hello, world!",
        avatarImageName: "MockProfilePhoto"
    )
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.nameFontSize, weight: .bold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.secondaryFontSize, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.secondaryFontSize, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.exit, for: .normal)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
        configureUI()
        configure(with: profile)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAvatarCornerRadius()
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
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.logoutButtonSize)
        ])
    }
    
    private func setupActions() {
        logoutButton.addTarget(self,
                               action: #selector(didTapLogoutButton),
                               for: .touchUpInside
        )
    }
    
    // MARK: - Configuration
    
    private func configureUI() {
        view.backgroundColor = .ypBlack
    }
    
    private func configure(with profile: Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.username
        bioLabel.text = profile.bio
        profileImageView.image = UIImage(named: profile.avatarImageName)
    }
    
    // MARK: - Private Helpers
    
    private func updateAvatarCornerRadius() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLogoutButton() { }
}
