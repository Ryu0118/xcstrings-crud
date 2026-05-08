import Foundation

/// Errors thrown by XCStringsKit
package enum XCStringsError: Error, LocalizedError {
    case fileNotFound(path: String)
    case fileAlreadyExists(path: String)
    case invalidFileFormat(path: String, reason: String)
    case keyNotFound(key: String, suggestions: [String] = [])
    case keyAlreadyExists(key: String)
    case languageNotFound(language: String, key: String)
    case writeError(path: String, reason: String)
    case invalidJSON(reason: String)

    package var errorDescription: String? {
        switch self {
        case let .fileNotFound(path):
            "File not found: \(path)"
        case let .fileAlreadyExists(path):
            "File already exists: \(path)"
        case let .invalidFileFormat(path, reason):
            "Invalid file format at '\(path)': \(reason)"
        case let .keyNotFound(key, suggestions):
            if suggestions.isEmpty {
                "Key not found: '\(key)'"
            } else {
                "Key not found: '\(key)'. Did you mean: \(suggestions.map { "'\($0)'" }.joined(separator: ", "))?"
            }
        case let .keyAlreadyExists(key):
            "Key already exists: '\(key)'"
        case let .languageNotFound(language, key):
            "Language '\(language)' not found for key '\(key)'"
        case let .writeError(path, reason):
            "Failed to write file at '\(path)': \(reason)"
        case let .invalidJSON(reason):
            "Invalid JSON: \(reason)"
        }
    }
}

/// Result type for CLI output
package struct CLIResult: Codable {
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
