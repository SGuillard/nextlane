#!/bin/bash

# Block commits directly on main branch
# Enforces the rule: always use feature branches and PRs
# Official format: reads JSON from stdin

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract command from JSON using jq
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# If jq failed or command is empty, allow
if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only check commands that contain git commit (handles "git add && git commit")
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# Get current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# If we couldn't get the branch name, allow (don't block on git errors)
if [ -z "$BRANCH" ]; then
  exit 0
fi

# Block if on main or master branch
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "❌ Blocked: Cannot commit directly to $BRANCH branch" >&2
  echo "💡 Create a feature branch first:" >&2
  echo "   git checkout -b feature/<description>" >&2
  exit 2
fi

exit 0
