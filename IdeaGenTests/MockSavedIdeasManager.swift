//
//  MockSavedIdeasManager.swift
//  IdeaGenTests
//
//  Created by Claude on 3/19/25.
//

import Foundation
@testable import IdeaGen

actor MockSavedIdeasManager: SavedIdeasManaging {
    var savedIdeas: [Idea] = []
    var saveCallCount = 0
    var getAllCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var shouldThrowError = false
    var error: SavedIdeasError = .encodingError
    
    func saveIdea(_ idea: Idea) async throws {
        saveCallCount += 1
        if shouldThrowError {
            throw error
        }
        if let index = savedIdeas.firstIndex(where: { $0.id == idea.id }) {
            savedIdeas[index] = idea
        } else {
            savedIdeas.append(idea)
        }
    }
    
    func getAllIdeas() async -> [Idea] {
        getAllCallCount += 1
        return savedIdeas.sorted { $0.createdAt > $1.createdAt }
    }
    
    func updateIdea(_ idea: Idea) async throws {
        updateCallCount += 1
        if shouldThrowError {
            throw error
        }
        guard let index = savedIdeas.firstIndex(where: { $0.id == idea.id }) else {
            throw SavedIdeasError.ideaNotFound
        }
        savedIdeas[index] = idea
    }
    
    func deleteIdea(withId id: UUID) async throws {
        deleteCallCount += 1
        if shouldThrowError {
            throw error
        }
        guard let index = savedIdeas.firstIndex(where: { $0.id == id }) else {
            throw SavedIdeasError.ideaNotFound
        }
        savedIdeas.remove(at: index)
    }
}