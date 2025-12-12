# prettymd

> **AI-powered Markdown formatter for developer workflows** — Think of it as "Prettier for Markdown, powered by AI"

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**prettymd** improves your Markdown files by fixing grammar, enhancing clarity, ensuring consistent formatting, and adapting tone — all from the command line. It's designed for developers who want their documentation to be as polished as their code.

## ✨ Features

- **🤖 AI-Powered Formatting** - Uses GPT-4 to intelligently improve your Markdown
- **🎨 Multiple Styles** - Choose between concise, technical, or friendly tones
- **📝 In-Place Editing** - Update files directly or preview changes first
- **🔍 Diff View** - See exactly what changes will be made with color-coded diffs
- **✅ CI-Ready** - Check mode for integration with CI/CD pipelines
- **🧪 Mock Mode** - Test without API keys using the built-in mock client
- **⚡ Fast & Efficient** - Process individual files quickly from the command line

## 📋 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Use Cases](#-use-cases)
- [Configuration](#-configuration)
- [Examples](#-examples)
- [API Providers](#-api-providers)
- [Privacy & Security](#-privacy--security)
- [Contributing](#-contributing)
- [Roadmap](#-roadmap)
- [License](#-license)

## 🚀 Installation

### Option 1: Build from Source (Recommended)

```bash
# Clone the repository
git clone https://github.com/alexissan/prettymd
cd prettymd

# Build the release version
swift build -c release

# Install globally (optional)
sudo cp .build/release/prettymd /usr/local/bin/
```

### Option 2: Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alexissan/prettymd", from: "0.1.0")
]
```

### Requirements

- macOS 13.0+ (Ventura or later)
- Swift 5.9+
- OpenAI API key (for AI features)

## 🎯 Quick Start

### 1. Set up your API key

```bash
export OPENAI_API_KEY="sk-..."
```

Add to your shell profile (`~/.zshrc` or `~/.bash_profile`) to persist.

### 2. Format a Markdown file

```bash
# Preview changes (outputs to stdout)
prettymd fix README.md

# Apply changes in-place
prettymd fix README.md --in-place

# Use a specific style
prettymd fix README.md --style friendly
```

### 3. Test without an API key

```bash
# Use mock mode for testing
prettymd fix README.md --mock
```

## 📖 Usage

### Basic Command Structure

```bash
prettymd fix <path> [options]
```

### Available Options

| Flag | Description | Example |
|------|-------------|---------|
| `--in-place` | Write changes back to the file | `prettymd fix README.md --in-place` |
| `--style <style>` | Set tone: `concise`, `technical`, or `friendly` | `prettymd fix doc.md --style concise` |
| `--check` | Exit with error if changes needed (CI mode) | `prettymd fix *.md --check` |
| `--diff` | Show color-coded diff of changes | `prettymd fix README.md --diff` |
| `--mock` | Use mock client (no API required) | `prettymd fix test.md --mock` |
| `--help` | Show help information | `prettymd --help` |

### Output Modes

1. **Standard Output** (default): Prints formatted content to stdout
2. **In-Place**: Updates the file directly with `--in-place`
3. **Diff View**: Shows changes with `--diff`
4. **Check Mode**: Returns exit code 1 if changes needed with `--check`

## 💡 Use Cases

### 1. Documentation Review

Perfect for polishing documentation before commits:

```bash
# Review all markdown files in docs/
for file in docs/*.md; do
  prettymd fix "$file" --in-place
done
```

### 2. Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Check if any staged .md files need formatting
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.md$'); do
  if ! prettymd fix "$file" --check; then
    echo "❌ $file needs formatting. Run: prettymd fix $file --in-place"
    exit 1
  fi
done
```

### 3. CI/CD Integration

GitHub Actions example:

```yaml
name: Markdown Lint
on: [pull_request]

jobs:
  lint:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: swift-actions/setup-swift@v1
      - run: |
          git clone https://github.com/alexissan/prettymd
          cd prettymd && swift build -c release
          cd ..
      - run: |
          export OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }}
          find . -name "*.md" -exec prettymd/prettymd fix {} --check \;
```

### 4. README Standardization

Ensure consistent README format across all projects:

```bash
# Create a style guide
export PRETTYMD_STYLE="technical"

# Format all READMEs
find ~/projects -name "README.md" -exec prettymd fix {} --in-place \;
```

### 5. Blog Post Polishing

```bash
# Polish a blog post with friendly tone
prettymd fix blog/my-post.md --style friendly --in-place
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | Your OpenAI API key | Required |
| `PRETTYMD_STYLE` | Default style for formatting | `technical` |

### Style Options

- **`technical`** (default): Precise, professional documentation style
- **`concise`**: Minimal, direct communication
- **`friendly`**: Approachable, conversational tone

## 📚 Examples

### Before and After

**Original:**
```markdown
# my project

this project does stuff with things.. its really cool!!!

- it has feature
-  another feature
- and   more stuff
```

**After `prettymd fix --style technical`:**
```markdown
# My Project

This project provides comprehensive functionality for managing system resources. The implementation offers robust and reliable performance.

- Implements core feature set
- Provides extended functionality
- Includes additional capabilities
```

### Diff Output Example

```bash
$ prettymd fix README.md --diff
```

```diff
--- original/README.md
+++ modified/README.md
@@ -1,3 +1,3 @@
-# my project
+# My Project

-this project does stuff
+This project provides comprehensive functionality
```

## 🔐 Privacy & Security

⚠️ **Important Security Considerations:**

- **API Transmission**: Your Markdown content is sent to OpenAI's API for processing
- **Sensitive Data**: Avoid processing files containing:
  - API keys, passwords, or secrets
  - Personal information (PII)
  - Proprietary code or algorithms
  - Confidential business information

### Best Practices

1. Review files before processing
2. Use `.prettymdignore` (coming soon) to exclude sensitive files
3. Consider using mock mode for testing with sensitive content
4. Set up a dedicated API key with usage limits

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests: `swift test`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/prettymd
cd prettymd

# Open in Xcode
open Package.swift

# Or use your favorite editor
code .
```

### Running Tests

```bash
# Run all tests
swift test

# Run with verbose output
swift test --verbose

# Test with mock client
.build/debug/prettymd fix Tests/Fixtures/sample.md --mock
```

## 🗺️ Roadmap

### Version 0.2.0 (Coming Soon)
- [ ] Support for multiple files/glob patterns
- [ ] `.prettymdrc` configuration file
- [ ] Batch processing with progress bar
- [ ] Cache processed files to avoid redundant API calls

### Version 0.3.0 (Planned)
- [ ] Local LLM support (Ollama, llama.cpp)
- [ ] Claude API integration
- [ ] Custom style definitions
- [ ] Markdown template generation (`prettymd new`)

### Future Ideas
- [ ] VS Code extension
- [ ] Obsidian plugin
- [ ] Interactive mode with preview
- [ ] GitHub Action marketplace listing
- [ ] Web interface
- [ ] Team style guide sharing

## 🐛 Troubleshooting

### Common Issues

**"API key is missing" error:**
```bash
# Make sure your API key is set
export OPENAI_API_KEY="sk-your-actual-key-here"
```

**"File too large" error:**
- Current limit is 100KB per file
- Split large files or increase the limit in `Sources/Core/FixManager.swift`

**Rate limiting:**
- Add delays between requests
- Upgrade your OpenAI plan
- Use mock mode for testing

**Build errors:**
```bash
# Clean and rebuild
swift package clean
swift build -c release
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
- Powered by [OpenAI GPT-4](https://openai.com)
- Inspired by [Prettier](https://prettier.io)

## 📮 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/alexissan/prettymd/issues)
- **Discussions**: [GitHub Discussions](https://github.com/alexissan/prettymd/discussions)
- **Author**: [@alexissan](https://github.com/alexissan)

---

<p align="center">
  Made with ❤️ for better documentation
</p>

<p align="center">
  <a href="#prettymd">⬆ Back to Top</a>
</p>