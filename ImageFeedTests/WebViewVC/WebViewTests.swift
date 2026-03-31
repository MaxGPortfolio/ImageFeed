//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Максим on 27.03.2026.
//

@testable import ImageFeed
import XCTest

@MainActor
final class WebViewTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewController: WebViewViewControllerSpy!
    private var presenterSpy: WebViewPresenterSpy!
    private var presenter: WebViewPresenter!
    private var authHelper: AuthHelperSpy!
    
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        viewController = WebViewViewControllerSpy()
        presenterSpy = WebViewPresenterSpy()
        authHelper = AuthHelperSpy()
        presenter = WebViewPresenter(authHelper: authHelper)
    }
    
    // MARK: - Tests
    
    func testViewControllerCallsViewDidLoad() {
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        viewController.simulateViewDidLoad()
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(authHelper.authRequestCalled)
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let progress: Float = 1.0
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
}
