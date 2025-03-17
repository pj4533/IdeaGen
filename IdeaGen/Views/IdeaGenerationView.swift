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
                    ideaView(idea)
                } else {
                    // Show placeholder when no idea is generated
                    emptyStateView
                }
                
                // Generate button
                generateButton
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
    
    // MARK: - Private view components
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 70))
                .foregroundColor(.yellow)
            
            Text("Generate a creative app idea")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Tap the button below to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !userSettings.apiKeyStored {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("API key required in settings")
                }
                .foregroundColor(.orange)
                .padding(.top)
            }
            
            Spacer()
        }
        .padding(.top, 60)
    }
    
    private func ideaView(_ idea: Idea) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated Idea")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Parse the idea content to extract the title and description
                    let components = parseIdeaContent(idea.content)
                    
                    if let title = components.title {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text(components.description)
                        .font(.body)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                )
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    Logger.ui.debug("Clear idea button tapped")
                    viewModel.clearIdea()
                }) {
                    Text("Clear")
                        .frame(minWidth: 80)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
    }
    
    private var generateButton: some View {
        Button(action: {
            Logger.ui.debug("Generate idea button tapped")
            viewModel.generateIdea()
        }) {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Image(systemName: "bolt.fill")
                }
                
                Text(viewModel.isGenerating ? "Generating..." : "Generate Idea")
            }
            .frame(minWidth: 200)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor)
            )
            .foregroundColor(.white)
        }
        .disabled(viewModel.isGenerating || !userSettings.apiKeyStored)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper methods
    
    /// Parses the idea content to extract the title and description
    private func parseIdeaContent(_ content: String) -> (title: String?, description: String) {
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

#Preview {
    IdeaGenerationView()
        .environmentObject(UserSettings.shared)
}