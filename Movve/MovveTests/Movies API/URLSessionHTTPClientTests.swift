//
//  URLSessionHTTPClientTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 6.4.24..
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_performsGETRequestWithURL() {
        URLProtocolStub.startIntercepting()
        let url = URL(string: "https://any-url.com")!
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url)
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopIntercepting()
    }
    
    // MARK: - Helpers
    
    private final class URLProtocolStub: URLProtocol {
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
