//
//  SettingsView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

class SettingsViewModel: ObservableObject {
    @Published var apiKey: String = ""
    @Published var isEditingApiKey = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    var userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func loadApiKey() {
        Logger.ui.debug("Loading API key for display in settings")
        if let key = KeychainManager.shared.getApiKey() {
            apiKey = key
            Logger.ui.info("API key loaded and masked for display")
        } else {
            Logger.ui.error("Failed to load API key for display")
        }
    }
    
    func startEditing() {
        Logger.ui.debug("User initiated API key editing")
        isEditingApiKey = true
        loadApiKey()
    }
    
    func cancelEditing() {
        Logger.ui.debug("User canceled API key editing")
        isEditingApiKey = false
        if let key = KeychainManager.shared.getApiKey() {
            apiKey = key
            Logger.ui.info("Restored original API key after canceling edit")
        }
    }
    
    func saveApiKey() {
        Logger.ui.debug("Attempting to save API key")
        if apiKey.isEmpty {
            Logger.ui.error("Cannot save empty API key")
            return
        }
        
        if KeychainManager.shared.saveApiKey(apiKey) {
            userSettings.apiKeyStored = true
            isEditingApiKey = false
            alertMessage = isEditingApiKey ? "API Key updated successfully" : "API Key saved successfully"
            showAlert = true
            Logger.ui.info("API key saved successfully")
        } else {
            alertMessage = "Failed to save API Key"
            showAlert = true
            Logger.ui.error("Failed to save API key to keychain")
        }
    }
    
    func deleteApiKey() {
        Logger.ui.debug("User requested API key deletion")
        apiKey = ""
        if KeychainManager.shared.deleteApiKey() {
            userSettings.apiKeyStored = false
            alertMessage = "API Key deleted successfully"
            showAlert = true
            Logger.ui.info("API key successfully deleted")
        } else {
            Logger.ui.error("Failed to delete API key")
        }
    }
    
    func maskApiKey(_ key: String) -> String {
        guard !key.isEmpty else { 
            Logger.ui.debug("Attempted to mask empty API key")
            return "" 
        }
        
        Logger.ui.debug("Masking API key for display")
        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        return "\(prefix)••••••••••••\(suffix)"
    }
}

struct ApiKeyViewDisplay: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.maskApiKey(viewModel.apiKey))
                .font(.system(.body, design: .monospaced))
                .onAppear {
                    viewModel.loadApiKey()
                }
            
            Spacer()
            
            Button("Edit") {
                viewModel.startEditing()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
}

struct ApiKeyEditView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            SecureField("Enter your OpenAI API Key", text: $viewModel.apiKey)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onAppear {
                    if viewModel.userSettings.apiKeyStored && viewModel.isEditingApiKey {
                        viewModel.loadApiKey()
                    }
                }
            
            Button(action: { viewModel.saveApiKey() }) {
                Text(viewModel.isEditingApiKey ? "Update API Key" : "Save API Key")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.apiKey.isEmpty)
            
            if viewModel.isEditingApiKey {
                Button("Cancel") {
                    viewModel.cancelEditing()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
            }
        }
    }
}

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
                Button(action: { viewModel.deleteApiKey() }) {
                    Text("Delete API Key")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

struct IdeaPromptSection: View {
    @ObservedObject var settings: UserSettings
    
    var body: some View {
        Section(header: Text("Idea Prompt"), footer: Text("This prompt will be used to generate ideas")) {
            TextEditor(text: $settings.ideaPrompt)
                .frame(minHeight: 100)
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: UserSettings
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        // Use StateObject to initialize the view model
        _viewModel = StateObject(wrappedValue: SettingsViewModel(userSettings: UserSettings.shared))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ApiKeySection(viewModel: viewModel)
                IdeaPromptSection(settings: settings)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Settings", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings.shared)
}