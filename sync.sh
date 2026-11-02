#!/usr/bin/env bash
# Pulls latest skills from git and ensures all agent symlinks are current.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo "==> Pulling latest skills from git..."
git pull --rebase

echo "==> Ensuring agent symlinks are up to date..."
./install.sh

echo "==> All skills synced and ready across Claude, Codex, Antigravity, and Grok!"
