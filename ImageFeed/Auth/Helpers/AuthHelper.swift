//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Максим on 26.03.2026.
//

import Foundation
import Logging

public protocol AuthHelperProtocol: AnyObject {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    // MARK: - Private Properties
    
    private let logger = Logger(label: "AuthHelper")
    private let configuration: AuthConfiguration
    
    // MARK: - Init
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Public
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            logger.error("Failed to build authorize URL")
            return nil
        }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if
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
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            logger.error("Failed to create URLComponents for authorize URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope),
        ]
        
        return urlComponents.url
    }
}
