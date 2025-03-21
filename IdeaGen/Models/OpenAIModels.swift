//
//  OpenAIModels.swift
//  IdeaGen
//
//  Created by PJ Gray on 3/17/25.
//

import Foundation

// Models for working with OpenAI API based on the Responses API
// https://platform.openai.com/docs/api-reference/responses

// Idea model has been moved to Idea.swift

/// Result of an idea generation operation
enum IdeaGenerationResult: Equatable, Sendable {
    case success(Idea)
    case failure(IdeaGenerationError)
}

/// Errors that can occur during idea generation
enum IdeaGenerationError: Error, LocalizedError, Equatable, Sendable {
    case networkError(String)
    case apiError(String)
    case noApiKey
    case invalidResponse
    case decodingError
    case serverError(Int)
    case rateLimitExceeded
    case contextLimitExceeded
    case invalidApiKey
    case unknown
    
    nonisolated var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .noApiKey:
            return "No API key found. Please set your OpenAI API key in Settings."
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .decodingError:
            return "Failed to decode the response from OpenAI API"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .contextLimitExceeded:
            return "Context limit exceeded. Please try with a shorter prompt."
        case .invalidApiKey:
            return "Invalid API key. Please check your OpenAI API key in Settings."
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - OpenAI API Request Models

/// Request model for OpenAI chat completions
struct OpenAICompletionsRequest: Codable, Sendable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Float?
    let maxTokens: Int?
    let responseFormat: ResponseFormat?
    
    // Fixed system message for idea generation
    static let ideaGenerationIntro = """
Generate a single short idea, under 10 words.
- Don't include any part of the prompt in the idea you generate. 
- Keep it descriptive to the idea only. 
- Dont not give the idea a name, only provide the text of the idea.
- Keep the idea quick and short. One sentence max. 
- Do not use any markdown or other styling.

EXAMPLE:
User: "Here is the basis for the idea you should generate: a cli tool for developers"

Assistant: "automatically generate documentation by scanning code comments."
"""
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }
    
    struct ResponseFormat: Codable, Sendable {
        let type: String
        
        static let json = ResponseFormat(type: "json_object")
        static let text = ResponseFormat(type: "text")
    }
}

/// Represents a message in the OpenAI chat completions API
struct OpenAIMessage: Codable, Sendable {
    let role: String
    let content: String
    
    static func system(_ content: String) -> OpenAIMessage {
        OpenAIMessage(role: "system", content: content)
    }
    
    static func user(_ content: String) -> OpenAIMessage {
        OpenAIMessage(role: "user", content: content)
    }
}

// MARK: - OpenAI API Response Models

/// Response model for OpenAI chat completions
struct OpenAICompletionsResponse: Codable, Sendable {
    let id: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
    let created: Int
    let model: String
    
    struct OpenAIChoice: Codable, Sendable {
        let index: Int
        let message: OpenAIMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }
    
    struct OpenAIUsage: Codable, Sendable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

/// Error response from OpenAI API
struct OpenAIErrorResponse: Codable, Sendable {
    let error: OpenAIError
    
    struct OpenAIError: Codable, Sendable {
        let message: String
        let type: String
        let code: String?
    }
}
