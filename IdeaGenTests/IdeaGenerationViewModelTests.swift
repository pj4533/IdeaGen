//
//  IdeaGenerationViewModelTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import SwiftUI
@testable import IdeaGen

struct IdeaGenerationViewModelTests {
    
    @MainActor
    @Test func testGenerateIdeaSuccess() async throws {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        let testPrompt = "a creative app idea that solves real problems"
        let testIdea = Idea(content: "TestApp\n\nA test app for unit testing")
        await mockOpenAIService.setPredefinedIdea(testIdea)
        
        let suiteName = "test_defaults_\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.set(testPrompt, forKey: "ideaPrompt")
        testDefaults.set(true, forKey: "apiKeyStored")
        
        let userSettings = UserSettings(defaults: testDefaults)
        let mockSavedIdeasManager = MockSavedIdeasManager()
        let viewModel = IdeaGenerationViewModel(
            openAIService: mockOpenAIService, 
            userSettings: userSettings,
            savedIdeasManager: mockSavedIdeasManager
        )
        
        // Act
        viewModel.generateIdea()
        
        // Allow time for the async task to complete
        try await Task.sleep(for: .seconds(1)) // 1 second
        
        // Assert
        #expect(viewModel.currentIdea?.content == testIdea.content, "ViewModel should have updated with the test idea")
        #expect(viewModel.isGenerating == false, "Generation should be complete")
        #expect(viewModel.error == nil, "There should be no error")
        #expect(viewModel.showError == false, "Error alert should not be shown")
        
        let callCount = await mockOpenAIService.callCount
        #expect(callCount == 1, "OpenAI service should have been called once")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: suiteName)
    }
    
    @MainActor
    @Test func testGenerateIdeaFailure() async throws {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        await mockOpenAIService.setSimulationMode(.failure(.networkError("Network connection failed")))
        
        let suiteName = "test_defaults_\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.set("test prompt", forKey: "ideaPrompt")
        testDefaults.set(true, forKey: "apiKeyStored")
        
        let userSettings = UserSettings(defaults: testDefaults)
        let mockSavedIdeasManager = MockSavedIdeasManager()
        let viewModel = IdeaGenerationViewModel(
            openAIService: mockOpenAIService, 
            userSettings: userSettings,
            savedIdeasManager: mockSavedIdeasManager
        )
        
        // Act
        viewModel.generateIdea()
        
        // Allow time for the async task to complete
        try await Task.sleep(for: .seconds(1)) // 1 second
        
        // Assert
        #expect(viewModel.currentIdea == nil, "No idea should be set")
        #expect(viewModel.isGenerating == false, "Generation should be complete")
        #expect(viewModel.error != nil, "There should be an error")
        #expect(viewModel.showError == true, "Error alert should be shown")
        
        let callCount = await mockOpenAIService.callCount
        #expect(callCount == 1, "OpenAI service should have been called once")
        
        if case .networkError = viewModel.error {
            // Error is of the expected type
        } else {
            #expect(false, "Error should be networkError but was \(String(describing: viewModel.error))")
        }
        
        // Clean up
        testDefaults.removePersistentDomain(forName: suiteName)
    }
    
    @MainActor
    @Test func testGenerateIdeaNoAPIKey() async throws {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        
        let suiteName = "test_defaults_\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.set("test prompt", forKey: "ideaPrompt")
        testDefaults.set(false, forKey: "apiKeyStored") // No API key stored
        
        let userSettings = UserSettings(defaults: testDefaults)
        let mockSavedIdeasManager = MockSavedIdeasManager()
        let viewModel = IdeaGenerationViewModel(
            openAIService: mockOpenAIService, 
            userSettings: userSettings,
            savedIdeasManager: mockSavedIdeasManager
        )
        
        // Act
        viewModel.generateIdea()
        
        // Assert - this happens synchronously since we check for API key before making async call
        #expect(viewModel.currentIdea == nil, "No idea should be set")
        #expect(viewModel.isGenerating == false, "Generation should not start")
        #expect(viewModel.error == IdeaGenerationError.noApiKey, "Error should be noApiKey")
        #expect(viewModel.showError == true, "Error alert should be shown")
        
        let callCount = await mockOpenAIService.callCount
        #expect(callCount == 0, "OpenAI service should not have been called")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: suiteName)
    }
    
    @MainActor
    @Test func testClearIdea() async throws {
        // Arrange
        let mockOpenAIService = MockOpenAIService()
        let testIdea = Idea(content: "Test idea content")
        
        let suiteName = "test_defaults_\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        let userSettings = UserSettings(defaults: testDefaults)
        let mockSavedIdeasManager = MockSavedIdeasManager()
        let viewModel = IdeaGenerationViewModel(
            openAIService: mockOpenAIService, 
            userSettings: userSettings,
            savedIdeasManager: mockSavedIdeasManager
        )
        
        // Set an idea manually
        viewModel.currentIdea = testIdea
        
        // Act
        viewModel.clearIdea()
        
        // Assert
        #expect(viewModel.currentIdea == nil, "Idea should be cleared")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: suiteName)
    }
}