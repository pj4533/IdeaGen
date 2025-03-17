//
//  UserSettings.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var ideaPrompt: String {
        didSet {
            UserDefaults.standard.set(ideaPrompt, forKey: "ideaPrompt")
        }
    }
    
    @Published var apiKeyStored: Bool {
        didSet {
            UserDefaults.standard.set(apiKeyStored, forKey: "apiKeyStored")
        }
    }
    
    private init() {
        self.ideaPrompt = UserDefaults.standard.string(forKey: "ideaPrompt") ?? "Generate 5 creative app ideas for indie developers that solve real problems"
        self.apiKeyStored = UserDefaults.standard.bool(forKey: "apiKeyStored")
    }
}