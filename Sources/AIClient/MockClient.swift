import Foundation

/// Mock AI client for testing without API calls
public class MockClient: AIModelClient {
    public var providerName: String {
        return "Mock"
    }

    public var isAvailable: Bool {
        return true
    }

    private let delay: TimeInterval

    public init(delay: TimeInterval = 0.5) {
        self.delay = delay
    }

    public func processMarkdown(content: String, style: String) async throws -> AIResult {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        // Apply basic mock transformations
        let processedContent = applyMockTransformations(to: content, style: style)

        return AIResult(
            content: processedContent,
            tokensUsed: content.count / 4, // Rough token estimate
            model: "mock-1.0"
        )
    }

    private func applyMockTransformations(to content: String, style: String) -> String {
        var lines = content.components(separatedBy: "\n")

        // Apply style-specific transformations
        switch style.lowercased() {
        case "concise":
            lines = makeContentConcise(lines)
        case "friendly":
            lines = makeContentFriendly(lines)
        case "technical":
            lines = makeContentTechnical(lines)
        default:
            break
        }

        // Apply general improvements
        lines = lines.map { line in
            var processed = line

            // Fix common issues
            processed = fixCommonIssues(processed)

            // Ensure proper heading formatting
            if processed.hasPrefix("#") {
                processed = ensureHeadingFormat(processed)
            }

            // Fix list formatting
            if processed.trimmingCharacters(in: .whitespaces).hasPrefix("-") ||
               processed.trimmingCharacters(in: .whitespaces).hasPrefix("*") {
                processed = ensureListFormat(processed)
            }

            return processed
        }

        return lines.joined(separator: "\n")
    }

    private func makeContentConcise(_ lines: [String]) -> [String] {
        return lines.map { line in
            // Simple conciseness simulation - remove filler words
            var processed = line
            let fillerWords = ["really", "very", "quite", "somewhat", "rather"]
            for word in fillerWords {
                processed = processed.replacingOccurrences(
                    of: " \(word) ",
                    with: " ",
                    options: .caseInsensitive
                )
            }
            return processed
        }
    }

    private func makeContentFriendly(_ lines: [String]) -> [String] {
        var processedLines = lines

        // Add friendly greeting if document starts with a heading
        if let firstLine = processedLines.first, firstLine.hasPrefix("#") {
            // Keep as is - friendly doesn't mean changing structure
        }

        return processedLines
    }

    private func makeContentTechnical(_ lines: [String]) -> [String] {
        return lines.map { line in
            // Ensure technical precision in certain phrases
            var processed = line
            processed = processed.replacingOccurrences(of: "app", with: "application")
            processed = processed.replacingOccurrences(of: "config", with: "configuration")
            processed = processed.replacingOccurrences(of: "repo", with: "repository")
            return processed
        }
    }

    private func fixCommonIssues(_ line: String) -> String {
        var processed = line

        // Fix double spaces
        while processed.contains("  ") {
            processed = processed.replacingOccurrences(of: "  ", with: " ")
        }

        // Fix missing space after period
        processed = processed.replacingOccurrences(of: ".", with: ". ")
        processed = processed.replacingOccurrences(of: ".  ", with: ". ")

        // Capitalize first letter after period
        let sentences = processed.components(separatedBy: ". ")
        processed = sentences.map { sentence in
            guard !sentence.isEmpty else { return sentence }
            return sentence.prefix(1).uppercased() + sentence.dropFirst()
        }.joined(separator: ". ")

        return processed
    }

    private func ensureHeadingFormat(_ line: String) -> String {
        // Ensure space after # symbols
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if let hashRange = trimmed.range(of: "^#+", options: .regularExpression) {
            let hashes = String(trimmed[hashRange])
            let rest = String(trimmed[hashRange.upperBound...])
            let trimmedRest = rest.trimmingCharacters(in: .whitespaces)

            if !trimmedRest.isEmpty {
                return "\(hashes) \(trimmedRest)"
            }
        }
        return line
    }

    private func ensureListFormat(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("-") || trimmed.hasPrefix("*") {
            let marker = String(trimmed.prefix(1))
            let rest = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)

            if !rest.isEmpty {
                // Detect indentation level
                let leadingSpaces = line.prefix(while: { $0 == " " })
                return "\(leadingSpaces)\(marker) \(rest)"
            }
        }
        return line
    }
}