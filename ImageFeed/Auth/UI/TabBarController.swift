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
            image: UIImage(named: "tab_editorial_no_active"),
            selectedImage: UIImage(named: "tab_editorial_active")
        )
        
        profileNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_no_active"),
            selectedImage: UIImage(named: "tab_profile_active")
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
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.iconColor = .ypGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ypGray]

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.standardAppearance = appearance
    }
}


