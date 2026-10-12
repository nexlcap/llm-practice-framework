#!/usr/bin/env bash
# Install the expert-panel skill for every Claude Code project on this machine.
# Target: $CLAUDE_SKILLS_DIR (default ~/.claude/skills), an absolute path. Idempotent. An existing copy
# that differs from the source is moved aside to <target>.bak.<timestamp>, never deleted; a symlinked
# target is refused. Customisations belong in a project's .claude/skills/expert-panel/, which shadows
# this copy.
set -euo pipefail
[ "${BASH_VERSINFO[0]}" -ge 4 ] || { echo "bash 4 or newer required" >&2; exit 2; }
here="$(cd -- "$(dirname -- "$0")" && pwd)"
base="${CLAUDE_SKILLS_DIR:-}"
if [ -z "$base" ]; then
  [ -n "${HOME:-}" ] || { echo "set HOME or CLAUDE_SKILLS_DIR" >&2; exit 2; }
  base="$HOME/.claude/skills"
fi
case "$base" in /*) ;; *) echo "CLAUDE_SKILLS_DIR must be an absolute path: $base" >&2; exit 2;; esac
src="$here/expert-panel"
dest="$base/expert-panel"
if [ -L "$dest" ]; then
  echo "refusing to replace $dest: it is a symlink; install into its target directory or remove the link first" >&2
  exit 1
fi
if [ -e "$dest" ]; then
  if [ ! -d "$dest" ] || [ ! -f "$dest/SKILL.md" ]; then
    echo "refusing to replace $dest: not a skill directory" >&2; exit 1
  fi
  if diff -rq -- "$src" "$dest" >/dev/null 2>&1; then
    echo "$dest is already current"
  else
    bak="$dest.bak.$(date +%Y%m%d%H%M%S)"
    [ -e "$bak" ] && bak="$bak.$$"
    mv -- "$dest" "$bak"
    echo "existing skill differed from the source; moved it to $bak (put customisations in a project's .claude/skills/expert-panel/ instead)"
  fi
fi
if [ ! -e "$dest" ]; then
  mkdir -p -- "$base"
  cp -r -- "$src" "$dest"
  echo "installed $dest"
fi
echo "skills are discovered when a session starts: restart any running session before invoking /expert-panel"
echo "adopt the framework in a project: $here/../../adopt.sh <project-dir>"
