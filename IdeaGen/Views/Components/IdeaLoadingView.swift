//
//  IdeaLoadingView.swift
//  IdeaGen
//
//  Created by Claude on 3/21/25.
//

import SwiftUI

struct IdeaLoadingView: View {
    var body: some View {
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

#Preview {
    IdeaLoadingView()
}