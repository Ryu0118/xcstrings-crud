# xcstrings-crud

CLI and MCP server for xcstrings (String Catalog) CRUD operations.

## Build & Test

```bash
swift build           # Build all targets
swift test            # Run all tests
swift build -c release # Release build
```

## Architecture

- `XCStringsKit/` - Core library (models, parser, reader, writer, stats)
- `XCStringsCLI/` - CLI commands using ArgumentParser (includes MCP subcommand)
- `XCStringsMCP/` - MCP server using swift-sdk
- `xcstrings-crud/` - CLI entry point (`xcstrings-crud mcp` for MCP server)

## Code Style

- Swift 6.0 with strict concurrency
- Use `async/await` for async operations
- Errors defined in `Errors.swift`, use `XCStringsError` enum
- All public APIs should have clear parameter names

## Key Files

- `XCStrings.swift` - Data models (`StringCatalog`, `StringUnit`, Xcode metadata fields, etc.)
- `XCStringsParser.swift` - Facade for file operations
- `XCStringsReader.swift` - Read operations (list, get, check), including key metadata and `shouldTranslate == false` handling for untranslated lists and per-key coverage
- `XCStringsWriter.swift` - Write operations (add, update, delete, rename)
- `XCStringsFileEncoder.swift` - Deterministic xcstrings JSON encoding with Xcode-like key order
- `XCStringsKeySorter.swift` - Xcode-like natural sorting for string catalog keys
- `XCStringsStatsCalculator.swift` - Coverage and progress stats; non-translatable keys are excluded from language totals

## Testing

```bash
swift test --filter XCStringsKitTests  # Run specific test target
```

Tests use fixture-based approach. See `TestFixtures.swift` for test data generation.
