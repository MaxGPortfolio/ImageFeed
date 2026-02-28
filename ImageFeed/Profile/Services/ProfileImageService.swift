//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Максим on 21.02.2026.
//
import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let large: String
    }
}

final class ProfileImageService {
    
    // MARK: - OAuth-specific constants
    
    private enum ProfileImageServiceConstants {
        static let usersURLString = "https://api.unsplash.com/users/"
        static let httpMethodGet = "GET"
    }
    
    private enum ProfileImageServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Shared
    
    static let shared = ProfileImageService()
    
    // MARK: - Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?
    private let tokenStorage = OAuth2TokenStorage.shared
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let avatarURLKey = "URL"
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastUsername != username else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.invalidRequest duplicateUsername=\(username)")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard
            let token = tokenStorage.token
        else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.invalidRequest token=nil username=\(username)")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard
            let request = makeProfileImageURLRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.invalidRequest request=nil username=\(username)")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        var requestTask: URLSessionTask?
        requestTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else {
                print("[ProfileImageService.fetchProfileImageURL]: NetworkError.urlSessionError self=nil username=\(username)")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard self.task === requestTask else { return }
            
            defer {
                self.task = nil
                self.lastUsername = nil
            }
            
            switch result {
            case .success(let userResult):
                let urlString = userResult.profileImage.large
                self.avatarURL = urlString
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: [ProfileImageService.avatarURLKey: urlString]
                )
                completion(.success(urlString))
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error) username=\(username)")
                completion(.failure(error))
            }
        }
        self.task = requestTask
        requestTask?.resume()
    }
    
    private func makeProfileImageURLRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(ProfileImageServiceConstants.usersURLString)\(username)") else {
            print("❌ Invalid avatar URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = ProfileImageServiceConstants.httpMethodGet
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
