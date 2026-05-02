import Foundation
import Testing
@testable import XCStringsKit

@Suite("Statistics and coverage calculations for xcstrings files")
struct XCStringsStatsCalculatorTests {
    // MARK: - getStats

    @Test
    func getStatsTotalKeys() throws {
        let file = try loadFixture(TestFixtures.manyKeys)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.totalKeys == 10)
    }

    @Test
    func getStatsSourceLanguage() throws {
        let file = try loadFixture(TestFixtures.japaneseSource)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.sourceLanguage == "ja")
    }

    @Test
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

    @Test
    func getStatsCoverage() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.coverageByLanguage["en"]?.coveragePercent == 100.0)
        #expect(stats.coverageByLanguage["ja"]?.coveragePercent == 100.0)
    }

    @Test
    func getStatsEmpty() throws {
        let file = try loadFixture(TestFixtures.empty)
        let calculator = XCStringsStatsCalculator(file: file)

        let stats = calculator.getStats()

        #expect(stats.totalKeys == 0)
    }

    @Test
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

    // MARK: - getProgress

    @Test
    func getProgressSpecificLanguage() throws {
        let file = try loadFixture(TestFixtures.singleKeyMultipleLangs)
        let calculator = XCStringsStatsCalculator(file: file)

        let progress = try calculator.getProgress(for: "ja")

        #expect(progress.translated == 1)
        #expect(progress.total == 1)
        #expect(progress.coveragePercent == 100.0)
    }

    @Test
    func getProgressLanguageNotFound() throws {
        let file = try loadFixture(TestFixtures.singleKeySingleLang)
        let calculator = XCStringsStatsCalculator(file: file)

        #expect(throws: XCStringsError.self) {
            _ = try calculator.getProgress(for: "fr")
        }
    }

    @Test
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
