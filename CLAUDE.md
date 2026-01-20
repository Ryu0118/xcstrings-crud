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
- `XCStringsCLI/` - CLI commands using ArgumentParser
- `XCStringsMCP/` - MCP server using swift-sdk
- `xcstrings-crud/` - CLI entry point
- `xcstrings-crud-mcp/` - MCP entry point

## Code Style

- Swift 6.0 with strict concurrency
- Use `async/await` for async operations
- Errors defined in `Errors.swift`, use `XCStringsError` enum
- All public APIs should have clear parameter names

## Key Files

- `XCStrings.swift` - Data models (`StringCatalog`, `StringUnit`, etc.)
- `XCStringsParser.swift` - Facade for file operations
- `XCStringsReader.swift` - Read operations (list, get, check)
- `XCStringsWriter.swift` - Write operations (add, update, delete, rename)
- `XCStringsStatsCalculator.swift` - Coverage and progress stats

## Testing

```bash
swift test --filter XCStringsKitTests  # Run specific test target
```

Tests use fixture-based approach. See `TestFixtures.swift` for test data generation.
