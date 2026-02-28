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
        static let feedTabImage = "tab_editorial_no_active"
        static let feedTabSelectedImage = "tab_editorial_active"
        static let profileTabImage = "tab_profile_no_active"
        static let profileTabSelectedImage = "tab_profile_active"
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
            image: UIImage(named: Constants.feedTabImage),
            selectedImage: UIImage(named: Constants.feedTabSelectedImage)
        )
        
        profileNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: Constants.profileTabImage),
            selectedImage: UIImage(named: Constants.profileTabSelectedImage)
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
