//
//  EmptyStateView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct EmptyStateView: View {
    @EnvironmentObject private var userSettings: UserSettings
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 70))
                .foregroundColor(.yellow)
            
            Text("Generate a creative app idea")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Tap the button below to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !userSettings.apiKeyStored {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("API key required in settings")
                }
                .foregroundColor(.orange)
                .padding(.top)
            }
            
            Spacer()
        }
        .padding(.top, 60)
    }
}

#Preview {
    EmptyStateView()
        .environmentObject(UserSettings.shared)
}