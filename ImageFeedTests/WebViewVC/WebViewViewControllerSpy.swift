//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Максим on 27.03.2026.
//

import ImageFeed
import Foundation

@MainActor
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    
    // MARK: - Public Properties
    
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    // MARK: - State
    
    var loadRequestCalled = false
    
    // MARK: - Public
    
    func simulateViewDidLoad() {
        presenter?.viewDidLoad()
    }
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) { }
    
    func setProgressHidden(_ isHidden: Bool) { }
    
    func cancelAuthFlow() { }
}
