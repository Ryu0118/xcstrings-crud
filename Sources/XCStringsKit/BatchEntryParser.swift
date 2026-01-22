import Foundation

/// Parser for batch entry format
package enum BatchEntryParser {
    /// Parse "key=lang:value,lang:value" format
    /// Example: "Hello=ja:こんにちは,en:Hello"
    package static func parse(_ input: String) throws -> BatchTranslationEntry {
        guard let equalsIndex = input.firstIndex(of: "=") else {
            throw BatchEntryParseError.invalidFormat(input)
        }

        let key = String(input[..<equalsIndex])
        let translationsStr = String(input[input.index(after: equalsIndex)...])

        guard !key.isEmpty else {
            throw BatchEntryParseError.emptyKey(input)
        }

        // Parse translations (comma-separated lang:value pairs)
        let translations = try translationsStr
            .split(separator: ",", omittingEmptySubsequences: false)
            .reduce(into: [String: String]()) { result, pair in
                let pairStr = String(pair)
                guard let colonIndex = pairStr.firstIndex(of: ":") else {
                    throw BatchEntryParseError.invalidTranslationFormat(pairStr)
                }

                let lang = String(pairStr[..<colonIndex])
                let value = String(pairStr[pairStr.index(after: colonIndex)...])

                guard !lang.isEmpty else {
                    throw BatchEntryParseError.emptyLanguage(pairStr)
                }

                result[lang] = value
            }

        if translations.isEmpty {
            throw BatchEntryParseError.noTranslations(input)
        }

        return BatchTranslationEntry(key: key, translations: translations)
    }
}

/// Errors for batch entry parsing
package enum BatchEntryParseError: Error, LocalizedError {
    case invalidFormat(String)
    case emptyKey(String)
    case invalidTranslationFormat(String)
    case emptyLanguage(String)
    case noTranslations(String)

    package var errorDescription: String? {
        switch self {
        case .invalidFormat(let input):
            return "Invalid batch entry format: '\(input)'. Expected 'key=lang:value,lang:value'"
        case .emptyKey(let input):
            return "Empty key in: '\(input)'"
        case .invalidTranslationFormat(let input):
            return "Invalid translation format: '\(input)'. Expected 'lang:value'"
        case .emptyLanguage(let input):
            return "Empty language code in: '\(input)'"
        case .noTranslations(let input):
            return "No translations specified for: '\(input)'"
        }
    }
}
