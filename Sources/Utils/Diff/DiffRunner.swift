import Foundation

/// Utility for generating diff output between original and modified content
public struct DiffRunner {
    public init() {}

    /// Generate a diff between original and modified content
    public func generateDiff(original: String, modified: String, fileName: String) async throws -> String {
        // Create temporary files
        let fileIO = FileIO()
        let tempDir = fileIO.temporaryDirectory()

        let originalPath = (tempDir as NSString).appendingPathComponent("original_\(UUID().uuidString).md")
        let modifiedPath = (tempDir as NSString).appendingPathComponent("modified_\(UUID().uuidString).md")

        try fileIO.writeFile(content: original, to: originalPath)
        try fileIO.writeFile(content: modified, to: modifiedPath)

        defer {
            // Clean up temporary files
            try? fileIO.removeFile(at: originalPath)
            try? fileIO.removeFile(at: modifiedPath)
        }

        // Run diff command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/diff")
        process.arguments = [
            "-u",
            "--label", "original/\(fileName)",
            "--label", "modified/\(fileName)",
            originalPath,
            modifiedPath
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        // If files are identical, diff returns empty output
        if output.isEmpty {
            return "No changes detected."
        }

        return formatDiffOutput(output)
    }

    /// Generate a simple inline diff without external tools
    public func generateSimpleDiff(original: String, modified: String) -> String {
        let originalLines = original.components(separatedBy: "\n")
        let modifiedLines = modified.components(separatedBy: "\n")

        var output = ["=== Changes ==="]

        let maxLines = max(originalLines.count, modifiedLines.count)

        for i in 0..<maxLines {
            let originalLine = i < originalLines.count ? originalLines[i] : nil
            let modifiedLine = i < modifiedLines.count ? modifiedLines[i] : nil

            if originalLine != modifiedLine {
                if let original = originalLine, let modified = modifiedLine {
                    // Line changed
                    output.append("Line \(i + 1):")
                    output.append("- \(original)")
                    output.append("+ \(modified)")
                } else if let original = originalLine {
                    // Line removed
                    output.append("Line \(i + 1) removed:")
                    output.append("- \(original)")
                } else if let modified = modifiedLine {
                    // Line added
                    output.append("Line \(i + 1) added:")
                    output.append("+ \(modified)")
                }
                output.append("")
            }
        }

        if output.count == 1 {
            return "No changes detected."
        }

        return output.joined(separator: "\n")
    }

    /// Format diff output with color codes for terminal
    private func formatDiffOutput(_ diff: String) -> String {
        let lines = diff.components(separatedBy: "\n")
        let formatted = lines.map { line in
            if line.hasPrefix("+++") {
                return "\u{001B}[32m\(line)\u{001B}[0m" // Green
            } else if line.hasPrefix("---") {
                return "\u{001B}[31m\(line)\u{001B}[0m" // Red
            } else if line.hasPrefix("+") {
                return "\u{001B}[32m\(line)\u{001B}[0m" // Green
            } else if line.hasPrefix("-") {
                return "\u{001B}[31m\(line)\u{001B}[0m" // Red
            } else if line.hasPrefix("@@") {
                return "\u{001B}[36m\(line)\u{001B}[0m" // Cyan
            } else {
                return line
            }
        }

        return formatted.joined(separator: "\n")
    }
}