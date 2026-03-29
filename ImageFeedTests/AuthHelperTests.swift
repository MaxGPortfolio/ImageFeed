//
//  AuthHelperTests.swift
//  ImageFeed
//
//  Created by Максим on 27.03.2026.
//

@testable import ImageFeed
import XCTest

final class AuthHelperTests: XCTestCase {
    
    private var configuration: AuthConfiguration!
    private var authHelper: AuthHelper!
    
    override func setUpWithError() throws {
        configuration = AuthConfiguration(
            accessKey: "test_access_key",
            secretKey: "test_secret_key",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURLString: "https://api.unsplash.com"
        )
        
        authHelper = AuthHelper(configuration: configuration)
    }
    
    func testAuthHelperAuthURL() {
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        let url = urlComponents.url!
        
        let code = authHelper.code(from: url)
        
        XCTAssertEqual(code, "test code")
    }
}
