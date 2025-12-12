import Foundation

public struct FileIO {
    public init() {}

    /// Read contents of a file at the given path
    public func readFile(at path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// Write contents to a file at the given path
    public func writeFile(content: String, to path: String) throws {
        let url = URL(fileURLWithPath: path)
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Check if a file exists at the given path
    public func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// Get file attributes
    public func fileAttributes(at path: String) throws -> [FileAttributeKey: Any] {
        return try FileManager.default.attributesOfItem(atPath: path)
    }

    /// Create a backup of a file
    public func createBackup(of path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        let backupPath = path + ".backup"
        let backupURL = URL(fileURLWithPath: backupPath)

        try FileManager.default.copyItem(at: url, to: backupURL)
        return backupPath
    }

    /// Remove a file
    public func removeFile(at path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }

    /// Get temporary directory path
    public func temporaryDirectory() -> String {
        return NSTemporaryDirectory()
    }

    /// Create a temporary file with the given content
    public func createTemporaryFile(content: String, extension ext: String = "md") throws -> String {
        let tempDir = temporaryDirectory()
        let fileName = UUID().uuidString + "." + ext
        let filePath = (tempDir as NSString).appendingPathComponent(fileName)

        try writeFile(content: content, to: filePath)
        return filePath
    }
}