//
//  ApiKeyEditView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

struct ApiKeyEditView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            SecureField("Enter your OpenAI API Key", text: $viewModel.apiKey)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onAppear {
                    if viewModel.userSettings.apiKeyStored && viewModel.isEditingApiKey {
                        Task {
                            await viewModel.loadApiKey()
                        }
                    }
                }
            
            Button(action: { 
                Task {
                    await viewModel.saveApiKey()
                }
            }) {
                Text(viewModel.isEditingApiKey ? "Update API Key" : "Save API Key")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.apiKey.isEmpty)
            
            if viewModel.isEditingApiKey {
                Button("Cancel") {
                    Task {
                        await viewModel.cancelEditing()
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
            }
        }
    }
}