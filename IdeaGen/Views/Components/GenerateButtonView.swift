//
//  GenerateButtonView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct GenerateButtonView: View {
    let isGenerating: Bool
    let isDisabled: Bool
    var onGenerate: () -> Void
    
    var body: some View {
        Button(action: {
            Logger.ui.debug("Generate idea button tapped")
            onGenerate()
        }) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Image(systemName: "bolt.fill")
                }
                
                Text(isGenerating ? "Generating..." : "Generate Idea")
            }
            .frame(minWidth: 200)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor)
            )
            .foregroundColor(.white)
        }
        .disabled(isGenerating || isDisabled)
        .padding(.bottom, 20)
    }
}

#Preview {
    VStack {
        GenerateButtonView(
            isGenerating: false,
            isDisabled: false,
            onGenerate: {}
        )
        
        GenerateButtonView(
            isGenerating: true,
            isDisabled: false,
            onGenerate: {}
        )
        
        GenerateButtonView(
            isGenerating: false,
            isDisabled: true,
            onGenerate: {}
        )
    }
    .padding()
}