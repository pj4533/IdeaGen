//
//  IdeaGenApp.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

@main
struct IdeaGenApp: App {
    @StateObject private var settings = UserSettings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
