#!/usr/bin/env bash
# Adopt the framework in a project: copy the documents to <project>/docs/llm-framework/ and keep
# agent-rules.md in the project's agent instructions file between two marker comments, so that
# re-running refreshes the block in place and never duplicates it. Idempotent.
# usage: adopt.sh <project-dir> [instructions-file]
#   instructions-file defaults to the one a previous run recorded in docs/llm-framework/.adopt, else
#   the first of AGENTS.md, CLAUDE.md, GEMINI.md that exists; if none exists the tool is inferred from
#   its config directory (.claude/ -> CLAUDE.md, .gemini/ -> GEMINI.md), else AGENTS.md is created.
#   Pass another path for editor-specific files. A team whose tools read different files runs this
#   once per file.
set -euo pipefail
usage() { echo "usage: $0 <project-dir> [instructions-file]" >&2; exit 2; }
[ $# -ge 1 ] && [ $# -le 2 ] || usage
here="$(cd -- "$(dirname -- "$0")" && pwd)"
[ "$1" != "-" ] && [ -d "$1" ] || { echo "not a directory: $1" >&2; exit 2; }
proj="$(cd -- "$1" && pwd)"
dest="$proj/docs/llm-framework"
state="$dest/.adopt"
files="README.md ADAPTING.md call-site-contract.md evaluation.md panel-protocol.md agent-rules.md"
begin_key='<!-- llm-framework:agent-rules begin'
begin="$begin_key (managed by adopt.sh: edit agent-rules.md upstream and re-run; edits here are overwritten) -->"
end='<!-- llm-framework:agent-rules end -->'

# Decide everything before writing anything.
if [ -e "$dest" ] && [ ! -d "$dest" ]; then echo "$dest exists and is not a directory" >&2; exit 2; fi
if [ $# -eq 2 ]; then
  [ -n "$2" ] || usage
  rules="$2"; case "$rules" in /*) ;; *) rules="$proj/$rules";; esac
  if [ -d "$rules" ]; then echo "instructions file is a directory: $rules" >&2; exit 2; fi
elif [ -f "$state" ] && recorded="$(sed -n 's/^rules=//p' "$state")" && [ -n "$recorded" ]; then
  case "$recorded" in /*) rules="$recorded";; *) rules="$proj/$recorded";; esac
else
  rules=""
  for cand in AGENTS.md CLAUDE.md GEMINI.md; do
    if [ -f "$proj/$cand" ]; then rules="$proj/$cand"; break; fi
  done
  if [ -z "$rules" ]; then
    if [ -d "$proj/.claude" ]; then rules="$proj/CLAUDE.md"
    elif [ -d "$proj/.gemini" ]; then rules="$proj/GEMINI.md"
    else rules="$proj/AGENTS.md"; echo "no instructions file found; creating AGENTS.md (pass another path as the second argument if your tool reads a different file)"
    fi
  fi
fi
if [ -f "$rules" ] && ! grep -qF -- "$begin_key" "$rules" && grep -qF -- 'No model call exists without a call-site contract' "$rules"; then
  {
    echo "$rules carries an unmarked rules block from an earlier adopt.sh. Wrap it in the two marker lines"
    echo "  $begin"
    echo "  $end"
    echo "or delete it, then re-run."
  } >&2
  exit 1
fi

# Documents.
mkdir -p "$dest" "$dest/contracts" "$dest/evaluations"
for f in $files; do cp "$here/$f" "$dest/"; done
cp "$here/LICENSE" "$dest/LICENSE"
if [ ! -f "$dest/LOCAL.md" ]; then
  cp "$here/LOCAL.template.md" "$dest/LOCAL.md"
  echo "created $dest/LOCAL.md from the template; fill it in, starting with the scale and the shape"
fi
case "$rules" in "$proj"/*) rec="${rules#"$proj"/}";; *) rec="$rules";; esac
src="$(git -C "$here" remote get-url origin 2>/dev/null || echo "$here")"
commit="$(git -C "$here" rev-parse --short HEAD 2>/dev/null || echo unknown)"
printf 'rules=%s\nsource=%s\ncommit=%s\n' "$rec" "$src" "$commit" > "$state"
echo "copied the six framework documents and LICENSE to $dest"

# Rules block.
mkdir -p "$(dirname -- "$rules")"
if [ -f "$rules" ] && grep -qF -- "$begin_key" "$rules"; then
  tmpf="$(mktemp)"
  awk -v b="$begin_key" -v e="$end" -v src="$here/agent-rules.md" -v bl="$begin" '
    index($0, b) == 1 { print bl; while ((getline l < src) > 0) print l; print e; skip = 1; next }
    index($0, e) == 1 { skip = 0; next }
    !skip { print }' "$rules" > "$tmpf"
  if cmp -s "$tmpf" "$rules"; then echo "rules block in $rules is current"
  else cat "$tmpf" > "$rules"; echo "refreshed the rules block in $rules; the rules changed, re-read them"; fi
  rm -f "$tmpf"
else
  { [ -s "$rules" ] && echo; echo "$begin"; cat "$here/agent-rules.md"; echo "$end"; } >> "$rules"
  echo "appended the rules block to $rules"
fi
for cand in AGENTS.md CLAUDE.md GEMINI.md; do
  if [ -f "$proj/$cand" ] && [ "$proj/$cand" != "$rules" ]; then
    echo "note: $proj/$cand also exists and was not changed; run again with it as the second argument if that tool should carry the rules too"
  fi
done
echo "next: follow $dest/ADAPTING.md; the first contract goes in $dest/contracts/"
