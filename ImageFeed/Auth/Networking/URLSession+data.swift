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
                    print("[URLSession.data]: NetworkError.httpStatusCode(\(statusCode)) request=\(request.url?.absoluteString ?? "nil") body=\(body ?? "nil")")
                    completeOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completeOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("[URLSession.data]: NetworkError.urlRequestError(\(error.localizedDescription)) request=\(request.url?.absoluteString ?? "nil")")
            } else {
                print("[URLSession.data]: NetworkError.urlSessionError request=\(request.url?.absoluteString ?? "nil")")
                completeOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = data(for: request) { result in
            
            switch result {
                
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let body = String(data: data, encoding: .utf8) ?? "nil"
                    print("[URLSession.objectTask]: NetworkError.decodingError(\(error.localizedDescription)) type=\(T.self) request=\(request.url?.absoluteString ?? "nil") body=\(body)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
