//
//  AuthNavigationController.swift
//  ImageFeed
//
//  Created by Максим on 07.02.2026.
//

import UIKit

final class AuthNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
