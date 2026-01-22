import Foundation
import MCP
import XCStringsKit

// MARK: - Delete Key Handler

struct DeleteKeyHandler: ToolHandler {
    static let toolName = "xcstrings_delete_key"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")

        let parser = XCStringsParser(path: file)
        try await parser.deleteKey(key)
        return "Key deleted successfully"
    }
}

// MARK: - Delete Translation Handler

struct DeleteTranslationHandler: ToolHandler {
    static let toolName = "xcstrings_delete_translation"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let language = try context.arguments.requireString("language")

        let parser = XCStringsParser(path: file)
        try await parser.deleteTranslation(key: key, language: language)
        return "Translation for '\(language)' deleted successfully"
    }
}

// MARK: - Delete Translations Handler

struct DeleteTranslationsHandler: ToolHandler {
    static let toolName = "xcstrings_delete_translations"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let languages = try context.arguments.requireStringArray("languages")

        let parser = XCStringsParser(path: file)
        try await parser.deleteTranslations(key: key, languages: languages)
        return "Translations deleted successfully for \(languages.count) languages"
    }
}
