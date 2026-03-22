//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Максим on 05.03.2026.
//

import UIKit
import Logging

// MARK: - Models

struct PhotoResult: Codable {
    let id: String
    let height: Int
    let width: Int
    let createdAt: Date?
    let description: String?
    let likedByUser: Bool
    let urls: Urls
    
    struct Urls: Codable {
        let full: String
        let regular: String
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let regularImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(
        id: String,
        size: CGSize,
        createdAt: Date?,
        welcomeDescription: String?,
        regularImageURL: String,
        largeImageURL: String,
        isLiked: Bool
    ) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.regularImageURL = regularImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
    
    init(result: PhotoResult) {
        id = result.id
        size = CGSize(width: result.width, height: result.height)
        createdAt = result.createdAt
        welcomeDescription = result.description
        isLiked = result.likedByUser
        regularImageURL = result.urls.regular
        largeImageURL = result.urls.full
    }
}

final class ImagesListService {
    
    // MARK: - Constants
    
    private enum Constants {
        static let photosURLString = "https://api.unsplash.com/photos"
    }
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }
    
    // MARK: - Errors
    
    private enum ImagesListServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Shared
    
    static let shared = ImagesListService()
    
    // MARK: - Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private let logger = Logger(label: "ImagesListService")
    private(set) var photos: [Photo] = []
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        fetchPhotos(nextPage)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let token = tokenStorage.token else {
            logger.error("Failed to change like: token is missing")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            logger.error("Failed to change like: could not create request")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        regularImageURL: photo.regularImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                logger.error("Failed to change like for photo \(photoId): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func cleanImagesList() {
        task?.cancel()
        task = nil
        lastLoadedPage = nil
        photos = []
    }
    
    // MARK: - Private
    
    private func fetchPhotos(_ page: Int) {
        assert(Thread.isMainThread)
        
        guard let token = tokenStorage.token else {
            logger.error("Failed to fetch photos: token is missing")
            return
        }
        
        guard let request = makePhotosRequest(page: page, token: token) else {
            logger.error("Failed to fetch photos: could not create request")
            return
        }
        
        var requestTask: URLSessionTask?
        requestTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else {
                return
            }
            
            guard self.task === requestTask else { return }
            
            defer { self.task = nil }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(result: $0 )}
                
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = page
                
                NotificationCenter.default.post(
                    name: Self.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                logger.error("Failed to fetch photos on page \(page): \(error.localizedDescription)")
            }
        }
        
        self.task = requestTask
        requestTask?.resume()
    }
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: Constants.photosURLString) else {
            logger.error("Failed to create URLComponents for photos request")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            logger.error("Failed to create URL for photos request")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let url = URL(string: urlString) else {
            logger.error("Failed to create like request URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
