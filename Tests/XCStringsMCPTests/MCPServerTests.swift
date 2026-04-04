import Foundation
import MCP
import Testing

@testable import XCStringsMCP

@Suite("XCStringsMCPServer tests")
struct MCPServerTests {

    // MARK: - Schema tests (allTools)

    @Test("file is required when no defaultPath")
    func fileRequiredByDefault() {
        let server = XCStringsMCPServer()
        let tool = server.allTools.first { $0.name == "xcstrings_list_keys" }!
        guard case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            Issue.record("Unexpected schema structure")
            return
        }
        #expect(required.contains(.string("file")))
    }

    @Test("files is required when no defaultPath")
    func filesRequiredByDefault() {
        let server = XCStringsMCPServer()
        let tool = server.allTools.first { $0.name == "xcstrings_batch_list_stale" }!
        guard case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            Issue.record("Unexpected schema structure")
            return
        }
        #expect(required.contains(.string("files")))
    }

    @Test("file is removed from required when defaultPath is set")
    func fileRemovedFromRequiredWithDefaultPath() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let tool = server.allTools.first { $0.name == "xcstrings_list_keys" }!
        guard case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            Issue.record("Unexpected schema structure")
            return
        }
        #expect(!required.contains(.string("file")))
    }

    @Test("files is removed from required when defaultPath is set")
    func filesRemovedFromRequiredWithDefaultPath() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let tool = server.allTools.first { $0.name == "xcstrings_batch_list_stale" }!
        guard case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            Issue.record("Unexpected schema structure")
            return
        }
        #expect(!required.contains(.string("files")))
    }

    @Test("xcstrings_create_file keeps file required even with defaultPath")
    func createFileKeepsFileRequired() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let tool = server.allTools.first { $0.name == "xcstrings_create_file" }!
        guard case .object(let schema) = tool.inputSchema,
              case .array(let required) = schema["required"] else {
            Issue.record("Unexpected schema structure")
            return
        }
        #expect(required.contains(.string("file")))
    }

    // MARK: - Arg injection tests (resolvedArguments)

    @Test("injects defaultPath as file when file arg absent")
    func injectsDefaultPathForFile() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let result = server.resolvedArguments([:], toolName: "xcstrings_list_keys")
        #expect(result["file"] == .string("/default/Localizable.xcstrings"))
    }

    @Test("does not override explicit file arg")
    func doesNotOverrideExplicitFile() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let args: [String: Value] = ["file": .string("/explicit/path.xcstrings")]
        let result = server.resolvedArguments(args, toolName: "xcstrings_list_keys")
        #expect(result["file"] == .string("/explicit/path.xcstrings"))
    }

    @Test("injects defaultPath as files array for batch tools")
    func injectsDefaultPathForFiles() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let result = server.resolvedArguments([:], toolName: "xcstrings_batch_list_stale")
        #expect(result["files"] == .array([.string("/default/Localizable.xcstrings")]))
    }

    @Test("does not override explicit files arg")
    func doesNotOverrideExplicitFiles() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let args: [String: Value] = ["files": .array([.string("/explicit/a.xcstrings"), .string("/explicit/b.xcstrings")])]
        let result = server.resolvedArguments(args, toolName: "xcstrings_batch_list_stale")
        #expect(result["files"] == .array([.string("/explicit/a.xcstrings"), .string("/explicit/b.xcstrings")]))
    }

    @Test("xcstrings_create_file receives no arg injection")
    func noInjectionForCreateFile() {
        let server = XCStringsMCPServer(defaultPath: "/default/Localizable.xcstrings")
        let result = server.resolvedArguments([:], toolName: "xcstrings_create_file")
        #expect(result["file"] == nil)
        #expect(result["files"] == nil)
    }

    @Test("no injection when defaultPath is nil")
    func noInjectionWithoutDefaultPath() {
        let server = XCStringsMCPServer()
        let result = server.resolvedArguments([:], toolName: "xcstrings_list_keys")
        #expect(result["file"] == nil)
    }
}
