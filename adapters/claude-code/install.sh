#!/usr/bin/env bash
# Install the expert-panel skill for every Claude Code project on this machine.
# Target: $CLAUDE_SKILLS_DIR (default ~/.claude/skills). Idempotent: re-run after editing the skill.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/expert-panel"
mkdir -p "$(dirname "$dest")"
if [ -e "$dest" ] && [ ! -f "$dest/SKILL.md" ]; then
  echo "refusing to replace $dest: not a skill directory" >&2; exit 1
fi
rm -rf "$dest"
cp -r "$here/expert-panel" "$dest"
echo "installed $dest"
echo "skills are discovered when a session starts: restart any running session before invoking /expert-panel"
echo "adopt the framework in a project: $here/../../adopt.sh <project-dir>"
