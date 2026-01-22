import Foundation
import MCP
import XCStringsKit

// MARK: - Add Translation Handler

struct AddTranslationHandler: ToolHandler {
    static let toolName = "xcstrings_add_translation"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let language = try context.arguments.requireString("language")
        let value = try context.arguments.requireString("value")

        let parser = XCStringsParser(path: file)
        try await parser.addTranslation(key: key, language: language, value: value)
        return "Translation added successfully"
    }
}

// MARK: - Add Translations Handler

struct AddTranslationsHandler: ToolHandler {
    static let toolName = "xcstrings_add_translations"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let translations = try context.arguments.requireTranslations("translations")

        let parser = XCStringsParser(path: file)
        try await parser.addTranslations(key: key, translations: translations)
        return "Translations added successfully for \(translations.count) languages"
    }
}

// MARK: - Update Translation Handler

struct UpdateTranslationHandler: ToolHandler {
    static let toolName = "xcstrings_update_translation"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let language = try context.arguments.requireString("language")
        let value = try context.arguments.requireString("value")

        let parser = XCStringsParser(path: file)
        try await parser.updateTranslation(key: key, language: language, value: value)
        return "Translation updated successfully"
    }
}

// MARK: - Update Translations Handler

struct UpdateTranslationsHandler: ToolHandler {
    static let toolName = "xcstrings_update_translations"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let key = try context.arguments.requireString("key")
        let translations = try context.arguments.requireTranslations("translations")

        let parser = XCStringsParser(path: file)
        try await parser.updateTranslations(key: key, translations: translations)
        return "Translations updated successfully for \(translations.count) languages"
    }
}

// MARK: - Rename Key Handler

struct RenameKeyHandler: ToolHandler {
    static let toolName = "xcstrings_rename_key"

    func execute(with context: ToolContext) async throws -> String {
        let file = try context.arguments.requireString("file")
        let oldKey = try context.arguments.requireString("oldKey")
        let newKey = try context.arguments.requireString("newKey")

        let parser = XCStringsParser(path: file)
        try await parser.renameKey(from: oldKey, to: newKey)
        return "Key renamed from '\(oldKey)' to '\(newKey)' successfully"
    }
}
