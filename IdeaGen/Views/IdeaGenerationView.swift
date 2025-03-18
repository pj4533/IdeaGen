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
                if let idea = viewModel.currentIdea {
                    // Display the idea
                    IdeaDisplayView(idea: idea) {
                        viewModel.clearIdea()
                    }
                } else {
                    // Show placeholder when no idea is generated
                    EmptyStateView()
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