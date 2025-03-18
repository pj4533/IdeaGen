//
//  Logger+Extensions.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import OSLog

extension Logger {
    // Define subsystems and categories
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    // App lifecycle and general operations
    static let app = Logger(subsystem: subsystem, category: "app")
    
    // Security and keychain related operations
    static let keychain = Logger(subsystem: subsystem, category: "keychain")
    
    // User settings and preferences
    static let settings = Logger(subsystem: subsystem, category: "settings")
    
    // Network and API related operations 
    static let network = Logger(subsystem: subsystem, category: "network")
    
    // UI related events and interactions
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    // Prompt construction and AI generation
    static let prompt = Logger(subsystem: subsystem, category: "prompt")
}