//
//  SettingsView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI

// Import all settings components
@_exported import OSLog

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: UserSettings
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        // Use StateObject to initialize the view model
        _viewModel = StateObject(wrappedValue: SettingsViewModel(userSettings: UserSettings.shared))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ApiKeySection(viewModel: viewModel)
                IdeaPromptSection(settings: settings)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Settings", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings.shared)
}