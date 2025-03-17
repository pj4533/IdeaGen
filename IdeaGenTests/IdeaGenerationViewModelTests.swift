//
//  IdeaGenerationViewModelTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import SwiftUI
import XCTest
@testable import IdeaGen

struct IdeaGenerationViewModelTests {
    
    @MainActor
    @Test func testGenerateIdeaSuccess() async {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        let testPrompt = "a creative app idea that solves real problems"
        let testIdea = Idea(content: "TestApp\n\nA test app for unit testing")
        await mockOpenAIService.setPredefinedIdea(testIdea)
        
        let testDefaults = UserDefaults(suiteName: "test_defaults_\(UUID().uuidString)")!
        testDefaults.set(testPrompt, forKey: "ideaPrompt")
        testDefaults.set(true, forKey: "apiKeyStored")
        
        let userSettings = UserSettings(defaults: testDefaults)
        let viewModel = IdeaGenerationViewModel(openAIService: mockOpenAIService, userSettings: userSettings)
        
        // Act
        viewModel.generateIdea()
        
        // Allow time for the async task to complete
        await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Assert
        XCTAssertEqual(viewModel.currentIdea?.content, testIdea.content, "ViewModel should have updated with the test idea")
        XCTAssertFalse(viewModel.isGenerating, "Generation should be complete")
        XCTAssertNil(viewModel.error, "There should be no error")
        XCTAssertFalse(viewModel.showError, "Error alert should not be shown")
        
        let callCount = await mockOpenAIService.callCount
        XCTAssertEqual(callCount, 1, "OpenAI service should have been called once")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: testDefaults.suiteName!)
    }
    
    @MainActor
    @Test func testGenerateIdeaFailure() async {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        await mockOpenAIService.setSimulationMode(.failure(.networkError("Network connection failed")))
        
        let testDefaults = UserDefaults(suiteName: "test_defaults_\(UUID().uuidString)")!
        testDefaults.set("test prompt", forKey: "ideaPrompt")
        testDefaults.set(true, forKey: "apiKeyStored")
        
        let userSettings = UserSettings(defaults: testDefaults)
        let viewModel = IdeaGenerationViewModel(openAIService: mockOpenAIService, userSettings: userSettings)
        
        // Act
        viewModel.generateIdea()
        
        // Allow time for the async task to complete
        await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Assert
        XCTAssertNil(viewModel.currentIdea, "No idea should be set")
        XCTAssertFalse(viewModel.isGenerating, "Generation should be complete")
        XCTAssertNotNil(viewModel.error, "There should be an error")
        XCTAssertTrue(viewModel.showError, "Error alert should be shown")
        
        let callCount = await mockOpenAIService.callCount
        XCTAssertEqual(callCount, 1, "OpenAI service should have been called once")
        
        guard case .networkError = viewModel.error else {
            XCTFail("Error should be networkError but was \(String(describing: viewModel.error))")
            return
        }
        
        // Clean up
        testDefaults.removePersistentDomain(forName: testDefaults.suiteName!)
    }
    
    @MainActor
    @Test func testGenerateIdeaNoAPIKey() async {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        
        let testDefaults = UserDefaults(suiteName: "test_defaults_\(UUID().uuidString)")!
        testDefaults.set("test prompt", forKey: "ideaPrompt")
        testDefaults.set(false, forKey: "apiKeyStored") // No API key stored
        
        let userSettings = UserSettings(defaults: testDefaults)
        let viewModel = IdeaGenerationViewModel(openAIService: mockOpenAIService, userSettings: userSettings)
        
        // Act
        viewModel.generateIdea()
        
        // Assert - this happens synchronously since we check for API key before making async call
        XCTAssertNil(viewModel.currentIdea, "No idea should be set")
        XCTAssertFalse(viewModel.isGenerating, "Generation should not start")
        XCTAssertEqual(viewModel.error, .noApiKey, "Error should be noApiKey")
        XCTAssertTrue(viewModel.showError, "Error alert should be shown")
        
        let callCount = await mockOpenAIService.callCount
        XCTAssertEqual(callCount, 0, "OpenAI service should not have been called")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: testDefaults.suiteName!)
    }
    
    @MainActor
    @Test func testClearIdea() async {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        let testIdea = Idea(content: "Test idea content")
        
        let testDefaults = UserDefaults(suiteName: "test_defaults_\(UUID().uuidString)")!
        let userSettings = UserSettings(defaults: testDefaults)
        let viewModel = IdeaGenerationViewModel(openAIService: mockOpenAIService, userSettings: userSettings)
        
        // Set an idea manually
        viewModel.currentIdea = testIdea
        
        // Act
        viewModel.clearIdea()
        
        // Assert
        XCTAssertNil(viewModel.currentIdea, "Idea should be cleared")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: testDefaults.suiteName!)
    }
}