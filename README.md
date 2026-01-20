# xcstrings-crud

CLI tool and MCP server for CRUD operations on xcstrings (String Catalog) files.

## Motivation

Large xcstrings files can contain thousands of localization keys across multiple languages, resulting in massive JSON files. When AI assistants (like Claude Code) read these files directly, they consume a significant amount of tokens—potentially exceeding context limits or rapidly depleting token budgets.

This tool provides a **token-efficient** approach by offering targeted CRUD operations:

- **Query only what you need**: Fetch specific keys or languages instead of loading the entire file
- **Incremental updates**: Add or update individual translations without reading the full content
- **Statistics at a glance**: Get coverage and progress summaries without parsing all entries

By using the MCP server or CLI, AI assistants can work with xcstrings files of any size while keeping token usage minimal.

## Installation

### Using Mise

```bash
mise use -g ubi:Ryu0118/xcstrings-crud
```

This installs two binaries: `xcstrings-crud` (CLI) and `xcstrings-crud-mcp` (MCP server).

### Build from source

```bash
git clone https://github.com/Ryu0118/xcstrings-crud.git
cd xcstrings-crud
swift build -c release
```

Binaries will be at `.build/release/xcstrings-crud` and `.build/release/xcstrings-crud-mcp`.

## CLI Usage

### Read Operations

```bash
# List all keys
xcstrings-crud list keys --file path/to/Localizable.xcstrings

# List languages
xcstrings-crud list languages --file path/to/Localizable.xcstrings

# List untranslated keys for a language
xcstrings-crud list untranslated --file path/to/Localizable.xcstrings --lang ja

# Get source language
xcstrings-crud get source-language --file path/to/Localizable.xcstrings

# Get translations for a key
xcstrings-crud get key "Hello" --file path/to/Localizable.xcstrings
xcstrings-crud get key "Hello" --file path/to/Localizable.xcstrings --lang ja

# Check if key exists
xcstrings-crud check key "Hello" --file path/to/Localizable.xcstrings

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

### Configuration

Add to your Claude Code MCP settings:

```json
{
  "mcpServers": {
    "xcstrings-crud-mcp": {
      "command": "xcstrings-crud-mcp"
    }
  }
}
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

## Requirements

- macOS 13+
- Swift 6.0+

## License

MIT
