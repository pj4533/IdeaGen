//
//  SavedIdeaEditView.swift
//  IdeaGen
//
//  Created by Claude on 3/18/25.
//

import SwiftUI
import OSLog

struct SavedIdeaEditView: View {
    // MARK: - Properties
    
    let idea: Idea
    let onSave: (Idea) -> Void
    let onCancel: () -> Void
    
    @State private var editedContent: String
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    init(idea: Idea, onSave: @escaping (Idea) -> Void, onCancel: @escaping () -> Void) {
        self.idea = idea
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedContent = State(initialValue: idea.content)
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextEditor(text: $editedContent)
                    .frame(minHeight: 200)
                    .font(.body)
            } header: {
                Text("Idea Content")
            } footer: {
                Text("Edit your idea content")
            }
            
            HStack {
                Text("Created")
                Spacer()
                Text(idea.createdAt, style: .date)
                Text(idea.createdAt, style: .time)
            }
            .foregroundColor(.secondary)
        }
        .navigationTitle("Edit Idea")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    Logger.ui.debug("Cancelled idea edit")
                    onCancel()
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Logger.ui.debug("Saving edited idea")
                    let updatedIdea = Idea(id: idea.id, content: editedContent, createdAt: idea.createdAt)
                    onSave(updatedIdea)
                    dismiss()
                }
                .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SavedIdeaEditView(
            idea: Idea(
                content: "A productivity app that uses AI to intelligently organize and prioritize your tasks based on deadlines, importance, and your work habits.",
                createdAt: Date()
            ),
            onSave: { _ in },
            onCancel: { }
        )
    }
}