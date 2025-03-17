//
//  IdeaGenTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import SwiftUI
import os.log
@testable import IdeaGen

struct IdeaGenTests {
    // Test UserSettings defaults
    @MainActor
    @Test func testUserSettingsDefaults() async throws {
        // Create a new UserDefaults instance for testing instead of using shared standard
        let testDefaults = UserDefaults(suiteName: "test_defaults")!
        testDefaults.removePersistentDomain(forName: "test_defaults")
        
        // Create a test settings instance with our test defaults - UserSettings is @MainActor
        let settings = UserSettings(defaults: testDefaults)
        
        // Check default prompt is set with expected content
        #expect(settings.ideaPrompt.contains("creative app idea"), "Default idea prompt should be set with expected content")
        #expect(settings.apiKeyStored == false, "API key stored should default to false")
        
        // Clean up
        testDefaults.removePersistentDomain(forName: "test_defaults")
    }
}
