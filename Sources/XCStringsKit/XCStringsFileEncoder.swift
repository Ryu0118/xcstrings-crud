import Foundation

enum XCStringsFileEncoder {
    static func encode(_ file: XCStringsFile) throws -> Data {
        let strings = try XCStringsKeySorter.sort(file.strings.keys).map { key in
            guard var entry = file.strings[key] else {
                throw EncodingError.invalidValue(
                    key,
                    EncodingError.Context(codingPath: [], debugDescription: "Missing string entry for key \(key)")
                )
            }

            // xcstringstool omits an empty `localizations` object entirely, the same as when
            // it's nil (e.g. after deleting a key's last language). Match that.
            if entry.localizations?.isEmpty == true {
                entry.localizations = nil
            }

            return try JSONMember(key: key, value: encodeJSONValue(entry))
        }

        let root = JSONValue.object([
            JSONMember(key: "sourceLanguage", value: .string(file.sourceLanguage)),
            JSONMember(key: "strings", value: .object(strings)),
            JSONMember(key: "version", value: .string(file.version)),
        ])

        // xcstringstool does not append a trailing newline.
        return Data(root.render().utf8)
    }

    private static func encodeJSONValue(_ value: some Encodable) throws -> JSONValue {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        let object = try JSONSerialization.jsonObject(with: data)
        return try JSONValue(jsonObject: object)
    }
}

private struct JSONMember {
    let key: String
    let value: JSONValue
}

private enum JSONValue {
    case object([JSONMember])
    case array([JSONValue])
    case string(String)
    case number(String)
    case bool(Bool)
    case null

    init(jsonObject: Any) throws {
        switch jsonObject {
        case let object as [String: Any]:
            self = try .object(object.keys.sorted(by: XCStringsKeySorter.areInIncreasingOrder).map { key in
                try JSONMember(key: key, value: JSONValue(jsonObject: object[key] as Any))
            })
        case let array as [Any]:
            self = try .array(array.map { try JSONValue(jsonObject: $0) })
        case let string as String:
            self = .string(string)
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .bool(number.boolValue)
            } else {
                self = .number(number.stringValue)
            }
        case _ as NSNull:
            self = .null
        default:
            throw EncodingError.invalidValue(
                jsonObject,
                EncodingError.Context(codingPath: [], debugDescription: "Unsupported JSON value \(jsonObject)")
            )
        }
    }

    func render(indentation: Int = 0) -> String {
        switch self {
        case let .object(members):
            guard !members.isEmpty else {
                // Matches xcstringstool: an open brace, a blank line, then a closing
                // brace on its own line at the object's own indentation.
                return "{\n\n\(String.spaces(indentation))}"
            }

            let childIndentation = indentation + 2
            let lines = members.map { member in
                "\(String.spaces(childIndentation))\(member.key.jsonEscaped()) : \(member.value.render(indentation: childIndentation))"
            }
            return "{\n\(lines.joined(separator: ",\n"))\n\(String.spaces(indentation))}"
        case let .array(values):
            guard !values.isEmpty else {
                return "[]"
            }

            let childIndentation = indentation + 2
            let lines = values.map { value in
                "\(String.spaces(childIndentation))\(value.render(indentation: childIndentation))"
            }
            return "[\n\(lines.joined(separator: ",\n"))\n\(String.spaces(indentation))]"
        case let .string(string):
            return string.jsonEscaped()
        case let .number(number):
            return number
        case let .bool(bool):
            return bool ? "true" : "false"
        case .null:
            return "null"
        }
    }
}

private extension String {
    static func spaces(_ count: Int) -> String {
        String(repeating: " ", count: count)
    }

    func jsonEscaped() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        let data = try? encoder.encode(self)
        return data.flatMap { String(bytes: $0, encoding: .utf8) } ?? "\"\""
    }
}
