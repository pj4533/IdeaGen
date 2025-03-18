//
//  IdeaContentParser.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation

/// Utility struct for parsing idea content into components
struct IdeaContentParser {
    /// Parses the idea content to extract the title and description
    /// - Parameter content: The raw idea content
    /// - Returns: A tuple containing the optional title and description
    static func parse(_ content: String) -> (title: String?, description: String) {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        
        if lines.count > 1 {
            // First line is the title, the rest is the description
            return (title: String(lines[0]), description: lines.dropFirst().joined(separator: "\n"))
        } else {
            // No clear title/description structure
            return (title: nil, description: content)
        }
    }
}