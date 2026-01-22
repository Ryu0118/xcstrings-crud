import Foundation
import MCP
import XCStringsKit

// MARK: - List Keys Handler

struct ListKeysHandler: ToolHandler {
    static let toolName = "xcstrings_list_keys"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let parser = XCStringsParser(path: file)
        let keys = try await parser.listKeys()
        return try JSONEncoderHelper.encode(keys)
    }
}

// MARK: - List Languages Handler

struct ListLanguagesHandler: ToolHandler {
    static let toolName = "xcstrings_list_languages"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let parser = XCStringsParser(path: file)
        let languages = try await parser.listLanguages()
        return try JSONEncoderHelper.encode(languages)
    }
}

// MARK: - List Untranslated Handler

struct ListUntranslatedHandler: ToolHandler {
    static let toolName = "xcstrings_list_untranslated"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let language = try context.arguments.requireString("language")
        let parser = XCStringsParser(path: file)
        let untranslated = try await parser.listUntranslated(for: language)
        return try JSONEncoderHelper.encode(untranslated)
    }
}

// MARK: - List Stale Handler

struct ListStaleHandler: ToolHandler {
    static let toolName = "xcstrings_list_stale"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let parser = XCStringsParser(path: file)
        let staleKeys = try await parser.listStaleKeys()
        let result = StaleKeysResult(staleKeys: staleKeys)
        return try JSONEncoderHelper.encode(result)
    }
}

// MARK: - Batch List Stale Handler

struct BatchListStaleHandler: ToolHandler {
    static let toolName = "xcstrings_batch_list_stale"

    func execute(with context: ToolContext) async throws -> String {
        let files = try context.arguments.requireStringArray("files")
        let result = try XCStringsParser.getBatchStaleKeys(paths: files)
        return try JSONEncoderHelper.encode(result)
    }
}
