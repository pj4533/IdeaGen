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
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Idea content text with dynamic size
                    Text(idea.content)
                        .font(.system(size: getDynamicFontSize(for: idea.content, in: geometry.size), weight: .bold, design: .default))
                        .minimumScaleFactor(0.5)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(8)
                        .blur(radius: isGenerating ? 30 : 0)
                        .opacity(isGenerating ? 0.2 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isGenerating)
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .leading)
                .padding()
            }
        }
    }
    
    // Calculate font size based on content length and available area
    private func getDynamicFontSize(for content: String, in size: CGSize) -> CGFloat {
        let baseSize: CGFloat = 48
        let averageCharWidth: CGFloat = 12  // Approximate width of character at base size
        
        let contentLength = content.count
        let availableWidth = size.width - 32  // Accounting for padding
        let availableHeight = size.height - 32
        
        // Estimate characters per line at base size
        let charsPerLine = max(1, Int(availableWidth / averageCharWidth))
        
        // Estimate number of lines needed
        let estimatedLines = Double(contentLength) / Double(charsPerLine)
        
        // Calculate size to fill available height
        let targetSize = min(baseSize, baseSize * (availableHeight / (estimatedLines * 1.5 * baseSize)))
        
        // Constrain size between reasonable bounds
        return min(max(targetSize, 20), baseSize)
    }
}

#Preview {
    IdeaContentView(
        idea: Idea(content: "TaskFlow\n\nA productivity app that uses AI to intelligently organize and prioritize your tasks."),
        isGenerating: false
    )
}