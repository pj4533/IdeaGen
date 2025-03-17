//
//  SettingsView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: UserSettings
    
    @State private var apiKey: String = ""
    @State private var isEditingApiKey = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("OpenAI API Key"), footer: Text("Your API key is stored securely in the device keychain")) {
                    VStack(spacing: 8) {
                        if settings.apiKeyStored && !isEditingApiKey {
                            HStack {
                                Text(maskApiKey(apiKey))
                                    .font(.system(.body, design: .monospaced))
                                    .onAppear {
                                        Logger.ui.debug("Loading API key for display in settings")
                                        if let key = KeychainManager.shared.getApiKey() {
                                            apiKey = key
                                            Logger.ui.info("API key loaded and masked for display")
                                        } else {
                                            Logger.ui.error("Failed to load API key for display")
                                        }
                                    }
                                
                                Spacer()
                                
                                Button("Edit") {
                                    Logger.ui.debug("User initiated API key editing")
                                    isEditingApiKey = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        } else {
                            SecureField("Enter your OpenAI API Key", text: $apiKey)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .onAppear {
                                    if settings.apiKeyStored && isEditingApiKey {
                                        Logger.ui.debug("Loading API key for editing in settings")
                                        if let key = KeychainManager.shared.getApiKey() {
                                            apiKey = key
                                            Logger.ui.info("API key loaded for editing")
                                        } else {
                                            Logger.ui.error("Failed to load API key for editing")
                                        }
                                    }
                                }
                            
                            Button(action: saveApiKey) {
                                Text(isEditingApiKey ? "Update API Key" : "Save API Key")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(apiKey.isEmpty)
                            
                            if isEditingApiKey {
                                Button("Cancel") {
                                    Logger.ui.debug("User canceled API key editing")
                                    isEditingApiKey = false
                                    if let key = KeychainManager.shared.getApiKey() {
                                        apiKey = key
                                        Logger.ui.info("Restored original API key after canceling edit")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    
                    if settings.apiKeyStored && !isEditingApiKey {
                        Button(action: { 
                            Logger.ui.debug("User requested API key deletion")
                            apiKey = ""
                            if KeychainManager.shared.deleteApiKey() {
                                settings.apiKeyStored = false
                                alertMessage = "API Key deleted successfully"
                                showAlert = true
                                Logger.ui.info("API key successfully deleted")
                            } else {
                                Logger.ui.error("Failed to delete API key")
                            }
                        }) {
                            Text("Delete API Key")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Section(header: Text("Idea Prompt"), footer: Text("This prompt will be used to generate ideas")) {
                    TextEditor(text: $settings.ideaPrompt)
                        .frame(minHeight: 100)
                }
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
            .alert("Settings", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveApiKey() {
        Logger.ui.debug("Attempting to save API key")
        if apiKey.isEmpty {
            Logger.ui.error("Cannot save empty API key")
            return
        }
        
        if KeychainManager.shared.saveApiKey(apiKey) {
            settings.apiKeyStored = true
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
    
    private func maskApiKey(_ key: String) -> String {
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

#Preview {
    SettingsView()
        .environmentObject(UserSettings.shared)
}