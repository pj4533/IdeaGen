//
//  MockKeychain.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
@testable import IdeaGen

/// A mock implementation of the KeychainManager for testing purposes
class MockKeychainManager {
    static let shared = MockKeychainManager()
    
    private var storage: [String: String] = [:]
    
    private init() {}
    
    func saveApiKey(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        
        storage["OpenAIApiKey"] = key
        return true
    }
    
    func getApiKey() -> String? {
        return storage["OpenAIApiKey"]
    }
    
    func deleteApiKey() -> Bool {
        storage.removeValue(forKey: "OpenAIApiKey")
        return true
    }
    
    func reset() {
        storage.removeAll()
    }
}