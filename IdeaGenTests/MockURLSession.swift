//
//  MockURLSession.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
@testable import IdeaGen

// For mocking URLSession responses in tests
class MockURLProtocol: URLProtocol {
    
    // Dictionary to store response handlers
    static var responseHandlers = [String: (URLRequest) -> (HTTPURLResponse, Data?, Error?)]()
    
    // Add a response handler for a specific URL
    static func setResponseHandler(for url: URL, handler: @escaping (URLRequest) -> (HTTPURLResponse, Data?, Error?)) {
        responseHandlers[url.absoluteString] = handler
    }
    
    // Clear all mock response handlers
    static func reset() {
        responseHandlers.removeAll()
    }
    
    // Add a standard success response for OpenAI
    static func setSuccessResponse(for url: URL, content: String = "TestApp\n\nA test app idea generated for unit tests.") {
        setResponseHandler(for: url) { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            
            // Create a valid OpenAI API response
            let responseObj = OpenAICompletionsResponse(
                id: "mock-\(UUID().uuidString)",
                choices: [
                    OpenAICompletionsResponse.OpenAIChoice(
                        index: 0,
                        message: OpenAIMessage(role: "assistant", content: content),
                        finishReason: "stop"
                    )
                ],
                usage: OpenAICompletionsResponse.OpenAIUsage(
                    promptTokens: 50,
                    completionTokens: 100,
                    totalTokens: 150
                ),
                created: Int(Date().timeIntervalSince1970),
                model: "gpt-4o"
            )
            
            let data = try! JSONEncoder().encode(responseObj)
            return (response, data, nil)
        }
    }
    
    // Add a standard error response
    static func setErrorResponse(for url: URL, statusCode: Int, errorMessage: String) {
        setResponseHandler(for: url) { request in
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            
            if statusCode != 200 {
                // Create an OpenAI API error response
                let errorObj = OpenAIErrorResponse(
                    error: OpenAIErrorResponse.OpenAIError(
                        message: errorMessage,
                        type: "api_error",
                        code: "error_code"
                    )
                )
                
                let data = try! JSONEncoder().encode(errorObj)
                return (response, data, nil)
            }
            
            return (response, nil, nil)
        }
    }
    
    // Set a network error response
    static func setNetworkError(for url: URL, error: Error) {
        setResponseHandler(for: url) { request in
            let response = HTTPURLResponse(url: url, statusCode: 0, httpVersion: nil, headerFields: nil)!
            return (response, nil, error)
        }
    }
    
    // MARK: - URLProtocol Implementation
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Handle all requests
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url else {
            fatalError("URL is nil in MockURLProtocol")
        }
        
        // Get the handler for this URL, or use a default error handler
        let handler = MockURLProtocol.responseHandlers[url.absoluteString] ?? { _ in
            let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, nil, nil)
        }
        
        // Get the mock response
        let (response, data, error) = handler(request)
        
        // Handle error if any
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        // Return the response and data
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // No need to implement for our testing purposes
    }
}

// Helper extension to create a mock URLSession
extension URLSession {
    static var mock: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}