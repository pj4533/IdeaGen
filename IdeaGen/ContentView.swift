//
//  ContentView.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @EnvironmentObject private var settings: UserSettings
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if settings.apiKeyStored {
                    Text("Ready to generate ideas!")
                        .font(.headline)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .imageScale(.large)
                            .foregroundStyle(.orange)
                        Text("Please add your OpenAI API key in settings")
                            .multilineTextAlignment(.center)
                        Button("Open Settings") {
                            Logger.ui.debug("User opened settings from API key prompt")
                            showingSettings = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Idea Generator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Logger.ui.debug("User opened settings from gear icon")
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings.shared)
}
