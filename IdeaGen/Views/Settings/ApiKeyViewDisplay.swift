//
//  ApiKeyViewDisplay.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

struct ApiKeyViewDisplay: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.maskApiKey(viewModel.apiKey))
                .font(.system(.body, design: .monospaced))
                .onAppear {
                    Task {
                        await viewModel.loadApiKey()
                    }
                }
            
            Spacer()
            
            Button("Edit") {
                viewModel.startEditing()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
}