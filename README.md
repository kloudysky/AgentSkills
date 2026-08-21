# AgentSkills

My global Claude Code skills. `~/.claude/skills` is a symlink into this repo, so editing a skill here updates it everywhere and `git pull` syncs machines.

## Install on a new machine

```sh
git clone git@github.com:kloudysky/AgentSkills.git
cd AgentSkills
./install.sh
```

The script symlinks `~/.claude/skills` to `skills/` in this repo. Any existing skills directory is backed up, not deleted.

## Adding or editing a skill

Edit under `skills/<name>/SKILL.md`, then commit and push. Other machines pick it up with `git pull`.
