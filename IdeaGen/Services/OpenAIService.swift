//
//  OpenAIService.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation
import OSLog

/// Protocol for OpenAI service - enables dependency injection for testing
protocol OpenAIServiceProtocol: Sendable {
    /// Generates an idea based on the given prompt
    /// - Parameter prompt: The user prompt to generate the idea
    /// - Returns: An IdeaGenerationResult containing either the generated idea or an error
    func generateIdea(prompt: String) async -> IdeaGenerationResult
}

/// Implementation of the OpenAI service
final class OpenAIService: OpenAIServiceProtocol {
    // Use singleton pattern for shared instance
    static let shared = OpenAIService()
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o" // Default model
    private let keychainManager: KeychainManaging
    private let urlSession: URLSession
    
    // Configuration for idea generation
    private let temperature: Float = 0.8
    private let maxTokens: Int = 1000
    
    nonisolated init(keychainManager: KeychainManaging = KeychainManager.shared,
         urlSession: URLSession = .shared) {
        self.keychainManager = keychainManager
        self.urlSession = urlSession
    }
    
    /// Generates an idea based on the given prompt
    /// - Parameter prompt: The user prompt to generate the idea
    /// - Returns: An IdeaGenerationResult containing either the generated idea or an error
    func generateIdea(prompt: String) async -> IdeaGenerationResult {
        Logger.prompt.info("User prompt: \(prompt)")
        
        // First, get the API key
        guard let apiKey = await keychainManager.getApiKey() else {
            Logger.network.error("No API key found for OpenAI service")
            return .failure(.noApiKey)
        }
        
        // Create the request body
        let requestBody = OpenAICompletionsRequest(
            model: model,
            messages: [
                .system(OpenAICompletionsRequest.ideaGenerationIntro),
                .user(prompt)
            ],
            temperature: temperature,
            maxTokens: maxTokens,
            responseFormat: nil
        )
        
        // Log the full request JSON for debugging
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let prettyJsonData = try jsonEncoder.encode(requestBody)
            if let jsonString = String(data: prettyJsonData, encoding: .utf8) {
                Logger.prompt.info("OpenAI Request: \(jsonString)")
            }
        } catch {
            Logger.prompt.error("Failed to log request JSON: \(error.localizedDescription)")
        }
        
        do {
            // Convert the request to JSON data
            let jsonData = try JSONEncoder().encode(requestBody)
            
            // Create the URLRequest
            var request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            // Make the network request
            Logger.network.debug("Sending request to OpenAI API")
            let (data, response) = try await urlSession.data(for: request)
            
            // Handle HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.network.error("Invalid HTTP response")
                return .failure(.invalidResponse)
            }
            
            // Handle error status codes
            switch httpResponse.statusCode {
            case 200:
                // Success - proceed to parsing
                break
            case 400:
                // Try to parse the error response
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    let errorMessage = errorResponse.error.message
                    Logger.network.error("API error: \(errorMessage)")
                    
                    // Handle specific error cases
                    if errorMessage.contains("limit") {
                        return .failure(.rateLimitExceeded)
                    } else if errorMessage.contains("context") {
                        return .failure(.contextLimitExceeded)
                    } else {
                        return .failure(.apiError(errorMessage))
                    }
                }
                return .failure(.apiError("Bad request"))
                
            case 401:
                Logger.network.error("API authentication failed - invalid API key")
                return .failure(.invalidApiKey)
                
            case 429:
                Logger.network.error("API rate limit exceeded")
                return .failure(.rateLimitExceeded)
                
            case 500...599:
                Logger.network.error("Server error with status code: \(httpResponse.statusCode)")
                return .failure(.serverError(httpResponse.statusCode))
                
            default:
                Logger.network.error("Unexpected status code: \(httpResponse.statusCode)")
                return .failure(.apiError("Unexpected status code: \(httpResponse.statusCode)"))
            }
            
            // Parse the response
            let decodedResponse = try JSONDecoder().decode(OpenAICompletionsResponse.self, from: data)
            
            // Extract the generated idea
            guard let choice = decodedResponse.choices.first,
                  let content = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
                Logger.network.error("Empty or invalid content in OpenAI response")
                return .failure(.invalidResponse)
            }
            
            let idea = Idea(content: content)
            return .success(idea)
            
        } catch {
            Logger.network.error("Error generating idea: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                return .failure(.networkError(urlError.localizedDescription))
            } else {
                return .failure(.unknown)
            }
        }
    }
    
}

// MARK: - Helper Extensions

extension String {
    /// Returns nil if the string is empty
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
}
