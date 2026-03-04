//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Максим on 25.02.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let feedTabImage = UIImage(resource: .tabEditorialNoActive)
        static let feedTabSelectedImage = UIImage(resource: .tabEditorialActive)
        static let profileTabImage = UIImage(resource: .tabProfileNoActive)
        static let profileTabSelectedImage = UIImage(resource: .tabProfileActive)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupAppearance()
    }
    
    // MARK: - Private
    
    private func setupViewControllers() {
        
        let feedNav = UINavigationController(rootViewController: ImagesListViewController())
        let profileNav = UINavigationController(rootViewController: ProfileViewController())
        
        feedNav.tabBarItem = UITabBarItem(
            title: "",
            image: Constants.feedTabImage,
            selectedImage: Constants.feedTabSelectedImage
        )
        
        profileNav.tabBarItem = UITabBarItem(
            title: "",
            image: Constants.profileTabImage,
            selectedImage: Constants.profileTabSelectedImage
        )
        
        viewControllers = [feedNav, profileNav]
        
        feedNav.setNavigationBarHidden(true, animated: false)
        profileNav.setNavigationBarHidden(true, animated: false)
        
        feedNav.view.backgroundColor = .ypBlack
        profileNav.view.backgroundColor = .ypBlack
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .ypBlack
        
        let stacked = appearance.stackedLayoutAppearance
        
        stacked.selected.iconColor = .white
        stacked.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        stacked.normal.iconColor = .ypGray
        stacked.normal.titleTextAttributes = [.foregroundColor: UIColor.ypGray]

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.standardAppearance = appearance
    }
}
