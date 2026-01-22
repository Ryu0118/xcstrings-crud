import Foundation
import Testing
@testable import XCStringsKit

@Suite("Batch operations for checking, adding, and updating multiple keys at once")
struct BatchOperationsTests {
    // MARK: - Check Keys Tests

    @Test("checkKeys returns correct results for multiple keys")
    func checkKeysMultiple() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.multipleKeysPartialTranslations.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let result = try await parser.checkKeys(["Hello", "Goodbye", "Welcome", "NonExistent"], language: nil)

        #expect(result.results["Hello"] == true)
        #expect(result.results["Goodbye"] == true)
        #expect(result.results["Welcome"] == true)
        #expect(result.results["NonExistent"] == false)
        #expect(result.existingKeys == ["Goodbye", "Hello", "Welcome"])
        #expect(result.missingKeys == ["NonExistent"])
    }

    @Test("checkKeys with language filter", arguments: [
        (FixtureType.multipleKeysPartialTranslations, "ja", ["Hello", "Welcome"], ["Goodbye"]),
        (FixtureType.multipleKeysPartialTranslations, "de", ["Welcome"], ["Goodbye", "Hello"]),
    ])
    func checkKeysWithLanguage(fixture: FixtureType, language: String, expectedExisting: [String], expectedMissing: [String]) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let result = try await parser.checkKeys(["Hello", "Goodbye", "Welcome"], language: language)

        #expect(result.existingKeys == expectedExisting)
        #expect(result.missingKeys == expectedMissing)
    }

    @Test("checkKeys with empty keys array")
    func checkKeysEmpty() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.singleKeySingleLang.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let result = try await parser.checkKeys([], language: nil)

        #expect(result.results.isEmpty)
        #expect(result.existingKeys.isEmpty)
        #expect(result.missingKeys.isEmpty)
    }

    // MARK: - Batch Add Translations Tests

    @Test("addTranslationsBatch adds multiple keys successfully")
    func addTranslationsBatchMultipleKeys() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.empty.content)
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
        #expect(result.succeeded.contains("Hello"))
        #expect(result.succeeded.contains("Goodbye"))
        #expect(result.succeeded.contains("Thanks"))

        // Verify data was written
        let keys = try await parser.listKeys()
        #expect(keys.count == 3)
        #expect(keys.contains("Hello"))
        #expect(keys.contains("Goodbye"))
        #expect(keys.contains("Thanks"))

        let translation = try await parser.getTranslation(key: "Hello", language: "ja")
        #expect(translation["ja"]?.value == "こんにちは")
    }

    @Test("addTranslationsBatch fails for duplicate keys without overwrite")
    func addTranslationsBatchDuplicateKey() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.singleKeySingleLang.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "New Hello"]),  // Already exists
            BatchTranslationEntry(key: "NewKey", translations: ["en": "New Value"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: false)

        #expect(result.successCount == 1)
        #expect(result.failedCount == 1)
        #expect(result.succeeded.contains("NewKey"))
        #expect(result.failed.count == 1)
        #expect(result.failed[0].key == "Hello")
    }

    @Test("addTranslationsBatch allows overwrite when flag is set")
    func addTranslationsBatchWithOverwrite() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.singleKeySingleLang.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "Updated Hello"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: true)

        #expect(result.successCount == 1)
        #expect(result.failedCount == 0)

        let translation = try await parser.getTranslation(key: "Hello", language: "en")
        #expect(translation["en"]?.value == "Updated Hello")
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

    @Test("updateTranslationsBatch fails for non-existent keys")
    func updateTranslationsBatchNonExistent() async throws {
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

    @Test("updateTranslationsBatch fails for non-existent language")
    func updateTranslationsBatchNonExistentLanguage() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.singleKeySingleLang.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["fr": "Bonjour"]),  // Language doesn't exist
        ]

        let result = try await parser.updateTranslationsBatch(entries: entries)

        #expect(result.successCount == 0)
        #expect(result.failedCount == 1)
    }

    // MARK: - Edge Cases

    @Test("batch operations with empty entries array")
    func batchOperationsEmptyEntries() async throws {
        let path = try TestHelper.createTempFile(content: FixtureType.empty.content)
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
            BatchTranslationEntry(key: "Hello", translations: ["en": "Duplicate"]),  // Will fail
            BatchTranslationEntry(key: "NewKey2", translations: ["en": "Value2"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: false)

        #expect(result.successCount == 2)
        #expect(result.failedCount == 1)

        // Verify successful entries were added
        let keys = try await parser.listKeys()
        #expect(keys.contains("NewKey1"))
        #expect(keys.contains("NewKey2"))
        #expect(keys.contains("Hello"))  // Original still exists
    }
}
