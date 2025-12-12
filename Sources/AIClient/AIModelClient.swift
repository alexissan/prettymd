import Foundation

/// Result from AI processing
public struct AIResult {
    public let content: String
    public let tokensUsed: Int?
    public let model: String

    public init(content: String, tokensUsed: Int? = nil, model: String) {
        self.content = content
        self.tokensUsed = tokensUsed
        self.model = model
    }
}

/// Protocol for AI model clients
public protocol AIModelClient {
    /// Process markdown content with the AI model
    func processMarkdown(content: String, style: String) async throws -> AIResult

    /// Get the name of the AI provider
    var providerName: String { get }

    /// Check if the client is available and configured
    var isAvailable: Bool { get }
}

/// Errors that can occur during AI processing
public enum AIClientError: LocalizedError {
    case apiKeyMissing
    case networkError(String)
    case invalidResponse
    case rateLimitExceeded
    case contentTooLarge
    case serverError(String)

    public var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API key is missing. Please set the OPENAI_API_KEY environment variable."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from AI provider"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .contentTooLarge:
            return "Content is too large for processing"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}