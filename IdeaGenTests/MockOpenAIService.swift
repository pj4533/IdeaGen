//
//  MockOpenAIService.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
@testable import IdeaGen

/// Mock implementation of the OpenAI service for testing
final class MockOpenAIService: OpenAIServiceProtocol {
    enum SimulationMode {
        case success
        case failure(IdeaGenerationError)
        case delayThenSuccess(TimeInterval)
    }
    
    var simulationMode: SimulationMode = .success
    var lastGeneratedPrompt: String?
    var predefinedIdea: Idea?
    var callCount = 0
    
    /// Resets the mock service state
    func reset() {
        lastGeneratedPrompt = nil
        callCount = 0
        simulationMode = .success
        predefinedIdea = nil
    }
    
    /// Sets the simulation mode
    func setSimulationMode(_ mode: SimulationMode) {
        simulationMode = mode
    }
    
    /// Sets the predefined idea
    func setPredefinedIdea(_ idea: Idea) {
        predefinedIdea = idea
    }
    
    /// Mock implementation of idea generation
    func generateIdea(prompt: String) async -> IdeaGenerationResult {
        lastGeneratedPrompt = prompt
        callCount += 1
        
        switch simulationMode {
        case .success:
            // Return either a predefined idea or a generated one
            let idea = predefinedIdea ?? Idea(content: "MockApp\n\nA mock app that generates creative ideas on demand. It uses advanced AI to understand user needs and create tailored solutions.")
            return .success(idea)
            
        case .failure(let error):
            return .failure(error)
            
        case .delayThenSuccess(let delay):
            // Simulate network delay
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            let idea = predefinedIdea ?? Idea(content: "DelayedApp\n\nAn app that teaches patience by intentionally adding delays to various features. Users earn rewards for waiting.")
            return .success(idea)
        }
    }
}