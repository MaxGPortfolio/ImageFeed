//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Максим on 31.03.2026.
//

@testable import ImageFeed
import Foundation

// MARK: - ImagesListViewControllerSpy

@MainActor
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    // MARK: - Public Properties
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - State
    
    var updateTableViewAnimatedCalled = false
    var oldCount: Int?
    var newCount: Int?
    
    var reloadRowCalled = false
    var reloadedIndexPath: IndexPath?
    
    var showLikeErrorCalled = false
    var showSingleImageCalled = false
    var shownURL: String?
    
    var showLoadingCalled = false
    var hideLoadingCalled = false
    
    // MARK: - Public
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        self.oldCount = oldCount
        self.newCount = newCount
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        reloadedIndexPath = indexPath
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
    
    func showSingleImage(url: String) {
        showSingleImageCalled = true
        shownURL = url
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
}
