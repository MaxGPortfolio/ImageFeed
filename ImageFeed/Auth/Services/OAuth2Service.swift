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

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {

    // MARK: - OAuth-specific constants
    
    private enum OAuthConstants {
        static let tokenURLString = "https://unsplash.com/oauth/token"
        static let httpMethodPost = "POST"
        static let grantTypeAuthorizationCode = "authorization_code"
    }

    // MARK: - Shared
    static let shared = OAuth2Service()

    // MARK: - Init
    private init() {}

    // MARK: - Public
    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ Invalid token request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body.accessToken))
                } catch {
                    print("❌ Failed to decode OAuth token:", error)
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
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
            URLQueryItem(name: "grant_type", value: OAuthConstants.grantTypeAuthorizationCode)
        ]
        guard let authTokenUrl = urlComponents.url else {
            print("❌ Failed to build token request URL")
            return nil
        }
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = OAuthConstants.httpMethodPost
        return request
    }
}

