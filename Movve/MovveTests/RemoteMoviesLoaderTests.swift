//
//  RemoteMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 5.4.24..
//

import XCTest
import Movve

final class RemoteMoviesLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, httpClient) = makeSUT()
        
        XCTAssertTrue(httpClient.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(httpClient.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(httpClient.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "any-error", code: 1)
            httpClient.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, httpClient) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                httpClient.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid-json".utf8)
            httpClient.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoMoviesOn200HTTPResponseWithEmptyJSONList() {
        let (sut, httpClient) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeMoviesJSON([])
            httpClient.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversMoviesOn200HTTPResponseWithJSONList() {
        let (sut, httpClient) = makeSUT()
        
        let movie1 = Movie(id: 1, imagePath: UUID().uuidString)
        let movie1JSON: [String:Any] = ["id": movie1.id, "poster_path": movie1.imagePath]
        let movie2JSON: [String:Any] = ["id": 2]
        
        expect(sut, toCompleteWith: .success([movie1]), when: {
            let json = makeMoviesJSON([movie1JSON, movie2JSON])
            httpClient.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://an-url.com")!) -> (sut: RemoteMoviesLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, httpClient: httpClient)
        return (sut, httpClient)
    }
    
    private func makeMoviesJSON(_ movies: [[String:Any]]) -> Data {
        let moviesJSON = ["results": movies]
        return try! JSONSerialization.data(withJSONObject: moviesJSON)
    }
    
    private func expect(_ sut: RemoteMoviesLoader, toCompleteWith result: RemoteMoviesLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults: [RemoteMoviesLoader.Result] = []
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
