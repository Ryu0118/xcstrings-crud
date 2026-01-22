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
                name: "xcstrings_list_stale",
                description: "List keys with stale extraction state (potentially unused keys). Note: This only detects keys marked as 'stale' by Xcode. To verify if these keys are truly unused, you should search for their usage in the module or project's source code.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                    ]),
                    "required": .array([.string("file")]),
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
            Tool(
                name: "xcstrings_batch_check_keys",
                description: "Check if multiple keys exist in the xcstrings file. Returns results for each key.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "keys": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of keys to check")]),
                        "language": .object(["type": .string("string"), "description": .string("Optional specific language to check")]),
                    ]),
                    "required": .array([.string("file"), .string("keys")]),
                ])
            ),
            Tool(
                name: "xcstrings_batch_add_translations",
                description: "Add translations for multiple keys at once. Each entry contains a key and its translations for multiple languages.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "entries": .object([
                            "type": .string("array"),
                            "items": .object([
                                "type": .string("object"),
                                "properties": .object([
                                    "key": .object(["type": .string("string"), "description": .string("The key to add translations for")]),
                                    "translations": .object(["type": .string("object"), "description": .string("Object mapping language codes to translation values")]),
                                ]),
                                "required": .array([.string("key"), .string("translations")]),
                            ]),
                            "description": .string("Array of entries, each with a key and translations object"),
                        ]),
                        "overwrite": .object(["type": .string("boolean"), "description": .string("Allow overwriting existing translations (default: false)")]),
                    ]),
                    "required": .array([.string("file"), .string("entries")]),
                ])
            ),
            Tool(
                name: "xcstrings_batch_update_translations",
                description: "Update translations for multiple keys at once. Each entry contains a key and its translations for multiple languages.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "file": .object(["type": .string("string"), "description": .string("Path to the xcstrings file")]),
                        "entries": .object([
                            "type": .string("array"),
                            "items": .object([
                                "type": .string("object"),
                                "properties": .object([
                                    "key": .object(["type": .string("string"), "description": .string("The key to update translations for")]),
                                    "translations": .object(["type": .string("object"), "description": .string("Object mapping language codes to translation values")]),
                                ]),
                                "required": .array([.string("key"), .string("translations")]),
                            ]),
                            "description": .string("Array of entries, each with a key and translations object"),
                        ]),
                    ]),
                    "required": .array([.string("file"), .string("entries")]),
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
            let args = params.arguments ?? [:]
            let result = try await ToolHandlerRegistry.shared.execute(toolName: params.name, arguments: args)
            return .init(content: [.text(result)], isError: false)
        } catch {
            return .init(content: [.text("Error: \(error.localizedDescription)")], isError: true)
        }
    }
}
