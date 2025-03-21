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
        Section(header: Text("Idea Prompt"), footer: Text("This prompt will be used to generate ideas")) {
            TextEditor(text: $settings.ideaPrompt)
                .font(.system(size: 16))
                .frame(minHeight: 100)
        }
    }
}