#!/bin/sh
SRCROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
CONFIG="$SRCROOT/docsync.yml"
DOCSYNC="$SRCROOT/.nest/bin/docsync"

[ -f "$CONFIG" ] || exit 0
[ -x "$DOCSYNC" ] || exit 0

OUTPUT=$("$DOCSYNC" check --codex-hook --config "$CONFIG" 2>/dev/null)
[ -n "$OUTPUT" ] && printf '%s\n' "$OUTPUT"
exit 0
