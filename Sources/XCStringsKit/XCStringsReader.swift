import Foundation

/// Handles read operations for xcstrings files
struct XCStringsReader: Sendable {
    private let file: XCStringsFile

    init(file: XCStringsFile) {
        self.file = file
    }

    /// Get all keys sorted alphabetically
    func listKeys() -> [String] {
        file.strings.keys.sorted()
    }

    /// Get all languages used in the file
    func listLanguages() -> [String] {
        var languages = Set<String>()
        languages.insert(file.sourceLanguage)

        for entry in file.strings.values {
            if let localizations = entry.localizations {
                languages.formUnion(localizations.keys)
            }
        }

        return languages.sorted()
    }

    /// Get untranslated keys for a specific language
    func listUntranslated(for language: String) -> [String] {
        var untranslated: [String] = []

        for (key, entry) in file.strings {
            let isTranslated = entry.localizations?[language]?.stringUnit?.value != nil
                || entry.localizations?[language]?.variations != nil

            if !isTranslated {
                untranslated.append(key)
            }
        }

        return untranslated.sorted()
    }

    /// Get keys with stale extraction state
    func listStaleKeys() -> [String] {
        file.strings
            .filter { $0.value.extractionState == "stale" }
            .map { $0.key }
            .sorted()
    }

    /// Get source language
    func getSourceLanguage() -> String {
        file.sourceLanguage
    }

    /// Get key information
    func getKey(_ key: String) throws -> KeyInfo {
        guard let entry = file.strings[key] else {
            throw XCStringsError.keyNotFound(key: key)
        }

        let languages = entry.localizations?.keys.sorted() ?? []

        return KeyInfo(
            key: key,
            comment: entry.comment,
            extractionState: entry.extractionState,
            languages: languages
        )
    }

    /// Get translation for a key
    func getTranslation(key: String, language: String?) throws -> [String: TranslationInfo] {
        guard let entry = file.strings[key] else {
            throw XCStringsError.keyNotFound(key: key)
        }

        var result: [String: TranslationInfo] = [:]

        if let lang = language {
            if let localization = entry.localizations?[lang] {
                result[lang] = TranslationInfo(
                    key: key,
                    language: lang,
                    value: localization.stringUnit?.value,
                    state: localization.stringUnit?.state,
                    hasVariations: localization.variations != nil
                )
            } else {
                throw XCStringsError.languageNotFound(language: lang, key: key)
            }
        } else {
            if let localizations = entry.localizations {
                for (lang, localization) in localizations {
                    result[lang] = TranslationInfo(
                        key: key,
                        language: lang,
                        value: localization.stringUnit?.value,
                        state: localization.stringUnit?.state,
                        hasVariations: localization.variations != nil
                    )
                }
            }
        }

        return result
    }

    /// Check if a key exists
    func checkKey(_ key: String, language: String?) -> Bool {
        guard let entry = file.strings[key] else {
            return false
        }

        if let lang = language {
            return entry.localizations?[lang] != nil
        }

        return true
    }

    /// Check coverage for a key
    func checkCoverage(_ key: String) throws -> CoverageInfo {
        let allLanguages = listLanguages()

        guard let entry = file.strings[key] else {
            throw XCStringsError.keyNotFound(key: key)
        }

        let translatedLanguages = entry.localizations?.keys.sorted() ?? []
        let missingLanguages = allLanguages.filter { !translatedLanguages.contains($0) }
        let coveragePercent = allLanguages.isEmpty ? 0 : Double(translatedLanguages.count) / Double(allLanguages.count) * 100

        return CoverageInfo(
            key: key,
            translatedLanguages: translatedLanguages,
            missingLanguages: missingLanguages,
            coveragePercent: coveragePercent
        )
    }
}
