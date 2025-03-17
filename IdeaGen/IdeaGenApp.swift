//
//  IdeaGenApp.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

@main
struct IdeaGenApp: App {
    @StateObject private var settings = UserSettings.shared
    
    init() {
        Logger.app.info("IdeaGen app initializing")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .onAppear {
                    Logger.app.info("Main ContentView appeared")
                }
        }
    }
}
