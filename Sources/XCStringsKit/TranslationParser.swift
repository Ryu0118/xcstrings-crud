import Foundation

/// Parses translation input formats
public enum TranslationParser {
    /// Parse "lang:value" format strings into a dictionary
    /// - Parameter inputs: Array of strings in "lang:value" format (e.g., ["ja:こんにちは", "en:Hello"])
    /// - Returns: Dictionary mapping language codes to values
    /// - Throws: `TranslationParseError` if format is invalid
    public static func parse(_ inputs: [String]) throws -> [String: String] {
        try inputs.reduce(into: [:]) { result, input in
            let (lang, value) = try parseSingle(input)
            result[lang] = value
        }
    }

    /// Parse a single "lang:value" format string
    /// - Parameter input: String in "lang:value" format
    /// - Returns: Tuple of (language, value)
    /// - Throws: `TranslationParseError` if format is invalid
    public static func parseSingle(_ input: String) throws -> (language: String, value: String) {
        guard let colonIndex = input.firstIndex(of: ":") else {
            throw TranslationParseError.invalidFormat(input)
        }
        let lang = String(input[..<colonIndex])
        let value = String(input[input.index(after: colonIndex)...])

        guard !lang.isEmpty else {
            throw TranslationParseError.emptyLanguage(input)
        }

        return (lang, value)
    }

    /// Parse JSON string into a translations dictionary
    /// - Parameter jsonString: JSON string in format `{"lang": "value", ...}`
    /// - Returns: Dictionary mapping language codes to values
    /// - Throws: `TranslationParseError.invalidJSON` if JSON is invalid
    public static func parseJSON(_ jsonString: String) throws -> [String: String] {
        guard let data = jsonString.data(using: .utf8) else {
            throw TranslationParseError.invalidJSON(jsonString)
        }
        guard let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            throw TranslationParseError.invalidJSON(jsonString)
        }
        return dict
    }
}

/// Errors that can occur when parsing translation input
public enum TranslationParseError: Error, LocalizedError, Equatable {
    case invalidFormat(String)
    case emptyLanguage(String)
    case invalidJSON(String)

    public var errorDescription: String? {
        switch self {
        case .invalidFormat(let input):
            return "Invalid translation format: '\(input)'. Expected 'lang:value'"
        case .emptyLanguage(let input):
            return "Empty language code in: '\(input)'"
        case .invalidJSON(let input):
            return "Invalid JSON format: '\(input)'. Expected '{\"lang\": \"value\", ...}'"
        }
    }
}
