//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Максим on 26.12.2025.
//
import Logging
import UIKit
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
        ProgressHUD.animationType = .circleStrokeSpin  // в библиотеке ProgressHUD нет .systemActivityIndicator
        ProgressHUD.colorHUD = .white
        ProgressHUD.colorAnimation = .black
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let sceneConfiguration = UISceneConfiguration(
            name: "Main",
            sessionRole: connectingSceneSession.role
        )
        
        sceneConfiguration.delegateClass = SceneDelegate.self
        
        return sceneConfiguration
    }
}
