//
//  UserSettings.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import SwiftUI
import OSLog

// Mark UserSettings as MainActor since it deals with UI state
@MainActor
final class UserSettings: ObservableObject, Sendable {
    static let shared = UserSettings()
    
    // UserDefaults is thread-safe for reading
    private let defaults: UserDefaults
    
    @Published var ideaPrompt: String {
        didSet {
            Logger.settings.debug("Updating idea prompt in UserDefaults")
            // Already on MainActor, no need for DispatchQueue.main
            self.defaults.set(self.ideaPrompt, forKey: "ideaPrompt")
        }
    }
    
    @Published var apiKeyStored: Bool {
        didSet {
            Logger.settings.debug("Updating apiKeyStored flag: \(self.apiKeyStored)")
            // Already on MainActor, no need for DispatchQueue.main
            self.defaults.set(self.apiKeyStored, forKey: "apiKeyStored")
        }
    }
    
    // Helper method for cross-actor access
    func setApiKeyStored(_ value: Bool) {
        apiKeyStored = value
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        Logger.settings.debug("Initializing user settings")
        
        if let savedPrompt = defaults.string(forKey: "ideaPrompt") {
            self.ideaPrompt = savedPrompt
            Logger.settings.info("Loaded saved idea prompt from UserDefaults")
        } else {
            self.ideaPrompt = "Generate 5 creative app ideas for indie developers that solve real problems"
            Logger.settings.info("Using default idea prompt")
        }
        
        self.apiKeyStored = defaults.bool(forKey: "apiKeyStored")
        Logger.settings.info("API key stored state: \(self.apiKeyStored)")
    }
}