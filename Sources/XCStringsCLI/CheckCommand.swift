import ArgumentParser
import Foundation
import XCStringsKit

struct CheckCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Check key existence or coverage",
        subcommands: [Key.self, Coverage.self, Untranslated.self]
    )
}

extension CheckCommand {
    struct Key: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Check if a key exists"
        )

        @Argument(help: "The key to check")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Option(name: .shortAndLong, help: "Specific language to check (optional)")
        var lang: String?

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let exists = try await parser.checkKey(key, language: lang)
            print(exists)
        }
    }

    struct Coverage: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "coverage",
            abstract: "Check translation coverage for a specific key"
        )

        @Argument(help: "The key to check coverage for")
        var key: String

        @Option(name: .shortAndLong, help: "Path to the xcstrings file")
        var file: String

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        func run() async throws {
            let parser = XCStringsParser(path: file)
            let coverage = try await parser.checkCoverage(key)
            try CLIOutput.printJSON(coverage, pretty: pretty)
        }
    }

    struct Untranslated: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "untranslated",
            abstract: "Check untranslated strings across xcstrings files"
        )

        @Option(name: [.short, .long], parsing: .upToNextOption, help: "Paths to xcstrings files")
        var files: [String]

        @Option(name: [.customShort("l"), .customLong("languages")], parsing: .upToNextOption, help: "Language codes to check")
        var languages: [String]

        @Flag(name: .long, help: "Output in pretty-printed JSON format")
        var pretty = false

        @Flag(name: .long, help: "Emit Codex PostToolUse hook JSON to stdout and exit 0. Mutually exclusive with --claude-hook.")
        var codexHook = false

        @Flag(name: .long, help: "Emit Claude hook JSON to stdout and exit 0. Mutually exclusive with --codex-hook.")
        var claudeHook = false

        func validate() throws {
            if files.isEmpty {
                throw ValidationError("At least one file must be specified")
            }
            if languages.isEmpty {
                throw ValidationError("At least one language must be specified")
            }
            if codexHook, claudeHook {
                throw ValidationError("--codex-hook and --claude-hook are mutually exclusive.")
            }
        }

        func run() async throws {
            let result = try XCStringsParser.checkUntranslated(paths: files, languages: languages)

            if codexHook {
                try printCodexHookOutput(for: result)
                return
            }

            if claudeHook {
                try printClaudeHookOutput(for: result)
                return
            }

            try CLIOutput.printJSON(result, pretty: pretty)

            if !result.isComplete {
                throw ExitCode(1)
            }
        }

        func codexHookOutput(for result: UntranslatedCheckResult) -> CodexPostToolUseHookOutput? {
            guard !result.isComplete else {
                return nil
            }

            return CodexPostToolUseHookOutput(reason: hookReason(for: result))
        }

        func claudeHookOutput(for result: UntranslatedCheckResult) -> ClaudeHookOutput? {
            guard !result.isComplete else {
                return nil
            }

            return ClaudeHookOutput(reason: hookReason(for: result))
        }

        private func printCodexHookOutput(for result: UntranslatedCheckResult) throws {
            guard let output = codexHookOutput(for: result) else {
                return
            }

            try CLIOutput.printJSON(
                output,
                pretty: false
            )
        }

        private func printClaudeHookOutput(for result: UntranslatedCheckResult) throws {
            guard let output = claudeHookOutput(for: result) else {
                return
            }

            try CLIOutput.printJSON(
                output,
                pretty: false
            )
        }

        private func hookReason(for result: UntranslatedCheckResult) -> String {
            let lines = result.issues.map { issue in
                "\(issue.file): \(issue.language): \(issue.key) (\(issue.reason.message(state: issue.state)))"
            }
            return "Untranslated strings found:\n" + lines.joined(separator: "\n")
        }
    }
}

struct CodexPostToolUseHookOutput: Encodable {
    let decision = "block"
    let reason: String
    let hookSpecificOutput: HookSpecificOutput

    init(reason: String) {
        self.reason = reason
        hookSpecificOutput = HookSpecificOutput()
    }

    struct HookSpecificOutput: Encodable {
        let hookEventName = "PostToolUse"
        let additionalContext = "Fix the listed untranslated strings before continuing."
    }
}

struct ClaudeHookOutput: Encodable {
    let decision = "block"
    let reason: String
}
