//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим on 05.02.2026.
//

import Foundation
import Logging

// MARK: - Models

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class OAuth2Service {
    
    // MARK: - OAuth-specific constants
    
    private enum OAuthConstants {
        static let tokenURLString = "https://unsplash.com/oauth/token"
        static let grantTypeAuthorizationCode = "authorization_code"
    }
    
    // MARK: - Errors
    
    private enum OAuth2ServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Shared
    
    static let shared = OAuth2Service()
    
    // MARK: - Properties
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private let urlSession = URLSession.shared
    private let logger = Logger(label: "OAuth2Service")
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            logger.warning("OAuth token request ignored: duplicate authorization code")
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            logger.error("OAuth token request failed: invalid request")
            task = nil
            lastCode = nil
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }
        
        var requestTask: URLSessionTask?
        let logger = self.logger
        
        requestTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else {
                logger.error("OAuth token request failed: service deallocated before completion")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard self.task === requestTask else { return }
            
            defer {
                self.task = nil
                self.lastCode = nil
            }
            
            switch result {
            case .success(let body):
                logger.info("OAuth token successfully received")
                completion(.success(body.accessToken))
            case .failure(let error):
                logger.error("OAuth token request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = requestTask
        requestTask?.resume()
    }
    
    // MARK: - Private
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuthConstants.tokenURLString) else {
            logger.error("Failed to create URLComponents for OAuth token request")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: OAuthConstants.grantTypeAuthorizationCode),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            logger.error("Failed to build OAuth token request URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
