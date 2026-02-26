//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Максим on 25.02.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupAppearance()
    }
    
    private func setupViewControllers() {
        
        let feedNav = UINavigationController(rootViewController: ImagesListViewController())
        let profileNav = UINavigationController(rootViewController: ProfileViewController())
        
        feedNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        profileNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        
        viewControllers = [feedNav, profileNav]
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.standardAppearance = appearance
    }
}
