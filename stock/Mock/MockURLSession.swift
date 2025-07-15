//
//  MockURLSession.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//
import Foundation

class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    // For tracking if dataTask was called
    var lastURL: URL?

    // Override dataTask(with:completionHandler:)
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.lastURL = url
        return MockURLSessionDataTask {
            completionHandler(self.data, self.response, self.error)
        }
    }

    // Override dataTask(with:URLRequest, completionHandler:) if your service uses URLRequest
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.lastURL = request.url
        return MockURLSessionDataTask {
            completionHandler(self.data, self.response, self.error)
        }
    }
}
