#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT=$(git rev-parse --show-toplevel)
git config --local core.hooksPath .githooks
chmod +x "$REPO_ROOT/.githooks/"*
echo "core.hooksPath=.githooks"
