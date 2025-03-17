//
//  IdeaGenTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import SwiftUI
import Combine
import os.log
@testable import IdeaGen

struct IdeaGenTests {
    
    // Test basic app functionality
    @Test func testBasicFunctionality() async throws {
        // Use the mock keychain
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        // Test save and retrieve
        let testKey = "test-integration-key-12345"
        let saveResult = mockKeychain.saveApiKey(testKey)
        #expect(saveResult == true, "Saving API key should succeed")
        
        let retrievedKey = mockKeychain.getApiKey()
        #expect(retrievedKey == testKey, "Retrieved key should match saved key")
        
        // Clean up
        _ = mockKeychain.deleteApiKey()
    }
    
    // Test UserSettings defaults
    @Test func testUserSettingsDefaults() async throws {
        // Clear any existing settings
        UserDefaults.standard.removeObject(forKey: "ideaPrompt")
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
        
        // Access the settings
        let settings = UserSettings.shared
        
        // Check default prompt is set
        let defaultPrompt = "Generate 5 creative app ideas for indie developers that solve real problems"
        #expect(settings.ideaPrompt.contains("Generate"), "Default idea prompt should be set with expected content")
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "ideaPrompt")
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
    }
    
    // Test complete workflow with mock
    @Test func testApiKeyWorkflow() async throws {
        // Clean up any existing state
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
        
        let settings = UserSettings.shared
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        // Initially, no API key is stored
        let initialKey = mockKeychain.getApiKey()
        #expect(initialKey == nil, "Initially no API key should be in keychain")
        
        // Save API key
        let testKey = "test-integration-key-12345"
        let saveResult = mockKeychain.saveApiKey(testKey)
        #expect(saveResult == true, "Saving API key should succeed")
        
        // Update settings flag
        settings.apiKeyStored = true
        
        // Retrieve the key
        let retrievedKey = mockKeychain.getApiKey()
        #expect(retrievedKey == testKey, "Retrieved key should match saved key")
        
        // Delete the key
        let deleteResult = mockKeychain.deleteApiKey()
        #expect(deleteResult == true, "Deleting API key should succeed")
        
        // Update settings flag
        settings.apiKeyStored = false
        
        // Verify key is gone
        let finalKey = mockKeychain.getApiKey()
        #expect(finalKey == nil, "After deletion, no API key should be in keychain")
    }
}
