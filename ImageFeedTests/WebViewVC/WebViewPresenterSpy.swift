//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Максим on 27.03.2026.
//

import ImageFeed
import Foundation

// MARK: - WebViewPresenterSpy

@MainActor
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    // MARK: - State
    var viewDidLoadCalled: Bool = false

    // MARK: - Public Properties
    var view: WebViewViewControllerProtocol?

    // MARK: - Public
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? { nil }
}
