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
final class IdeaGenerationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentIdea: Idea?
    @Published var isGenerating = false
    @Published var error: IdeaGenerationError?
    @Published var showError = false
    
    // MARK: - Private Properties
    
    private let openAIService: OpenAIServiceProtocol
    private let userSettings: UserSettings
    private let savedIdeasManager: SavedIdeasManaging
    private var generatedIdeas: [Idea] = []
    
    // MARK: - Initialization
    
    nonisolated init(
        openAIService: OpenAIServiceProtocol = OpenAIService.shared,
        userSettings: UserSettings = .shared,
        savedIdeasManager: SavedIdeasManaging = SavedIdeasManager()
    ) {
        self.openAIService = openAIService
        self.userSettings = userSettings
        self.savedIdeasManager = savedIdeasManager
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
            // Create enhanced prompt with previous ideas
            let enhancedPrompt = createEnhancedPrompt(basePrompt: prompt)
            Logger.app.info("Generating idea with enhanced prompt that includes previous idea history")
            
            let result = await openAIService.generateIdea(prompt: enhancedPrompt)
            
            switch result {
            case .success(let idea):
                Logger.app.info("Successfully generated idea: \(idea.content)")
                currentIdea = idea
                // Store the generated idea for future reference
                self.generatedIdeas.append(idea)
                Logger.app.debug("Added idea to history, total ideas: \(self.generatedIdeas.count)")
                
                // Add a small delay for the animation to be noticeable
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
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
    
    /// Saves the current idea to storage and generates a new one
    func saveCurrentIdea() async {
        guard let idea = currentIdea else {
            Logger.app.error("No current idea to save")
            return
        }
        
        Logger.app.info("Saving current idea: \(idea.id)")
        
        do {
            try await savedIdeasManager.saveIdea(idea)
            Logger.app.debug("Successfully saved idea: \(idea.id)")
            
            // Clear the current idea and generate a new one
            currentIdea = nil
            generateIdea()
        } catch {
            Logger.app.error("Failed to save idea: \(error.localizedDescription)")
            self.error = .unknown
            self.showError = true
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Creates an enhanced prompt that includes previously generated ideas
    /// - Parameter basePrompt: The original user prompt
    /// - Returns: Enhanced prompt with instructions to generate different ideas
    private func createEnhancedPrompt(basePrompt: String) -> String {
        var enhancedPrompt = "Here is the basis for the idea you should generate: \(basePrompt)"
        
        // Only add previous ideas if we have some
        if !self.generatedIdeas.isEmpty {
            // Start with the instruction
            enhancedPrompt += "\n\nMake sure the idea is significantly different than each of these: "
            
            // Add each previous idea
            let previousIdeasText = self.generatedIdeas
                .map { $0.content }
                .joined(separator: ", ")
            
            enhancedPrompt += previousIdeasText
            
            Logger.app.debug("Enhanced prompt with \(self.generatedIdeas.count) previous ideas")
        }
        
        return enhancedPrompt
    }
}