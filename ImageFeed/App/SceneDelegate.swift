//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Максим on 26.12.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Lifecycle
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
    }
}
