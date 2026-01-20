import Foundation

/// Errors thrown by XCStringsKit
package enum XCStringsError: Error, LocalizedError, Sendable {
    case fileNotFound(path: String)
    case fileAlreadyExists(path: String)
    case invalidFileFormat(path: String, reason: String)
    case keyNotFound(key: String)
    case keyAlreadyExists(key: String)
    case languageNotFound(language: String, key: String)
    case writeError(path: String, reason: String)
    case invalidJSON(reason: String)

    package var errorDescription: String? {
        switch self {
        case let .fileNotFound(path):
            return "File not found: \(path)"
        case let .fileAlreadyExists(path):
            return "File already exists: \(path)"
        case let .invalidFileFormat(path, reason):
            return "Invalid file format at '\(path)': \(reason)"
        case let .keyNotFound(key):
            return "Key not found: '\(key)'"
        case let .keyAlreadyExists(key):
            return "Key already exists: '\(key)'"
        case let .languageNotFound(language, key):
            return "Language '\(language)' not found for key '\(key)'"
        case let .writeError(path, reason):
            return "Failed to write file at '\(path)': \(reason)"
        case let .invalidJSON(reason):
            return "Invalid JSON: \(reason)"
        }
    }
}

/// Result type for CLI output
package struct CLIResult: Codable, Sendable {
    package let success: Bool
    package let message: String?
    package let error: String?

    package init(success: Bool, message: String?, error: String?) {
        self.success = success
        self.message = message
        self.error = error
    }

    package static func success(message: String? = nil) -> CLIResult {
        CLIResult(success: true, message: message, error: nil)
    }

    package static func failure(error: String) -> CLIResult {
        CLIResult(success: false, message: nil, error: error)
    }
}
