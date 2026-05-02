import Foundation
import Testing
@testable import XCStringsKit

@Suite("Listing keys, languages, and untranslated entries from xcstrings files")
struct ListOperationsTests {
    @Test(arguments: FixtureType.allCases)
    func listKeysCount(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let keys = try await parser.listKeys()

        #expect(keys.count == fixture.expectedKeyCount)
    }

    @Test(arguments: [
        FixtureType.multipleKeysPartialTranslations,
        FixtureType.manyKeys,
    ])
    func listKeysSorted(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let keys = try await parser.listKeys()
        let sortedKeys = keys.sorted()

        #expect(keys == sortedKeys)
    }

    @Test(arguments: [
        (FixtureType.singleKeySingleLang, 1),
        (FixtureType.singleKeyMultipleLangs, 3),
        (FixtureType.manyLanguages, 7),
    ])
    func listLanguagesCount(fixture: FixtureType, expectedCount: Int) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let languages = try await parser.listLanguages()

        #expect(languages.count == expectedCount)
    }

    @Test(arguments: [
        (FixtureType.multipleKeysPartialTranslations, "ja", ["Goodbye"]),
        (FixtureType.multipleKeysPartialTranslations, "de", ["Goodbye", "Hello"]),
        (FixtureType.manyKeys, "ja", ["Key1", "Key10", "Key2", "Key3", "Key4", "Key5", "Key9"]),
    ])
    func listUntranslated(fixture: FixtureType, language: String, expectedKeys: [String]) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let untranslated = try await parser.listUntranslated(for: language)

        #expect(untranslated == expectedKeys)
    }

    @Test
    func listStaleKeys() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.withStaleKeys)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let staleKeys = try await parser.listStaleKeys()

        #expect(staleKeys == ["StaleKey1", "StaleKey2"])
    }

    @Test
    func listStaleKeysEmpty() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let staleKeys = try await parser.listStaleKeys()

        #expect(staleKeys.isEmpty)
    }

    @Test
    func listStaleKeysIgnoresOtherStates() async throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.withComments)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let staleKeys = try await parser.listStaleKeys()

        // withComments has "manual" extraction state, not "stale"
        #expect(staleKeys.isEmpty)
    }

    // MARK: - Batch Stale Keys Tests

    @Test
    func batchListStaleKeys() throws {
        let path1 = try TestHelper.createTempFile(content: TestFixtures.withStaleKeys)
        let path2 = try TestHelper.createTempFile(content: TestFixtures.singleKeySingleLang)
        defer {
            TestHelper.removeTempFile(at: path1)
            TestHelper.removeTempFile(at: path2)
        }

        let result = try XCStringsParser.getBatchStaleKeys(paths: [path1, path2])

        #expect(result.files.count == 2)
        #expect(result.totalStaleKeys == 2)

        let file1Summary = result.files.first { $0.file == path1 }
        #expect(file1Summary?.staleKeys == ["StaleKey1", "StaleKey2"])
        #expect(file1Summary?.count == 2)

        let file2Summary = result.files.first { $0.file == path2 }
        #expect(file2Summary?.staleKeys.isEmpty == true)
        #expect(file2Summary?.count == 0)
    }

    @Test
    func batchListStaleKeysNote() throws {
        let path = try TestHelper.createTempFile(content: TestFixtures.withStaleKeys)
        defer { TestHelper.removeTempFile(at: path) }

        let result = try XCStringsParser.getBatchStaleKeys(paths: [path])

        #expect(result.note == StaleKeysConstants.note)
    }

    @Test
    func batchListStaleKeysEmptyFiles() throws {
        let result = try XCStringsParser.getBatchStaleKeys(paths: [])

        #expect(result.files.isEmpty)
        #expect(result.totalStaleKeys == 0)
    }
}
