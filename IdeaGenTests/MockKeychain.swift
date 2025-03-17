//
//  MockKeychain.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
@testable import IdeaGen

/// A mock implementation of KeychainManager for testing purposes
class MockKeychainManager: KeychainManaging {
    static let shared = MockKeychainManager()
    
    private var storage: [String: String] = [:]
    private let storageKey = "OpenAIApiKey"
    
    init() {}
    
    func saveApiKey(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        
        storage[storageKey] = key
        return true
    }
    
    func getApiKey() -> String? {
        return storage[storageKey]
    }
    
    func deleteApiKey() -> Bool {
        storage.removeValue(forKey: storageKey)
        return true
    }
    
    func reset() {
        storage.removeAll()
    }
}