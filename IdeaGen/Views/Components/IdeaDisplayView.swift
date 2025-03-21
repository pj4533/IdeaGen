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
    
    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading, spacing: 16) {
                Text("\(UserSettings.shared.ideaPrompt)...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                IdeaContentView(idea: idea, isGenerating: isGenerating)
                
                // Action buttons for saving or generating a new idea - only visible when not generating
                if !isGenerating {
                    IdeaActionButtonsView(onClear: onClear, onSave: onSave)
                }
            }
            
            // Loading animation - only visible component during generation
            if isGenerating {
                IdeaLoadingView()
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