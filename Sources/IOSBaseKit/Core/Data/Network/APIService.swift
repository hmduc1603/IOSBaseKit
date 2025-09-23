//
//  APIService.swift
//  magiclight
//
//  Created by Dennis Hoang on 17/8/25.
//

import Alamofire
import Foundation

public class APIService {
    private static func createURLRequest(
        url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
        if method == .post, let body = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }

    public static func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createURLRequest(
                url: url,
                method: method,
                parameters: parameters,
                headers: headers,
            )
            AF.request(request)
                .validate()
                .response { response in
                    switch response.result {
                    case .success(let value):
                        if let data = value {
                            do {
                                let decoded = try JSONDecoder().decode(T.self, from: data)
                                continuation.resume(returning: decoded)
                            } catch {
                                print("APIService: Failed to decode!")
                                print("APIService: Raw Data: \(String(data: value ?? Data(), encoding: .utf8) ?? "No data")")
                                continuation.resume(throwing: error)
                            }
                        } else {
                            continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    public static func request(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
    ) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createURLRequest(
                url: url,
                method: method,
                parameters: parameters,
                headers: headers,
            )
            AF.request(request)
                .validate()
                .response { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    public static func streamRequest(
        url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        onChunk: @escaping (Data) -> Void,
        completion: @escaping (Error?) -> Void
    ) {
        let request = createURLRequest(
            url: url,
            method: method,
            parameters: parameters,
            headers: headers,
        )
        AF.streamRequest(request)
            .responseStream { stream in
                switch stream.event {
                case .stream(let result):
                    switch result {
                    case .success(let chunk):
                        onChunk(chunk)
                    case .failure(let error):
                        completion(error)
                    }
                case .complete:
                    completion(nil)
                }
            }
    }
}
