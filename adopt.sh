#!/usr/bin/env bash
# Adopt the framework in a project: copy the documents to <project>/docs/llm-framework/ and append
# agent-rules.md once to the project's agent instructions file. Idempotent.
# usage: adopt.sh <project-dir> [rules-file]
#   rules-file defaults to the first of AGENTS.md, CLAUDE.md, GEMINI.md that exists in the project;
#   if none exists, the tool is inferred from its config directory (.claude/ -> CLAUDE.md,
#   .gemini/ -> GEMINI.md), else AGENTS.md is created. Pass another path for editor-specific files.
set -euo pipefail
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "usage: $0 <project-dir> [rules-file]" >&2; exit 2; }
here="$(cd "$(dirname "$0")" && pwd)"
proj="$(cd "$1" && pwd)"
dest="$proj/docs/llm-framework"
mkdir -p "$dest"
cp "$here/README.md" "$here/ADAPTING.md" "$here/call-site-contract.md" "$here/evaluation.md" "$here/panel-protocol.md" "$here/agent-rules.md" "$dest/"
if [ ! -f "$dest/LOCAL.md" ]; then cp "$here/LOCAL.template.md" "$dest/LOCAL.md"; echo "created $dest/LOCAL.md from the template; fill it in"; fi
echo "copied framework to $dest"
if [ $# -eq 2 ]; then
  rules="$2"; case "$rules" in /*) ;; *) rules="$proj/$rules";; esac
else
  rules=""
  for cand in AGENTS.md CLAUDE.md GEMINI.md; do
    [ -f "$proj/$cand" ] && { rules="$proj/$cand"; break; }
  done
  if [ -z "$rules" ]; then
    if [ -d "$proj/.claude" ]; then rules="$proj/CLAUDE.md"
    elif [ -d "$proj/.gemini" ]; then rules="$proj/GEMINI.md"
    else rules="$proj/AGENTS.md"; echo "no instructions file found; creating AGENTS.md (pass another path as the second argument if your tool reads a different file)"
    fi
  fi
fi
mkdir -p "$(dirname "$rules")"
if [ -f "$rules" ] && grep -q '^## LLM usage rules' "$rules"; then
  echo "$rules already carries the rules; not appended"
else
  { [ -s "$rules" ] && echo; cat "$here/agent-rules.md"; } >> "$rules"
  echo "appended rules to $rules"
fi
mkdir -p "$dest/contracts" "$dest/evaluations"
echo "next: follow $dest/ADAPTING.md; first contract goes in $dest/contracts/"
