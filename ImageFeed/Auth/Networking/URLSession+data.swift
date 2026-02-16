//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Максим on 05.02.2026.
//
import Foundation

// MARK: - Errors

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

// MARK: - URLSession

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let completeOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    completeOnTheMainThread(.success(data))
                } else {
                    let body = String(data: data, encoding: .utf8)
                    print("❌ HTTP \(statusCode). Response body:", body ?? "nil")
                    completeOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completeOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("❌ URLRequest error:", error)
            } else {
                print("❌ URLSession error: missing data/response and no underlying error")
                completeOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
