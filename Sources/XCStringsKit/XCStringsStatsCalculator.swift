import Foundation

/// Handles statistics calculations for xcstrings files
struct XCStringsStatsCalculator: Sendable {
    private let file: XCStringsFile
    private let reader: XCStringsReader

    init(file: XCStringsFile) {
        self.file = file
        self.reader = XCStringsReader(file: file)
    }

    /// Get overall statistics
    func getStats() -> StatsInfo {
        let allLanguages = reader.listLanguages()

        var coverageByLanguage: [String: LanguageStats] = [:]

        for language in allLanguages {
            var translated = 0
            var untranslated = 0

            for entry in file.strings.values {
                let isTranslated = entry.localizations?[language]?.stringUnit?.value != nil
                    || entry.localizations?[language]?.variations != nil

                if isTranslated {
                    translated += 1
                } else {
                    untranslated += 1
                }
            }

            let total = translated + untranslated
            let coveragePercent = total == 0 ? 0 : Double(translated) / Double(total) * 100

            coverageByLanguage[language] = LanguageStats(
                translated: translated,
                untranslated: untranslated,
                total: total,
                coveragePercent: coveragePercent
            )
        }

        return StatsInfo(
            totalKeys: file.strings.count,
            sourceLanguage: file.sourceLanguage,
            languages: allLanguages,
            coverageByLanguage: coverageByLanguage
        )
    }

    /// Get progress for a specific language
    func getProgress(for language: String) throws -> LanguageStats {
        let stats = getStats()

        guard let langStats = stats.coverageByLanguage[language] else {
            throw XCStringsError.languageNotFound(language: language, key: "")
        }

        return langStats
    }
}
