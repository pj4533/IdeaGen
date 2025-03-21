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
        if !isGenerating {
            Button(action: {
                Logger.ui.debug("Generate idea button tapped")
                onGenerate()
            }) {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("Generate Idea")
                }
                .frame(minWidth: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor)
                )
                .foregroundColor(.white)
            }
            .disabled(isDisabled)
            .padding(.bottom, 20)
        } else {
            // Empty view with same padding when generating
            Color.clear
                .frame(height: 20)
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    VStack {
        // Normal state
        GenerateButtonView(
            isGenerating: false,
            isDisabled: false,
            onGenerate: {}
        )
        
        // Generating state (should be invisible)
        GenerateButtonView(
            isGenerating: true,
            isDisabled: false,
            onGenerate: {}
        )
        
        // Disabled state
        GenerateButtonView(
            isGenerating: false,
            isDisabled: true,
            onGenerate: {}
        )
    }
    .padding()
}