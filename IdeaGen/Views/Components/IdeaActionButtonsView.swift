//
//  IdeaActionButtonsView.swift
//  IdeaGen
//
//  Created by Claude on 3/21/25.
//

import SwiftUI
import OSLog

struct IdeaActionButtonsView: View {
    var onClear: () -> Void
    var onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // Generate New button
            Button(action: {
                Logger.ui.debug("Generate new idea button tapped")
                onClear()
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
            
            // Save and generate button
            Button(action: {
                Logger.ui.debug("Save and new button tapped")
                onSave()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save & New")
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

#Preview {
    IdeaActionButtonsView(onClear: {}, onSave: {})
        .padding()
}