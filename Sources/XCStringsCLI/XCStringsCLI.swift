import ArgumentParser

@available(macOS 13.0, *)
public struct XCStringsCLI: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "xcstrings-crud",
        abstract: "A CLI tool for CRUD operations on xcstrings files",
        version: "1.0.0",
        subcommands: [
            CreateCommand.self,
            ListCommand.self,
            GetCommand.self,
            CheckCommand.self,
            AddCommand.self,
            UpdateCommand.self,
            DeleteCommand.self,
            RenameCommand.self,
            StatsCommand.self,
            MCPCommand.self,
        ]
    )

    public init() {}
}
