#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
WORKTREE_NAME=$(echo "$INPUT" | jq -r '.name')
PROJECT_DIR="$CLAUDE_PROJECT_DIR"
WORKTREE_PATH="$PROJECT_DIR/.claude/worktrees/$WORKTREE_NAME"

log() { echo "[worktree-create] $*" >&2; }

log "name=$WORKTREE_NAME path=$WORKTREE_PATH"

# Create the worktree (the hook is responsible for this when WorktreeCreate is configured)
BRANCH_NAME="worktree-$WORKTREE_NAME"

if git -C "$PROJECT_DIR" show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  log "branch exists, reusing"
  git -C "$PROJECT_DIR" worktree add "$WORKTREE_PATH" "$BRANCH_NAME" >/dev/null 2>&1
else
  log "creating new branch"
  git -C "$PROJECT_DIR" worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" >/dev/null 2>&1
fi

# Symlink local env files (except .env.example) from main repo to worktree
ENV_FILES=(
  ".env"
  ".env.local"
  ".env.production.local"
)

for rel_path in "${ENV_FILES[@]}"; do
  src="$PROJECT_DIR/$rel_path"
  dest="$WORKTREE_PATH/$rel_path"
  if [ -f "$src" ] && [ ! -e "$dest" ]; then
    ln -s "$src" "$dest"
    log "symlinked $rel_path"
  fi
done

# Symlink settings.local.json (gitignored, contains personal permissions like bypassPermissions)
SETTINGS_LOCAL="$PROJECT_DIR/.claude/settings.local.json"
if [ -f "$SETTINGS_LOCAL" ] && [ ! -e "$WORKTREE_PATH/.claude/settings.local.json" ]; then
  ln -s "$SETTINGS_LOCAL" "$WORKTREE_PATH/.claude/settings.local.json"
  log "symlinked .claude/settings.local.json"
fi

# Symlink node_modules at root to avoid a fresh npm install
if [ -d "$PROJECT_DIR/node_modules" ] && [ ! -e "$WORKTREE_PATH/node_modules" ]; then
  ln -s "$PROJECT_DIR/node_modules" "$WORKTREE_PATH/node_modules"
  log "symlinked root node_modules"
fi

log "done"
echo "$WORKTREE_PATH"
