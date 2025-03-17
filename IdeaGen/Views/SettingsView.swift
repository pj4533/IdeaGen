//
//  SettingsView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

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
                                        if let key = KeychainManager.shared.getApiKey() {
                                            apiKey = key
                                        }
                                    }
                                
                                Spacer()
                                
                                Button("Edit") {
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
                                        if let key = KeychainManager.shared.getApiKey() {
                                            apiKey = key
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
                                    isEditingApiKey = false
                                    if let key = KeychainManager.shared.getApiKey() {
                                        apiKey = key
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    
                    if settings.apiKeyStored && !isEditingApiKey {
                        Button(action: { 
                            apiKey = ""
                            if KeychainManager.shared.deleteApiKey() {
                                settings.apiKeyStored = false
                                alertMessage = "API Key deleted successfully"
                                showAlert = true
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
        if KeychainManager.shared.saveApiKey(apiKey) {
            settings.apiKeyStored = true
            isEditingApiKey = false
            alertMessage = isEditingApiKey ? "API Key updated successfully" : "API Key saved successfully"
            showAlert = true
        } else {
            alertMessage = "Failed to save API Key"
            showAlert = true
        }
    }
    
    private func maskApiKey(_ key: String) -> String {
        guard !key.isEmpty else { return "" }
        
        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        return "\(prefix)••••••••••••\(suffix)"
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings.shared)
}