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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(viewModel.savedIdeas) { idea in
                Button(action: {
                    Logger.ui.debug("Selected saved idea: \(idea.id)")
                    selectedIdea = idea
                    showEditView = true
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
                                try await viewModel.deleteIdea(idea)
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
        .navigationTitle("Saved Ideas")
        .task {
            await viewModel.loadSavedIdeas()
        }
        .refreshable {
            await viewModel.loadSavedIdeas()
        }
        .overlay {
            if viewModel.savedIdeas.isEmpty {
                ContentUnavailableView(
                    "No Saved Ideas",
                    systemImage: "lightbulb",
                    description: Text("Your saved ideas will appear here")
                )
            }
        }
        .sheet(isPresented: $showEditView, onDismiss: {
            Task {
                await viewModel.loadSavedIdeas()
            }
        }) {
            if let selectedIdea = selectedIdea {
                NavigationStack {
                    SavedIdeaEditView(idea: selectedIdea) { updatedIdea in
                        Task {
                            do {
                                try await viewModel.updateIdea(updatedIdea)
                                self.selectedIdea = nil
                                showEditView = false
                            } catch {
                                Logger.app.error("Failed to update idea: \(error.localizedDescription)")
                            }
                        }
                    } onCancel: {
                        self.selectedIdea = nil
                        showEditView = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SavedIdeasListView()
    }
}