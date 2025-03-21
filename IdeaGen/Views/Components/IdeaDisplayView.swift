//
//  IdeaDisplayView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct IdeaDisplayView: View {
    let idea: Idea
    var onClear: () -> Void
    var onSave: () -> Void
    var isGenerating: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading, spacing: 16) {
                Text("\(UserSettings.shared.ideaPrompt)...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Idea content text
                        Text(idea.content)
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
                
                // Action buttons for saving or generating a new idea
                if !isGenerating {
                    HStack(spacing: 10) {
                        // Generate New button
                        Button(action: {
                            Logger.ui.debug("Generate new idea button tapped")
                            onClear() // Now calls generateIdea() directly
                        }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Generate New")
                                    .fontWeight(.semibold)
                            }
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.bordered)
                        
                        // Save button
                        Button(action: {
                            Logger.ui.debug("Save idea button tapped")
                            onSave()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save")
                                    .fontWeight(.semibold)
                            }
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
            
            // Loading animation - absolutely positioned over everything
            if isGenerating {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                                .symbolEffect(.pulse.byLayer, options: .repeating)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 100))
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
    IdeaDisplayView(
        idea: Idea(content: "TaskFlow\n\nA productivity app that uses AI to intelligently organize and prioritize your tasks based on deadlines, importance, and your work habits. It integrates with calendars and uses adaptive learning to suggest optimal times for focused work."),
        onClear: {},
        onSave: {},
        isGenerating: false
    )
}