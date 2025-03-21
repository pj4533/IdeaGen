//
//  SavedIdeasEmptyStateView.swift
//  IdeaGen
//
//  Created by Claude on 3/21/25.
//

import SwiftUI

struct SavedIdeasEmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No Saved Ideas",
            systemImage: "lightbulb",
            description: Text("Your saved ideas will appear here")
        )
    }
}

#Preview {
    SavedIdeasEmptyStateView()
}