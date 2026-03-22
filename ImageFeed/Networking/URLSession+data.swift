//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Максим on 05.02.2026.
//
import Foundation
import Logging

// MARK: - Errors

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

// MARK: - Properties

private let logger = Logger(label: "network.URLSession")

// MARK: - Data Task

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
                    logger.error("HTTP error with status code \(statusCode)")
                    completeOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completeOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                logger.error("Network request failed: \(error.localizedDescription)")
            } else {
                logger.error("Network session error occurred")
                completeOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }

    
    // MARK: - Object Task
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        let task = data(for: request) { result in
            
            switch result {
                
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let body = String(data: data, encoding: .utf8) ?? "nil"
                    logger.error("Decoding error for type \(T.self): \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
