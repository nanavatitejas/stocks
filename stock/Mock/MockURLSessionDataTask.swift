//
//  MockURLSessionDataTask.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // We don't need to do anything here, just call the closure
    override func resume() {
        closure()
    }

    override func cancel() {
        // No-op for this mock
    }
}
