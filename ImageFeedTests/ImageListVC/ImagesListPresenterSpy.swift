//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Максим on 31.03.2026.
//

@testable import ImageFeed
import Foundation

// MARK: - ImagesListPresenterSpy

@MainActor
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int = 0
    
    // MARK: - State
    
    var viewDidLoadCalled = false
    var didShowCellCalled = false
    var didTapLikeCalled = false
    var didSelectRowCalled = false
    
    // MARK: - Public
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            regularImageURL: "https://example.com/regular.jpg",
            largeImageURL: "https://example.com/full.jpg",
            isLiked: false
        )
    }
    
    func formattedDate(for indexPath: IndexPath) -> String {
        "1 января 2026"
    }
    
    func didShowCell(at indexPath: IndexPath) {
        didShowCellCalled = true
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        didSelectRowCalled = true
    }
}
