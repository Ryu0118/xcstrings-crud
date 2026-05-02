import Foundation
import MCP
import Testing
@testable import XCStringsKit
@testable import XCStringsMCP

@Suite("Tool handler integration tests")
struct ToolHandlerIntegrationTests {
    // MARK: - List Handlers

    @Test
    func listKeysHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.multipleKeysPartialTranslations)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = ListKeysHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("Hello"))
        #expect(result.contains("Goodbye"))
        #expect(result.contains("Welcome"))
    }

    @Test
    func listLanguagesHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeyMultipleLangs)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = ListLanguagesHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("en"))
        #expect(result.contains("ja"))
        #expect(result.contains("de"))
    }

    @Test
    func listUntranslatedHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.multipleKeysPartialTranslations)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = ListUntranslatedHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "language": .string("ja"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("Goodbye"))
    }

    @Test
    func listStaleHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.withStaleKeys)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = ListStaleHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("StaleKey1"))
        #expect(result.contains("StaleKey2"))
        #expect(!result.contains("\"ActiveKey\""))
    }

    @Test
    func batchListStaleHandler() async throws {
        let path1 = try TestHelper.createTempFile(content: TestFixtures.withStaleKeys)
        let path2 = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer {
            TestHelper.removeTempFile(at: path1)
            TestHelper.removeTempFile(at: path2)
        }

        let handler = BatchListStaleHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "files": .array([.string(path1), .string(path2)]),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("StaleKey1"))
        #expect(result.contains("StaleKey2"))
        #expect(result.contains("totalStaleKeys"))
        #expect(result.contains("note"))
    }

    // MARK: - Get Handlers

    @Test
    func getSourceLanguageHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.japaneseSource)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = GetSourceLanguageHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result == "ja")
    }

    @Test
    func getKeyHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeyMultipleLangs)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = GetKeyHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("Hello"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("こんにちは"))
        #expect(result.contains("Hallo"))
    }

    @Test
    func checkKeyHandlerExists() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = CheckKeyHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("Hello"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result == "true")
    }

    @Test
    func checkKeyHandlerNotExists() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = CheckKeyHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("NonExistent"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result == "false")
    }

    // MARK: - Stats Handlers

    @Test
    func statsCoverageHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.manyKeys)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = StatsCoverageHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "compact": .bool(false),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("totalKeys"))
        #expect(result.contains("10"))
    }

    @Test
    func statsProgressHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.manyKeys)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = StatsProgressHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "language": .string("ja"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("translated"))
        #expect(result.contains("3"))
    }

    // MARK: - Create Handlers

    @Test
    func createFileHandler() async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let path = tempDir.appendingPathComponent("create_test_\(UUID().uuidString).xcstrings").path
        defer { TestHelper.removeTempFile(at: path) }

        let handler = CreateFileHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "sourceLanguage": .string("ja"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("Created"))
        #expect(FileManager.default.fileExists(atPath: path))
    }

    // MARK: - Write Handlers

    @Test
    func addTranslationHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = AddTranslationHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("NewKey"),
            "language": .string("ja"),
            "value": .string("新しいキー"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("successfully"))

        // Verify the translation was added
        let parser = XCStringsParser(path: path)
        let translation = try await parser.getTranslation(key: "NewKey", language: "ja")
        #expect(translation["ja"]?.value == "新しいキー")
    }

    @Test
    func updateTranslationHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = UpdateTranslationHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("Hello"),
            "language": .string("en"),
            "value": .string("Hi there"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("successfully"))

        // Verify the translation was updated
        let parser = XCStringsParser(path: path)
        let translation = try await parser.getTranslation(key: "Hello", language: "en")
        #expect(translation["en"]?.value == "Hi there")
    }

    @Test
    func renameKeyHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = RenameKeyHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "oldKey": .string("Hello"),
            "newKey": .string("Greeting"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("successfully"))

        // Verify the key was renamed
        let parser = XCStringsParser(path: path)
        let oldExists = try await parser.checkKey("Hello", language: nil)
        let newExists = try await parser.checkKey("Greeting", language: nil)
        #expect(!oldExists)
        #expect(newExists)
    }

    // MARK: - Delete Handlers

    @Test
    func deleteKeyHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.multipleKeysPartialTranslations)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = DeleteKeyHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("Hello"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("successfully"))

        // Verify the key was deleted
        let parser = XCStringsParser(path: path)
        let exists = try await parser.checkKey("Hello", language: nil)
        #expect(!exists)
    }

    @Test
    func deleteTranslationHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeyMultipleLangs)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = DeleteTranslationHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "key": .string("Hello"),
            "language": .string("ja"),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("successfully"))

        // Verify the translation was deleted
        let parser = XCStringsParser(path: path)
        let exists = try await parser.checkKey("Hello", language: "ja")
        #expect(!exists)
    }

    // MARK: - Batch Handlers

    @Test
    func batchCheckKeysHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.multipleKeysPartialTranslations)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = BatchCheckKeysHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "keys": .array([.string("Hello"), .string("Goodbye"), .string("NonExistent")]),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("existingKeys"))
        #expect(result.contains("missingKeys"))
        #expect(result.contains("NonExistent"))
    }

    @Test
    func batchAddTranslationsHandler() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.empty)
        defer { TestHelper.removeTempFile(at: path) }

        let handler = BatchAddTranslationsHandler()
        let context = ToolContext(arguments: ToolArguments(raw: [
            "file": .string(path),
            "entries": .array([
                .object([
                    "key": .string("Hello"),
                    "translations": .object([
                        "ja": .string("こんにちは"),
                        "en": .string("Hello"),
                    ]),
                ]),
                .object([
                    "key": .string("Goodbye"),
                    "translations": .object([
                        "ja": .string("さようなら"),
                    ]),
                ]),
            ]),
        ]))

        let result = try await handler.execute(with: context)
        #expect(result.contains("successCount"))
        #expect(result.contains("2"))

        // Verify translations were added
        let parser = XCStringsParser(path: path)
        let keys = try await parser.listKeys()
        #expect(keys.contains("Hello"))
        #expect(keys.contains("Goodbye"))
    }
}
