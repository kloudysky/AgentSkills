# AgentSkills

Global agent skills shared across **Claude Code**, **OpenAI Codex**, **Google Antigravity**, and **xAI Grok**.

All skills live in `skills/`. Running `./install.sh` symlinks the standard configuration directories for each supported agent environment to `skills/`, providing a single source of truth across all tools and machines.

## Supported Agents & Locations

| Agent | Discovery Paths Linked |
| :--- | :--- |
| **Claude Code** | `~/.claude/skills` |
| **OpenAI Codex** | `~/.agents/skills` (open standard) & `~/.codex/skills` |
| **Google Antigravity** | `~/.agents/skills`, `~/.gemini/skills`, `~/.gemini/antigravity-cli/skills`, `~/.gemini/config/skills`, `~/.gemini/antigravity/skills` |
| **xAI Grok** | `~/.agents/skills`, `~/.grok/skills`, `~/.claude/skills` |

## Quick Start on Any Machine (Mac or Linux)

```bash
git clone git@github.com:kloudysky/AgentSkills.git ~/Code/AgentSkills
cd ~/Code/AgentSkills
./install.sh
```

The installer:
- Symlinks all agent paths directly to `skills/`.
- Preserves existing system skills (such as `~/.codex/skills/.system`).
- Backs up any existing real directories (appended with `.backup.<timestamp>`), never overwriting uncommitted local files.

## Keeping Machines in Sync

Because each agent directory is a symlink directly into this repository:
1. When you edit or add a skill, commit and push to GitHub:
   ```bash
   git add skills/<skill-name>
   git commit -m "Add <skill-name>"
   git push
   ```
2. On any other machine (local or remote), simply pull:
   ```bash
   cd ~/Code/AgentSkills
   git pull
   # or run:
   ./sync.sh
   ```
   All four agents immediately see the changes without needing a re-install.

## Adding a New Skill

Create a new directory under `skills/<name>/` with a `SKILL.md`:

```markdown
---
name: my-skill
description: Concise description of when and why an agent should activate this skill.
---

# My Skill

Instructions for the agent...
```
