//
//  KeychainManager.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import Security
import OSLog

// Update protocol for Swift 6 concurrency
protocol KeychainManaging: Sendable {
    func saveApiKey(_ key: String) async -> Bool
    func getApiKey() async -> String?
    func deleteApiKey() async -> Bool
}

// Make KeychainManager actor for thread safety
actor KeychainManager: KeychainManaging {
    enum KeychainError: Error, Sendable {
        case itemNotFound
        case invalidItemFormat
        case unexpectedStatus(OSStatus)
    }
    static let shared = KeychainManager()
    
    let service: String
    let account: String
    
    init(service: String = "com.saygoodnight.IdeaGen", account: String = "OpenAIApiKey") {
        self.service = service
        self.account = account
    }
    
    // We don't need to add 'async' here because actor methods are implicitly async
    func saveApiKey(_ key: String) -> Bool {
        Logger.keychain.debug("Attempting to save API key to keychain")
        guard let data = key.data(using: .utf8) else {
            Logger.keychain.error("Failed to convert API key to data")
            return false 
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Check if item exists
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            // Update existing item
            Logger.keychain.info("API key exists in keychain, updating")
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if updateStatus != errSecSuccess {
                Logger.keychain.error("Failed to update API key in keychain: \(updateStatus)")
            } else {
                Logger.keychain.info("Successfully updated API key in keychain")
            }
            return updateStatus == errSecSuccess
        } else if status == errSecItemNotFound {
            // Create new item
            Logger.keychain.info("API key not found in keychain, creating new entry")
            var newQuery = query
            newQuery.merge(attributes) { (_, new) in new }
            let addStatus = SecItemAdd(newQuery as CFDictionary, nil)
            if addStatus != errSecSuccess {
                Logger.keychain.error("Failed to add API key to keychain: \(addStatus)")
            } else {
                Logger.keychain.info("Successfully added API key to keychain")
            }
            return addStatus == errSecSuccess
        } else {
            Logger.keychain.error("Unexpected keychain status when checking for existing API key: \(status)")
        }
        
        return false
    }
    
    // Actor methods are implicitly async
    func getApiKey() -> String? {
        Logger.keychain.debug("Attempting to retrieve API key from keychain")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status != errSecSuccess {
            if status == errSecItemNotFound {
                Logger.keychain.info("API key not found in keychain")
            } else {
                Logger.keychain.error("Failed to retrieve API key from keychain: \(status)")
            }
            return nil
        }
        
        guard let data = item as? Data else {
            Logger.keychain.error("Retrieved keychain item is not in the expected Data format")
            return nil
        }
        
        guard let key = String(data: data, encoding: .utf8) else {
            Logger.keychain.error("Failed to convert API key data to string")
            return nil
        }
        
        Logger.keychain.info("Successfully retrieved API key from keychain")
        return key
    }
    
    // Actor methods are implicitly async
    func deleteApiKey() -> Bool {
        Logger.keychain.debug("Attempting to delete API key from keychain")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            Logger.keychain.info("Successfully deleted API key from keychain")
            return true
        } else if status == errSecItemNotFound {
            Logger.keychain.info("No API key found to delete in keychain")
            return true
        } else {
            Logger.keychain.error("Failed to delete API key from keychain: \(status)")
            return false
        }
    }
}