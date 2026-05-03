import Foundation
import Testing
@testable import XCStringsKit

@Suite("Statistics and coverage calculations for xcstrings files")
struct XCStringsStatsCalculatorTests {
    // MARK: - getStats

    @Test("getStats returns correct total key count")
    func getStatsTotalKeys() throws {
        let file = try loadFixture(TestFixtures.manyKeys)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.totalKeys == 10)
    }

    @Test("getStats returns correct source language")
    func getStatsSourceLanguage() throws {
        let file = try loadFixture(TestFixtures.japaneseSource)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.sourceLanguage == "ja")
    }

    @Test("getStats returns all languages")
    func getStatsLanguages() throws {
        let file = try loadFixture(TestFixtures.manyLanguages)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.languages.contains("en"))
        #expect(stats.languages.contains("ja"))
        #expect(stats.languages.contains("de"))
        #expect(stats.languages.contains("fr"))
        #expect(stats.languages.contains("es"))
    }

    @Test("getStats calculates coverage by language")
    func getStatsCoverage() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.coverageByLanguage["en"]?.coveragePercent == 100.0)
        #expect(stats.coverageByLanguage["ja"]?.coveragePercent == 100.0)
    }

    @Test("getStats returns zero for empty file")
    func getStatsEmpty() throws {
        let file = try loadFixture(TestFixtures.empty)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.totalKeys == 0)
    }

    @Test("getStats calculates partial coverage correctly")
    func getStatsPartialCoverage() throws {
        let file = try loadFixture(TestFixtures.multipleKeysPartialTranslations)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        // English should have higher coverage than other languages
        let enStats = stats.coverageByLanguage["en"]
        let jaStats = stats.coverageByLanguage["ja"]

        #expect(enStats != nil)
        #expect(jaStats != nil)
        #expect(try #require(enStats?.translated) >= jaStats!.translated)
    }

    @Test("getStats excludes keys marked shouldTranslate false from coverage totals")
    func getStatsExcludesNonTranslatableKeys() throws {
        let file = try loadFixture(TestFixtures.withNonTranslatableKey)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()
        let enStats = stats.coverageByLanguage["en"]

        #expect(stats.totalKeys == 2)
        #expect(enStats?.translated == 1)
        #expect(enStats?.untranslated == 0)
        #expect(enStats?.total == 1)
        #expect(enStats?.coveragePercent == 100.0)
    }

    // MARK: - getProgress

    @Test("getProgress returns stats for specific language")
    func getProgressSpecificLanguage() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let calculator = XCStringsStatsCalculator(file: file)

        let progress = try calculator.getProgress(for: "ja")

        #expect(progress.translated == 1)
        #expect(progress.total == 1)
        #expect(progress.coveragePercent == 100.0)
    }

    @Test("getProgress throws for non-existent language")
    func getProgressLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)
        let calculator = XCStringsStatsCalculator(file: file)

        #expect(throws: XCStringsError.self) {
            _ = try calculator.getProgress(for: "fr")
        }
    }

    @Test("getProgress calculates untranslated count correctly")
    func getProgressUntranslated() throws {
        let file = try loadFixture(TestFixtures.multipleKeysPartialTranslations)
        let calculator = XCStringsStatsCalculator(file: file)

        let progress = try calculator.getProgress(for: "ja")

        #expect(progress.untranslated > 0)
        #expect(progress.total == progress.translated + progress.untranslated)
    }

    // MARK: - Helper

    private func loadFixture(_ content: String) throws -> XCStringsFile {
        let data = content.data(using: .utf8)!
        return try JSONDecoder().decode(XCStringsFile.self, from: data)
    }
}
