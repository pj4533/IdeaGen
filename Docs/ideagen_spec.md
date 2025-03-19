**## Developer Specification: Idea Generator iOS App**

### **Overview**
This is a minimalistic iOS app designed to quickly generate, save, and manage short idea snippets using OpenAI's GPT-4o through the brand new [Responses API](https://platform.openai.com/docs/api-reference/responses). The user enters a persistent prompt in settings, taps a button to generate an idea, and decides to either save or discard it. The app is designed for quick interactions and local storage of ideas.

---

## **Features & Requirements**

### **1. Core Functionality**
- **User starts on a main screen** with a button to generate an idea.
- **Upon tapping the button**, the app calls OpenAI’s API using the user’s saved prompt.
- **Streaming response:** Ideas are displayed token-by-token as they arrive.
- **Users can either save or discard the idea.**
  - Both actions immediately generate a new idea.
- **Saved ideas** are stored locally and displayed in a simple chronological list.
- **Tapping a saved idea** opens a modal for editing or deleting it.
- **Settings screen** allows users to enter an OpenAI API key and a prompt.
- **Key is stored securely in the iOS Keychain.**
- **Error handling** provides detailed messages for API failures.

### **2. UI & UX**
- **Minimalist design, following system defaults** (e.g., buttons, text fields).
- **Supports Dark Mode.**
- **Uses Dynamic Type for text resizing.**
- **Animations:**
  - Placeholder text displayed while waiting for the first token.
  - Subtle loading indicator before response starts streaming.
- **Navigation:**
  - Main screen for idea generation.
  - Separate saved ideas screen.
  - Modal for editing saved ideas.
  - Settings screen.
- **Actions:**
  - Save/discard idea.
  - Edit/delete saved ideas.
  - Enter/remove OpenAI API key.
  - Enter a persistent prompt.
  - Swipe to delete ideas from the list.

---

## **Architecture**

### **1. MVVM Structure**
- **View:** SwiftUI views for UI elements.
- **ViewModel:** Handles UI logic and API calls.
- **Model:** Data structures for ideas and user settings.
- **Managers:**
  - `NetworkManager`: Handles network requests (dependency-injected for testability).
  - `OpenAIManager`: Handles API calls and response decoding.
  - `StorageManager`: Manages saving/loading ideas via `UserDefaults`.

### **2. Data Handling**
- **Saved ideas stored locally** using `Codable` JSON format in `UserDefaults`.
- **No cloud sync or online backup.**
- **No analytics or tracking.**
- **No user authentication.**

### **3. OpenAI API Integration**
- Uses **GPT-4o Responses API**.
- **Streaming enabled** to display ideas progressively.
- **Fixed temperature and token limits**, set in code.
- **API key stored in Keychain**, entered manually by the user.
- **No caching of API responses.**

### **4. Error Handling & Logging**
- **Network & API errors display detailed messages** to the user.
- **OSLog used for internal debugging logs.**
- **Offline detection:** Shows error only when trying to generate an idea.
- **No automatic retries for failed API requests.**

---

## **Testing Plan**

### **1. Unit Testing**
- `NetworkManagerTests`: Ensure API requests return expected responses.
- `OpenAIManagerTests`: Validate parsing of streamed API responses.
- `StorageManagerTests`: Verify saving, editing, and deleting ideas.

---

## **Future Enhancements**
- Sharing/exporting ideas.
- Custom gestures for interaction.
- Optional tone/style adjustments.
- iPad support and multitasking.
- Alternative LLM providers (Anthropic, etc.).
- Onboarding tutorial (if needed).

---

## **Final Notes**
- **SwiftUI-only implementation.**
- **Requires the latest iOS major version.**
- **No Combine framework.**
- **Portrait mode only.**
- **No tracking, analytics, or authentication.**

This document provides a full breakdown of the app’s requirements, architecture, and testing plan, allowing a developer to start implementation immediately.

