//
//  SettingsViewModelTests.swift
//  IdeaGenTests
//
//  Created by PJ Gray on 3/17/25.
//

import Testing
import Foundation
import SwiftUI
import os.log
@testable import IdeaGen

/// Simple test helper for API key masking
struct KeyMasker {
    static func maskApiKey(_ key: String) -> String {
        guard !key.isEmpty else { return "" }
        
        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        return "\(prefix)••••••••••••\(suffix)"
    }
}

struct SettingsViewModelTests {
    
    // Test masking API key functionality
    @Test func testMaskApiKey() async throws {
        // Test with normal key
        let testKey = "sk-abcdefghijklmnopqrst1234"
        let masked = KeyMasker.maskApiKey(testKey)
        #expect(masked == "sk-a••••••••••••1234", "Key should be properly masked")
        
        // Test with short key
        let shortKey = "short"
        let maskedShort = KeyMasker.maskApiKey(shortKey)
        #expect(maskedShort == "shor••••••••••••hort", "Short key should still be masked")
        
        // Test with empty key
        let emptyKey = ""
        let maskedEmpty = KeyMasker.maskApiKey(emptyKey)
        #expect(maskedEmpty == "", "Empty key should remain empty")
    }
}