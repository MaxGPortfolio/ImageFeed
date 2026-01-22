//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим on 16.01.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    struct Profile {
        let name: String
        let username: String
        let bio: String
        let avatarImageName: String
    }
  
    private let profile = Profile(
        name: "Екатерина Новикова",
        username: "@ekaterina_nov",
        bio: "Hello, world!",
        avatarImageName: "MockProfilePhoto"
    )
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let bioLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
     
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
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .ypBlack
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        
        usernameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = .ypGray
        
        bioLabel.font = .systemFont(ofSize: 13, weight: .regular)
        bioLabel.textColor = .ypWhite
        
        logoutButton.setImage(.exit, for: .normal)
        logoutButton.tintColor = .ypRed
    }
    
    private func configure(with profile: Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.username
        bioLabel.text = profile.bio
        profileImageView.image = UIImage(named: profile.avatarImageName)
    }
    
    private func setupActions() {
        logoutButton.addTarget(self,
                               action: #selector(didTapLogoutButton),
                               for: .touchUpInside
        )
    }
    
    @objc
    private func didTapLogoutButton() { }
}
