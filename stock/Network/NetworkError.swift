//
//  NetworkError.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable { 
    case invalidURL
    case noData
    case decodingError(String)
    case networkFailed(String)
    case coreDataError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided was invalid."
        case .noData: return "No data was received from the server."
        case .decodingError(let description): return "Failed to decode data: \(description)"
        case .networkFailed(let description): return "Network request failed: \(description)"
        case .coreDataError(let description): return "Core Data operation failed: \(description)"

        }
    }
}
