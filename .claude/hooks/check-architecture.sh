#!/bin/sh
INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')
NEW_CONTENT=$(printf '%s' "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

printf '%s' "$FILE_PATH" | grep -q '\.swift$' || exit 0

if printf '%s' "$NEW_CONTENT" | grep -q 'swiftlint:disable'; then
  jq -n '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "swiftlint:disable is not allowed. Fix the underlying lint violation instead."
    }
  }'
fi

exit 0
