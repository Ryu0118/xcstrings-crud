import Foundation
import XCStringsCLI

@main
@available(macOS 13.0, *)
struct XCStringsCRUDMain {
    static func main() async throws {
        await XCStringsCLI.main()
    }
}
