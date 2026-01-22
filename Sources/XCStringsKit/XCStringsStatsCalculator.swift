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
        let entries = file.strings.values

        let coverageByLanguage = Dictionary(uniqueKeysWithValues: allLanguages.lazy.map { language in
            let translated = entries.lazy.filter { entry in
                let localization = entry.localizations?[language]
                return localization?.stringUnit?.value != nil || localization?.variations != nil
            }.count

            let total = entries.count
            let untranslated = total - translated
            let coveragePercent = total == 0 ? 0 : Double(translated) / Double(total) * 100

            return (language, LanguageStats(
                translated: translated,
                untranslated: untranslated,
                total: total,
                coveragePercent: coveragePercent
            ))
        })

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

    /// Get compact coverage summary (token-efficient)
    func getCoverageSummary(fileName: String) -> FileCoverageSummary {
        let stats = getStats()
        let languages = stats.coverageByLanguage.mapValues { $0.coveragePercent }
        return FileCoverageSummary(
            file: fileName,
            totalKeys: stats.totalKeys,
            languages: languages
        )
    }

    /// Get batch coverage for multiple files
    static func getBatchCoverage(files: [(path: String, file: XCStringsFile)]) -> BatchCoverageSummary {
        let summaries = files.map { (path, file) in
            XCStringsStatsCalculator(file: file).getCoverageSummary(fileName: path)
        }

        // Aggregate stats
        let totalFiles = summaries.count
        let totalKeys = summaries.reduce(0) { $0 + $1.totalKeys }

        // Calculate weighted average coverage by language
        let languageTotals = summaries.lazy
            .flatMap(\.languages)
            .reduce(into: [String: (sum: Double, count: Int)]()) { totals, pair in
                let current = totals[pair.key] ?? (sum: 0, count: 0)
                totals[pair.key] = (sum: current.sum + pair.value, count: current.count + 1)
            }
        let averageCoverage = languageTotals.mapValues { $0.sum / Double($0.count) }

        return BatchCoverageSummary(
            files: summaries,
            aggregated: AggregatedCoverage(
                totalFiles: totalFiles,
                totalKeys: totalKeys,
                averageCoverageByLanguage: averageCoverage
            )
        )
    }

    // MARK: - Compact Output (100% languages omitted)

    /// Get compact stats (only shows incomplete languages)
    func getCompactStats() -> CompactStatsInfo {
        CompactStatsInfo(from: getStats())
    }

    /// Get compact batch coverage for multiple files
    static func getCompactBatchCoverage(files: [(path: String, file: XCStringsFile)]) -> CompactBatchCoverageSummary {
        CompactBatchCoverageSummary(from: getBatchCoverage(files: files))
    }
}
