import Foundation
import Testing
@testable import XCStringsKit

@Suite("Batch operations for checking, adding, and updating multiple keys at once")
struct BatchOperationsTests {
    // MARK: - Test Cases

    struct CheckKeysTestCase: Sendable {
        let fixture: FixtureType
        let keys: [String]
        let language: String?
        let expectedExisting: [String]
        let expectedMissing: [String]

        static let allCases: [CheckKeysTestCase] = [
            CheckKeysTestCase(
                fixture: .multipleKeysPartialTranslations,
                keys: ["Hello", "Goodbye", "Welcome", "NonExistent"],
                language: nil,
                expectedExisting: ["Goodbye", "Hello", "Welcome"],
                expectedMissing: ["NonExistent"]
            ),
            CheckKeysTestCase(
                fixture: .multipleKeysPartialTranslations,
                keys: ["Hello", "Goodbye", "Welcome"],
                language: "ja",
                expectedExisting: ["Hello", "Welcome"],
                expectedMissing: ["Goodbye"]
            ),
            CheckKeysTestCase(
                fixture: .multipleKeysPartialTranslations,
                keys: ["Hello", "Goodbye", "Welcome"],
                language: "de",
                expectedExisting: ["Welcome"],
                expectedMissing: ["Goodbye", "Hello"]
            ),
            CheckKeysTestCase(
                fixture: .singleKeySingleLang,
                keys: [],
                language: nil,
                expectedExisting: [],
                expectedMissing: []
            ),
        ]
    }

    struct BatchAddTestCase: Sendable {
        let fixture: FixtureType
        let allowOverwrite: Bool
        let expectedSuccess: Int
        let expectedFailed: Int
        let expectedSucceeded: [String]
        let expectedFailedKeys: [String]

        static let allCases: [BatchAddTestCase] = [
            BatchAddTestCase(
                fixture: .singleKeySingleLang,
                allowOverwrite: false,
                expectedSuccess: 1,
                expectedFailed: 1,
                expectedSucceeded: ["NewKey"],
                expectedFailedKeys: ["Hello"]
            ),
            BatchAddTestCase(
                fixture: .singleKeySingleLang,
                allowOverwrite: true,
                expectedSuccess: 2,
                expectedFailed: 0,
                expectedSucceeded: ["Hello", "NewKey"],
                expectedFailedKeys: []
            ),
        ]
    }

    struct BatchUpdateFailureTestCase: Sendable {
        let fixture: FixtureType
        let key: String
        let translations: [String: String]
        let expectedFailedKey: String

        static let allCases: [BatchUpdateFailureTestCase] = [
            BatchUpdateFailureTestCase(
                fixture: .singleKeySingleLang,
                key: "NonExistent",
                translations: ["en": "Value"],
                expectedFailedKey: "NonExistent"
            ),
            BatchUpdateFailureTestCase(
                fixture: .singleKeySingleLang,
                key: "Hello",
                translations: ["fr": "Bonjour"],
                expectedFailedKey: "Hello"
            ),
        ]
    }

    // MARK: - Check Keys Tests

    @Test("checkKeys returns correct results for multiple keys", arguments: CheckKeysTestCase.allCases)
    func checkKeysMultiple(testCase: CheckKeysTestCase) async throws {
        let path = try TestHelper.createTempFile(content: testCase.fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let result = try await parser.checkKeys(testCase.keys, language: testCase.language)

        #expect(result.existingKeys == testCase.expectedExisting)
        #expect(result.missingKeys == testCase.expectedMissing)
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
        #expect(Set(result.succeeded) == Set(["Hello", "Goodbye", "Thanks"]))

        // Verify data was written
        let keys = try await parser.listKeys()
        #expect(keys.count == 3)
        #expect(Set(keys) == Set(["Hello", "Goodbye", "Thanks"]))

        let translation = try await parser.getTranslation(key: "Hello", language: "ja")
        #expect(translation["ja"]?.value == "こんにちは")
    }

    @Test("addTranslationsBatch handles duplicate and overwrite scenarios", arguments: BatchAddTestCase.allCases)
    func addTranslationsBatchDuplicateHandling(testCase: BatchAddTestCase) async throws {
        let path = try TestHelper.createTempFile(content: testCase.fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: "Hello", translations: ["en": "Updated Hello"]),
            BatchTranslationEntry(key: "NewKey", translations: ["en": "New Value"]),
        ]

        let result = try await parser.addTranslationsBatch(entries: entries, allowOverwrite: testCase.allowOverwrite)

        #expect(result.successCount == testCase.expectedSuccess)
        #expect(result.failedCount == testCase.expectedFailed)
        #expect(Set(result.succeeded) == Set(testCase.expectedSucceeded))
        #expect(Set(result.failed.map(\.key)) == Set(testCase.expectedFailedKeys))
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

    @Test("updateTranslationsBatch fails for invalid scenarios", arguments: BatchUpdateFailureTestCase.allCases)
    func updateTranslationsBatchFailures(testCase: BatchUpdateFailureTestCase) async throws {
        let path = try TestHelper.createTempFile(content: testCase.fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let entries = [
            BatchTranslationEntry(key: testCase.key, translations: testCase.translations),
        ]

        let result = try await parser.updateTranslationsBatch(entries: entries)

        #expect(result.successCount == 0)
        #expect(result.failedCount == 1)
        #expect(result.failed[0].key == testCase.expectedFailedKey)
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
