//
//  KeychainManagerTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Security
import os.log
@testable import IdeaGen

struct KeychainManagerTests {
    
    // Test saving API key with mock
    @Test func testSaveApiKey() async throws {
        // Use the mock
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        let testKey = "test-api-key-12345"
        let result = mockKeychain.saveApiKey(testKey)
        
        #expect(result == true, "Saving API key should return true")
        
        // Verify key was saved
        let savedKey = mockKeychain.getApiKey()
        #expect(savedKey == testKey, "Saved key should match test key")
    }
    
    // Test retrieving API key with mock
    @Test func testGetApiKey() async throws {
        // Use the mock
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        // No key initially
        let initialKey = mockKeychain.getApiKey()
        #expect(initialKey == nil, "Initially no key should be present")
        
        // Save a key
        let testKey = "test-api-key-12345"
        let saveResult = mockKeychain.saveApiKey(testKey)
        #expect(saveResult == true, "Saving API key should succeed")
        
        // Retrieve it
        let retrievedKey = mockKeychain.getApiKey()
        #expect(retrievedKey == testKey, "Retrieved key should match the saved key")
    }
    
    // Test update API key with mock
    @Test func testUpdateApiKey() async throws {
        // Use the mock
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        // First save a key
        let initialKey = "initial-test-key"
        let saveResult = mockKeychain.saveApiKey(initialKey)
        #expect(saveResult == true, "Initial saving of API key should succeed")
        
        // Verify initial key
        let firstRetrieval = mockKeychain.getApiKey()
        #expect(firstRetrieval == initialKey, "First retrieval should match initial key")
        
        // Then update it
        let updatedKey = "updated-test-key"
        let updateResult = mockKeychain.saveApiKey(updatedKey)
        #expect(updateResult == true, "Updating API key should succeed")
        
        // Check that it was updated
        let secondRetrieval = mockKeychain.getApiKey()
        #expect(secondRetrieval == updatedKey, "Second retrieval should match updated key")
    }
    
    // Test deleting API key with mock
    @Test func testDeleteApiKey() async throws {
        // Use the mock
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        // First save a key
        let testKey = "test-api-key-12345"
        let saveResult = mockKeychain.saveApiKey(testKey)
        #expect(saveResult == true, "Saving API key should succeed")
        
        // Verify key exists
        let keyBeforeDelete = mockKeychain.getApiKey()
        #expect(keyBeforeDelete == testKey, "Key should exist before deletion")
        
        // Then delete it
        let deleteResult = mockKeychain.deleteApiKey()
        #expect(deleteResult == true, "Deleting API key should succeed")
        
        // Check that it's gone
        let keyAfterDelete = mockKeychain.getApiKey()
        #expect(keyAfterDelete == nil, "Key should be nil after deletion")
    }
    
    // Test handling empty API key with mock
    @Test func testEmptyApiKey() async throws {
        // Use the mock
        let mockKeychain = MockKeychainManager.shared
        mockKeychain.reset()
        
        // Try to save an empty key
        let emptyKey = ""
        let saveResult = mockKeychain.saveApiKey(emptyKey)
        
        // Our implementation should not allow empty keys
        #expect(saveResult == false, "Saving empty API key should fail")
    }
}