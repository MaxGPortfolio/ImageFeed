//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Максим on 31.03.2026.
//

@testable import ImageFeed
import XCTest
import UIKit

@MainActor
final class ImagesListTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func makePhoto(
        id: String = "1",
        createdAt: Date? = nil,
        isLiked: Bool = false,
        largeImageURL: String = "https://example.com/full.jpg"
    ) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: createdAt,
            welcomeDescription: nil,
            regularImageURL: "https://example.com/regular.jpg",
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
    
    // MARK: - ViewController -> Presenter
    
    func testViewControllerCallsPresenterViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        
        viewController.presenter = presenter
        
        viewController.loadViewIfNeeded()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // MARK: - Presenter
    
    func testPresenterCallsFetchPhotosNextPageOnViewDidLoad() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewControllerSpy()
        
        presenter.view = view
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
        XCTAssertEqual(service.fetchPhotosNextPageCallsCount, 1)
    }
    
    func testPresenterCallsUpdateTableViewWhenNotificationReceived() {
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(id: "1")]
        
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        presenter.viewDidLoad()
        
        service.photos.append(makePhoto(id: "2"))
        
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        
        let expectation = expectation(description: "Notification handled")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(view.updateTableViewAnimatedCalled)
        XCTAssertEqual(view.oldCount, 1)
        XCTAssertEqual(view.newCount, 2)
    }
    
    func testPresenterCallsFetchNextPageWhenShowingLastCells() {
        let service = ImagesListServiceSpy()
        service.photos = (0..<10).map { index in
            makePhoto(id: "\(index)")
        }
        
        let presenter = ImagesListPresenter(imagesListService: service)
        
        presenter.didShowCell(at: IndexPath(row: 9, section: 0))
        
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testPresenterCallsChangeLike() {
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(id: "42", isLiked: false)]
        
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertEqual(service.receivedPhotoId, "42")
        XCTAssertEqual(service.receivedIsLike, true)
        XCTAssertTrue(view.showLoadingCalled)
        XCTAssertTrue(view.hideLoadingCalled)
    }
    
    func testPresenterReloadsRowOnLikeSuccess() {
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(id: "42", isLiked: false)]
        service.changeLikeResult = .success(())
        
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        let indexPath = IndexPath(row: 0, section: 0)
        presenter.didTapLike(at: indexPath)
        
        XCTAssertTrue(view.reloadRowCalled)
        XCTAssertEqual(view.reloadedIndexPath, indexPath)
    }
    
    func testPresenterShowsLikeErrorOnLikeFailure() {
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(id: "42", isLiked: false)]
        service.changeLikeResult = .failure(ImagesListServiceSpyError.stub)
        
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(view.showLikeErrorCalled)
    }
    
    func testPresenterShowsSingleImageOnSelect() {
        let expectedURL = "https://example.com/single.jpg"
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(id: "1", largeImageURL: expectedURL)]
        
        let presenter = ImagesListPresenter(imagesListService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        presenter.didSelectRow(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(view.showSingleImageCalled)
        XCTAssertEqual(view.shownURL, expectedURL)
    }
}
