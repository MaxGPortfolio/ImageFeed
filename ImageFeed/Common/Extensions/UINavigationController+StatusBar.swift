//
//  UINavigationController.swift
//  ImageFeed
//
//  Created by Максим on 28.02.2026.
//
import UIKit


extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
