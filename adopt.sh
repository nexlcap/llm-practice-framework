#!/usr/bin/env bash
# Adopt the framework in a project: copy the documents to <project>/docs/llm-framework/ and append
# the rules fragment to <project>/CLAUDE.md once. Idempotent.
set -euo pipefail
[ $# -eq 1 ] || { echo "usage: $0 <project-dir>" >&2; exit 2; }
here="$(cd "$(dirname "$0")" && pwd)"
proj="$(cd "$1" && pwd)"
dest="$proj/docs/llm-framework"
mkdir -p "$dest"
cp "$here/README.md" "$here/call-site-contract.md" "$here/panel-protocol.md" "$here/CLAUDE.md.fragment" "$dest/"
echo "copied framework to $dest"
if [ -f "$proj/CLAUDE.md" ] && grep -q '^## LLM usage rules' "$proj/CLAUDE.md"; then
  echo "CLAUDE.md already carries the rules; not appended"
else
  { [ -f "$proj/CLAUDE.md" ] && [ -s "$proj/CLAUDE.md" ] && echo; cat "$here/CLAUDE.md.fragment"; } >> "$proj/CLAUDE.md"
  echo "appended rules to $proj/CLAUDE.md"
fi
echo "next: write the first call-site contract from $dest/call-site-contract.md"
