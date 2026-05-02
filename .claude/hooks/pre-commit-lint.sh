#!/bin/sh
INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')
printf '%s' "$COMMAND" | grep -q '^git commit' || exit 0

SRCROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
SWIFTFORMAT="$SRCROOT/.nest/bin/swiftformat"
SWIFTLINT="$SRCROOT/.nest/bin/swiftlint"

STAGED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)
[ -n "$STAGED_SWIFT_FILES" ] || exit 0

if [ -x "$SWIFTFORMAT" ] && [ -f "$SRCROOT/.swiftformat" ]; then
  printf '%s\n' "$STAGED_SWIFT_FILES" | xargs "$SWIFTFORMAT" --cache ignore --config "$SRCROOT/.swiftformat"
  printf '%s\n' "$STAGED_SWIFT_FILES" | xargs git add
fi

if [ ! -x "$SWIFTLINT" ] || [ ! -f "$SRCROOT/.swiftlint.yml" ]; then
  exit 0
fi

ABSOLUTE_FILES=""
for file in $STAGED_SWIFT_FILES; do
  if [ -f "$SRCROOT/$file" ]; then
    ABSOLUTE_FILES="$ABSOLUTE_FILES $SRCROOT/$file"
  fi
done
[ -n "$ABSOLUTE_FILES" ] || exit 0

# shellcheck disable=SC2086
LINT_OUTPUT=$("$SWIFTLINT" lint --config "$SRCROOT/.swiftlint.yml" --force-exclude --quiet --no-cache $ABSOLUTE_FILES 2>&1) || true
if [ -n "$LINT_OUTPUT" ]; then
  REASON=$(printf '%s' "$LINT_OUTPUT" | jq -Rs .)
  printf '{"decision":"block","reason":%s}\n' "$REASON"
fi

exit 0
