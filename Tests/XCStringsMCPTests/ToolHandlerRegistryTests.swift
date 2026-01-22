import Foundation
import MCP
import Testing

@testable import XCStringsMCP

@Suite("ToolHandlerRegistry tests")
struct ToolHandlerRegistryTests {

    @Test("All expected handlers are registered")
    func allHandlersRegistered() async {
        let registry = ToolHandlerRegistry.shared
        let registeredTools = await registry.registeredToolNames

        // List handlers
        #expect(registeredTools.contains("xcstrings_list_keys"))
        #expect(registeredTools.contains("xcstrings_list_languages"))
        #expect(registeredTools.contains("xcstrings_list_untranslated"))
        #expect(registeredTools.contains("xcstrings_list_stale"))

        // Get handlers
        #expect(registeredTools.contains("xcstrings_get_source_language"))
        #expect(registeredTools.contains("xcstrings_get_key"))
        #expect(registeredTools.contains("xcstrings_check_key"))
        #expect(registeredTools.contains("xcstrings_check_coverage"))

        // Stats handlers
        #expect(registeredTools.contains("xcstrings_stats_coverage"))
        #expect(registeredTools.contains("xcstrings_stats_progress"))
        #expect(registeredTools.contains("xcstrings_batch_stats_coverage"))

        // Create handlers
        #expect(registeredTools.contains("xcstrings_create_file"))

        // Write handlers
        #expect(registeredTools.contains("xcstrings_add_translation"))
        #expect(registeredTools.contains("xcstrings_add_translations"))
        #expect(registeredTools.contains("xcstrings_update_translation"))
        #expect(registeredTools.contains("xcstrings_update_translations"))
        #expect(registeredTools.contains("xcstrings_rename_key"))

        // Delete handlers
        #expect(registeredTools.contains("xcstrings_delete_key"))
        #expect(registeredTools.contains("xcstrings_delete_translation"))
        #expect(registeredTools.contains("xcstrings_delete_translations"))

        // Batch handlers
        #expect(registeredTools.contains("xcstrings_batch_check_keys"))
        #expect(registeredTools.contains("xcstrings_batch_add_translations"))
        #expect(registeredTools.contains("xcstrings_batch_update_translations"))
    }

    @Test("Execute throws for unknown tool")
    func executeUnknownToolThrows() async {
        let registry = ToolHandlerRegistry.shared

        await #expect(throws: Error.self) {
            _ = try await registry.execute(toolName: "unknown_tool", arguments: [:])
        }
    }

    @Test("handler(for:) returns handler for registered tool")
    func handlerForRegisteredTool() async {
        let registry = ToolHandlerRegistry.shared
        let handler = await registry.handler(for: "xcstrings_list_keys")
        #expect(handler != nil)
    }

    @Test("handler(for:) returns nil for unregistered tool")
    func handlerForUnregisteredTool() async {
        let registry = ToolHandlerRegistry.shared
        let handler = await registry.handler(for: "nonexistent_tool")
        #expect(handler == nil)
    }
}
