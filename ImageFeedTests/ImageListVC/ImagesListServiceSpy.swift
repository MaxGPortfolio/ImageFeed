//
//  ImagesListServiceSpy.swift
//  ImageFeed
//
//  Created by Максим on 31.03.2026.
//

@testable import ImageFeed
import Foundation

// MARK: - ImagesListServiceSpyError
enum ImagesListServiceSpyError: Error {
    case stub
}

// MARK: - ImagesListServiceSpy
@MainActor
final class ImagesListServiceSpy: NSObject, ImagesListServiceProtocol {
    // MARK: - Public Properties
    var photos: [Photo] = []
    
    // MARK: - State
    var fetchPhotosNextPageCalled = false
    var fetchPhotosNextPageCallsCount = 0
    var changeLikeCalled = false
    var receivedPhotoId: String?
    var receivedIsLike: Bool?
    var changeLikeResult: Result<Void, Error> = .success(())
    
    // MARK: - Public
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
        fetchPhotosNextPageCallsCount += 1
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        receivedPhotoId = photoId
        receivedIsLike = isLike
        completion(changeLikeResult)
    }
}
