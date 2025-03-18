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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated Idea")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Parse the idea content to extract the title and description
                    let components = IdeaContentParser.parse(idea.content)
                    
                    if let title = components.title {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text(components.description)
                        .font(.body)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                )
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    Logger.ui.debug("Clear idea button tapped")
                    onClear()
                }) {
                    Text("Clear")
                        .frame(minWidth: 80)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    IdeaDisplayView(
        idea: Idea(content: "TaskFlow\n\nA productivity app that uses AI to intelligently organize and prioritize your tasks based on deadlines, importance, and your work habits. It integrates with calendars and uses adaptive learning to suggest optimal times for focused work."),
        onClear: {}
    )
}