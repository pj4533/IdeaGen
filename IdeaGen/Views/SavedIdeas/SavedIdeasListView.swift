//
//  SavedIdeasListView.swift
//  IdeaGen
//
//  Created by Claude on 3/18/25.
//

import SwiftUI
import OSLog

struct SavedIdeasListView: View {
    @StateObject private var viewModel = SavedIdeasViewModel()
    @State private var selectedIdea: Idea?
    @State private var showEditView = false
    
    var body: some View {
        ideaListContent
            .navigationTitle("Saved Ideas")
            .task {
                await viewModel.loadSavedIdeas()
            }
            .refreshable {
                await viewModel.loadSavedIdeas()
            }
            .overlay {
                if viewModel.savedIdeas.isEmpty {
                    SavedIdeasEmptyStateView()
                }
            }
            .sheet(isPresented: $showEditView, onDismiss: {
                Task {
                    await viewModel.loadSavedIdeas()
                }
            }) {
                SavedIdeaDetailSheet(
                    idea: selectedIdea,
                    onSave: { updatedIdea in
                        try await viewModel.updateIdea(updatedIdea)
                        clearSelection()
                    },
                    onDismiss: clearSelection
                )
            }
    }
    
    private var ideaListContent: some View {
        List {
            ForEach(viewModel.savedIdeas) { idea in
                SavedIdeaRowView(
                    idea: idea,
                    onSelect: { selectedIdea in
                        self.selectedIdea = selectedIdea
                        showEditView = true
                    },
                    onDelete: { idea in
                        try await viewModel.deleteIdea(idea)
                    }
                )
            }
        }
    }
    
    private func clearSelection() {
        selectedIdea = nil
        showEditView = false
    }
}

#Preview {
    NavigationStack {
        SavedIdeasListView()
    }
}