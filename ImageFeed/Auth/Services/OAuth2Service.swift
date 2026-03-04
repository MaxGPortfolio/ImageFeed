//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим on 05.02.2026.
//

import Foundation

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
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            print("[OAuth2Service.fetchAuthToken]: duplicate code ignored code=\(code)")
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service.fetchAuthToken]: OAuth2ServiceError.invalidRequest request=nil code=\(code)")
            task = nil
            lastCode = nil
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }
        
        var requestTask: URLSessionTask?
        
        requestTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else {
                print("[OAuth2Service.fetchAuthToken]: NetworkError.urlSessionError self=nil code=\(code)")
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
                completion(.success(body.accessToken))
            case .failure(let error):
                print("[OAuth2Service.fetchAuthToken]: \(error) code=\(code)")
                completion(.failure(error))
            }
        }
        self.task = requestTask
        requestTask?.resume()
    }
    
    // MARK: - Private
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuthConstants.tokenURLString) else {
            print("❌ Failed to create URLComponents for token request")
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
            print("❌ Failed to build token request URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
