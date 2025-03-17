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
    @Test func testUserSettingsDefaults() async throws {
        // Clear any existing settings
        UserDefaults.standard.removeObject(forKey: "ideaPrompt")
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
        
        // Access the settings
        let settings = UserSettings.shared
        
        // Check default prompt is set with expected content
        #expect(settings.ideaPrompt.contains("Generate"), "Default idea prompt should be set with expected content")
        #expect(settings.apiKeyStored == false, "API key stored should default to false")
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "ideaPrompt")
        UserDefaults.standard.removeObject(forKey: "apiKeyStored")
    }
}
