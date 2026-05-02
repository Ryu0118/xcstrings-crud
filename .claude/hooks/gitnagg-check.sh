#!/bin/sh
SRCROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
GITNAGG="$SRCROOT/.nest/bin/gitnagg"

[ -f "$SRCROOT/.gitnagg.yml" ] || exit 0
[ -x "$GITNAGG" ] || exit 0

"$GITNAGG" check --config "$SRCROOT/.gitnagg.yml" --claude-hook
