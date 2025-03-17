//
//  IdeaPromptSection.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

struct IdeaPromptSection: View {
    @ObservedObject var settings: UserSettings
    
    var body: some View {
        Section(header: Text("Idea Prompt"), footer: Text("This prompt will be prefaced with contextual information to generate each idea")) {
            TextEditor(text: $settings.ideaPrompt)
                .frame(minHeight: 100)
        }
    }
}