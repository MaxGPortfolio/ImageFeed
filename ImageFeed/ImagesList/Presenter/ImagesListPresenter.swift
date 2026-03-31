//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Максим on 29.03.2026.
//

import UIKit
import Logging

// MARK: - ImagesListPresenterProtocol

@MainActor
protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    var photosCount: Int { get }
    
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo
    func formattedDate(for indexPath: IndexPath) -> String
    func didShowCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
}

// MARK: - ImagesListServiceProtocol

@MainActor
protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

@MainActor
final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Private Properties
    
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    private var renderedPhotosCount = 0
    private let logger = Logger(label: "ImagesListPresenter")
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Init
    
    init(imagesListService: ImagesListServiceProtocol? = nil) {
        self.imagesListService = imagesListService ?? ImagesListService.shared
    }
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    
    var photosCount: Int {
        imagesListService.photos.count
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        renderedPhotosCount = imagesListService.photos.count
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                self.logger.info("Images list updated")

                let oldCount = self.renderedPhotosCount
                let newCount = self.imagesListService.photos.count
                self.renderedPhotosCount = newCount

                self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
            }
        }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Public
    
    func photo(at indexPath: IndexPath) -> Photo {
        imagesListService.photos[indexPath.row]
    }
    
    func formattedDate(for indexPath: IndexPath) -> String {
        let photo = imagesListService.photos[indexPath.row]
        return photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
    }
    
    func didShowCell(at indexPath: IndexPath) {
        guard photosCount > 0 else { return }
        
        let thresholdIndex = max(photosCount - 5, 0)
        if indexPath.row >= thresholdIndex {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        
        logger.info("Like tapped for photo id: \(photo.id)")
        
        view?.showLoading()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else {
                return
            }
            
            self.view?.hideLoading()
            
            switch result {
            case .success:
                self.view?.reloadRow(at: indexPath)
            case .failure:
                self.logger.error("Failed to change like for photo id: \(photo.id)")
                self.view?.showLikeError()
            }
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        view?.showSingleImage(url: photo.largeImageURL)
    }
    
    // MARK: - Private
    
    deinit {
        logger.debug("ImagesListPresenter deinitialized")
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
