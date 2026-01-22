import Foundation
import MCP
import XCStringsKit

// MARK: - Get Source Language Handler

struct GetSourceLanguageHandler: ToolHandler {
    static let toolName = "xcstrings_get_source_language"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let parser = XCStringsParser(path: file)
        return try await parser.getSourceLanguage()
    }
}

// MARK: - Get Key Handler

struct GetKeyHandler: ToolHandler {
    static let toolName = "xcstrings_get_key"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let language = context.arguments.optionalString("language")

        let parser = XCStringsParser(path: file)
        let translations = try await parser.getTranslation(key: key, language: language)
        return try JSONEncoderHelper.encode(translations)
    }
}

// MARK: - Check Key Handler

struct CheckKeyHandler: ToolHandler {
    static let toolName = "xcstrings_check_key"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let language = context.arguments.optionalString("language")

        let parser = XCStringsParser(path: file)
        let exists = try await parser.checkKey(key, language: language)
        return String(exists)
    }
}

// MARK: - Check Coverage Handler

struct CheckCoverageHandler: ToolHandler {
    static let toolName = "xcstrings_check_coverage"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")

        let parser = XCStringsParser(path: file)
        let coverage = try await parser.checkCoverage(key)
        return try JSONEncoderHelper.encode(coverage)
    }
}
