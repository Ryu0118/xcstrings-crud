import Foundation
import Testing
@testable import XCStringsKit

@Suite("Batch operations for checking, adding, and updating multiple keys at once")
struct BatchOperationsTests {
    // MARK: - Check Keys Tests

    @Test("checkKeys returns correct results for multiple keys", arguments: [
        (FixtureType.multipleKeysPartialTranslations, ["Hello", "Goodbye", "Welcome", "NonExistent"], nil as String?, ["Goodbye", "Hello", "Welcome"], ["NonExistent"]),
        (FixtureType.multipleKeysPartialTranslations, ["Hello", "Goodbye", "Welcome"], "ja", ["Hello", "Welcome"], ["Goodbye"]),
        (FixtureType.multipleKeysPartialTranslations, ["Hello", "Goodbye", "Welcome"], "de", ["Welcome"], ["Goodbye", "Hello"]),
        (FixtureType.singleKeySingleLang, [], nil as String?, [] as [String], [] as [String]),
    ])
    func checkKeysMultiple(fixture: FixtureType, keys: [String], language: String?, expectedExisting: [String], expectedMissing: [String]) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let result = try await parser.checkKeys(keys, language: language)

        #expect(result.existingKeys == expectedExisting)
        #expect(result.missingKeys == expectedMissing)
    }

    // MARK: - Batch Add Translations Tests

    @Test("addTranslationsBatch adds multiple keys successfully", arguments: [
        FixtureType.empty,
    ])
    func addTranslationsBatchMultipleKeys(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "Hello", "ja": "こんにちは"]),
            BatchTranslationEntry(key: "Goodbye", translations: ["en": "Goodbye", "ja": "さようなら"]),
            BatchTranslationEntry(key: "Thanks", translations: ["en": "Thanks"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries)

        #expect(result.successCount == 3)
        #expect(result.failedCount == 0)
        #expect(Set(result.succeeded) == Set(["Hello", "Goodbye", "Thanks"]))

        // Verify data was written
        let keys = try await parser.listKeys()
        #expect(keys.count == 3)
        #expect(Set(keys) == Set(["Hello", "Goodbye", "Thanks"]))

        let translation = try await parser.getTranslation(key: "Hello", language: "ja")
        #expect(translation["ja"]?.value == "こんにちは")
    }

    @Test("addTranslationsBatch handles duplicate and overwrite scenarios", arguments: [
        (FixtureType.singleKeySingleLang, false, 1, 1, ["NewKey"], ["Hello"]),
        (FixtureType.singleKeySingleLang, true, 2, 0, ["Hello", "NewKey"], [] as [String]),
    ])
    func addTranslationsBatchDuplicateHandling(fixture: FixtureType, allowOverwrite: Bool, expectedSuccess: Int, expectedFailed: Int, expectedSucceeded: [String], expectedFailedKeys: [String]) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "Updated Hello"]),
            BatchTranslationEntry(key: "NewKey", translations: ["en": "New Value"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: allowOverwrite)

        #expect(result.successCount == expectedSuccess)
        #expect(result.failedCount == expectedFailed)
        #expect(Set(result.succeeded) == Set(expectedSucceeded))
        #expect(Set(result.failed.map(\.key)) == Set(expectedFailedKeys))
    }

    // MARK: - Batch Update Translations Tests

    @Test("updateTranslationsBatch updates multiple keys successfully")
    func updateTranslationsBatchMultipleKeys() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.multipleKeysPartialTranslations.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "Hi there"]),
            BatchTranslationEntry(key: "Welcome", translations: ["en": "Welcome!", "ja": "ようこそ！"]),
        ]

        let result = try await parser.updateTranslationsBatch(entries: entries)

        #expect(result.successCount == 2)
        #expect(result.failedCount == 0)

        let helloTranslation = try await parser.getTranslation(key: "Hello", language: "en")
        #expect(helloTranslation["en"]?.value == "Hi there")

        let welcomeTranslation = try await parser.getTranslation(key: "Welcome", language: "en")
        #expect(welcomeTranslation["en"]?.value == "Welcome!")
    }

    @Test("updateTranslationsBatch fails for invalid scenarios", arguments: [
        (FixtureType.singleKeySingleLang, "NonExistent", ["en": "Value"], "NonExistent"),
        (FixtureType.singleKeySingleLang, "Hello", ["fr": "Bonjour"], "Hello"),
    ])
    func updateTranslationsBatchFailures(fixture: FixtureType, key: String, translations: [String: String], expectedFailedKey: String) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: key, translations: translations),
        ]

        let result = try await parser.updateTranslationsBatch(entries: entries)

        #expect(result.successCount == 0)
        #expect(result.failedCount == 1)
        #expect(result.failed[0].key == expectedFailedKey)
    }

    @Test("updateTranslationsBatch with mixed success and failure")
    func updateTranslationsBatchMixed() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.singleKeySingleLang.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "Updated"]),
            BatchTranslationEntry(key: "NonExistent", translations: ["en": "Value"]),
        ]

        let result = try await parser.updateTranslationsBatch(entries: entries)

        #expect(result.successCount == 1)
        #expect(result.failedCount == 1)
        #expect(result.succeeded.contains("Hello"))
        #expect(result.failed[0].key == "NonExistent")
    }

    // MARK: - Edge Cases

    @Test("batch operations with empty entries array", arguments: [
        FixtureType.empty,
        FixtureType.singleKeySingleLang,
    ])
    func batchOperationsEmptyEntries(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)

        let addResult = try await parser.addTranslationsBatch(entries: [])
        #expect(addResult.successCount == 0)
        #expect(addResult.failedCount == 0)

        let updateResult = try await parser.updateTranslationsBatch(entries: [])
        #expect(updateResult.successCount == 0)
        #expect(updateResult.failedCount == 0)
    }

    @Test("batch add preserves file integrity on partial failure")
    func batchAddPartialFailureIntegrity() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.singleKeySingleLang.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "NewKey1", translations: ["en": "Value1"]),
            BatchTranslationEntry(key: "Hello", translations: ["en": "Duplicate"]),
            BatchTranslationEntry(key: "NewKey2", translations: ["en": "Value2"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: false)

        #expect(result.successCount == 2)
        #expect(result.failedCount == 1)

        // Verify successful entries were added
        let keys = try await parser.listKeys()
        #expect(keys.contains("NewKey1"))
        #expect(keys.contains("NewKey2"))
        #expect(keys.contains("Hello"))
    }
}
