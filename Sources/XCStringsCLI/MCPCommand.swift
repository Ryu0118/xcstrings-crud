import ArgumentParser
import XCStringsMCP

@available(macOS 13.0, *)
struct MCPCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mcp",
        abstract: "Start the MCP server"
    )

    @Option(name: .long, help: "Default path to the xcstrings file")
    var path: String?

    func run() async throws {
        let server = XCStringsMCPServer(defaultPath: path)
        try await server.run()
    }
}
