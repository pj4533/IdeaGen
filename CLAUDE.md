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

## Documentation
- Project documentation is located in the `/Docs` folder:
  - `ideagen_spec.md`: Project specifications and requirements
  - `swift6_concurrency__pitfalls_and_best_practices.md`: Guidance on Swift 6 concurrency
  - `swifttesting_documentation.md`: How to use the SwiftTesting framework

## Testing Framework
- Use **SwiftTesting** instead of XCTest for all tests
- Import the Testing framework: `import Testing`
- Mark test functions with `@Test` macro
- Test suites should be structs, not XCTestCase subclasses
- Use `#expect(condition)` instead of XCTAssert functions
- Use `#require(value)` to unwrap and verify non-nil values
- For expected errors, use `#expect(throws: ErrorType.self) { ... }`

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

## Swift 6 Concurrency Guidelines
- **UI Code**: All SwiftUI views are `@MainActor` isolated in Swift 6 - keep UI work on main thread
- **Background Tasks**: Use `Task.detached` not `Task` when in a `@MainActor` context to ensure heavy work runs off main thread
- **Task Inheritance**: Be aware that `Task` inherits context from its creator - tasks created in `@MainActor` contexts inherit that isolation
- **Thread Safety**: Make shared models `Sendable` or restrict usage to one actor for thread safety
- **MainActor Usage**: Use `@MainActor` for types that work with UI, models that update UI state, or any code that must run on main thread
- **Isolation Context**: For callbacks guaranteed to run on main thread, use `MainActor.assumeIsolated { ... }` instead of creating new tasks
- **Sendable Conformance**: Ensure data passed between actors conforms to `Sendable` protocol to avoid data races
- **Global Actors**: Swift 6 requires explicit actor isolation - types don't inherit global actor isolation from context

## Project Structure
- **Models/**: Data models and shared state (UserSettings)
- **Views/**: 
  - Main SwiftUI view components (SettingsView)
  - **Views/Settings/**: Components for the settings screen:
    - SettingsViewModel.swift: View model for settings
    - ApiKeyViewDisplay.swift: Display component for API key
    - ApiKeyEditView.swift: Editing component for API key
    - ApiKeySection.swift: Section containing API key components
    - IdeaPromptSection.swift: Section for prompt editing
- **KeychainManager/**: Security utilities for API key storage
- **Services/**: Network and API communication (future OpenAI integration)
- **Extensions/**: Swift extensions including logging categories (Logger+Extensions)

## Code Organization Principles
- Follow MVVM pattern with separate ViewModels for complex views
- Split large views into smaller component files in subdirectories
- Each file should focus on a single responsibility
- Use protocols for testable interfaces like KeychainManaging