//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Максим on 26.03.2026.
//

import Foundation

@MainActor
public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

@MainActor
final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: - Constants
    private enum WebViewPresenterConstants {
        static let progressComplete: Float = 1.0
        static let progressHideThreshold: Float = 0.001
    }
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        loadAuthView()
    }
    
    private func loadAuthView() {
        guard let request = authHelper.authRequest() else {
            view?.cancelAuthFlow()
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - WebViewPresenterConstants.progressComplete) <= WebViewPresenterConstants.progressHideThreshold
    }
}
