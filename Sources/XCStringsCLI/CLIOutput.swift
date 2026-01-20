import Foundation

/// CLI output utilities
public enum CLIOutput {
    /// Encode and print a value as JSON
    /// - Parameters:
    ///   - value: The value to encode
    ///   - pretty: Whether to use pretty-printed formatting
    public static func printJSON<T: Encodable>(_ value: T, pretty: Bool) throws {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        let data = try encoder.encode(value)
        if let json = String(data: data, encoding: .utf8) {
            print(json)
        }
    }
}
