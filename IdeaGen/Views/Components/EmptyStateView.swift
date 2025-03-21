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
    var isGenerating: Bool = false
    
    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading, spacing: 16) {
                Text("\(userSettings.ideaPrompt)...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tap the generate button to create an idea based on your prompt")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .minimumScaleFactor(0.5)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(6)
                            .blur(radius: isGenerating ? 30 : 0)
                            .opacity(isGenerating ? 0.2 : 1)
                            .animation(.easeInOut(duration: 0.2), value: isGenerating)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                
                if !userSettings.apiKeyStored {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("API key required in settings")
                    }
                    .foregroundColor(.orange)
                    .padding(.top, 8)
                }
            }
            
            // Loading animation - positioned over everything when generating
            if isGenerating {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.yellow)
                                .symbolEffect(.pulse.byLayer, options: .repeating)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 120))
                                .foregroundColor(.orange.opacity(0.7))
                                .symbolEffect(.bounce.up.byLayer, options: .repeating)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    EmptyStateView()
        .environmentObject(UserSettings.shared)
}