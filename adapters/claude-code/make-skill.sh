#!/usr/bin/env bash
# Generate the Claude Code skill from the protocol: skill-header.md (the tool-specific part) followed by
# the body of panel-protocol.md. The shipped SKILL.md is never edited by hand.
# usage: make-skill.sh            rewrite expert-panel/SKILL.md
#        make-skill.sh --check    exit 1 if the shipped SKILL.md differs from what would be generated
set -euo pipefail
here="$(cd -- "$(dirname -- "$0")" && pwd)"
out="$here/expert-panel/SKILL.md"
gen() { cat "$here/skill-header.md"; echo; tail -n +3 "$here/../../panel-protocol.md"; }
if [ "${1:-}" = "--check" ]; then
  if gen | cmp -s - "$out"; then echo "SKILL.md is current"
  else echo "SKILL.md differs from skill-header.md + panel-protocol.md; run $0" >&2; exit 1; fi
else
  gen > "$out"
  echo "wrote $out"
fi
