//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Максим on 27.03.2026.
//

import ImageFeed
import Foundation

@MainActor
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
