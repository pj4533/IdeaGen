//
//  SettingsViewModel.swift
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