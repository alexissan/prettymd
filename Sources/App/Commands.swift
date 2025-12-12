import ArgumentParser
import Foundation
import Core
import Utils
import AIClient

@main
struct PrettyMD: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "prettymd",
        abstract: "AI-powered Markdown formatter for developer workflows",
        version: "0.1.0",
        subcommands: [Fix.self],
        defaultSubcommand: Fix.self
    )
}

struct Fix: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Polish and improve existing Markdown files"
    )

    @Argument(help: "Path to the Markdown file to fix")
    var path: String

    @Flag(name: .long, help: "Write the polished Markdown back to the file")
    var inPlace: Bool = false

    @Option(name: .long, help: "Set the tone style (concise, technical, friendly)")
    var style: String?

    @Flag(name: .long, help: "Exit with non-zero status if changes would be made")
    var check: Bool = false

    @Flag(name: .long, help: "Use mock AI client for testing (no API key required)")
    var mock: Bool = false

    @Flag(name: .long, help: "Show diff between original and fixed content")
    var diff: Bool = false

    @Option(name: .long, help: "OpenAI model to use (gpt-4o-mini, gpt-3.5-turbo)")
    var model: String?

    mutating func run() async throws {
        // Validate file path
        let fileURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw ValidationError("File not found: \(path)")
        }

        guard fileURL.pathExtension == "md" || fileURL.pathExtension == "markdown" else {
            throw ValidationError("File must be a Markdown file (.md or .markdown)")
        }

        // Get style from option or environment
        let selectedStyle = style ?? ProcessInfo.processInfo.environment["PRETTYMD_STYLE"] ?? "technical"

        // Initialize AI client
        let aiClient: AIModelClient
        if mock {
            aiClient = MockClient()
        } else {
            guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
                throw ValidationError("OPENAI_API_KEY environment variable is required. Set it with: export OPENAI_API_KEY=\"sk-...\"")
            }
            let selectedModel = model ?? ProcessInfo.processInfo.environment["PRETTYMD_MODEL"]
            aiClient = try await AIClient.OpenAIClient(apiKey: apiKey, model: selectedModel)
        }

        // Create and run fix manager
        let fixManager = FixManager(
            aiClient: aiClient,
            fileIO: FileIO()
        )

        let result = try await fixManager.fix(
            filePath: path,
            style: selectedStyle,
            checkMode: check
        )

        // Handle output based on flags
        if check {
            // In check mode, exit with status 1 if changes would be made
            if result.hasChanges {
                fputs("Markdown file would be modified by prettymd\n", stderr)
                throw ExitCode(1)
            } else {
                print("Markdown file is already well-formatted")
            }
        } else if inPlace {
            // Write back to file
            if result.hasChanges {
                try result.content.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
                print("File updated: \(path)")
            } else {
                print("No changes needed for: \(path)")
            }
        } else {
            // Output to stdout
            if diff && result.hasChanges {
                // Show diff if requested
                let diffRunner = DiffRunner()
                let diffOutput = try await diffRunner.generateDiff(
                    original: result.originalContent,
                    modified: result.content,
                    fileName: fileURL.lastPathComponent
                )
                print(diffOutput)
            } else {
                print(result.content)
            }
        }
    }
}

extension Fix {
    struct ValidationError: LocalizedError {
        let message: String

        init(_ message: String) {
            self.message = message
        }

        var errorDescription: String? {
            return message
        }
    }
}