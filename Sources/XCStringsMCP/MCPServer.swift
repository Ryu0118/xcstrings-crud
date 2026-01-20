import Foundation
import MCP
import XCStringsKit

public struct XCStringsMCPServer {
    public init() {}

    public func run() async throws {
        let server = Server(
            name: "xcstrings-mcp",
            version: "0.2.0",
            capabilities: .init(
                tools: .init(listChanged: false)
            )
        )

        // Register tool list handler
        await server.withMethodHandler(ListTools.self) { _ in
            .init(tools: Self.allTools)
        }

        // Register tool call handler
        await server.withMethodHandler(CallTool.self) { params in
            await Self.handleToolCall(params)
        }

        let transport = StdioTransport()
        try await server.start(transport: transport)
        await server.waitUntilCompleted()
    }

    // MARK: - Tool Definitions

    private static var allTools: [Tool] {
        [
            // Read operations
            Tool(
                name: "xcstrings_list_keys",
                description: "List all keys in the xcstrings file",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                    ]),
                    "required": .array([.string("file")]),
                ])
            ),
            Tool(
                name: "xcstrings_list_languages",
                description: "List all languages in the xcstrings file",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                    ]),
                    "required": .array([.string("file")]),
                ])
            ),
            Tool(
                name: "xcstrings_list_untranslated",
                description: "List untranslated keys for a specific language",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "language": .object(["type": .string("string"), "description": .string("Language code to check")]),
                    ]),
                    "required": .array([.string("file"), .string("language")]),
                ])
            ),
            Tool(
                name: "xcstrings_get_source_language",
                description: "Get the source language of the xcstrings file",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                    ]),
                    "required": .array([.string("file")]),
                ])
            ),
            Tool(
                name: "xcstrings_get_key",
                description: "Get translations for a specific key",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to get translations for")]),
                        "language": .object(["type": .string("string"), "description": .string("Optional specific language to get")]),
                    ]),
                    "required": .array([.string("file"), .string("key")]),
                ])
            ),
            Tool(
                name: "xcstrings_check_key",
                description: "Check if a key exists in the xcstrings file",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to check")]),
                        "language": .object(["type": .string("string"), "description": .string("Optional specific language to check")]),
                    ]),
                    "required": .array([.string("file"), .string("key")]),
                ])
            ),
            Tool(
                name: "xcstrings_check_coverage",
                description: "Get translation coverage for a specific key",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to check coverage for")]),
                    ]),
                    "required": .array([.string("file"), .string("key")]),
                ])
            ),
            Tool(
                name: "xcstrings_stats_coverage",
                description: "Get overall translation statistics. Use compact mode to only show languages under 100%.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "compact": .object(["type": .string("boolean"), "description": .string("If true, only show languages under 100% coverage (default: true)")]),
                    ]),
                    "required": .array([.string("file")]),
                ])
            ),
            Tool(
                name: "xcstrings_stats_progress",
                description: "Get translation progress for a specific language",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "language": .object(["type": .string("string"), "description": .string("Language code to check progress for")]),
                    ]),
                    "required": .array([.string("file"), .string("language")]),
                ])
            ),
            Tool(
                name: "xcstrings_batch_stats_coverage",
                description: "Get token-efficient coverage statistics for multiple xcstrings files at once. Returns compact summary with coverage percentages per language for each file and aggregated totals. Use compact mode to only show languages under 100%.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "files": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of paths to xcstrings files")]),
                        "compact": .object(["type": .string("boolean"), "description": .string("If true, only show languages under 100% coverage (default: true)")]),
                    ]),
                    "required": .array([.string("files")]),
                ])
            ),
            // Create operations
            Tool(
                name: "xcstrings_create_file",
                description: "Create a new xcstrings file with the specified source language",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path for the new xcstrings file")]),
                        "sourceLanguage": .object(["type": .string("string"), "description": .string("Source language code (default: en)")]),
                        "overwrite": .object(["type": .string("boolean"), "description": .string("Overwrite existing file if it exists (default: false)")]),
                    ]),
                    "required": .array([.string("file")]),
                ])
            ),
            // Write operations
            Tool(
                name: "xcstrings_add_translation",
                description: "Add a translation for a key",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to add translation for")]),
                        "language": .object(["type": .string("string"), "description": .string("Language code for the translation")]),
                        "value": .object(["type": .string("string"), "description": .string("Translation value")]),
                    ]),
                    "required": .array([.string("file"), .string("key"), .string("language"), .string("value")]),
                ])
            ),
            Tool(
                name: "xcstrings_add_translations",
                description: "Add translations for multiple languages at once",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to add translations for")]),
                        "translations": .object(["type": .string("object"), "description": .string("Object mapping language codes to translation values, e.g. {\"ja\": \"こんにちは\", \"en\": \"Hello\"}")]),
                    ]),
                    "required": .array([.string("file"), .string("key"), .string("translations")]),
                ])
            ),
            Tool(
                name: "xcstrings_update_translation",
                description: "Update a translation for a key",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to update translation for")]),
                        "language": .object(["type": .string("string"), "description": .string("Language code for the translation")]),
                        "value": .object(["type": .string("string"), "description": .string("New translation value")]),
                    ]),
                    "required": .array([.string("file"), .string("key"), .string("language"), .string("value")]),
                ])
            ),
            Tool(
                name: "xcstrings_update_translations",
                description: "Update translations for multiple languages at once",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to update translations for")]),
                        "translations": .object(["type": .string("object"), "description": .string("Object mapping language codes to translation values, e.g. {\"ja\": \"こんにちは\", \"en\": \"Hello\"}")]),
                    ]),
                    "required": .array([.string("file"), .string("key"), .string("translations")]),
                ])
            ),
            Tool(
                name: "xcstrings_rename_key",
                description: "Rename a key",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "oldKey": .object(["type": .string("string"), "description": .string("Current key name")]),
                        "newKey": .object(["type": .string("string"), "description": .string("New key name")]),
                    ]),
                    "required": .array([.string("file"), .string("oldKey"), .string("newKey")]),
                ])
            ),
            // Delete operations
            Tool(
                name: "xcstrings_delete_key",
                description: "Delete a key entirely",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to delete")]),
                    ]),
                    "required": .array([.string("file"), .string("key")]),
                ])
            ),
            Tool(
                name: "xcstrings_delete_translation",
                description: "Delete a specific translation for a key",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to delete translation from")]),
                        "language": .object(["type": .string("string"), "description": .string("Language code to delete")]),
                    ]),
                    "required": .array([.string("file"), .string("key"), .string("language")]),
                ])
            ),
            Tool(
                name: "xcstrings_delete_translations",
                description: "Delete translations for multiple languages at once",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "key": .object(["type": .string("string"), "description": .string("The key to delete translations from")]),
                        "languages": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of language codes to delete, e.g. [\"ja\", \"en\", \"fr\"]")]),
                    ]),
                    "required": .array([.string("file"), .string("key"), .string("languages")]),
                ])
            ),
        ]
    }

    // MARK: - Tool Call Handler

    private static func handleToolCall(_ params: CallTool.Parameters) async -> CallTool.Result {
        do {
            let result = try await executeToolCall(params)
            return .init(content: [.text(result)], isError: false)
        } catch {
            return .init(content: [.text("Error: \(error.localizedDescription)")], isError: true)
        }
    }

    private static func executeToolCall(_ params: CallTool.Parameters) async throws -> String {
        let args = params.arguments ?? [:]
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // Handle batch operations that don't use single 'file' parameter
        if params.name == "xcstrings_batch_stats_coverage" {
            guard let filesValue = args["files"]?.arrayValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'files' parameter")
            }
            let files = filesValue.compactMap { $0.stringValue }
            let compact = args["compact"]?.boolValue ?? true
            if compact {
                let batchCoverage = try XCStringsParser.getCompactBatchCoverage(paths: files)
                return try String(data: encoder.encode(batchCoverage), encoding: .utf8) ?? "{}"
            } else {
                let batchCoverage = try XCStringsParser.getBatchCoverage(paths: files)
                return try String(data: encoder.encode(batchCoverage), encoding: .utf8) ?? "{}"
            }
        }

        guard let file = args["file"]?.stringValue else {
            throw XCStringsError.invalidJSON(reason: "Missing 'file' parameter")
        }

        // Handle create operation (doesn't need existing file)
        if params.name == "xcstrings_create_file" {
            let sourceLanguage = args["sourceLanguage"]?.stringValue ?? "en"
            let overwrite = args["overwrite"]?.boolValue ?? false
            try XCStringsParser.createFile(at: file, sourceLanguage: sourceLanguage, overwrite: overwrite)
            return "Created xcstrings file at '\(file)' with source language '\(sourceLanguage)'"
        }

        let parser = XCStringsParser(path: file)

        switch params.name {
        case "xcstrings_list_keys":
            let keys = try await parser.listKeys()
            return try String(data: encoder.encode(keys), encoding: .utf8) ?? "[]"

        case "xcstrings_list_languages":
            let languages = try await parser.listLanguages()
            return try String(data: encoder.encode(languages), encoding: .utf8) ?? "[]"

        case "xcstrings_list_untranslated":
            guard let language = args["language"]?.stringValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'language' parameter")
            }
            let untranslated = try await parser.listUntranslated(for: language)
            return try String(data: encoder.encode(untranslated), encoding: .utf8) ?? "[]"

        case "xcstrings_get_source_language":
            return try await parser.getSourceLanguage()

        case "xcstrings_get_key":
            guard let key = args["key"]?.stringValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'key' parameter")
            }
            let language = args["language"]?.stringValue
            let translations = try await parser.getTranslation(key: key, language: language)
            return try String(data: encoder.encode(translations), encoding: .utf8) ?? "{}"

        case "xcstrings_check_key":
            guard let key = args["key"]?.stringValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'key' parameter")
            }
            let language = args["language"]?.stringValue
            let exists = try await parser.checkKey(key, language: language)
            return String(exists)

        case "xcstrings_check_coverage":
            guard let key = args["key"]?.stringValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'key' parameter")
            }
            let coverage = try await parser.checkCoverage(key)
            return try String(data: encoder.encode(coverage), encoding: .utf8) ?? "{}"

        case "xcstrings_stats_coverage":
            let compact = args["compact"]?.boolValue ?? true
            if compact {
                let stats = try await parser.getCompactStats()
                return try String(data: encoder.encode(stats), encoding: .utf8) ?? "{}"
            } else {
                let stats = try await parser.getStats()
                return try String(data: encoder.encode(stats), encoding: .utf8) ?? "{}"
            }

        case "xcstrings_stats_progress":
            guard let language = args["language"]?.stringValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'language' parameter")
            }
            let progress = try await parser.getProgress(for: language)
            return try String(data: encoder.encode(progress), encoding: .utf8) ?? "{}"

        case "xcstrings_add_translation":
            guard let key = args["key"]?.stringValue,
                  let language = args["language"]?.stringValue,
                  let value = args["value"]?.stringValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            try await parser.addTranslation(key: key, language: language, value: value)
            return "Translation added successfully"

        case "xcstrings_add_translations":
            guard let key = args["key"]?.stringValue,
                  let translationsValue = args["translations"]?.objectValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            var translations: [String: String] = [:]
            for (lang, value) in translationsValue {
                if let stringValue = value.stringValue {
                    translations[lang] = stringValue
                }
            }
            try await parser.addTranslations(key: key, translations: translations)
            return "Translations added successfully for \(translations.count) languages"

        case "xcstrings_update_translation":
            guard let key = args["key"]?.stringValue,
                  let language = args["language"]?.stringValue,
                  let value = args["value"]?.stringValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            try await parser.updateTranslation(key: key, language: language, value: value)
            return "Translation updated successfully"

        case "xcstrings_update_translations":
            guard let key = args["key"]?.stringValue,
                  let translationsValue = args["translations"]?.objectValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            var translations: [String: String] = [:]
            for (lang, value) in translationsValue {
                if let stringValue = value.stringValue {
                    translations[lang] = stringValue
                }
            }
            try await parser.updateTranslations(key: key, translations: translations)
            return "Translations updated successfully for \(translations.count) languages"

        case "xcstrings_rename_key":
            guard let oldKey = args["oldKey"]?.stringValue,
                  let newKey = args["newKey"]?.stringValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            try await parser.renameKey(from: oldKey, to: newKey)
            return "Key renamed from '\(oldKey)' to '\(newKey)' successfully"

        case "xcstrings_delete_key":
            guard let key = args["key"]?.stringValue else {
                throw XCStringsError.invalidJSON(reason: "Missing 'key' parameter")
            }
            try await parser.deleteKey(key)
            return "Key deleted successfully"

        case "xcstrings_delete_translation":
            guard let key = args["key"]?.stringValue,
                  let language = args["language"]?.stringValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            try await parser.deleteTranslation(key: key, language: language)
            return "Translation for '\(language)' deleted successfully"

        case "xcstrings_delete_translations":
            guard let key = args["key"]?.stringValue,
                  let languagesValue = args["languages"]?.arrayValue
            else {
                throw XCStringsError.invalidJSON(reason: "Missing required parameters")
            }
            let languages = languagesValue.compactMap { $0.stringValue }
            try await parser.deleteTranslations(key: key, languages: languages)
            return "Translations deleted successfully for \(languages.count) languages"

        default:
            throw XCStringsError.invalidJSON(reason: "Unknown tool: \(params.name)")
        }
    }
}
