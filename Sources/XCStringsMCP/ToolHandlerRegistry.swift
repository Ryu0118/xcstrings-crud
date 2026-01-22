import Foundation
import MCP
import XCStringsKit

/// Actor-based registry for tool handlers.
/// Maps tool names to their handlers, following Open/Closed principle -
/// new tools can be added by registering new handlers without modifying existing code.
/// Using actor ensures thread-safe access to the registry.
actor ToolHandlerRegistry {
    /// Shared instance
    static let shared = ToolHandlerRegistry()

    /// Dictionary mapping tool names to their handlers
    private let handlers: [String: any ToolHandler] = [
        // List handlers
        ListKeysHandler.toolName: ListKeysHandler(),
        ListLanguagesHandler.toolName: ListLanguagesHandler(),
        ListUntranslatedHandler.toolName: ListUntranslatedHandler(),
        ListStaleHandler.toolName: ListStaleHandler(),
        BatchListStaleHandler.toolName: BatchListStaleHandler(),

        // Get handlers
        GetSourceLanguageHandler.toolName: GetSourceLanguageHandler(),
        GetKeyHandler.toolName: GetKeyHandler(),
        CheckKeyHandler.toolName: CheckKeyHandler(),
        CheckCoverageHandler.toolName: CheckCoverageHandler(),

        // Stats handlers
        StatsCoverageHandler.toolName: StatsCoverageHandler(),
        StatsProgressHandler.toolName: StatsProgressHandler(),
        BatchStatsCoverageHandler.toolName: BatchStatsCoverageHandler(),

        // Create handlers
        CreateFileHandler.toolName: CreateFileHandler(),

        // Write handlers
        AddTranslationHandler.toolName: AddTranslationHandler(),
        AddTranslationsHandler.toolName: AddTranslationsHandler(),
        UpdateTranslationHandler.toolName: UpdateTranslationHandler(),
        UpdateTranslationsHandler.toolName: UpdateTranslationsHandler(),
        RenameKeyHandler.toolName: RenameKeyHandler(),

        // Delete handlers
        DeleteKeyHandler.toolName: DeleteKeyHandler(),
        DeleteTranslationHandler.toolName: DeleteTranslationHandler(),
        DeleteTranslationsHandler.toolName: DeleteTranslationsHandler(),

        // Batch handlers
        BatchCheckKeysHandler.toolName: BatchCheckKeysHandler(),
        BatchAddTranslationsHandler.toolName: BatchAddTranslationsHandler(),
        BatchUpdateTranslationsHandler.toolName: BatchUpdateTranslationsHandler(),
    ]

    /// Get handler for a tool name
    func handler(for toolName: String) -> (any ToolHandler)? {
        handlers[toolName]
    }

    /// Execute a tool call
    func execute(toolName: String, arguments: [String: Value]) async throws -> String {
        guard let handler = handler(for: toolName) else {
            throw XCStringsError.invalidJSON(reason: "Unknown tool: \(toolName)")
        }

        let context = ToolContext(arguments: arguments)
        return try await handler.execute(with: context)
    }

    /// Get all registered tool names
    var registeredToolNames: [String] {
        Array(handlers.keys)
    }
}
