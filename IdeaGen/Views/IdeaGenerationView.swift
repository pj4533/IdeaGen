//
//  IdeaGenerationView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct IdeaGenerationView: View {
    @ObservedObject private var viewModel: IdeaGenerationViewModel
    @EnvironmentObject private var userSettings: UserSettings
    @State private var showSettings = false
    
    init(viewModel: IdeaGenerationViewModel = IdeaGenerationViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if let idea = viewModel.currentIdea {
                        // Display the idea with selective blur animation on content
                        IdeaDisplayView(
                            idea: idea, 
                            onClear: {
                                viewModel.clearIdea()
                            },
                            onSave: {
                                viewModel.saveCurrentIdea()
                            },
                            isGenerating: viewModel.isGenerating
                        )
                    } else {
                        // Show placeholder with matching layout when no idea is generated
                        EmptyStateView(isGenerating: viewModel.isGenerating)
                    }
                }
                
                // Generate button
                GenerateButtonView(
                    isGenerating: viewModel.isGenerating,
                    isDisabled: !userSettings.apiKeyStored,
                    onGenerate: {
                        viewModel.generateIdea()
                    }
                )
            }
            .padding()
            .navigationTitle("IdeaGen")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SavedIdeasListView()) {
                        Image(systemName: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Logger.ui.debug("Settings button tapped")
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert(isPresented: $viewModel.showError, error: viewModel.error) { _ in
                Button("OK") {
                    viewModel.showError = false
                }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    IdeaGenerationView()
        .environmentObject(UserSettings.shared)
}