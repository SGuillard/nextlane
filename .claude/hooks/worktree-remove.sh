#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')

# Remove symlinks before worktree removal
rm -f "$WORKTREE_PATH/node_modules"

git -C "$CLAUDE_PROJECT_DIR" worktree remove "$WORKTREE_PATH" --force >/dev/null 2>&1 || true
