#!/bin/sh
INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')
printf '%s' "$FILE_PATH" | grep -q '\.swift$' || exit 0

SRCROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
if [ ! -f "$FILE_PATH" ] && [ -f "$SRCROOT/$FILE_PATH" ]; then
  FILE_PATH="$SRCROOT/$FILE_PATH"
fi
[ -f "$FILE_PATH" ] || exit 0

ALL_REASONS=""
SWIFTFORMAT="$SRCROOT/.nest/bin/swiftformat"
SWIFTLINT="$SRCROOT/.nest/bin/swiftlint"

if [ -x "$SWIFTFORMAT" ] && [ -f "$SRCROOT/.swiftformat" ]; then
  "$SWIFTFORMAT" --cache ignore --config "$SRCROOT/.swiftformat" "$FILE_PATH" 2>/dev/null || true
fi

if [ -x "$SWIFTLINT" ] && [ -f "$SRCROOT/.swiftlint.yml" ]; then
  LINT_OUTPUT=$("$SWIFTLINT" lint --config "$SRCROOT/.swiftlint.yml" --force-exclude --quiet --no-cache "$FILE_PATH" 2>&1) || true
  if [ -n "$LINT_OUTPUT" ]; then
    ALL_REASONS="${ALL_REASONS}${LINT_OUTPUT}\n"
  fi
fi

if [ -n "$ALL_REASONS" ]; then
  REASON=$(printf '%b' "$ALL_REASONS" | jq -Rs .)
  printf '{"decision":"block","reason":%s}\n' "$REASON"
fi

exit 0
