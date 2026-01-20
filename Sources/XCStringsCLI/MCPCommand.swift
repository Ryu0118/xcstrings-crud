import ArgumentParser
import XCStringsMCP

@available(macOS 13.0, *)
struct MCPCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mcp",
        abstract: "Start the MCP server"
    )

    func run() async throws {
        let server = XCStringsMCPServer()
        try await server.run()
    }
}
