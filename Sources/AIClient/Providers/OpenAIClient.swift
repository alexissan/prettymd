import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1

/// OpenAI API client implementation
public class OpenAIClient: AIModelClient {
    private let apiKey: String
    private let httpClient: HTTPClient
    private let model: String
    private let maxTokens: Int = 4000
    private let temperature: Double = 0.7

    public var providerName: String {
        return "OpenAI"
    }

    public var isAvailable: Bool {
        return !apiKey.isEmpty
    }

    public init(apiKey: String, model: String? = nil) async throws {
        guard !apiKey.isEmpty else {
            throw AIClientError.apiKeyMissing
        }
        self.apiKey = apiKey
        // Default to gpt-4o-mini for cost efficiency, allow override
        self.model = model ?? "gpt-4o-mini"
        self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
    }

    deinit {
        try? httpClient.syncShutdown()
    }

    public func processMarkdown(content: String, style: String) async throws -> AIResult {
        let systemPrompt = createSystemPrompt(style: style)
        let userPrompt = "Please improve the following Markdown content:\n\n\(content)"

        let requestBody = OpenAIRequest(
            model: model,
            messages: [
                Message(role: "system", content: systemPrompt),
                Message(role: "user", content: userPrompt)
            ],
            max_tokens: maxTokens,
            temperature: temperature
        )

        let response = try await sendRequest(body: requestBody)

        guard let firstChoice = response.choices.first else {
            throw AIClientError.invalidResponse
        }

        return AIResult(
            content: firstChoice.message.content,
            tokensUsed: response.usage?.total_tokens,
            model: model
        )
    }

    private func createSystemPrompt(style: String) -> String {
        let basePrompt = """
        You are an expert Markdown formatter. Your task is to improve Markdown documents while preserving their meaning and structure.

        Focus on:
        - Fixing grammar and spelling errors
        - Improving clarity and readability
        - Ensuring consistent formatting
        - Maintaining proper Markdown syntax
        - Preserving code blocks and technical content exactly as-is

        Important rules:
        - Do not change the meaning or intent of the content
        - Preserve all code blocks, commands, and technical specifications exactly
        - Maintain the original document structure
        - Keep the same heading hierarchy
        - Return only the improved Markdown content without explanations
        """

        let styleModifier: String
        switch style.lowercased() {
        case "concise":
            styleModifier = "\n\nStyle: Be concise and direct. Remove unnecessary words while maintaining clarity."
        case "friendly":
            styleModifier = "\n\nStyle: Use a friendly, approachable tone while maintaining professionalism."
        case "technical":
            styleModifier = "\n\nStyle: Use precise technical language. Be thorough and accurate."
        default:
            styleModifier = "\n\nStyle: Professional and clear technical documentation style."
        }

        return basePrompt + styleModifier
    }

    private func sendRequest(body: OpenAIRequest) async throws -> OpenAIResponse {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestData = try encoder.encode(body)

        var request = HTTPClientRequest(url: "https://api.openai.com/v1/chat/completions")
        request.method = .POST
        request.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        request.headers.add(name: "Content-Type", value: "application/json")
        request.body = .bytes(ByteBuffer(data: requestData))

        let response: HTTPClientResponse
        do {
            response = try await httpClient.execute(request, timeout: .seconds(30))
        } catch {
            throw AIClientError.networkError(error.localizedDescription)
        }

        guard response.status == .ok else {
            if response.status == .tooManyRequests {
                throw AIClientError.rateLimitExceeded
            }
            let body = try await response.body.collect(upTo: 1024 * 1024)
            let errorMessage = String(buffer: body)
            throw AIClientError.serverError("HTTP \(response.status.code): \(errorMessage)")
        }

        let responseBody = try await response.body.collect(upTo: 10 * 1024 * 1024) // 10MB max
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(OpenAIResponse.self, from: responseBody)
        } catch {
            throw AIClientError.invalidResponse
        }
    }
}

// MARK: - OpenAI API Models

private struct OpenAIRequest: Encodable {
    let model: String
    let messages: [Message]
    let max_tokens: Int
    let temperature: Double
}

private struct Message: Codable {
    let role: String
    let content: String
}

private struct OpenAIResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?

    struct Choice: Decodable {
        let message: Message
    }

    struct Usage: Decodable {
        let total_tokens: Int
    }
}