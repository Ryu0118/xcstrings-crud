import Foundation

/// Facade for xcstrings file operations
/// Delegates to specialized components following Single Responsibility Principle
package actor XCStringsParser {
    private let fileHandler: XCStringsFileHandler

    package init(path: String) {
        self.fileHandler = XCStringsFileHandler(path: path)
    }

    // MARK: - File Operations

    /// Load file from disk
    func load() throws -> XCStringsFile {
        try fileHandler.load()
    }

    /// Save file to disk
    func save(_ file: XCStringsFile) throws {
        try fileHandler.save(file)
    }

    // MARK: - Read Operations

    /// Get all keys sorted alphabetically
    package func listKeys() throws -> [String] {
        let file = try load()
        return XCStringsReader(file: file).listKeys()
    }

    /// Get all languages used in the file
    package func listLanguages() throws -> [String] {
        let file = try load()
        return XCStringsReader(file: file).listLanguages()
    }

    /// Get untranslated keys for a specific language
    package func listUntranslated(for language: String) throws -> [String] {
        let file = try load()
        return XCStringsReader(file: file).listUntranslated(for: language)
    }

    /// Get source language
    package func getSourceLanguage() throws -> String {
        let file = try load()
        return XCStringsReader(file: file).getSourceLanguage()
    }

    /// Get key information
    package func getKey(_ key: String) throws -> KeyInfo {
        let file = try load()
        return try XCStringsReader(file: file).getKey(key)
    }

    /// Get translation for a key
    package func getTranslation(key: String, language: String?) throws -> [String: TranslationInfo] {
        let file = try load()
        return try XCStringsReader(file: file).getTranslation(key: key, language: language)
    }

    /// Check if a key exists
    package func checkKey(_ key: String, language: String?) throws -> Bool {
        let file = try load()
        return XCStringsReader(file: file).checkKey(key, language: language)
    }

    /// Check coverage for a key
    package func checkCoverage(_ key: String) throws -> CoverageInfo {
        let file = try load()
        return try XCStringsReader(file: file).checkCoverage(key)
    }

    // MARK: - Stats Operations

    /// Get overall statistics
    package func getStats() throws -> StatsInfo {
        let file = try load()
        return XCStringsStatsCalculator(file: file).getStats()
    }

    /// Get progress for a specific language
    package func getProgress(for language: String) throws -> LanguageStats {
        let file = try load()
        return try XCStringsStatsCalculator(file: file).getProgress(for: language)
    }

    // MARK: - Write Operations

    /// Add a translation
    package func addTranslation(key: String, language: String, value: String, allowOverwrite: Bool = false) throws {
        let file = try load()
        let updated = try XCStringsWriter.addTranslation(to: file, key: key, language: language, value: value, allowOverwrite: allowOverwrite)
        try save(updated)
    }

    /// Add translations for multiple languages
    package func addTranslations(key: String, translations: [String: String], allowOverwrite: Bool = false) throws {
        let file = try load()
        let updated = try XCStringsWriter.addTranslations(to: file, key: key, translations: translations, allowOverwrite: allowOverwrite)
        try save(updated)
    }

    /// Update an existing translation
    package func updateTranslation(key: String, language: String, value: String) throws {
        let file = try load()
        let updated = try XCStringsWriter.updateTranslation(in: file, key: key, language: language, value: value)
        try save(updated)
    }

    /// Update translations for multiple languages
    package func updateTranslations(key: String, translations: [String: String]) throws {
        let file = try load()
        let updated = try XCStringsWriter.updateTranslations(in: file, key: key, translations: translations)
        try save(updated)
    }

    /// Rename a key
    package func renameKey(from oldKey: String, to newKey: String) throws {
        let file = try load()
        let updated = try XCStringsWriter.renameKey(in: file, from: oldKey, to: newKey)
        try save(updated)
    }

    // MARK: - Delete Operations

    /// Delete a key entirely
    package func deleteKey(_ key: String) throws {
        let file = try load()
        let updated = try XCStringsWriter.deleteKey(from: file, key: key)
        try save(updated)
    }

    /// Delete a translation for a specific language
    package func deleteTranslation(key: String, language: String) throws {
        let file = try load()
        let updated = try XCStringsWriter.deleteTranslation(from: file, key: key, language: language)
        try save(updated)
    }

    /// Delete translations for multiple languages
    package func deleteTranslations(key: String, languages: [String]) throws {
        let file = try load()
        let updated = try XCStringsWriter.deleteTranslations(from: file, key: key, languages: languages)
        try save(updated)
    }
}
