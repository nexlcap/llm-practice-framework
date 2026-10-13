#!/usr/bin/env bash
# Adopt the framework in a project: copy the documents to <project>/docs/llm-framework/ and keep
# agent-rules.md in the project's agent instructions file between two marker comments, so that
# re-running refreshes the block in place and never duplicates it. Idempotent. Nothing is written
# until every check has passed.
# usage: adopt.sh <project-dir> [instructions-file]
#   instructions-file defaults to the one a previous run recorded in docs/llm-framework/.adopt, else
#   the first of AGENTS.md, CLAUDE.md, GEMINI.md that exists; if none exists the tool is inferred from
#   its config directory (.claude/ -> CLAUDE.md, .gemini/ -> GEMINI.md), else AGENTS.md is created.
#   Pass another path for editor-specific files. A team whose tools read different files runs this
#   once per file. The two marker lines must stay at column 1, one pair, begin before end; marker
#   lines quoted inside a ``` fence are documentation and are left alone. CRLF line endings and a
#   leading BOM are kept. A symlinked instructions file is refused (pass its target). The .adopt
#   record names the source repository without any credential in its URL.
set -euo pipefail
[ "${BASH_VERSINFO[0]}" -ge 4 ] || { echo "bash 4 or newer required" >&2; exit 2; }
usage() { echo "usage: $0 <project-dir> [instructions-file]" >&2; exit 2; }
[ $# -ge 1 ] && [ $# -le 2 ] || usage
here="$(cd -- "$(dirname -- "$0")" && pwd -P)"
[ "$1" != "-" ] && [ -d "$1" ] || { echo "not a directory: $1" >&2; exit 2; }
proj="$(cd -- "$1" && pwd -P)"
dest="$proj/docs/llm-framework"
state="$dest/.adopt"
files="README.md ADAPTING.md call-site-contract.md evaluation.md panel-protocol.md agent-rules.md"
begin_key='<!-- llm-framework:agent-rules begin'
begin="$begin_key (managed by adopt.sh: edit agent-rules.md upstream and re-run; edits here are overwritten) -->"
end='<!-- llm-framework:agent-rules end -->'
legacy='^- No model call exists without a call-site contract'

# Marker scan over the file as an agent reads it: a trailing CR and a leading BOM do not count for
# matching, lines inside ``` fences are text, and the lines between a begin and its end are the old
# block (agent-rules.md carries no fence, so none can open there; tests/run.sh pins that).
scan() { # scan FILE -> "begin-at-column-1 begin-elsewhere end begin-line end-line"
  awk -v b="$begin_key" -v e="$end" '
    { l = $0; sub(/\r$/, "", l); if (NR == 1 && index(l, "\357\273\277") == 1) l = substr(l, 4) }
    inblock { if (l == e) { ne++; if (!el) el = NR; inblock = 0 } next }
    l ~ /^```/ { fence = !fence; next }
    fence { next }
    index(l, b) == 1 { nb++; if (!bl) bl = NR; inblock = 1; next }
    index(l, b) > 1 { stray++; next }
    l == e { ne++; if (!el) el = NR }
    END { printf "%d %d %d %d %d\n", nb + 0, stray + 0, ne + 0, bl + 0, el + 0 }' "$1"
}
rewrite() { # rewrite FILE -> the file with the managed block replaced by the current agent-rules.md
  awk -v b="$begin_key" -v e="$end" -v src="$here/agent-rules.md" -v bl="$begin" '
    { l = $0; cr = ""; if (sub(/\r$/, "", l)) cr = "\r"; m = l; bom = ""
      if (NR == 1 && index(m, "\357\273\277") == 1) { bom = substr(m, 1, 3); m = substr(m, 4) } }
    skip { if (m == e) skip = 0; next }
    m ~ /^```/ { fence = !fence; print; next }
    fence { print; next }
    index(m, b) == 1 {
      printf "%s%s%s\n", bom, bl, cr
      while ((getline x < src) > 0) printf "%s%s\n", x, cr
      printf "%s%s\n", e, cr; skip = 1; next }
    { print }' "$1"
}

# Pre-flight: decide everything and check everything before writing anything.
for f in $files LICENSE LOCAL.template.md; do
  [ -f "$here/$f" ] || { echo "framework copy is incomplete: $here/$f is missing" >&2; exit 2; }
done
if [ -e "$dest" ] && [ ! -d "$dest" ]; then echo "$dest exists and is not a directory" >&2; exit 2; fi
if [ $# -eq 2 ]; then
  [ -n "$2" ] || usage
  rules="$2"; case "$rules" in /*) ;; *) rules="$proj/$rules";; esac
  if [ -d "$rules" ]; then echo "instructions file is a directory: $rules" >&2; exit 2; fi
elif [ -f "$state" ] && recorded="$(sed -n 's/^rules=//p' "$state")" && [ -n "$recorded" ]; then
  case "$recorded" in /*) rules="$recorded";; *) rules="$proj/$recorded";; esac
  # the recorded path lives in the repository, so it is contained; an explicit argument is consent
  rdir="$(dirname -- "$rules")"
  if [ -d "$rdir" ]; then
    parent="$(cd -- "$rdir" && pwd -P)"
    case "$parent/" in "$proj"/*) ;; *) echo ".adopt names an instructions file outside the project ($recorded); pass the path explicitly as the second argument if that is intended" >&2; exit 2;; esac
  else # the directory was deleted; a relative path that never climbs is contained and is recreated below
    case "$recorded" in /*|..|../*|*/../*|*/..) echo ".adopt names an instructions file outside the project ($recorded) whose directory no longer exists; pass the path explicitly as the second argument" >&2; exit 2;; esac
  fi
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
case "$rules" in "$dest"/*) echo "the instructions file must not live under docs/llm-framework/ (a refresh overwrites that directory)" >&2; exit 2;; esac
if [ -L "$rules" ]; then echo "instructions file is a symlink: $rules; pass its target as the second argument if that is intended" >&2; exit 2; fi
tmpf=""
if [ -f "$rules" ]; then
  read -r nb stray ne bl el < <(scan "$rules")
  if [ "$((nb + stray + ne))" -eq 0 ]; then
    if grep -q -- "$legacy" "$rules"; then
      {
        echo "$rules carries an unmarked rules block from an earlier adopt.sh. Wrap it in the two marker lines"
        echo "  $begin"
        echo "  $end"
        echo "or delete it, then re-run."
      } >&2
      exit 1
    fi
  else
    if [ "$nb" -ne 1 ] || [ "$stray" -ne 0 ] || [ "$ne" -ne 1 ] || [ "$bl" -ge "$el" ]; then
      echo "$rules: expected exactly one begin marker line at column 1 followed by one end marker line (found $nb begin at column 1, $stray begin elsewhere, $ne end); fix the marker lines by hand, then re-run. Nothing was changed." >&2
      exit 1
    fi
    tmpf="$(mktemp)"; trap 'rm -f "$tmpf"' EXIT
    rewrite "$rules" > "$tmpf"
    read -r nb stray ne bl el < <(scan "$tmpf")
    if [ "$nb" -ne 1 ] || [ "$ne" -ne 1 ]; then
      echo "internal error: the rewritten block is malformed; nothing was changed" >&2; exit 1
    fi
  fi
fi

# Documents.
mkdir -p "$dest" "$dest/contracts" "$dest/evaluations" "$dest/reviews"
for f in $files; do cp "$here/$f" "$dest/"; done
cp "$here/LICENSE" "$dest/LICENSE"
if [ ! -f "$dest/LOCAL.md" ]; then
  cp "$here/LOCAL.template.md" "$dest/LOCAL.md"
  echo "created $dest/LOCAL.md from the template; fill it in, starting with the scale and the shapes"
else
  missing="$(grep '^## ' "$here/LOCAL.template.md" | while IFS= read -r h; do grep -qxF -- "$h" "$dest/LOCAL.md" || printf '%s; ' "$h"; done)"
  [ -z "$missing" ] || echo "note: $dest/LOCAL.md lacks sections the current template has: ${missing%; }; add them, since contracts and reviewers point at them"
fi
case "$rules" in "$proj"/*) rec="${rules#"$proj"/}";; *) rec="$rules";; esac
src="$here"; commit=unknown
if [ "$(git -C "$here" rev-parse --show-toplevel 2>/dev/null || true)" = "$here" ]; then
  src="$(git -C "$here" remote get-url origin 2>/dev/null || echo "$here")"
  src="$(printf '%s' "$src" | sed -E 's#^([A-Za-z][A-Za-z0-9+.-]*://)[^/@]*@#\1#')"   # never a credential
  commit="$(git -C "$here" rev-parse --short HEAD 2>/dev/null || echo unknown)"
fi
printf 'rules=%s\nsource=%s\ncommit=%s\n' "$rec" "$src" "$commit" > "$state"
echo "copied the six framework documents and LICENSE to $dest"

# Rules block.
mkdir -p "$(dirname -- "$rules")"
if [ -n "$tmpf" ]; then
  if cmp -s "$tmpf" "$rules"; then echo "rules block in $rules is current"
  else cat "$tmpf" > "$rules"; echo "refreshed the rules block in $rules; the rules changed, re-read them"; fi
else
  { [ -s "$rules" ] && echo; echo "$begin"; cat "$here/agent-rules.md"; echo "$end"; } >> "$rules"
  echo "appended the rules block to $rules"
fi
for cand in AGENTS.md CLAUDE.md GEMINI.md; do
  if [ -f "$proj/$cand" ] && [ "$proj/$cand" != "$rules" ] && ! [ "$proj/$cand" -ef "$rules" ]; then
    echo "note: $proj/$cand also exists and was not changed; run again with it as the second argument if that tool should carry the rules too"
  fi
done
echo "next: follow $dest/ADAPTING.md; the first contract goes in $dest/contracts/"
