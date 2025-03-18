//
//  ApiKeySection.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

struct ApiKeySection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text("OpenAI API Key"), footer: Text("Your API key is stored securely in the device keychain")) {
            VStack(spacing: 8) {
                if viewModel.userSettings.apiKeyStored && !viewModel.isEditingApiKey {
                    ApiKeyViewDisplay(viewModel: viewModel)
                } else {
                    ApiKeyEditView(viewModel: viewModel)
                }
            }
            
            if viewModel.userSettings.apiKeyStored && !viewModel.isEditingApiKey {
                Button(action: { 
                    Task {
                        await viewModel.deleteApiKey()
                    }
                }) {
                    Text("Delete API Key")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}