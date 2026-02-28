//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Максим on 20.02.2026.
//

import Foundation

// MARK: - Models

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(result: ProfileResult) {
        username = result.username
        let fullname = [result.firstName, result.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        name = fullname
        loginName = "@\(result.username)"
        bio = result.bio ?? ""
    }
}

final class ProfileService {
    
    // MARK: - Constants
    
    private enum Constants {
        static let profileURLString = "https://api.unsplash.com/me"
        static let httpMethodGet = "GET"
    }
    
    // MARK: - Errors
    
    private enum ProfileServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Shared
    
    static let shared = ProfileService()
    
    // MARK: - Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            print("[ProfileService.fetchProfile]: ProfileServiceError.invalidRequest duplicateToken=\(token)")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: ProfileServiceError.invalidRequest request=nil token=\(token)")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        var requestTask: URLSessionTask?
        requestTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else {
                print("[ProfileService.fetchProfile]: NetworkError.urlSessionError self=nil token=\(token)")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard self.task === requestTask else { return }
            
            defer {
                self.task = nil
                self.lastToken = nil
            }
            
            switch result {
            case .success(let body):
                let profile = Profile(result: body)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(error) token=\(token)")
                completion(.failure(error))
            }
        }
        self.task = requestTask
        requestTask?.resume()
    }
    
    // MARK: - Private
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.profileURLString) else {
            print("❌ Invalid profile URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = Constants.httpMethodGet
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
