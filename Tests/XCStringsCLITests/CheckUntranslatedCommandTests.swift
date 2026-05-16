import ArgumentParser
import Foundation
import Testing
@testable import XCStringsCLI
@testable import XCStringsKit

@Suite("check untranslated CLI command")
struct CheckUntranslatedCommandTests {
    @Test("rejects invalid argument combinations", arguments: ValidationCase.invalidCases)
    func rejectsInvalidArgumentCombinations(testCase: ValidationCase) throws {
        #expect(throws: Error.self) {
            _ = try CheckCommand.Untranslated.parse(testCase.arguments)
        }
    }

    @Test("throws exit code one for untranslated entries in normal CLI mode")
    func throwsExitCodeForUntranslatedEntries() async throws {
        let path = try createTempFile(content: Self.untranslatedFixture)
        defer { removeTempFile(at: path) }

        let command = try CheckCommand.Untranslated.parse(["--files", path, "--languages", "ja"])

        await #expect(throws: ExitCode.self) {
            try await command.run()
        }
    }

    @Test("does not throw for complete translations")
    func doesNotThrowForCompleteTranslations() async throws {
        let path = try createTempFile(content: Self.completeFixture)
        defer { removeTempFile(at: path) }

        let command = try CheckCommand.Untranslated.parse(["--files", path, "--languages", "ja"])

        try await command.run()
    }

    @Test("builds Codex hook JSON payload")
    func buildsCodexHookPayload() throws {
        let command = try CheckCommand.Untranslated.parse(["--files", "/tmp/Localizable.xcstrings", "--languages", "ja"])
        let result = UntranslatedCheckResult(issues: [
            UntranslatedIssue(file: "/tmp/Localizable.xcstrings", language: "ja", key: "Hello", reason: .missingLocalization),
        ])

        let output = try #require(command.codexHookOutput(for: result))
        let json = try encode(output)

        #expect(json.contains("\"decision\":\"block\""))
        #expect(json.contains("\"hookEventName\":\"PostToolUse\""))
        #expect(json.contains("Hello"))
        #expect(json.contains("missing localization"))
    }

    @Test("builds Claude hook JSON payload")
    func buildsClaudeHookPayload() throws {
        let command = try CheckCommand.Untranslated.parse(["--files", "/tmp/Localizable.xcstrings", "--languages", "ja"])
        let result = UntranslatedCheckResult(issues: [
            UntranslatedIssue(file: "/tmp/Localizable.xcstrings", language: "ja", key: "Hello", reason: .missingLocalization),
        ])

        let output = try #require(command.claudeHookOutput(for: result))
        let json = try encode(output)

        #expect(json.contains("\"decision\":\"block\""))
        #expect(!json.contains("hookSpecificOutput"))
        #expect(json.contains("Hello"))
        #expect(json.contains("missing localization"))
    }

    @Test("returns no hook payload when complete")
    func returnsNoHookPayloadWhenComplete() throws {
        let command = try CheckCommand.Untranslated.parse(["--files", "/tmp/Localizable.xcstrings", "--languages", "ja"])
        let result = UntranslatedCheckResult(issues: [])

        #expect(command.codexHookOutput(for: result) == nil)
        #expect(command.claudeHookOutput(for: result) == nil)
    }

    private func createTempFile(content: String) throws -> String {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("cli_test_\(UUID().uuidString).xcstrings")
            .path
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        return path
    }

    private func removeTempFile(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }

    private func encode(_ value: some Encodable) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        return try #require(String(data: data, encoding: .utf8))
    }

    private static let completeFixture = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Hello" } },
            "ja": { "stringUnit": { "state": "translated", "value": "こんにちは" } }
          }
        }
      },
      "version": "1.0"
    }
    """

    private static let untranslatedFixture = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Hello" } }
          }
        }
      },
      "version": "1.0"
    }
    """
}

struct ValidationCase: CustomTestStringConvertible {
    let testDescription: String
    let arguments: [String]

    static let invalidCases = [
        ValidationCase(
            testDescription: "missing files",
            arguments: ["--languages", "ja"]
        ),
        ValidationCase(
            testDescription: "missing languages",
            arguments: ["--files", "/tmp/Localizable.xcstrings"]
        ),
        ValidationCase(
            testDescription: "mutually exclusive hook flags",
            arguments: [
                "--files", "/tmp/Localizable.xcstrings",
                "--languages", "ja",
                "--codex-hook",
                "--claude-hook",
            ]
        ),
    ]
}
