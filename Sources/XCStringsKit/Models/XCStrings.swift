import Foundation

/// Root structure of xcstrings file
package struct XCStringsFile: Codable, Sendable {
    var sourceLanguage: String
    var strings: [String: StringEntry]
    var version: String

    package init(sourceLanguage: String = "en", strings: [String: StringEntry] = [:], version: String = "1.0") {
        self.sourceLanguage = sourceLanguage
        self.strings = strings
        self.version = version
    }
}

/// String entry for each key
package struct StringEntry: Codable, Sendable {
    var comment: String?
    var extractionState: String?
    var localizations: [String: Localization]?

    package init(comment: String? = nil, extractionState: String? = nil, localizations: [String: Localization]? = nil) {
        self.comment = comment
        self.extractionState = extractionState
        self.localizations = localizations
    }
}

/// Localization entry
package struct Localization: Codable, Sendable {
    var stringUnit: StringUnit?
    var variations: Variations?

    package init(stringUnit: StringUnit? = nil, variations: Variations? = nil) {
        self.stringUnit = stringUnit
        self.variations = variations
    }
}

/// String unit containing the actual translation value
package struct StringUnit: Codable, Sendable {
    var state: String
    var value: String

    package init(state: String = "translated", value: String) {
        self.state = state
        self.value = value
    }
}

/// Variations (plural, device, etc.)
package struct Variations: Codable, Sendable {
    var plural: PluralVariation?
    var device: DeviceVariation?

    package init(plural: PluralVariation? = nil, device: DeviceVariation? = nil) {
        self.plural = plural
        self.device = device
    }
}

/// Plural variation
package struct PluralVariation: Codable, Sendable {
    var zero: StringUnit?
    var one: StringUnit?
    var two: StringUnit?
    var few: StringUnit?
    var many: StringUnit?
    var other: StringUnit?

    package init(
        zero: StringUnit? = nil,
        one: StringUnit? = nil,
        two: StringUnit? = nil,
        few: StringUnit? = nil,
        many: StringUnit? = nil,
        other: StringUnit? = nil
    ) {
        self.zero = zero
        self.one = one
        self.two = two
        self.few = few
        self.many = many
        self.other = other
    }
}

/// Device variation
package struct DeviceVariation: Codable, Sendable {
    var iphone: StringUnit?
    var ipad: StringUnit?
    var mac: StringUnit?
    var applewatch: StringUnit?
    var appletv: StringUnit?

    package init(
        iphone: StringUnit? = nil,
        ipad: StringUnit? = nil,
        mac: StringUnit? = nil,
        applewatch: StringUnit? = nil,
        appletv: StringUnit? = nil
    ) {
        self.iphone = iphone
        self.ipad = ipad
        self.mac = mac
        self.applewatch = applewatch
        self.appletv = appletv
    }
}

// MARK: - Output Models

/// Key information for output
package struct KeyInfo: Codable, Sendable {
    package let key: String
    package let comment: String?
    package let extractionState: String?
    package let languages: [String]

    package init(key: String, comment: String?, extractionState: String?, languages: [String]) {
        self.key = key
        self.comment = comment
        self.extractionState = extractionState
        self.languages = languages
    }
}

/// Translation information for output
package struct TranslationInfo: Codable, Sendable {
    package let key: String
    package let language: String
    package let value: String?
    package let state: String?
    package let hasVariations: Bool

    package init(key: String, language: String, value: String?, state: String?, hasVariations: Bool) {
        self.key = key
        self.language = language
        self.value = value
        self.state = state
        self.hasVariations = hasVariations
    }
}

/// Coverage information for output
package struct CoverageInfo: Codable, Sendable {
    package let key: String
    package let translatedLanguages: [String]
    package let missingLanguages: [String]
    package let coveragePercent: Double

    package init(key: String, translatedLanguages: [String], missingLanguages: [String], coveragePercent: Double) {
        self.key = key
        self.translatedLanguages = translatedLanguages
        self.missingLanguages = missingLanguages
        self.coveragePercent = coveragePercent
    }
}

/// Overall statistics for output
package struct StatsInfo: Codable, Sendable {
    package let totalKeys: Int
    package let sourceLanguage: String
    package let languages: [String]
    package let coverageByLanguage: [String: LanguageStats]

    package init(totalKeys: Int, sourceLanguage: String, languages: [String], coverageByLanguage: [String: LanguageStats]) {
        self.totalKeys = totalKeys
        self.sourceLanguage = sourceLanguage
        self.languages = languages
        self.coverageByLanguage = coverageByLanguage
    }
}

/// Per-language statistics
package struct LanguageStats: Codable, Sendable {
    package let translated: Int
    package let untranslated: Int
    package let total: Int
    package let coveragePercent: Double

    package init(translated: Int, untranslated: Int, total: Int, coveragePercent: Double) {
        self.translated = translated
        self.untranslated = untranslated
        self.total = total
        self.coveragePercent = coveragePercent
    }
}

/// Token-efficient batch coverage summary for multiple files
package struct BatchCoverageSummary: Codable, Sendable {
    package let files: [FileCoverageSummary]
    package let aggregated: AggregatedCoverage

    package init(files: [FileCoverageSummary], aggregated: AggregatedCoverage) {
        self.files = files
        self.aggregated = aggregated
    }
}

/// Compact coverage summary for a single file
package struct FileCoverageSummary: Codable, Sendable {
    package let file: String
    package let totalKeys: Int
    package let languages: [String: Double]  // lang -> coveragePercent

    package init(file: String, totalKeys: Int, languages: [String: Double]) {
        self.file = file
        self.totalKeys = totalKeys
        self.languages = languages
    }
}

/// Aggregated coverage across all files
package struct AggregatedCoverage: Codable, Sendable {
    package let totalFiles: Int
    package let totalKeys: Int
    package let averageCoverageByLanguage: [String: Double]

    package init(totalFiles: Int, totalKeys: Int, averageCoverageByLanguage: [String: Double]) {
        self.totalFiles = totalFiles
        self.totalKeys = totalKeys
        self.averageCoverageByLanguage = averageCoverageByLanguage
    }
}

// MARK: - Compact Output Models (100% languages omitted)

/// Compact stats info - only shows languages under 100%
package struct CompactStatsInfo: Codable, Sendable {
    package let totalKeys: Int
    package let sourceLanguage: String
    package let totalLanguages: Int
    package let allComplete: Bool
    package let incompleteLanguages: [String: LanguageStats]?  // nil if all complete
    package let completeCount: Int  // number of languages at 100%

    package init(from stats: StatsInfo) {
        self.totalKeys = stats.totalKeys
        self.sourceLanguage = stats.sourceLanguage
        self.totalLanguages = stats.languages.count

        let incomplete = stats.coverageByLanguage.filter { $0.value.coveragePercent < 100 }
        self.allComplete = incomplete.isEmpty
        self.incompleteLanguages = incomplete.isEmpty ? nil : incomplete
        self.completeCount = stats.coverageByLanguage.count - incomplete.count
    }
}

/// Compact file coverage summary - only shows languages under 100%
package struct CompactFileCoverageSummary: Codable, Sendable {
    package let file: String
    package let totalKeys: Int
    package let totalLanguages: Int
    package let allComplete: Bool
    package let incompleteLanguages: [String: Double]?  // nil if all complete
    package let completeCount: Int

    package init(from summary: FileCoverageSummary) {
        self.file = summary.file
        self.totalKeys = summary.totalKeys
        self.totalLanguages = summary.languages.count

        let incomplete = summary.languages.filter { $0.value < 100 }
        self.allComplete = incomplete.isEmpty
        self.incompleteLanguages = incomplete.isEmpty ? nil : incomplete
        self.completeCount = summary.languages.count - incomplete.count
    }
}

/// Compact batch coverage summary
package struct CompactBatchCoverageSummary: Codable, Sendable {
    package let files: [CompactFileCoverageSummary]
    package let aggregated: CompactAggregatedCoverage

    package init(from batch: BatchCoverageSummary) {
        self.files = batch.files.map { CompactFileCoverageSummary(from: $0) }
        self.aggregated = CompactAggregatedCoverage(from: batch.aggregated)
    }
}

/// Compact aggregated coverage
package struct CompactAggregatedCoverage: Codable, Sendable {
    package let totalFiles: Int
    package let totalKeys: Int
    package let totalLanguages: Int
    package let allComplete: Bool
    package let incompleteLanguages: [String: Double]?
    package let completeCount: Int

    package init(from agg: AggregatedCoverage) {
        self.totalFiles = agg.totalFiles
        self.totalKeys = agg.totalKeys
        self.totalLanguages = agg.averageCoverageByLanguage.count

        let incomplete = agg.averageCoverageByLanguage.filter { $0.value < 100 }
        self.allComplete = incomplete.isEmpty
        self.incompleteLanguages = incomplete.isEmpty ? nil : incomplete
        self.completeCount = agg.averageCoverageByLanguage.count - incomplete.count
    }
}

// MARK: - Batch Operation Models

/// Result of batch key existence check
package struct BatchCheckKeysResult: Codable, Sendable {
    package let results: [String: Bool]  // key -> exists
    package let existingKeys: [String]
    package let missingKeys: [String]

    package init(results: [String: Bool]) {
        self.results = results
        self.existingKeys = results.filter { $0.value }.keys.sorted()
        self.missingKeys = results.filter { !$0.value }.keys.sorted()
    }
}

/// Single entry for batch add/update operations
package struct BatchTranslationEntry: Codable, Sendable {
    package let key: String
    package let translations: [String: String]  // language -> value

    package init(key: String, translations: [String: String]) {
        self.key = key
        self.translations = translations
    }
}

/// Result of batch add/update operations
package struct BatchWriteResult: Codable, Sendable {
    package let successCount: Int
    package let failedCount: Int
    package let succeeded: [String]
    package let failed: [BatchWriteError]

    package init(succeeded: [String], failed: [BatchWriteError]) {
        self.successCount = succeeded.count
        self.failedCount = failed.count
        self.succeeded = succeeded
        self.failed = failed
    }
}

/// Error info for batch write operations
package struct BatchWriteError: Codable, Sendable {
    package let key: String
    package let error: String

    package init(key: String, error: String) {
        self.key = key
        self.error = error
    }
}
