//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Денис Кель on 07.03.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case noData
    case unauthorized
    case invalidResponse
}
