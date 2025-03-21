//
//  SavedIdeaRowView.swift
//  IdeaGen
//
//  Created by Claude on 3/21/25.
//

import SwiftUI
import OSLog

struct SavedIdeaRowView: View {
    let idea: Idea
    let onSelect: (Idea) -> Void
    let onDelete: (Idea) async throws -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: {
            Logger.ui.debug("Selected saved idea: \(idea.id)")
            onSelect(idea)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(idea.content)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text("Saved on \(dateFormatter.string(from: idea.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .swipeActions {
            Button(role: .destructive) {
                Task {
                    do {
                        try await onDelete(idea)
                    } catch {
                        Logger.app.error("Failed to delete idea: \(error.localizedDescription)")
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    SavedIdeaRowView(
        idea: Idea(
            content: "A productivity app that uses AI to intelligently organize and prioritize your tasks.",
            createdAt: Date()
        ),
        onSelect: { _ in },
        onDelete: { _ in }
    )
    .previewLayout(.sizeThatFits)
    .padding()
}