//
//  IdeaContentView.swift
//  IdeaGen
//
//  Created by Claude on 3/21/25.
//

import SwiftUI

struct IdeaContentView: View {
    let idea: Idea
    let isGenerating: Bool
    
    var body: some View {
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
    }
}

#Preview {
    IdeaContentView(
        idea: Idea(content: "TaskFlow\n\nA productivity app that uses AI to intelligently organize and prioritize your tasks."),
        isGenerating: false
    )
}