# AgentSkills

Global agent skills shared across **Claude Code**, **OpenAI Codex**, **Google Antigravity**, and **xAI Grok**.

All skills live in `skills/`. Running `./install.sh` symlinks the standard configuration directories for each supported agent environment to `skills/`, providing a single source of truth across all tools and machines.

## Skills

### T-Stack Autonomous Engineering Skills ([tstack](https://github.com/t3dotgg/tstack))

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching: proves it, reviews it, files it, babysits it, merges it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for you to merge. |
| `council` | "council" | Gets review from three models from different providers, and loops until they agree. |
| `sol-loop` | "sol loop" | Reviews a change with GPT Sol in a loop until both agents agree. |
| `file-pr` | "file a PR" | Files a short PR that leads with the problem, not an inventory of changes. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or agent thread, and keeps their credit. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots (`watch_pull_request` in T3 Code, `pr-wait` CLI everywhere else), and fixes real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides if it should still exist. |
| `leaving-pr-comments` | (automatic) | Formats comments that an agent posts on your behalf. |

### Domain & Platform Skills

- **Clerk**: `clerk`, `clerk-backend-api`, `clerk-cli`, `clerk-custom-ui`, `clerk-nextjs-patterns`, `clerk-setup`, `clerk-testing`, `clerk-webhooks`
- **Convex**: `convex-docs`, `convex-verify`, `convex-deploy-guard`
- **Utility**: `file-upload`, `grilling`, `grill-me`, `handoff`, `html-communication`, `improve-codebase-architecture`, `postplan-read`, `unslop`, `writing-for-agents`

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
- Backs up any existing real directories (`.backup.<timestamp>`), never overwriting uncommitted local files.

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
   ./sync.sh
   ```
   All four agents immediately see the changes without needing a re-install.

## Staying Current with tstack

`sync-tstack.sh` runs daily on one machine (cloud-ubuntu, 5:15 AM Chicago). It applies upstream changes under `skills/` from [tstack](https://github.com/t3dotgg/tstack) and pushes them straight to `main`, with no review. Local edits to those skills are kept through a 3-way merge. On a conflict it applies nothing and retries the next day, so check `~/.local/state/tstack-sync/cron.log` there if updates stop. Other machines get the changes through `./sync.sh`.

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
