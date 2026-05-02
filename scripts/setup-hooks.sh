#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

if [ ! -d "$REPO_ROOT/.githooks" ]; then
  echo "Error: .githooks not found at $REPO_ROOT/.githooks"
  exit 1
fi

git config --local core.hooksPath .githooks
chmod +x "$REPO_ROOT/.githooks/"*

if [ -d "$REPO_ROOT/.codex/hooks" ]; then
  chmod +x "$REPO_ROOT/.codex/hooks/"*
fi

if [ -d "$REPO_ROOT/.claude/hooks" ]; then
  chmod +x "$REPO_ROOT/.claude/hooks/"*
fi

echo "core.hooksPath=.githooks"
