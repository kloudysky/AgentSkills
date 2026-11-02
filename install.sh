#!/usr/bin/env bash
# Symlinks global skills directories across Claude, Codex, Antigravity, and Grok
# to this repository's skills/ directory so every agent and machine shares one set
# of global skills.
#
# Safe to re-run; backs up any existing real directories before symlinking.
set -euo pipefail

REPO_SKILLS="$(cd "$(dirname "$0")/skills" && pwd)"

echo "=== Installing AgentSkills ==="
echo "Source: $REPO_SKILLS"
echo ""

# Standard target directories to symlink directly to $REPO_SKILLS
TARGETS=(
  # Claude Code
  "$HOME/.claude/skills"

  # Universal Agent Skills standard (Codex, Antigravity, Grok, etc.)
  "$HOME/.agents/skills"

  # xAI Grok
  "$HOME/.grok/skills"

  # Google Antigravity & Gemini CLI / IDE
  "$HOME/.gemini/skills"
  "$HOME/.gemini/antigravity-cli/skills"
  "$HOME/.gemini/config/skills"
  "$HOME/.gemini/antigravity/skills"
)

link_target() {
  local target="$1"
  local parent
  parent="$(dirname "$target")"

  mkdir -p "$parent"

  if [ -L "$target" ]; then
    local current_link
    current_link="$(readlink "$target")"
    if [ "$current_link" = "$REPO_SKILLS" ]; then
      echo "  [OK] Already linked: $target -> $REPO_SKILLS"
      return 0
    fi
    echo "  [UPDATE] Updating symlink: $target (was $current_link)"
    rm "$target"
  elif [ -d "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "  [BACKUP] Backed up existing directory to $backup"
  fi

  ln -s "$REPO_SKILLS" "$target"
  echo "  [LINKED] $target -> $REPO_SKILLS"
}

for target in "${TARGETS[@]}"; do
  link_target "$target"
done

# Handle ~/.codex/skills specially:
# Codex stores built-in system skills in ~/.codex/skills/.system, while also
# scanning ~/.agents/skills.
CODEX_TARGET="$HOME/.codex/skills"
if [ -L "$CODEX_TARGET" ]; then
  link_target "$CODEX_TARGET"
elif [ -d "$CODEX_TARGET" ]; then
  if [ -d "$CODEX_TARGET/.system" ]; then
    echo "  [PRESERVED] $CODEX_TARGET/.system preserved."
    echo "  Codex discovers all repo skills via $HOME/.agents/skills."
    # Also link individual skills into ~/.codex/skills if not present
    for skill_path in "$REPO_SKILLS"/*; do
      if [ -d "$skill_path" ]; then
        skill_name="$(basename "$skill_path")"
        [ "$skill_name" = "synced" ] && continue
        [ "$skill_name" = ".system" ] && continue
        
        target_skill="$CODEX_TARGET/$skill_name"
        if [ ! -e "$target_skill" ]; then
          ln -s "$skill_path" "$target_skill"
          echo "    [LINKED] $target_skill -> $skill_path"
        fi
      fi
    done
  else
    link_target "$CODEX_TARGET"
  fi
else
  link_target "$CODEX_TARGET"
fi

echo ""
echo "=== AgentSkills installation complete! ==="
