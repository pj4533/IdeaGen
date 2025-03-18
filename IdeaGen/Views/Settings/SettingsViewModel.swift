//
//  SettingsViewModel.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

// Mark as MainActor to ensure UI operations happen on the main thread
@MainActor
final class SettingsViewModel: ObservableObject, Sendable {
    @Published var apiKey: String = ""
    @Published var isEditingApiKey = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // Since UserSettings is @MainActor and Sendable, we can safely store it
    nonisolated let userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func loadApiKey() async {
        Logger.ui.debug("Loading API key for display in settings")
        if let key = await KeychainManager.shared.getApiKey() {
            apiKey = key
            Logger.ui.info("API key loaded and masked for display")
        } else {
            Logger.ui.error("Failed to load API key for display")
        }
    }
    
    func startEditing() {
        Logger.ui.debug("User initiated API key editing")
        isEditingApiKey = true
        Task {
            await loadApiKey()
        }
    }
    
    func cancelEditing() async {
        Logger.ui.debug("User canceled API key editing")
        isEditingApiKey = false
        if let key = await KeychainManager.shared.getApiKey() {
            apiKey = key
            Logger.ui.info("Restored original API key after canceling edit")
        }
    }
    
    func saveApiKey() async {
        Logger.ui.debug("Attempting to save API key")
        if apiKey.isEmpty {
            Logger.ui.error("Cannot save empty API key")
            return
        }
        
        let keyToSave = apiKey // Capture current value
        
        if await KeychainManager.shared.saveApiKey(keyToSave) {
            // userSettings is already on MainActor and we're in a MainActor class
            userSettings.setApiKeyStored(true)
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
    
    func deleteApiKey() async {
        Logger.ui.debug("User requested API key deletion")
        apiKey = ""
        
        if await KeychainManager.shared.deleteApiKey() {
            userSettings.setApiKeyStored(false)
            alertMessage = "API Key deleted successfully"
            showAlert = true
            Logger.ui.info("API key successfully deleted")
        } else {
            Logger.ui.error("Failed to delete API key")
        }
    }
    
    // This is a pure function that doesn't access shared state, so it can be nonisolated
    nonisolated func maskApiKey(_ key: String) -> String {
        guard !key.isEmpty else { 
            // Don't use Logger here as it would require isolation
            return "" 
        }
        
        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        return "\(prefix)••••••••••••\(suffix)"
    }
}