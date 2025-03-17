//
//  SettingsViewModelTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import SwiftUI
import Combine
import os.log
@testable import IdeaGen

/// Helper ViewModel to test the SettingsView functionality
class TestSettingsViewModel {
    var apiKey: String = ""
    var alertMessage = ""
    private let keychainManager = MockKeychainManager.shared
    
    init() {
        // Reset the mock for clean tests
        keychainManager.reset()
    }
    
    func saveApiKey() -> Bool {
        if apiKey.isEmpty {
            return false
        }
        
        return keychainManager.saveApiKey(apiKey)
    }
    
    func deleteApiKey() -> Bool {
        apiKey = ""
        return keychainManager.deleteApiKey()
    }
    
    func getApiKey() -> String? {
        return keychainManager.getApiKey()
    }
    
    func maskApiKey(_ key: String) -> String {
        guard !key.isEmpty else { return "" }
        
        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        return "\(prefix)••••••••••••\(suffix)"
    }
}

struct SettingsViewModelTests {
    
    // Test masking API key functionality
    @Test func testMaskApiKey() async throws {
        let viewModel = TestSettingsViewModel()
        
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
    
    // Test API key save functionality
    @Test func testApiKeySave() async throws {
        let viewModel = TestSettingsViewModel()
        viewModel.apiKey = "test-viewmodel-key-12345"
        
        let result = viewModel.saveApiKey()
        #expect(result == true, "Saving valid API key should succeed")
        
        // Verify key was saved
        let storedKey = viewModel.getApiKey()
        #expect(storedKey == "test-viewmodel-key-12345", "Stored key should match test key")
    }
    
    // Test empty API key handling
    @Test func testEmptyApiKey() async throws {
        let viewModel = TestSettingsViewModel()
        viewModel.apiKey = ""
        
        let result = viewModel.saveApiKey()
        #expect(result == false, "Saving empty API key should fail")
    }
    
    // Test API key deletion
    @Test func testDeleteApiKey() async throws {
        let viewModel = TestSettingsViewModel()
        
        // First save a key
        viewModel.apiKey = "test-key-to-delete"
        let saveResult = viewModel.saveApiKey()
        #expect(saveResult == true, "Saving should succeed")
        
        // Verify key exists
        let keyBeforeDelete = viewModel.getApiKey()
        #expect(keyBeforeDelete == "test-key-to-delete", "Key should exist before deletion")
        
        // Delete the key
        let result = viewModel.deleteApiKey()
        
        #expect(result == true, "Deleting API key should succeed")
        #expect(viewModel.apiKey == "", "API key should be cleared")
        
        // Verify key was deleted
        let storedKey = viewModel.getApiKey()
        #expect(storedKey == nil, "No key should be stored after deletion")
    }
}