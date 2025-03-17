//
//  UserSettingsTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import os.log
@testable import IdeaGen

struct UserSettingsTests {
    
    @Sendable func resetUserDefaults() {
        let keys = ["ideaPrompt", "apiKeyStored"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // Test setting the idea prompt property
    @Test func testSetIdeaPrompt() async throws {
        // We'll just test that the property can be set correctly in memory
        let settings = UserSettings.shared
        
        // Save original for restoration later
        let originalPrompt = settings.ideaPrompt
        
        // Set a test prompt
        let testPrompt = "Test prompt for unit testing"
        settings.ideaPrompt = testPrompt
        
        // Check it was assigned correctly
        #expect(settings.ideaPrompt == testPrompt, "Idea prompt should be updated in memory")
        
        // Restore original
        settings.ideaPrompt = originalPrompt
    }
    
    // Test setting and persisting API key stored flag
    @Test func testSetApiKeyStored() async throws {
        resetUserDefaults()
        
        let settings = UserSettings.shared
        
        // Verify default state
        #expect(settings.apiKeyStored == false, "API key stored should default to false")
        
        // Set to true
        settings.apiKeyStored = true
        
        // Verify changes
        #expect(settings.apiKeyStored == true, "API key stored should be updated in memory")
        #expect(UserDefaults.standard.bool(forKey: "apiKeyStored") == true, "API key stored should be saved to UserDefaults")
        
        resetUserDefaults()
    }
}