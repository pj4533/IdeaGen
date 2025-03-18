//
//  SavedIdeasManager.swift
//  IdeaGen
//
//  Created by Claude on 3/18/25.
//

import Foundation
import OSLog

/// Protocol defining the interface for managing saved ideas
protocol SavedIdeasManaging: Sendable {
    func saveIdea(_ idea: Idea) throws
    func getAllIdeas() -> [Idea]
    func updateIdea(_ idea: Idea) throws
    func deleteIdea(withId id: UUID) throws
}

/// Manages the storage and retrieval of saved ideas using UserDefaults
@MainActor
final class SavedIdeasManager: SavedIdeasManaging {
    // MARK: - Properties
    
    // Use UserDefaults directly from methods instead of storing as a property
    private let savedIdeasKey = "savedIdeas"
    
    // MARK: - Initialization
    
    init() {
        // No stored properties needed
    }
    
    // MARK: - SavedIdeasManaging Implementation
    
    /// Saves a new idea to storage
    /// - Parameter idea: The idea to save
    func saveIdea(_ idea: Idea) throws {
        Logger.storage.debug("Saving idea: \(idea.id)")
        var savedIdeas = getAllIdeas()
        
        // Check if the idea already exists (just in case)
        if let index = savedIdeas.firstIndex(where: { $0.id == idea.id }) {
            savedIdeas[index] = idea
        } else {
            savedIdeas.append(idea)
        }
        
        try saveIdeasToStorage(savedIdeas)
    }
    
    /// Retrieves all saved ideas from storage
    /// - Returns: Array of saved ideas, sorted by created date (newest first)
    func getAllIdeas() -> [Idea] {
        guard let data = UserDefaults.standard.data(forKey: savedIdeasKey) else {
            Logger.storage.debug("No saved ideas found")
            return []
        }
        
        do {
            let ideas = try JSONDecoder().decode([Idea].self, from: data)
            Logger.storage.debug("Retrieved \(ideas.count) saved ideas")
            // Sort by created date (newest first)
            return ideas.sorted { $0.createdAt > $1.createdAt }
        } catch {
            Logger.storage.error("Failed to decode saved ideas: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Updates an existing idea in storage
    /// - Parameter idea: The idea with updated content
    func updateIdea(_ idea: Idea) throws {
        Logger.storage.debug("Updating idea: \(idea.id)")
        var savedIdeas = getAllIdeas()
        
        guard let index = savedIdeas.firstIndex(where: { $0.id == idea.id }) else {
            throw SavedIdeasError.ideaNotFound
        }
        
        savedIdeas[index] = idea
        try saveIdeasToStorage(savedIdeas)
    }
    
    /// Deletes an idea from storage
    /// - Parameter id: The ID of the idea to delete
    func deleteIdea(withId id: UUID) throws {
        Logger.storage.debug("Deleting idea: \(id)")
        var savedIdeas = getAllIdeas()
        
        guard let index = savedIdeas.firstIndex(where: { $0.id == id }) else {
            throw SavedIdeasError.ideaNotFound
        }
        
        savedIdeas.remove(at: index)
        try saveIdeasToStorage(savedIdeas)
    }
    
    // MARK: - Private Helpers
    
    /// Saves the ideas array to UserDefaults
    /// - Parameter ideas: The array of ideas to save
    private func saveIdeasToStorage(_ ideas: [Idea]) throws {
        do {
            let data = try JSONEncoder().encode(ideas)
            UserDefaults.standard.set(data, forKey: savedIdeasKey)
            Logger.storage.debug("Successfully saved \(ideas.count) ideas to storage")
        } catch {
            Logger.storage.error("Failed to encode ideas for storage: \(error.localizedDescription)")
            throw SavedIdeasError.encodingError
        }
    }
}

/// Errors related to saved ideas operations
enum SavedIdeasError: Error, LocalizedError {
    case ideaNotFound
    case encodingError
    case decodingError
    
    nonisolated var errorDescription: String? {
        switch self {
        case .ideaNotFound:
            return "The requested idea could not be found"
        case .encodingError:
            return "Failed to encode ideas for storage"
        case .decodingError:
            return "Failed to decode ideas from storage"
        }
    }
}