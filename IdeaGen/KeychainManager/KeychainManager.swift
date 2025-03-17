//
//  KeychainManager.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import Security

class KeychainManager {
    enum KeychainError: Error {
        case itemNotFound
        case invalidItemFormat
        case unexpectedStatus(OSStatus)
    }
    static let shared = KeychainManager()
    
    private init() {}
    
    func saveApiKey(_ key: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIApiKey",
            kSecAttrService as String: "com.saygoodnight.IdeaGen"
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Check if item exists
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            // Update existing item
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            return updateStatus == errSecSuccess
        } else if status == errSecItemNotFound {
            // Create new item
            var newQuery = query
            newQuery.merge(attributes) { (_, new) in new }
            let addStatus = SecItemAdd(newQuery as CFDictionary, nil)
            return addStatus == errSecSuccess
        }
        
        return false
    }
    
    func getApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIApiKey",
            kSecAttrService as String: "com.saygoodnight.IdeaGen",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func deleteApiKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIApiKey",
            kSecAttrService as String: "com.saygoodnight.IdeaGen"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}