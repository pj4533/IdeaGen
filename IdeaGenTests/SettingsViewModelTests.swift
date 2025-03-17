//
//  SettingsViewModelTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import SwiftUI
import os.log
@testable import IdeaGen

struct SettingsViewModelTests {
    
    // Test masking API key functionality
    @Test func testMaskApiKey() async throws {
        let viewModel = SettingsViewModel(userSettings: UserSettings())
        
        // Test with normal key
        let testKey = "sk-abcdefghijklmnopqrst1234"
        let masked = viewModel.maskApiKey(testKey)
        #expect(masked == "sk-a••••••••••••1234", "Key should be properly masked")
        
        // Test with short key
        let shortKey = "short"
        let maskedShort = viewModel.maskApiKey(shortKey)
        #expect(maskedShort == "shor••••••••••••hort", "Short key should still be masked")
        
        // Test with empty key
        let emptyKey = ""
        let maskedEmpty = viewModel.maskApiKey(emptyKey)
        #expect(maskedEmpty == "", "Empty key should remain empty")
    }
    
    // Test editing state management
    @Test func testEditingStateManagement() throws {
        // Create dependencies
        let mockKeychain = MockKeychainManager()
        let userSettings = UserSettings()
        let viewModel = SettingsViewModel(userSettings: userSettings)
        
        // Replace shared instance with our mock for testing
        KeychainManager.shared = mockKeychain
        
        // Initial state check
        #expect(viewModel.isEditingApiKey == false, "Should not be in editing mode initially")
        
        // Start editing
        viewModel.startEditing()
        #expect(viewModel.isEditingApiKey == true, "Should be in editing mode after startEditing")
        
        // Cancel editing
        viewModel.cancelEditing()
        #expect(viewModel.isEditingApiKey == false, "Should exit editing mode after cancelEditing")
        
        // Test save and editing state
        viewModel.apiKey = "test-key-123"
        viewModel.isEditingApiKey = true
        viewModel.saveApiKey()
        #expect(viewModel.isEditingApiKey == false, "Should exit editing mode after saving")
        #expect(userSettings.apiKeyStored == true, "Should mark API key as stored")
        
        // Restore shared instance
        KeychainManager.shared = KeychainManager()
    }
    
    // Test alert messages
    @Test func testAlertMessages() throws {
        // Create dependencies with mock keychain that returns success
        let mockKeychain = MockKeychainManager()
        let userSettings = UserSettings()
        let viewModel = SettingsViewModel(userSettings: userSettings)
        
        // Replace shared instance with our mock for testing
        KeychainManager.shared = mockKeychain
        
        // Save API key scenario
        viewModel.apiKey = "test-api-key"
        viewModel.isEditingApiKey = false
        viewModel.saveApiKey()
        
        #expect(viewModel.showAlert == true, "Alert should be shown after save")
        #expect(viewModel.alertMessage == "API Key saved successfully", "Should show success message")
        
        // Update API key scenario
        viewModel.showAlert = false
        viewModel.apiKey = "updated-key"
        viewModel.isEditingApiKey = true
        viewModel.saveApiKey()
        
        #expect(viewModel.alertMessage == "API Key updated successfully", "Should show update message")
        
        // Delete API key scenario
        viewModel.showAlert = false
        viewModel.deleteApiKey()
        
        #expect(viewModel.showAlert == true, "Alert should be shown after delete")
        #expect(viewModel.alertMessage == "API Key deleted successfully", "Should show delete success message")
        #expect(userSettings.apiKeyStored == false, "API key stored flag should be false after deletion")
        
        // Restore shared instance
        KeychainManager.shared = KeychainManager()
    }
}