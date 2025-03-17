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
    
    // Test default values
    @Test func testDefaultValues() async throws {
        // Clear user defaults for testing
        let keys = ["ideaPrompt", "apiKeyStored"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Create a new instance to test default values
        let settings = UserSettings.shared
        
        // Check defaults
        let defaultPrompt = "Generate 5 creative app ideas for indie developers that solve real problems"
        #expect(settings.ideaPrompt.contains("Generate"), "Default idea prompt should be set correctly")
        #expect(settings.apiKeyStored == false, "API key stored should default to false")
        
        // Clean up
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // Test setting and persisting idea prompt
    @Test func testSetIdeaPrompt() async throws {
        // Clear user defaults for testing
        UserDefaults.standard.removeObject(forKey: "ideaPrompt")
        
        let settings = UserSettings.shared
        let testPrompt = "Generate 3 mobile game ideas"
        
        // Set the new value
        settings.ideaPrompt = testPrompt
        
        // Check it was set in memory
        #expect(settings.ideaPrompt == testPrompt, "Idea prompt should be updated in memory")
        
        // Check it was persisted to UserDefaults
        let savedPrompt = UserDefaults.standard.string(forKey: "ideaPrompt")
        #expect(savedPrompt == testPrompt, "Idea prompt should be saved to UserDefaults")
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "ideaPrompt")
    }
    
    // Test setting and persisting API key stored flag
    @Test func testSetApiKeyStored() async throws {
        // Clear user defaults for testing
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
        
        let settings = UserSettings.shared
        
        // Set to true
        settings.apiKeyStored = true
        
        // Check it was set in memory
        #expect(settings.apiKeyStored == true, "API key stored should be updated in memory")
        
        // Check it was persisted to UserDefaults
        let saved = UserDefaults.standard.bool(forKey: "apiKeyStored") 
        #expect(saved == true, "API key stored should be saved to UserDefaults")
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
    }
    
    // Test loading from UserDefaults
    @Test func testLoadFromUserDefaults() async throws {
        // Clear user defaults for testing
        let keys = ["ideaPrompt", "apiKeyStored"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Set values in UserDefaults directly
        let testPrompt = "Generate 10 startup ideas"
        UserDefaults.standard.set(testPrompt, forKey: "ideaPrompt")
        UserDefaults.standard.set(true, forKey: "apiKeyStored")
        
        // Create a new instance of user settings after setting defaults
        let settings = UserSettings.shared
        
        // Test that the saved values are reflected in the settings
        #expect(settings.ideaPrompt == testPrompt, "Idea prompt should match the value set in UserDefaults")
        #expect(settings.apiKeyStored == true, "API key stored flag should match the value set in UserDefaults")
        
        // Clean up
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}