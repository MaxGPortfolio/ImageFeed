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
    
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    var loadRequestCalled = false
    
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
