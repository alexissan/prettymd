import Foundation
import AIClient
import Utils

/// Result of a fix operation
public struct FixResult {
    public let originalContent: String
    public let content: String
    public let hasChanges: Bool
    public let style: String
    public let model: String

    public init(originalContent: String, content: String, style: String, model: String) {
        self.originalContent = originalContent
        self.content = content
        self.style = style
        self.model = model

        // Use hasher to detect changes
        let hasher = Hasher()
        self.hasChanges = hasher.hasChanged(original: originalContent, modified: content)
    }
}

/// Manager for fixing markdown files
public class FixManager {
    private let aiClient: AIModelClient
    private let fileIO: FileIO
    private let hasher: Hasher

    public init(aiClient: AIModelClient, fileIO: FileIO) {
        self.aiClient = aiClient
        self.fileIO = fileIO
        self.hasher = Hasher()
    }

    /// Fix a markdown file at the given path
    public func fix(filePath: String, style: String, checkMode: Bool) async throws -> FixResult {
        // Read the original content
        let originalContent = try fileIO.readFile(at: filePath)

        // Validate content size (prevent huge files)
        guard originalContent.count < 100_000 else { // ~100KB limit
            throw FixError.fileTooLarge(size: originalContent.count)
        }

        // Process with AI
        let aiResult = try await aiClient.processMarkdown(
            content: originalContent,
            style: style
        )

        // Clean up the result
        let cleanedContent = cleanupMarkdown(aiResult.content)

        return FixResult(
            originalContent: originalContent,
            content: cleanedContent,
            style: style,
            model: aiResult.model
        )
    }

    /// Fix markdown content directly (without file I/O)
    public func fixContent(_ content: String, style: String) async throws -> FixResult {
        // Validate content size
        guard content.count < 100_000 else {
            throw FixError.contentTooLarge(size: content.count)
        }

        // Process with AI
        let aiResult = try await aiClient.processMarkdown(
            content: content,
            style: style
        )

        // Clean up the result
        let cleanedContent = cleanupMarkdown(aiResult.content)

        return FixResult(
            originalContent: content,
            content: cleanedContent,
            style: style,
            model: aiResult.model
        )
    }

    /// Clean up markdown content after AI processing
    private func cleanupMarkdown(_ content: String) -> String {
        var cleaned = content

        // Remove any potential markdown wrapping that AI might add
        if cleaned.hasPrefix("```markdown") && cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropFirst("```markdown".count))
            cleaned = String(cleaned.dropLast("```".count))
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if cleaned.hasPrefix("```md") && cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropFirst("```md".count))
            cleaned = String(cleaned.dropLast("```".count))
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if cleaned.hasPrefix("```") && cleaned.hasSuffix("```") {
            // Check if it's a full document wrap
            let firstNewline = cleaned.firstIndex(of: "\n") ?? cleaned.endIndex
            let firstLine = String(cleaned[..<firstNewline])
            if firstLine == "```" {
                cleaned = String(cleaned.dropFirst("```".count))
                cleaned = String(cleaned.dropLast("```".count))
                cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        // Ensure single trailing newline
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned += "\n"

        return cleaned
    }
}

/// Errors that can occur during fix operations
public enum FixError: LocalizedError {
    case fileTooLarge(size: Int)
    case contentTooLarge(size: Int)
    case invalidMarkdown
    case processingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .fileTooLarge(let size):
            return "File too large: \(size) bytes (max: 100KB)"
        case .contentTooLarge(let size):
            return "Content too large: \(size) bytes (max: 100KB)"
        case .invalidMarkdown:
            return "Invalid Markdown content"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        }
    }
}