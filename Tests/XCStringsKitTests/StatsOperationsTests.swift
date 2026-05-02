import Foundation
import Testing
@testable import XCStringsKit

@Suite("Calculating translation coverage and progress statistics")
struct StatsOperationsTests {
    @Test("getStats returns correct total keys", arguments: FixtureType.allCases)
    func getStatsTotalKeys(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let stats = try await parser.getStats()

        #expect(stats.totalKeys == fixture.expectedKeyCount)
    }

    @Test("getStats returns correct source language", arguments: FixtureType.allCases)
    func getStatsSourceLanguage(fixture: FixtureType) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let stats = try await parser.getStats()

        #expect(stats.sourceLanguage == fixture.expectedSourceLanguage)
    }

    @Test("getProgress returns correct progress", arguments: [
        (FixtureType.multipleKeysPartialTranslations, "ja", 2, 1),
        (FixtureType.multipleKeysPartialTranslations, "de", 1, 2),
        (FixtureType.manyKeys, "ja", 3, 7),
        (FixtureType.manyKeys, "en", 10, 0),
    ])
    func getProgress(fixture: FixtureType, language: String, translated: Int, untranslated: Int) async throws {
        let path = try TestHelper.createTempFile(content: fixture.content)
        defer { TestHelper.removeTempFile(at: path) }

        let parser = XCStringsParser(path: path)
        let progress = try await parser.getProgress(for: language)

        #expect(progress.translated == translated)
        #expect(progress.untranslated == untranslated)
    }
}
