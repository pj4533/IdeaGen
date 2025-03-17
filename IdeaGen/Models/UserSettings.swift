//
//  UserSettings.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import SwiftUI
import OSLog

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var ideaPrompt: String {
        didSet {
            Logger.settings.debug("Updating idea prompt in UserDefaults")
            UserDefaults.standard.set(self.ideaPrompt, forKey: "ideaPrompt")
        }
    }
    
    @Published var apiKeyStored: Bool {
        didSet {
            Logger.settings.debug("Updating apiKeyStored flag: \(self.apiKeyStored)")
            UserDefaults.standard.set(self.apiKeyStored, forKey: "apiKeyStored")
        }
    }
    
    private init() {
        Logger.settings.debug("Initializing user settings")
        
        if let savedPrompt = UserDefaults.standard.string(forKey: "ideaPrompt") {
            self.ideaPrompt = savedPrompt
            Logger.settings.info("Loaded saved idea prompt from UserDefaults")
        } else {
            self.ideaPrompt = "Generate 5 creative app ideas for indie developers that solve real problems"
            Logger.settings.info("Using default idea prompt")
        }
        
        self.apiKeyStored = UserDefaults.standard.bool(forKey: "apiKeyStored")
        Logger.settings.info("API key stored state: \(self.apiKeyStored)")
    }
}