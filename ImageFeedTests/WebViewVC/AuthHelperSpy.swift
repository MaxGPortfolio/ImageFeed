//
//  AuthHelperSpy.swift
//  ImageFeed
//
//  Created by Максим on 27.03.2026.
//

import ImageFeed
import Foundation

final class AuthHelperSpy: AuthHelperProtocol {
    var authRequestCalled = false
    
    func authRequest() -> URLRequest? {
        authRequestCalled = true
        
        guard let url = URL(string: "https://example.com") else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? { nil }
}
