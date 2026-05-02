import Foundation

enum XCStringsFileEncoder {
    static func encode(_ file: XCStringsFile) throws -> Data {
        let strings = try XCStringsKeySorter.sort(file.strings.keys).map { key in
            guard let entry = file.strings[key] else {
                throw EncodingError.invalidValue(
                    key,
                    EncodingError.Context(codingPath: [], debugDescription: "Missing string entry for key \(key)")
                )
            }

            return JSONMember(key: key, value: try encodeJSONValue(entry))
        }

        let root = JSONValue.object([
            JSONMember(key: "sourceLanguage", value: .string(file.sourceLanguage)),
            JSONMember(key: "strings", value: .object(strings)),
            JSONMember(key: "version", value: .string(file.version)),
        ])

        return Data((root.render() + "\n").utf8)
    }

    private static func encodeJSONValue<T: Encodable>(_ value: T) throws -> JSONValue {
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
            self = .object(try object.keys.sorted().map { key in
                JSONMember(key: key, value: try JSONValue(jsonObject: object[key] as Any))
            })
        case let array as [Any]:
            self = .array(try array.map { try JSONValue(jsonObject: $0) })
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
        case .object(let members):
            guard !members.isEmpty else {
                return "{}"
            }

            let childIndentation = indentation + 2
            let lines = members.map { member in
                "\(String.spaces(childIndentation))\(member.key.jsonEscaped()) : \(member.value.render(indentation: childIndentation))"
            }
            return "{\n\(lines.joined(separator: ",\n"))\n\(String.spaces(indentation))}"
        case .array(let values):
            guard !values.isEmpty else {
                return "[]"
            }

            let childIndentation = indentation + 2
            let lines = values.map { value in
                "\(String.spaces(childIndentation))\(value.render(indentation: childIndentation))"
            }
            return "[\n\(lines.joined(separator: ",\n"))\n\(String.spaces(indentation))]"
        case .string(let string):
            return string.jsonEscaped()
        case .number(let number):
            return number
        case .bool(let bool):
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
        let data = try? JSONEncoder().encode(self)
        return data.map { String(decoding: $0, as: UTF8.self) } ?? "\"\""
    }
}
