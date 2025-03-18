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
    @MainActor // We need MainActor since UserSettings is @MainActor-isolated
    @Test func testSetIdeaPrompt() async throws {
        // Create a test-specific UserDefaults instance
        let testDefaults = UserDefaults(suiteName: "test_settings")!
        testDefaults.removePersistentDomain(forName: "test_settings")
        
        // Create a test-specific UserSettings instance - uses MainActor
        let settings = UserSettings(defaults: testDefaults)
        
        // Since we're already on the MainActor, no need for MainActor.run
        // Save original for later comparison
        let originalPrompt = settings.ideaPrompt
        
        // Set a test prompt
        let testPrompt = "Test prompt for unit testing"
        settings.ideaPrompt = testPrompt
        
        // Check it was assigned correctly
        #expect(settings.ideaPrompt == testPrompt, "Idea prompt should be updated in memory")
        
        // Restore original
        settings.ideaPrompt = originalPrompt
        
        // Clean up
        testDefaults.removePersistentDomain(forName: "test_settings")
    }
    
    // Test setting and persisting API key stored flag
    @MainActor // We need MainActor since UserSettings is @MainActor-isolated
    @Test func testSetApiKeyStored() async throws {
        // Create a test-specific UserDefaults instance with a unique name for this test
        let testSuiteName = "api_key_stored_test_\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: testSuiteName)!
        testDefaults.removePersistentDomain(forName: testSuiteName)
        
        // Create a test-specific UserSettings instance - uses MainActor
        let settings = UserSettings(defaults: testDefaults)
        
        // Since we're already on the MainActor, no need for MainActor.run
        // Verify default state
        #expect(settings.apiKeyStored == false, "API key stored should default to false")
        
        // Set to true
        settings.apiKeyStored = true
        
        // Verify changes
        #expect(settings.apiKeyStored == true, "API key stored should be updated in memory")
        
        // Wait a moment for async UserDefaults operations to complete
        // This can run off the MainActor
        await Task {
            do {
                try await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds
            } catch {
                // Handle error if needed
            }
        }.value
        
        // Test that UserDefaults was updated - still on MainActor
        let storedValue = testDefaults.bool(forKey: "apiKeyStored")
        #expect(storedValue == true, "API key stored should be saved to UserDefaults")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: testSuiteName)
    }
}