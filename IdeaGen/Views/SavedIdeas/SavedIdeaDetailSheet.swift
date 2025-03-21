//
//  SavedIdeaDetailSheet.swift
//  IdeaGen
//
//  Created by Claude on 3/21/25.
//

import SwiftUI

struct SavedIdeaDetailSheet: View {
    let idea: Idea?
    let onSave: (Idea) async throws -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        if let idea = idea {
            NavigationStack {
                SavedIdeaEditView(idea: idea) { updatedIdea in
                    try await onSave(updatedIdea)
                } onCancel: {
                    onDismiss()
                }
            }
        }
    }
}

#Preview {
    SavedIdeaDetailSheet(
        idea: Idea(
            content: "A productivity app that uses AI to intelligently organize and prioritize your tasks.",
            createdAt: Date()
        ),
        onSave: { _ in },
        onDismiss: {}
    )
}