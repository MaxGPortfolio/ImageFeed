//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Максим on 29.01.2026.
//

import UIKit
import WebKit

private enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

    static let progressComplete: Double = 1.0
    static let progressHideThreshold: Double = 0.001
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!

    // MARK: - Public Properties
    weak var delegate: WebViewViewControllerDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
        updateProgress()
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == #keyPath(WKWebView.estimatedProgress) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        updateProgress()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        updateProgress()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
    }

    // MARK: - Private
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - WebViewConstants.progressComplete) <= WebViewConstants.progressHideThreshold
    }
}

private extension WebViewViewController {
    func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("❌ Failed to create URLComponents for authorize URL")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            print("❌ Failed to build authorize URL")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

