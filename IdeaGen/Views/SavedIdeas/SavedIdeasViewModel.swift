//
//  SavedIdeasViewModel.swift
//  IdeaGen
//
//  Created by Claude on 3/18/25.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
final class SavedIdeasViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var savedIdeas: [Idea] = []
    @Published var isLoading = false
    @Published var error: SavedIdeasError?
    @Published var showError = false
    
    // MARK: - Private Properties
    
    private let savedIdeasManager: SavedIdeasManaging
    
    // MARK: - Initialization
    
    init(savedIdeasManager: SavedIdeasManaging) {
        self.savedIdeasManager = savedIdeasManager
    }
    
    convenience init() {
        self.init(savedIdeasManager: SavedIdeasManager())
    }
    
    // MARK: - Public Methods
    
    /// Loads all saved ideas from storage
    func loadSavedIdeas() async {
        Logger.storage.debug("Loading saved ideas")
        self.isLoading = true
        
        self.savedIdeas = await savedIdeasManager.getAllIdeas()
        
        self.isLoading = false
        Logger.storage.info("Loaded \(self.savedIdeas.count) saved ideas")
    }
    
    /// Saves a new idea to storage
    /// - Parameter idea: The idea to save
    func saveIdea(_ idea: Idea) async throws {
        Logger.storage.debug("Saving idea: \(idea.id)")
        
        do {
            try await savedIdeasManager.saveIdea(idea)
            await loadSavedIdeas()
        } catch {
            Logger.storage.error("Failed to save idea: \(error.localizedDescription)")
            self.error = error as? SavedIdeasError ?? .encodingError
            self.showError = true
            throw error
        }
    }
    
    /// Updates an existing idea in storage
    /// - Parameter idea: The idea with updated content
    func updateIdea(_ idea: Idea) async throws {
        Logger.storage.debug("Updating idea: \(idea.id)")
        
        do {
            try await savedIdeasManager.updateIdea(idea)
            await loadSavedIdeas()
        } catch {
            Logger.storage.error("Failed to update idea: \(error.localizedDescription)")
            self.error = error as? SavedIdeasError ?? .encodingError
            self.showError = true
            throw error
        }
    }
    
    /// Deletes an idea from storage
    /// - Parameter idea: The idea to delete
    func deleteIdea(_ idea: Idea) async throws {
        Logger.storage.debug("Deleting idea: \(idea.id)")
        
        do {
            try await savedIdeasManager.deleteIdea(withId: idea.id)
            await loadSavedIdeas()
        } catch {
            Logger.storage.error("Failed to delete idea: \(error.localizedDescription)")
            self.error = error as? SavedIdeasError ?? .encodingError
            self.showError = true
            throw error
        }
    }
}