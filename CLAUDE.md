# IdeaGen Development Guide

## Build & Test Commands
- Open in Xcode: `xed IdeaGen.xcodeproj`
- Build app (GUI): ⌘+B (or Product > Build)
- Run app (GUI): ⌘+R (or Product > Run)
- Run all tests (GUI): ⌘+U (or Product > Test)
- Run single test (GUI): Select test method and press ⌃+⌥+⌘+U
- Run UI tests (GUI): Select UI test class/method and press ⌃+⌥+⌘+U
- Build from command line: `xcodebuild -project IdeaGen.xcodeproj -scheme IdeaGen -configuration Debug -destination "platform=iOS Simulator,name=iPhone 16 Pro" build`
- Run tests from command line: `xcodebuild -project IdeaGen.xcodeproj -scheme IdeaGen -configuration Debug -destination "platform=iOS Simulator,name=iPhone 16 Pro" test`

## Code Style Guidelines
- **Imports**: Group imports with SwiftUI first, then alphabetically
- **Formatting**: 4-space indentation, 100-character line limit
- **Types**: Use Swift's type inference when obvious, explicit types otherwise
- **Naming**:
  - Use descriptive camelCase for variables, methods, and properties
  - Use UpperCamelCase for types (structs, classes, enums)
  - Prefer clarity over brevity in names
- **SwiftUI Views**: Extract reusable view components to separate structs
- **Error Handling**: Use Swift's modern async/await with try/catch blocks
- **Access Control**: Mark private properties that aren't used outside their type
- **Comments**: Use meaningful comments for complex logic, avoid obvious ones
- **Testing**: Follow AAA pattern (Arrange, Act, Assert) in test methods
- **Logging**: Use OSLog with appropriate categories:
  - `Logger.app`: App lifecycle and general operations
  - `Logger.keychain`: Security and keychain operations
  - `Logger.settings`: User preferences and settings
  - `Logger.network`: API communications
  - `Logger.ui`: User interface events
  - Use appropriate log levels (debug, info, error)

## Project Structure
- **Models/**: Data models and shared state (UserSettings)
- **Views/**: SwiftUI view components (SettingsView)
- **KeychainManager/**: Security utilities for API key storage
- **Services/**: Network and API communication (future OpenAI integration)
- **Extensions/**: Swift extensions including logging categories (Logger+Extensions)