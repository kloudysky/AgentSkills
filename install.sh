#!/usr/bin/env bash
# Symlinks ~/.claude/skills to this repo's skills/ directory so every machine
# shares one set of global Claude skills. Safe to re-run; backs up any existing
# real directory before replacing it.
set -euo pipefail

REPO_SKILLS="$(cd "$(dirname "$0")/skills" && pwd)"
TARGET="$HOME/.claude/skills"

mkdir -p "$HOME/.claude"

if [ -L "$TARGET" ]; then
  if [ "$(readlink "$TARGET")" = "$REPO_SKILLS" ]; then
    echo "Already installed: $TARGET -> $REPO_SKILLS"
    exit 0
  fi
  rm "$TARGET"
elif [ -d "$TARGET" ]; then
  BACKUP="$TARGET.backup.$(date +%Y%m%d%H%M%S)"
  mv "$TARGET" "$BACKUP"
  echo "Backed up existing skills to $BACKUP"
fi

ln -s "$REPO_SKILLS" "$TARGET"
echo "Installed: $TARGET -> $REPO_SKILLS"
