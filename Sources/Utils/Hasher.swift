import Foundation
import CryptoKit

public struct Hasher {
    public init() {}

    /// Generate SHA256 hash of a string
    public func hash(_ content: String) -> String {
        guard let data = content.data(using: .utf8) else {
            return ""
        }
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Check if two strings are different based on their hash
    public func hasChanged(original: String, modified: String) -> Bool {
        return hash(original) != hash(modified)
    }

    /// Generate a hash-based fingerprint for content
    public func fingerprint(_ content: String) -> String {
        let hashed = hash(content)
        // Return first 8 characters of hash for a short fingerprint
        return String(hashed.prefix(8))
    }

    /// Compare two files by their content hash
    public func filesAreIdentical(path1: String, path2: String) throws -> Bool {
        let content1 = try String(contentsOfFile: path1, encoding: .utf8)
        let content2 = try String(contentsOfFile: path2, encoding: .utf8)
        return hash(content1) == hash(content2)
    }
}