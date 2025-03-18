//
//  Idea.swift
//  IdeaGen
//
//  Created by Claude on 3/18/25.
//

import Foundation

/// Represents an app idea with title, description, and optional additional details
struct Idea: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let content: String
    let createdAt: Date
    
    init(id: UUID = UUID(), content: String, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }
}

extension Idea {
    /// Creates an example idea for preview and testing purposes
    static var example: Idea {
        Idea(
            content: "A weather app that provides detailed forecasts specifically for hiking trails with altitude-based predictions.",
            createdAt: Date().addingTimeInterval(-86400) // Yesterday
        )
    }
}