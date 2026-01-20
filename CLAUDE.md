# xcstrings-crud

CLI tool and MCP server for CRUD operations on xcstrings (String Catalog) files.

## Installation

### Using Mise (recommended)

```toml
# mise.toml
[tools]
xcstrings-crud = { version = "0.1.0", url = "https://github.com/Ryu0118/xcstrings-crud", path = "mise-plugin" }
```

Then run:

```bash
mise install
```

This installs both `xcstrings-crud` and `xcstrings-crud-mcp` commands.

### Using SPM directly

```bash
mise use spm:Ryu0118/xcstrings-crud@0.1.0
```

### Build from source

```bash
cd xcstrings-crud
swift build -c release
```

## CLI Usage

### Read Operations

```bash
# List all keys
xcstrings-crud list keys --file path/to/Localizable.xcstrings

# List languages
xcstrings-crud list languages --file path/to/Localizable.xcstrings

# List untranslated keys
xcstrings-crud list untranslated --file path/to/Localizable.xcstrings --lang ja

# Get source language
xcstrings-crud get source-language --file path/to/Localizable.xcstrings

# Get translations for a key
xcstrings-crud get key "Hello" --file path/to/Localizable.xcstrings
xcstrings-crud get key "Hello" --file path/to/Localizable.xcstrings --lang ja

# Check if key exists
xcstrings-crud check key "Hello" --file path/to/Localizable.xcstrings
xcstrings-crud check key "Hello" --file path/to/Localizable.xcstrings --lang ja

# Check key coverage
xcstrings-crud check coverage "Hello" --file path/to/Localizable.xcstrings

# Get overall statistics
xcstrings-crud stats coverage --file path/to/Localizable.xcstrings

# Get progress for a language
xcstrings-crud stats progress --file path/to/Localizable.xcstrings --lang ja
```

### Create/Update Operations

```bash
# Add translation (single language)
xcstrings-crud add key "Hello" --file path/to/Localizable.xcstrings --lang ja --value "こんにちは"

# Add translation (multiple languages)
xcstrings-crud add key "Hello" --file path/to/Localizable.xcstrings --translations '{"ja":"こんにちは","en":"Hello"}'

# Update translation
xcstrings-crud update key "Hello" --file path/to/Localizable.xcstrings --lang ja --value "こんにちは！"

# Add or update translation (upsert)
xcstrings-crud upsert key "Hello" --file path/to/Localizable.xcstrings --lang ja --value "こんにちは"

# Rename key
xcstrings-crud rename key "Hello" --file path/to/Localizable.xcstrings --to "Greeting"
```

### Delete Operations

```bash
# Delete entire key
xcstrings-crud delete key "Hello" --file path/to/Localizable.xcstrings

# Delete translation for specific language only
xcstrings-crud delete key "Hello" --file path/to/Localizable.xcstrings --lang ja
```

### Common Options

- `--file <path>`: xcstrings file path (required)
- `--pretty`: Pretty-printed JSON output

## MCP Server

### Start

```bash
xcstrings-crud-mcp
```

### Available Tools

| Tool | Description |
|------|-------------|
| `xcstrings_list_keys` | List all keys |
| `xcstrings_list_languages` | List supported languages |
| `xcstrings_list_untranslated` | List untranslated keys |
| `xcstrings_get_source_language` | Get source language |
| `xcstrings_get_key` | Get translations for a key |
| `xcstrings_check_key` | Check if key exists |
| `xcstrings_check_coverage` | Check key language coverage |
| `xcstrings_stats_coverage` | Get overall coverage statistics |
| `xcstrings_stats_progress` | Get translation progress by language |
| `xcstrings_add_translation` | Add translation |
| `xcstrings_update_translation` | Update translation |
| `xcstrings_upsert_translation` | Add or update translation |
| `xcstrings_rename_key` | Rename key |
| `xcstrings_delete_key` | Delete entire key |
| `xcstrings_delete_translation` | Delete translation for specific language |

## Project Structure

```
xcstrings-crud/
├── Package.swift
├── CLAUDE.md
├── Sources/
│   ├── XCStringsKit/              # Core library
│   │   ├── Models/
│   │   │   └── XCStrings.swift    # Data models
│   │   ├── Errors.swift           # Error definitions
│   │   ├── XCStringsParser.swift  # Parser (facade)
│   │   ├── XCStringsFileHandler.swift  # File I/O
│   │   ├── XCStringsReader.swift  # Read operations
│   │   ├── XCStringsWriter.swift  # Write operations
│   │   └── XCStringsStatsCalculator.swift  # Statistics
│   │
│   ├── XCStringsCLI/              # CLI commands
│   │   ├── XCStringsCLI.swift
│   │   ├── ListCommand.swift
│   │   ├── GetCommand.swift
│   │   ├── CheckCommand.swift
│   │   ├── AddCommand.swift
│   │   ├── UpdateCommand.swift
│   │   ├── UpsertCommand.swift
│   │   ├── DeleteCommand.swift
│   │   ├── RenameCommand.swift
│   │   └── StatsCommand.swift
│   │
│   ├── XCStringsMCP/              # MCP server
│   │   └── MCPServer.swift
│   │
│   ├── xcstrings-crud/            # CLI executable
│   │   └── main.swift
│   │
│   └── xcstrings-crud-mcp/        # MCP executable
│       └── main.swift
│
└── Tests/
    └── XCStringsKitTests/
```
