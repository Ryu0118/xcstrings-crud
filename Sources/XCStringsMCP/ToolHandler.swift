import Foundation
import MCP
import XCStringsKit

// MARK: - Tool Handler Protocol

/// Protocol for handling individual MCP tool calls.
/// Each tool handler is responsible for a single tool, following Single Responsibility Principle.
protocol ToolHandler: Sendable {
    /// The name of the tool this handler handles
    static var toolName: String { get }

    /// Execute the tool with the given context
    /// - Parameter context: The execution context containing parsed arguments
    /// - Returns: The result string to return to the client
    func execute(with context: ToolContext) async throws -> String
}

// MARK: - Tool Context

/// Context for tool execution, containing parsed arguments and utilities.
/// This abstraction allows for easier testing by decoupling from MCP types.
struct ToolContext: Sendable {
    let arguments: ToolArguments

    init(arguments: [String: Value]) {
        self.arguments = ToolArguments(raw: arguments)
    }

    init(arguments: ToolArguments) {
        self.arguments = arguments
    }
}

// MARK: - Tool Arguments

/// Type-safe wrapper for tool arguments with convenient accessors.
struct ToolArguments: Sendable {
    private let raw: [String: Value]

    init(raw: [String: Value]) {
        self.raw = raw
    }

    /// Get a required string argument
    func requireString(_ key: String) throws -> String {
        guard let value = raw[key]?.stringValue else {
            throw XCStringsError.invalidJSON(reason: "Missing '\(key)' parameter")
        }
        return value
    }

    /// Get an optional string argument
    func optionalString(_ key: String) -> String? {
        raw[key]?.stringValue
    }

    /// Get a required boolean argument with default value
    func bool(_ key: String, default defaultValue: Bool) -> Bool {
        raw[key]?.boolValue ?? defaultValue
    }

    /// Get a required array of strings
    func requireStringArray(_ key: String) throws -> [String] {
        guard let arrayValue = raw[key]?.arrayValue else {
            throw XCStringsError.invalidJSON(reason: "Missing '\(key)' parameter")
        }
        return arrayValue.compactMap { $0.stringValue }
    }

    /// Get an optional array of strings
    func optionalStringArray(_ key: String) -> [String]? {
        raw[key]?.arrayValue?.compactMap { $0.stringValue }
    }

    /// Get a required translations dictionary (language -> value)
    func requireTranslations(_ key: String) throws -> [String: String] {
        guard let objectValue = raw[key]?.objectValue else {
            throw XCStringsError.invalidJSON(reason: "Missing '\(key)' parameter")
        }
        return parseTranslations(from: objectValue)
    }

    /// Get a required array of batch translation entries
    func requireBatchEntries(_ key: String) throws -> [BatchTranslationEntry] {
        guard let entriesValue = raw[key]?.arrayValue else {
            throw XCStringsError.invalidJSON(reason: "Missing '\(key)' parameter")
        }

        return try entriesValue.map { entryValue in
            guard let entryObj = entryValue.objectValue,
                  let entryKey = entryObj["key"]?.stringValue,
                  let translationsValue = entryObj["translations"]?.objectValue
            else {
                throw XCStringsError.invalidJSON(reason: "Invalid entry format")
            }
            let translations = parseTranslations(from: translationsValue)
            return BatchTranslationEntry(key: entryKey, translations: translations)
        }
    }

    /// Parse translations from a Value object
    private func parseTranslations(from objectValue: [String: Value]) -> [String: String] {
        var translations: [String: String] = [:]
        for (lang, value) in objectValue {
            if let stringValue = value.stringValue {
                translations[lang] = stringValue
            }
        }
        return translations
    }
}

// MARK: - JSON Encoding Helper

/// Shared JSON encoder configuration for consistent output
enum JSONEncoderHelper {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    static func encode<T: Encodable>(_ value: T) throws -> String {
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
