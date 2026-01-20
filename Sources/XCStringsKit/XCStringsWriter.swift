import Foundation

/// Handles write operations for xcstrings files
enum XCStringsWriter {
    /// Add a translation for a key
    static func addTranslation(
        to file: XCStringsFile,
        key: String,
        language: String,
        value: String,
        allowOverwrite: Bool = false
    ) throws -> XCStringsFile {
        var result = file

        if result.strings[key] == nil {
            result.strings[key] = StringEntry(localizations: [:])
        }

        if !allowOverwrite, result.strings[key]?.localizations?[language] != nil {
            throw XCStringsError.keyAlreadyExists(key: "\(key):\(language)")
        }

        if result.strings[key]?.localizations == nil {
            result.strings[key]?.localizations = [:]
        }

        result.strings[key]?.localizations?[language] = Localization(
            stringUnit: StringUnit(state: "translated", value: value)
        )

        return result
    }

    /// Add translations for multiple languages
    static func addTranslations(
        to file: XCStringsFile,
        key: String,
        translations: [String: String],
        allowOverwrite: Bool = false
    ) throws -> XCStringsFile {
        var result = file

        if result.strings[key] == nil {
            result.strings[key] = StringEntry(localizations: [:])
        }

        if result.strings[key]?.localizations == nil {
            result.strings[key]?.localizations = [:]
        }

        for (language, value) in translations {
            if !allowOverwrite, result.strings[key]?.localizations?[language] != nil {
                throw XCStringsError.keyAlreadyExists(key: "\(key):\(language)")
            }

            result.strings[key]?.localizations?[language] = Localization(
                stringUnit: StringUnit(state: "translated", value: value)
            )
        }

        return result
    }

    /// Update an existing translation
    static func updateTranslation(
        in file: XCStringsFile,
        key: String,
        language: String,
        value: String
    ) throws -> XCStringsFile {
        var result = file

        guard result.strings[key] != nil else {
            throw XCStringsError.keyNotFound(key: key)
        }

        guard result.strings[key]?.localizations?[language] != nil else {
            throw XCStringsError.languageNotFound(language: language, key: key)
        }

        result.strings[key]?.localizations?[language] = Localization(
            stringUnit: StringUnit(state: "translated", value: value)
        )

        return result
    }

    /// Update translations for multiple languages
    static func updateTranslations(
        in file: XCStringsFile,
        key: String,
        translations: [String: String]
    ) throws -> XCStringsFile {
        var result = file

        guard result.strings[key] != nil else {
            throw XCStringsError.keyNotFound(key: key)
        }

        for (language, value) in translations {
            guard result.strings[key]?.localizations?[language] != nil else {
                throw XCStringsError.languageNotFound(language: language, key: key)
            }

            result.strings[key]?.localizations?[language] = Localization(
                stringUnit: StringUnit(state: "translated", value: value)
            )
        }

        return result
    }

    /// Rename a key
    static func renameKey(
        in file: XCStringsFile,
        from oldKey: String,
        to newKey: String
    ) throws -> XCStringsFile {
        var result = file

        guard let entry = result.strings[oldKey] else {
            throw XCStringsError.keyNotFound(key: oldKey)
        }

        if result.strings[newKey] != nil {
            throw XCStringsError.keyAlreadyExists(key: newKey)
        }

        result.strings[newKey] = entry
        result.strings.removeValue(forKey: oldKey)

        return result
    }

    /// Delete a key entirely
    static func deleteKey(
        from file: XCStringsFile,
        key: String
    ) throws -> XCStringsFile {
        var result = file

        guard result.strings[key] != nil else {
            throw XCStringsError.keyNotFound(key: key)
        }

        result.strings.removeValue(forKey: key)

        return result
    }

    /// Delete a translation for a specific language
    static func deleteTranslation(
        from file: XCStringsFile,
        key: String,
        language: String
    ) throws -> XCStringsFile {
        var result = file

        guard result.strings[key] != nil else {
            throw XCStringsError.keyNotFound(key: key)
        }

        guard result.strings[key]?.localizations?[language] != nil else {
            throw XCStringsError.languageNotFound(language: language, key: key)
        }

        result.strings[key]?.localizations?.removeValue(forKey: language)

        return result
    }

    /// Delete translations for multiple languages
    static func deleteTranslations(
        from file: XCStringsFile,
        key: String,
        languages: [String]
    ) throws -> XCStringsFile {
        var result = file

        guard result.strings[key] != nil else {
            throw XCStringsError.keyNotFound(key: key)
        }

        for language in languages {
            guard result.strings[key]?.localizations?[language] != nil else {
                throw XCStringsError.languageNotFound(language: language, key: key)
            }

            result.strings[key]?.localizations?.removeValue(forKey: language)
        }

        return result
    }
}
