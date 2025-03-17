# IdeaGen Development Guide

## Build & Test Commands
- Build app: `xed IdeaGen.xcodeproj` then ⌘+B (or Product > Build)
- Run app: ⌘+R (or Product > Run)
- Run all tests: ⌘+U (or Product > Test)
- Run single test: Select test method and press ⌃+⌥+⌘+U
- Run UI tests: Select UI test class/method and press ⌃+⌥+⌘+U

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