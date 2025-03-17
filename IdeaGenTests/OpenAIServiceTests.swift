//
//  OpenAIServiceTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import OSLog
import XCTest
@testable import IdeaGen

struct OpenAIServiceTests {
    // MARK: - Mock Tests
    
    @Test func testMockOpenAIServiceSuccess() async throws {
        // Arrange
        let mockService = MockOpenAIService()
        let testPrompt = "Test prompt for creative app ideas"
        
        // Act
        let result = await mockService.generateIdea(prompt: testPrompt)
        
        // Assert
        guard case .success(let idea) = result else {
            XCTFail("Expected successful result but got failure")
            return
        }
        
        let lastPrompt = await mockService.lastGeneratedPrompt
        let callCount = await mockService.callCount
        
        XCTAssertEqual(lastPrompt, testPrompt, "Mock service should record the prompt used")
        XCTAssertEqual(callCount, 1, "Mock service should record call count")
        XCTAssertFalse(idea.content.isEmpty, "Generated idea content should not be empty")
        XCTAssertNotEqual(idea.id, UUID(), "Each idea should have a unique ID")
    }
    
    @Test func testMockOpenAIServiceFailure() async throws {
        // Arrange
        let mockService = MockOpenAIService()
        // Use Task to access actor-isolated property
        await mockService.setSimulationMode(.failure(.noApiKey))
        
        // Act
        let result = await mockService.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .failure(let error) = result else {
            XCTFail("Expected failure result but got success")
            return
        }
        
        XCTAssertEqual(error, .noApiKey, "Error should match the simulated error")
    }
    
    @Test func testMockOpenAIServiceDelay() async throws {
        // Arrange
        let mockService = MockOpenAIService()
        let shortDelay: TimeInterval = 0.1  // 100ms delay for test efficiency
        await mockService.setSimulationMode(.delayThenSuccess(shortDelay))
        
        // Act - measure the execution time
        let startTime = Date()
        let result = await mockService.generateIdea(prompt: "Test prompt")
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // Assert
        guard case .success = result else {
            XCTFail("Expected successful result after delay but got failure")
            return
        }
        
        // The elapsed time should be at least the delay time
        XCTAssertGreaterThanOrEqual(elapsedTime, shortDelay, "Operation should take at least the simulated delay time")
    }
    
    @Test func testMockOpenAIServiceWithPredefinedIdea() async throws {
        // Arrange
        let mockService = MockOpenAIService()
        let predefinedIdea = Idea(id: UUID(), content: "CustomApp\n\nA completely custom test idea for verification")
        await mockService.setPredefinedIdea(predefinedIdea)
        
        // Act
        let result = await mockService.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .success(let idea) = result else {
            XCTFail("Expected successful result but got failure")
            return
        }
        
        XCTAssertEqual(idea.content, predefinedIdea.content, "Generated idea should match the predefined idea")
        XCTAssertEqual(idea.id, predefinedIdea.id, "Generated idea ID should match the predefined idea ID")
    }
    
    // MARK: - Real Service Tests with Mocked Dependencies
    
    @Test func testOpenAIServiceWithNoApiKey() async throws {
        // Arrange - create a keychain mock that returns nil for API key
        let mockKeychain = MockKeychainManager()
        let service = OpenAIService(keychainManager: mockKeychain)
        
        // Act
        let result = await service.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .failure(let error) = result else {
            XCTFail("Expected failure result with no API key but got success")
            return
        }
        
        XCTAssertEqual(error, .noApiKey, "Service should return noApiKey error when keychain has no API key")
    }
    
    @Test func testOpenAIServiceWithMockedURLSession() async throws {
        // Arrange
        let mockKeychain = MockKeychainManager()
        await mockKeychain.saveApiKey("test-api-key")
        
        let mockSession = URLSession.mock
        let service = OpenAIService(keychainManager: mockKeychain, urlSession: mockSession)
        
        // Setup successful response
        let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        let expectedContent = "IdeaTestApp\n\nAn app that generates and tests creative ideas automatically."
        MockURLProtocol.setSuccessResponse(for: openAIURL, content: expectedContent)
        
        // Act
        let result = await service.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .success(let idea) = result else {
            #fail("Expected successful result but got failure")
            return
        }
        
        #expect(idea.content == expectedContent, "Content should match the mocked response")
        
        // Clean up
        MockURLProtocol.reset()
    }
    
    @Test func testOpenAIServiceWithErrorResponse() async throws {
        // Arrange
        let mockKeychain = MockKeychainManager()
        await mockKeychain.saveApiKey("test-api-key")
        
        let mockSession = URLSession.mock
        let service = OpenAIService(keychainManager: mockKeychain, urlSession: mockSession)
        
        // Setup error response
        let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        MockURLProtocol.setErrorResponse(for: openAIURL, statusCode: 401, errorMessage: "Invalid API key")
        
        // Act
        let result = await service.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .failure(let error) = result else {
            #fail("Expected failure result but got success")
            return
        }
        
        #expect(error == .invalidApiKey, "Error should be invalidApiKey for 401 status code")
        
        // Clean up
        MockURLProtocol.reset()
    }
    
    @Test func testOpenAIServiceWithNetworkError() async throws {
        // Arrange
        let mockKeychain = MockKeychainManager()
        await mockKeychain.saveApiKey("test-api-key")
        
        let mockSession = URLSession.mock
        let service = OpenAIService(keychainManager: mockKeychain, urlSession: mockSession)
        
        // Setup network error
        let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        let networkError = URLError(.notConnectedToInternet)
        MockURLProtocol.setNetworkError(for: openAIURL, error: networkError)
        
        // Act
        let result = await service.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .failure(let error) = result else {
            #fail("Expected failure result but got success")
            return
        }
        
        if case .networkError(let message) = error {
            #expect(message.contains("internet"), "Error message should mention connection issue")
        } else {
            #fail("Expected networkError but got \(error)")
        }
        
        // Clean up
        MockURLProtocol.reset()
    }
    
    @Test func testOpenAIServiceWithRateLimitResponse() async throws {
        // Arrange
        let mockKeychain = MockKeychainManager()
        await mockKeychain.saveApiKey("test-api-key")
        
        let mockSession = URLSession.mock
        let service = OpenAIService(keychainManager: mockKeychain, urlSession: mockSession)
        
        // Setup rate limit response
        let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        MockURLProtocol.setErrorResponse(
            for: openAIURL, 
            statusCode: 429, 
            errorMessage: "Rate limit exceeded"
        )
        
        // Act
        let result = await service.generateIdea(prompt: "Test prompt")
        
        // Assert
        guard case .failure(let error) = result else {
            #fail("Expected failure result but got success")
            return
        }
        
        #expect(error == .rateLimitExceeded, "Error should be rateLimitExceeded for 429 status code")
        
        // Clean up
        MockURLProtocol.reset()
    }
}