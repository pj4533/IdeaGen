//
//  IdeaGenerationViewModel.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
final class IdeaGenerationViewModel: ObservableObject, Sendable {
    // MARK: - Published Properties
    
    @Published var currentIdea: Idea?
    @Published var isGenerating = false
    @Published var error: IdeaGenerationError?
    @Published var showError = false
    
    // MARK: - Private Properties
    
    private let openAIService: OpenAIServiceProtocol
    private let userSettings: UserSettings
    
    // MARK: - Initialization
    
    init(
        openAIService: OpenAIServiceProtocol = OpenAIService.shared,
        userSettings: UserSettings = .shared
    ) {
        self.openAIService = openAIService
        self.userSettings = userSettings
    }
    
    // MARK: - Public Methods
    
    /// Generates a new idea using the OpenAI service
    func generateIdea() {
        Logger.app.debug("User requested idea generation")
        
        if !userSettings.apiKeyStored {
            Logger.app.error("Cannot generate idea - no API key stored")
            self.error = .noApiKey
            self.showError = true
            return
        }
        
        // Get the prompt from user settings
        let prompt = userSettings.ideaPrompt
        
        if prompt.isEmpty {
            Logger.app.error("Empty idea prompt")
            return
        }
        
        // Start generation
        isGenerating = true
        error = nil
        
        // Generate the idea asynchronously
        Task {
            Logger.app.info("Generating idea with prompt: \(prompt)")
            
            let result = await openAIService.generateIdea(prompt: prompt)
            
            switch result {
            case .success(let idea):
                Logger.app.info("Successfully generated idea: \(idea.content)")
                currentIdea = idea
                isGenerating = false
                
            case .failure(let ideaError):
                Logger.app.error("Failed to generate idea: \(ideaError.localizedDescription)")
                error = ideaError
                showError = true
                isGenerating = false
            }
        }
    }
    
    /// Clears the current idea
    func clearIdea() {
        Logger.app.debug("Clearing current idea")
        currentIdea = nil
    }
}