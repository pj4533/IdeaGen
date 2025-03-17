//
//  ContentView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @EnvironmentObject private var settings: UserSettings
    
    var body: some View {
        // Use our new IdeaGenerationView as the main content
        IdeaGenerationView()
            .environmentObject(settings)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings.shared)
}
