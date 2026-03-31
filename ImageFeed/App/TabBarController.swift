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
    
    // MARK: - Setup
    
    private func setupViewControllers() {
        
        let imagesListVC = ImagesListViewController()
        let imagesListPresenter: ImagesListPresenter = ImagesListPresenter()
        imagesListVC.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListVC
        
        let profileVC = ProfileViewController()
        let profilePresenter: ProfilePresenter = ProfilePresenter()
        profileVC.presenter = profilePresenter
        profilePresenter.view = profileVC
        
        let feedNav = UINavigationController(rootViewController: imagesListVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
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
        
        viewControllers = [feedNav, profileNav,]
        
        feedNav.setNavigationBarHidden(true, animated: false)
        profileNav.setNavigationBarHidden(true, animated: false)
        
        feedNav.view.backgroundColor = .ypBlack
        profileNav.view.backgroundColor = .ypBlack
    }
    
    // MARK: - Appearance
    
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
