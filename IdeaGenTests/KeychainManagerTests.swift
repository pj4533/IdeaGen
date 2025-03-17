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
    
    // No longer needed since we create new instances for each test
    // @Sendable func setup() {
    //     MockKeychainManager.shared.reset()
    // }
    
    // Test saving API key with mock
    @Test func testSaveAndRetrieveApiKey() async throws {
        let mockKeychain = MockKeychainManager()
        
        // First check that no key exists
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
        // Create a fresh instance instead of using shared
        let mockKeychain = MockKeychainManager()
        
        // First save a key
        let initialKey = "initial-test-key"
        let saveResult = mockKeychain.saveApiKey(initialKey)
        #expect(saveResult == true, "Saving initial API key should succeed")
        
        // Then update it
        let updatedKey = "updated-test-key"
        let updateResult = mockKeychain.saveApiKey(updatedKey)
        #expect(updateResult == true, "Updating API key should succeed")
        
        // Check that it was updated
        let retrievedKey = mockKeychain.getApiKey()
        #expect(retrievedKey == updatedKey, "Retrieved key should match updated key")
    }
    
    // Test deleting API key with mock
    @Test func testDeleteApiKey() async throws {
        let mockKeychain = MockKeychainManager()
        
        // First save a key
        mockKeychain.saveApiKey("test-api-key-12345")
        
        // Verify key exists
        #expect(mockKeychain.getApiKey() != nil, "Key should exist before deletion")
        
        // Delete it
        let deleteResult = mockKeychain.deleteApiKey()
        #expect(deleteResult == true, "Deleting API key should succeed")
        
        // Check that it's gone
        #expect(mockKeychain.getApiKey() == nil, "Key should be nil after deletion")
    }
    
    // Test handling empty API key with mock
    @Test func testEmptyApiKey() async throws {
        let mockKeychain = MockKeychainManager()
        
        // Try to save an empty key
        let saveResult = mockKeychain.saveApiKey("")
        #expect(saveResult == false, "Saving empty API key should fail")
    }
}