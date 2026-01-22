import Foundation
import MCP
import XCStringsKit

// MARK: - Batch Check Keys Handler

struct BatchCheckKeysHandler: ToolHandler {
    static let toolName = "xcstrings_batch_check_keys"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let keys = try context.arguments.requireStringArray("keys")
        let language = context.arguments.optionalString("language")

        let parser = XCStringsParser(path: file)
        let result = try await parser.checkKeys(keys, language: language)
        return try JSONEncoderHelper.encode(result)
    }
}

// MARK: - Batch Add Translations Handler

struct BatchAddTranslationsHandler: ToolHandler {
    static let toolName = "xcstrings_batch_add_translations"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let entries = try context.arguments.requireBatchEntries("entries")
        let overwrite = context.arguments.bool("overwrite", default: false)

        let parser = XCStringsParser(path: file)
        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: overwrite)
        return try JSONEncoderHelper.encode(result)
    }
}

// MARK: - Batch Update Translations Handler

struct BatchUpdateTranslationsHandler: ToolHandler {
    static let toolName = "xcstrings_batch_update_translations"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let entries = try context.arguments.requireBatchEntries("entries")

        let parser = XCStringsParser(path: file)
        let result = try await parser.updateTranslationsBatch(entries: entries)
        return try JSONEncoderHelper.encode(result)
    }
}
