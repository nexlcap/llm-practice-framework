# Panel report 3: Observer, Engineering pair, Experience pair

**Artifact:** LLM Practice Framework, repository at `<checkout>` (published, MIT, last edited 2026-09-05). Document set plus three bash scripts; no application code.
**Review date:** 2026-10-12.
**Seats in this session:** Common Sense Observer (speaks first); Engineering pair (Software Engineer <-> Code Reviewer); Experience pair adapted for a documentation artifact (UX Designer <-> Technical Writer / Information Architect).
**Build stage:** everything under review exists as published text and scripts. No "planned" controls were reviewed as shipped; where a document describes a test or mechanism that an adopter must build (guard tests, inventory test), it was reviewed as a *specification* and judged on whether two engineers would build the same thing from it.
**Method:** every file read in full (17 files, 1,585 lines of content). The three scripts were copied to `$S = <scratch>/panel/eng-scratch/fw` and run against 20+ fake project directories; `install.sh` ran with `HOME` pointed at `$S/../fakehome`. Nothing in the repository was modified; no state-changing git command was run. Full command transcripts are in Appendix A. One external check: the Claude Code skills documentation, to verify SKILL.md's precedence claim.

**VERDICT: MODIFY-BEFORE-BUILD** (0 blockers, 21 modify, 12 latent/nit). Reasoning in section 5. No finding below appears in the author's own list of known problems (ADAPTING.md §8 "Mistakes people make", contract line 177-178 "known residual risk"); the author's list is about adopters' mistakes, not the framework's.

---

## 1. Common Sense Observer (first, unfiltered)

I have no background in this. I read it as a smart person who was handed the repo link and ten minutes.

### 1.1 What is this for, in one sentence?

My attempt after reading everything: *"A rulebook, three fill-in templates, and a review ritual for software teams whose code calls a language model, so the model cannot quietly invent facts, cost too much, run unwatched, or ship unreviewed."*

Does the README say that in its first three lines? **Partly, and in the wrong register.** README.md:3-5 says "A project-independent framework for using large language models **sufficiently**..., **critically**..., **effectively**..., **efficiently**..., and **guardrailed**...". Five adverbs and a word that is not an adverb. It does not say *who* it is for. "Using large language models" to a newcomer means typing into ChatGPT; it takes until line 13 ("No model call exists without one") to learn that this is about *code that calls a model*, and until line 57 to meet the first concrete rule. The audience ("engineers building a product that makes API calls to a model") should be in sentence one. JUDGMENT.

Also, line 6 says "five months of production use" and line 343 says "several months". Why two numbers for the same fact in a document whose first principle is that facts must not drift? VERIFIED (README.md:6, README.md:343).

### 1.2 Words used before they are explained

| Word | First used (README) | Where it is finally explained | Observer's reaction |
|---|---|---|---|
| guard / guardrailed | line 5 (title adverb), 66 (P3) | §3.4 heading line 162, list at 165-176 | "Guard" means an output check at line 66, an *architecture test* at line 110 ("guard tests"), a *freshness check* at 223, and an unnamed thing at 263 ("A guard is verified on the path the default caller actually takes"). Four different things, one word. |
| door / one door | line 27, P4 line 71 | §6 step 2, line 313 ("One package ... with a transport, a `complete()` entry point...") | A metaphor used 7 times before it is defined 240 lines later. I guessed right, but I guessed. |
| gate | line 20 ("first panel gate") | §3.10 line 243 ("Three gates: design..., spec..., results...") | Also used for "delta condition gates it" (101), "Gate calls on did the input change" (75), "No quality gate inside the prompt" (153), "The final gate is the full suite" (225). Same word, four mechanisms. |
| contract / call-site contract | line 13 | §2 line 93 | OK: defined 80 lines later and the intro points at the file. Acceptable. |
| call site | line 72 (P4) | never defined as a term; inferred from §2 | A programmer's word. One sentence would do: "a call site is one place in the code that asks the model something". |
| panel | line 19 ("tailor the panel") | §3.10 line 241 points to another file | The README never says in its own words what a panel is. |
| seat | not in README | panel-protocol.md:10-31 | Fine inside the protocol. |
| pin / incident pin / pinned | line 76?? No: P7 line 85 "Tests are pinned to the incidents they prevent" | §3.8 line 221 | "Pinned" I had to work out. "Each test says which real failure it exists to prevent, with the date" is plainer. |
| TBD convention | not in README | ADAPTING.md:86-92, call-site-contract.md:5-6 | Fine where it is; but README §2 line 115 says "A call whose contract has a blank field is not ready" without mentioning that a dated TBD is the sanctioned exception. A reader of the README alone thinks blanks are forbidden, full stop. |
| snapshot | line 140 | same sentence | Defined in use. OK. |
| suppression layer / deterministic suppression | line 68 (P3) | §3.4 item 5, line 173 | 105 lines apart. "Code gets the last word on what the user sees" is the plain version. |
| doctrine | line 104 (§2 table) | the same table row: "The policy or intent stated in the prompt" | Why "doctrine"? It is a military/religious word for "the rules we state up front". The table's own definition ("policy or intent") is clearer than the term. JUDGMENT. |
| inline (never reviews its own work inline) | line 85 | panel-protocol.md:63-64 | "Inline" is tool jargon. "In the same conversation that wrote it" is what it means. |
| frame / frame-inversion | line 159 (3.3), 303 (ladder) | panel-protocol.md:31, 73-75 | The README mentions "frame inversion" in the ladder (303) and "framing-sensitive" (160) without ever saying what a frame is. |
| closed vocabulary | line 67 (P3) | §2 line 103 | Reasonably self-explanatory; acceptable. |

Pattern: the Principles section is written for people who already know the vocabulary the rest of the document introduces. Either define each term on first use with a half-sentence, or add a 12-line glossary after the "Four parts" block. VERIFIED (line numbers above).

### 1.3 Why eight principles? Do any two say the same thing?

- **P1 and P2 overlap heavily.** P1: "Code owns facts; the model owns judgment... computed or retrieved by deterministic code and injected... The model copies them." P2: "Server retrieves, model judges, code enforces. Deterministic code decides what evidence exists and shows it. The model judges only what it is shown." Both say: code supplies the facts, the model only judges. P2's only new content is "code enforces" (which is P3) and "Model output never feeds another model call as fact" (one sentence). Merge P1+P2, keep the chaining sentence. JUDGMENT.
- **P7 and P8** are both "process rules about what happens after the code is written" rather than design rules; they read as a different kind of thing from P1-P6. Not duplicates, but the list changes category without saying so.
- **No principle covers security or isolation**, although the title line promises "guardrailed (isolation, failure handling, security)" (README.md:5) and the §2 table maps the "Security" row to P4 (README.md:112), whose text (lines 71-73) says nothing about secrets, injection, or tools. The mapping is a stretch. VERIFIED.
- So the honest count is six or seven principles, one of which is missing. "Eight" is not wrong, but the author should be able to say why these eight; the document does not.

### 1.4 Why does a document about using LLMs need a review protocol with twelve-plus roles?

The protocol names 6 pairs + veto + observer + frame-inversion = **15 role titles** (panel-protocol.md:21-31). The answer the author would give is at panel-protocol.md:46: "Convene only the seats the change touches. Proportionality is part of the protocol", and ADAPTING.md:217-218: "the minimum viable panel is three sessions". That answer is **absent from the README**: §3.10 (lines 239-251) has seven checklist items and none of them says "only the seats the change touches". A newcomer reading the README's summary concludes that every change needs a fifteen-role committee, and leaves. VERIFIED (absence in README.md:239-251). Resolve: add one item to §3.10: "Only the seats the change touches are convened (scoping table in the protocol, §2); the minimum is the engineering pair, the observer, and the frame-inversion reviewer."

Also: the two documents disagree on the minimum. ADAPTING.md:217-218 says "three sessions: engineering pair, observer, frame inversion"; panel-protocol.md:60-62 groups "engineering + experience + observer" into *one* session plus frame-inversion = **two** sessions, and `adapters/generic/prompts/3-engineering-experience-observer.md` is one prompt. VERIFIED.

### 1.5 What would a newcomer do in the first ten minutes, and does the README tell them?

What I would want: (1) read one paragraph that says what it is and who it is for; (2) skim the principles; (3) run one command; (4) open one template and see a filled example. What the README gives: a dense 30-line preamble, a layout table, two commands (lines 48-51) with no "then do this" after them, then 300 lines. The "Adopting it" section is at line 307, after the maturity ladder. The install commands at line 48-51 come *before* the reader knows what a "project" is in this context or what the script will write into their repo (it appends to CLAUDE.md, which a newcomer would want to know before running it). There is no table of contents; the "Four parts" list is the nearest thing and it does not match the section numbers (section 1.6 of the Experience pair below). JUDGMENT, with VERIFIED structure at README.md:10-20 vs headings at 55, 93, 120, 271, 290, 307, 341, 348.

### 1.6 Other "but why?" items

- README.md:257: "Delegated agents never touch branch state. Git is limited to add, commit, status, log, diff." A commit moves the branch. Either "branch state" means something narrower (checkout, rebase, push, merge) and should say so, or "commit" should not be on the list. VERIFIED wording.
- README.md:25-27 says "Nothing in the core assumes a particular API, CLI, agent product, or language", then README.md:188 says "The subprocess or SDK runs with...", 192-193 "enforced on the process group, and never orphan a credentialed subprocess", and the agentic example at call-site-contract.md:198-199 "the process group is killed on timeout". The source system evidently drove a CLI as a subprocess. A reader using an HTTP SDK has no process group. Say "if the transport is a subprocess" or drop the subprocess language from the core. VERIFIED.
- README.md:28-29: "The three helper scripts are POSIX shell". They are not (Engineering finding E4). I would not have known, but an engineer told me and now I trust line 28 less.
- README.md:7: "the incident-level evidence is in the practices guide named under Provenance." I went to Provenance (341-346). No guide is named. The one place that promises evidence for "every rule below paid for itself at least once" points at nothing. VERIFIED. This matters to me more than to the experts: the whole document asks me to take rules on faith ("where a rule seems arbitrary, assume it was paid for", line 346) and the receipt is missing.

---

## 2. Engineering pair

### 2.1 Software Engineer: independent assessment

Scope question first: does the complexity earn its keep? Three scripts totalling 96 lines, one skill file that is a header plus a verbatim copy of the protocol, four reviewer prompts. The shape is right: thin scripts, prose as the source of truth, copy-not-link so adopters' copies do not change under them. I would not add a build system to this. The failures are in details, and several of them are the kind the framework itself warns about (a rule without a test is a suggestion; the scripts have no tests).

**E1. `adopt.sh` idempotency is a string match on one heading, and it has three failure modes.** Mechanism: `grep -q '^## LLM usage rules' "$rules"` (adopt.sh:32). Reproduced:
- User demotes the heading to `###` to fit their CLAUDE.md structure, re-runs: the rules are appended a second time (B2: 2 headings, 137 lines).
- User renames the heading: appended again (B3: `The model never authors facts` occurs 2x).
- User's own CLAUDE.md happens to contain `## LLM usage rules` with their own content: rules never appended, script reports "already carries the rules" (B4: 0 occurrences of the framework text).
- Upstream `agent-rules.md` changes; re-run refreshes `docs/llm-framework/agent-rules.md` but **not** the pasted block, and says only "already carries the rules; not appended" (B5: new rule present in docs copy 1x, in CLAUDE.md 0x). ADAPTING.md:243-258 ("Keep the copy current") does not mention that the pasted rules are *not* refreshed; an adopter who follows §7 ends up with an instructions file enforcing an older ruleset than the docs beside it. VERIFIED.

Resolve: fence the block with sentinel comments and replace between them on re-run:

```bash
start='<!-- llm-framework:agent-rules:start (managed by adopt.sh; edit agent-rules.md upstream) -->'
end='<!-- llm-framework:agent-rules:end -->'
if [ -f "$rules" ] && grep -qF "$start" "$rules"; then
  awk -v s="$start" -v e="$end" -v f="$here/agent-rules.md" '
    $0==s { print; while ((getline l < f) > 0) print l; skip=1; next }
    $0==e { skip=0 }
    !skip { print }' "$rules" > "$rules.tmp" && mv "$rules.tmp" "$rules"
  echo "refreshed the rules block in $rules"
else
  { [ -s "$rules" ] && echo; echo "$start"; cat "$here/agent-rules.md"; echo "$end"; } >> "$rules"
  echo "appended rules to $rules"
fi
```
Also print a diff-sized hint ("rules block changed: N lines") so the adopter knows to re-read.

**E2. `adopt.sh` refresh without the second argument creates a stray `AGENTS.md`.** A7: first run `adopt.sh p7 .cursor/rules/llm.md` (correct), re-run `adopt.sh p7` as ADAPTING.md:248 shows for refresh: output "no instructions file found; creating AGENTS.md", and the project now has rules in two files. The refresh command in ADAPTING §7 omits the argument that §2 line 35 told the Cursor/Copilot user to pass. VERIFIED. Resolve: record the chosen rules path in `docs/llm-framework/LOCAL.md` (a `Rules file:` line) or in `docs/llm-framework/.adopt`, and read it when the argument is absent; and change ADAPTING.md:248 to `./adopt.sh /path/to/project [same rules-file as before]`.

**E3. Two instructions files present: silent choice.** A4: with both `AGENTS.md` and `CLAUDE.md`, rules go to `AGENTS.md` only, no notice. Claude Code reads `CLAUDE.md` (adapters/README.md:14), so a Claude Code project that also keeps an `AGENTS.md` for Codex gets rules the Claude sessions never see. VERIFIED. Resolve: after choosing, loop over the candidates and print "note: CLAUDE.md also exists and was not modified; pass it as the second argument if that tool should carry the rules too".

**E4. "POSIX shell" is false; the scripts are bash.** README.md:28-29 claims POSIX; all three use `set -o pipefail` (adopt.sh:8, install.sh:4, panel-run.sh:13), and panel-run.sh uses `local` (22) and arrays (32, 39). D1: under `dash` (Debian/Ubuntu `/bin/sh`) all three exit 2 immediately: `set: Illegal option -o pipefail`; `dash -n panel-run.sh` gives `Syntax error: "(" unexpected`. The shebangs are `#!/usr/bin/env bash`, so `./adopt.sh` works; `sh adopt.sh` does not. VERIFIED. Resolve: change README.md:28-29 to "The three helper scripts are bash (present on Linux, macOS, WSL, and Git Bash)". Making them POSIX is also cheap (drop `pipefail`, replace the pid array with a `wait` on all children) but the wording fix is the minimum.

**E5. `install.sh` destroys a customized personal skill without warning or backup, and detaches a symlink.** I2: append a line to the installed `~/.claude/skills/expert-panel/SKILL.md`, add `my-notes.md`, re-run: both gone, exit 0, message "installed". I7: if `~/.claude/skills/expert-panel` is a symlink into a dotfiles repo, `rm -rf "$dest"` (install.sh:11) removes the link and `cp -r` creates a real directory; the dotfiles copy is untouched but no longer used, silently. The guard at install.sh:8-10 only protects a directory *without* `SKILL.md`, i.e. the one case where nothing valuable can be lost (I4, I5 refuse correctly). VERIFIED. The design intent (personal = generic; project `.claude/skills/expert-panel/` = customized, SKILL.md:8-11) is sound, but the installer should enforce it: if `$dest/SKILL.md` exists and differs from the source, print the diff stat and require `--force`; if `$dest` is a symlink, refuse.

**E6. `panel-run.sh` roster substitution is a `sed` injection.** Values from `PANEL_DOMAIN_A/B`, `PANEL_VETO`, `PANEL_EXTRA_PAIR` are spliced into `sed -e "s|{{DOMAIN_A}}|$VALUE|g"` (panel-run.sh:23-26). Reproduced:
- `&` is sed's "matched text": `PANEL_DOMAIN_A='Clinician & Nurse Lead'` -> the model sees `Roles: Clinician {{DOMAIN_A}} Nurse Lead` (R4). Silent corruption, exit 0.
- `|` is the delimiter: `PANEL_DOMAIN_A='Practitioner | Examiner'` -> `sed: unknown option to 's'`, four empty reports, exit 1 (R5). The roster table at ADAPTING.md:165-173 and panel-protocol.md:25 itself uses "Web / Content Security"; a user writing "Web | Content Security" (the table's own `|` column separator) gets this.
- A newline in a value -> `unterminated 's' command`, empty reports (R6b).
- Backslash is eaten: `Path\Analyst` -> `PathAnalyst` (R6).
VERIFIED. Resolve: the script is bash anyway, so use literal parameter substitution, which treats the replacement as plain text:

```bash
build_input() {
  local prompt="$1"; shift
  local da="${PANEL_DOMAIN_A:-the Domain Practitioner}" db="${PANEL_DOMAIN_B:-the Domain Skeptic}"
  local veto="${PANEL_VETO:-the owner of the irreversible resource}" extra="${PANEL_EXTRA_PAIR:+$PANEL_EXTRA_PAIR }"
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line//'{{DOMAIN_A}}'/$da}"; line="${line//'{{DOMAIN_B}}'/$db}"
    line="${line//'{{VETO}}'/$veto}";    line="${line//'{{EXTRA_PAIR}}'/$extra}"
    printf '%s\n' "$line"
  done < "$prompt"
  ...
}
```

**E7. `panel-run.sh`'s verdict summary is wrong in the unsafe direction.** `grep -H -o -m1 -E 'BLOCKERS|MODIFY-BEFORE-BUILD|APPROVE-AS-IS'` (panel-run.sh:41) prints the first line containing any of the words. V1: a report reading "I looked for BLOCKERS and found none. / APPROVE-AS-IS" is summarized as `BLOCKERS`. The mirror case ("This is not an APPROVE-AS-IS... BLOCKERS") would be summarized as `APPROVE-AS-IS`. V2: a report that follows the protocol's own §4 casing ("Modify-before-build", panel-protocol.md:99-101) is reported as "no verdict line found". R2 (model = `cat`) shows `-o` also prints every word on the first matching line. VERIFIED. Resolve: the prompts already demand the word "on its own line" (prompts 1-3 line 25-26, prompt 4 line 13), so anchor and take the last such line:

```bash
for r in "$report_dir"/*.md; do
  v="$(grep -E '^(BLOCKERS|MODIFY-BEFORE-BUILD|APPROVE-AS-IS)[[:space:]]*$' "$r" | tail -1)"
  printf '%s: %s\n' "$r" "${v:-NO VERDICT LINE; read the report}"
done
```
and make panel-protocol.md §4 use the same three uppercase tokens (see E12).

**E8. The generic runner cannot run the Data pair, and the dispatch grouping forgets it.** The roster has "Data pair | ML Engineer <-> Data Engineer" (panel-protocol.md:24); the scoping table convenes it for "Decision logic, model prompts, scoring, thresholds" (line 51). `grep -rn 'Data pair\|ML Engineer'` hits only the roster/scoping tables in panel-protocol.md, SKILL.md and LOCAL.template.md. No prompt in `adapters/generic/prompts/` embodies it, and the dispatch grouping at panel-protocol.md:60-62 ("domain + veto; security + systems; engineering + experience + observer") has no slot for it. The second most common change type in a model project has a seat that only the Claude Code adapter can fill, and only if the dispatching session notices. VERIFIED. Resolve: fold it into prompt 1 ("domain pair, data pair, and veto seat") and change the grouping text to "domain + data + veto".

**E9. `panel-run.sh` never reads `LOCAL.md`, but two documents say the panel does.** `grep -n LOCAL panel-run.sh` hits only the comment at line 11 ("the project's roster from LOCAL.md, substituted into the prompts"). ADAPTING.md:160-161: "The panel reads the roster from `LOCAL.md`, so once it is written there every gate uses it without retyping." True for the Claude Code skill (SKILL.md:11-12), false for the generic runner and the chat path. R2 with no env vars and no LOCAL.md: defaults silently used, no warning. VERIFIED. Resolve: either parse the two roster rows (fragile) or fix the text: panel-run.sh:11 "the project's roster, copied from LOCAL.md into these variables", and ADAPTING.md:160-161 "The Claude Code adapter reads the roster from LOCAL.md; with the generic runner export it as `PANEL_DOMAIN_A` etc. (a `.panel.env` beside LOCAL.md, sourced before each run, avoids retyping)". Also have the runner print the roster it is using.

**E10. The generic runner has no scoping and no build-stage input.** It runs every `*.md` in the prompts dir (panel-run.sh:33), so "Pure refactor: Engineering pair, Observer, Frame-Inversion only" (protocol §2) cannot be honoured without the user making a second prompts directory; ADAPTING.md:195 does not say so. ADAPTING.md:201-202: "Every reviewer prompt states what exists in code and what is design only"; the runner has no `PANEL_BUILD_STAGE` variable (V5), so the only channels are the artifact itself or `PANEL_PUSH_ON`. The prompts' fallback ("treat every control as unbuilt") then fires on every run, which is exactly the "planned control reviewed as shipped" problem §5.5 wants to prevent, inverted. VERIFIED. Resolve: add `PANEL_SEATS` (space-separated prompt basenames or numbers; default all) and `PANEL_BUILD_STAGE` (emitted as a `## Build stage` section before `## Push on`).

**E11. Minor runner defects.** (a) Empty `PANEL_PROMPTS` dir: the glob stays literal, `sed: can't read .../*.md`, and the report dir gets files literally named `*.md` and `*.err` (V4). Add `shopt -s nullglob` and a "no prompts found" error. (b) `{{EXTRA_PAIR}}` is substituted as a bare name with a trailing space: R3 produces "...what sample would change the conclusion). Social Scientist <-> Research Methodologist The veto seat, Treasury, blocks..." (prompt 1 line 8). The extra pair gets no role description, no tension, no sentence. Resolve: `{{EXTRA_PAIR}}` -> "A second pair, {{EXTRA_PAIR}}, reviews the project's second question in the same way. " when set. (c) The inlined-file fence is `=== <name> ===` / `=== end <name> ===` (panel-run.sh:29); an artifact that contains its own end marker breaks the fence (V6). Low risk since the prompt says the content is data, but a random fence token per run costs one line. VERIFIED.

### 2.2 Code Reviewer: independent assessment

Edge cases, hidden coupling, tests that assert nothing, drift between copies.

**E12. Five copies of the protocol content already disagree.** Diffed/compared:
- `panel-protocol.md:3-163` vs `SKILL.md:57-217`: byte-identical (good). But `SKILL.md:51-54` is a **stale earlier intro** ("Reviewers are separate model sessions (subagents)... This file is written to be dropped into any project as a skill or a checklist") left above the current intro at 57-62. The skill therefore says its preamble twice, in two wordings. This is the drift ADAPTING §7 and adapters/README.md:26-28 ("Generate the tool's file from it... rather than maintaining a second copy") are meant to prevent, and it has already happened; there is no generator script, and ADAPTING §7 covers refreshing *project copies*, not re-deriving the adapter from the protocol. VERIFIED.
- **Verdict class casing:** protocol §4 (panel-protocol.md:99-101) "**Blockers** / **Modify-before-build** / **Approve-as-is**"; protocol skeleton (85) and all four prompts: `BLOCKERS, MODIFY-BEFORE-BUILD, APPROVE-AS-IS`; README.md:247 "blockers, modify-before-build, approve-as-is"; SKILL.md:3 "Blockers / Modify-before-build / Approve-as-is". The runner greps uppercase only (E7/V2). VERIFIED.
- **Reproduction rule:** panel-protocol.md:119-130: verify directly first; reproduce only judgment findings; "A blocker that does not reproduce is demoted". README.md:249: "A load-bearing verdict is re-run and must reproduce" (always re-run). agent-rules.md:59: "load-bearing verdicts are re-run until they reproduce" — "until" inverts the demotion rule: keep running until agreement, which is the opposite of what §6 prescribes and is the panel equivalent of p-hacking. VERIFIED.
- **Minimum panel:** ADAPTING.md:217-218 three sessions vs protocol grouping two (Observer 1.4). VERIFIED.
- **Output shape:** protocol §4 is "per pair... 4. Verdict", i.e. one verdict per pair; prompt 3 bundles two pairs and the observer under one verdict; prompt 4 has no "Output shape" heading, places "Build stage" *after* the verdict instruction (the other three place it before), and its build-stage text is truncated (lacks "do not review a planned control as a shipped one"). VERIFIED (4-frame-inversion.md:13-20 vs 1-domain-and-veto.md:15-28).
- **Role titles:** roster rule "Role titles only" (panel-protocol.md:41) but the Experience pair is "UX Designer <-> Data Visualization" (28) — a discipline, not a title; prompt 3 patches it to "the Data Visualization expert". VERIFIED.
- **README §3.10 vs protocol:** README omits scoping/proportionality (Observer 1.4) and the "verify directly first" rule; otherwise consistent.
- Single source of truth: `panel-protocol.md` is declared the source (adapters/README.md:26) and is in fact copied verbatim into SKILL.md, so for the *body* yes. For the *summaries* (README §3.10, agent-rules.md Review paragraph, SKILL header, prompt files) there is none, and they have drifted as listed. ADAPTING §7 does not describe how to keep them aligned. Resolve: (a) delete SKILL.md:50-55; (b) add `adapters/claude-code/build-skill.sh` = header file + `tail -n +3 ../../panel-protocol.md`, and a one-line check (`diff <(tail -n +3 panel-protocol.md) <(sed -n '57,$p' SKILL.md)`) in ADAPTING §7 under a new heading "Keeping the adapters in sync"; (c) pick the uppercase tokens everywhere; (d) rewrite README.md:249 and agent-rules.md:59 to "verified against the code where it names a line, otherwise reproduced; a blocker that does not reproduce is demoted".

**E13. Cross-references: broken or stale.** Every section-number, filename and path mention was listed (Appendix A, grep) and checked.
| Reference | Where | Status |
|---|---|---|
| "the practices guide named under Provenance" | README.md:7 | **Broken**: Provenance (341-346) names nothing; "practices guide" appears nowhere else in the repo. |
| "Four parts: 1-4" | README.md:10-20 | **Stale**: actual structure is §1-§6 + Provenance + License; §4 (learning curve) is in no part; "maturity ladder" is attributed to §6 (line 17) but is §5. |
| "overwrites the five framework files" / "those five files" | ADAPTING.md:248, 251 | **Wrong count**: adopt.sh:14 copies six (README, ADAPTING, call-site-contract, evaluation, panel-protocol, agent-rules); ADAPTING.md:38-39 lists six. |
| "The framework's core (README.md, call-site-contract.md, panel-protocol.md, agent-rules.md)" | adapters/README.md:3 | Four files; ADAPTING.md and evaluation.md are also copied as core. Three different counts (4/5/6) for one set. |
| "one row per rule in section 3" / "the six rules above" | ADAPTING.md:59, 114 | LOCAL.template.md:41-49 has **seven** rows (six rules + "Log record minimum fields"). Minor mismatch. |
| "Validators, in order: Schema, vocabulary, numeric copy, audit, suppression" | README.md:106 | Five layers; README §3.4 (165-176) and contract §6 (77-84) have six (adds structural impossibility). |
| "`adapters/`", "`adopt.sh`", "`LOCAL.template.md`", "See `LICENSE`" | README.md:28, 40, 43-46, 49-50, 311, 320, 350; panel-protocol.md:7, 156-157; ADAPTING.md:34-35, 194-196, 248 | **Dangling in the adopted copy**: adopt.sh copies none of these (B10 listing). A project's `docs/llm-framework/README.md` tells readers to run `./adopt.sh` and look in `adapters/`, which do not exist there; and the copy ships without the MIT notice the licence requires in "all copies or substantial portions" (LICENSE:12-13). |
| SKILL.md:9 personal/project shadowing claim | SKILL.md:8-11 | **Verified correct** against the Claude Code skills docs ("Enterprise over personal, and personal over project"). Step 0(a) is justified. |
| All other section refs (ADAPTING §5.4 from adapters/README:22; protocol §2 from ADAPTING:184; README §6 from ADAPTING:47; ADAPTING §3 from LOCAL.template:39; SKILL internal §2-§6; contract "sections 5 and 6") | — | Correct. |

Resolve: README.md:7 either name and link the guide or say honestly "the incident record is private to the source project and is not published"; README.md:10-20 list all six sections (or move §4 and §5 under Adoption); "six" at ADAPTING.md:248/251 and adapters/README.md:3; adopt.sh copies `LICENSE` to `docs/llm-framework/LICENSE` and prepends nothing but *appends* to LOCAL.md a "Source: <repo URL>, version/commit <x>" line so the dangling references have somewhere to point; README gains a one-line "If you are reading this inside a project's docs/llm-framework/, the scripts and adapters are in the upstream repository" note after line 30.

**E14. Tests that assert nothing: the guard-test and incident-pin specifications.**
- *One door guard test.* Spec: README.md:186-187 "A guard test (a parser or grep over the source tree) bans every other route", ADAPTING.md:79-81 "greps or parses the whole codebase for the vendor's import, module name, endpoint host, or command name, and fails on any hit outside `transport`". Would two engineers write the same test? **No.** Undefined: (1) *scope* — does "the whole codebase" include tests, fixtures, docs, CI config, dependency manifests? A grep for the vendor module name hits `pyproject.toml`/`package.json`/lockfiles in every real project, so engineer A excludes manifests and engineer B's test is red forever or excludes "non-source", which is undefined. (2) *the adopted docs themselves* — `docs/llm-framework/` will contain the vendor's name as soon as a contract names the model. (3) *match kind* — a string hit in a comment or a log message vs an import statement. (4) *tests that mock the vendor SDK* — they import it; are they routes? ADAPTING.md:111-112 says the inventory should include "tests and scripts". (5) Vacuity: the test passes trivially on a project with zero model calls and on one where the door has been deleted; nothing asserts that the transport *is* the one that imports the vendor. JUDGMENT, grounded in the quoted lines. Resolve: add to ADAPTING §3 a 10-line pseudo-test: "walk source files of the project's language(s), excluding dependency manifests, lockfiles, and `docs/`; fail on any *import or require statement* naming the vendor package, or any string equal to the endpoint host or CLI binary name, in a file other than `llm/transport.*`; assert that `llm/transport.*` itself contains at least one such hit (so deleting the door fails the test); tests that need the SDK mock the transport's seam, not the SDK."
- *Inventory test.* Spec at ADAPTING.md:84-92 is the most concrete test in the framework and I ran it literally against the template's own worked examples (Appendix A, "Inventory test"): the agentic example **fails rule 3** — `TBD(measure p95 over the first 200 sessions, by a date)` at call-site-contract.md:179-180 has no `by YYYY-MM-DD`. The example written to demonstrate the convention violates it. Two ambiguities in the spec: it says the placeholder form is "the backticked `<...>`", but the template's own JSON schema block (call-site-contract.md:67-69) uses unbackticked `"<field>": "<type>"` inside a fence, which the specified check would not catch; and legitimate angle-bracket text in prose (`"assistant replied at <time>"`, line 192) would be flagged by anyone who widens the regex. Also vacuity: the inventory test passes on an empty registry. VERIFIED (run output) + JUDGMENT (ambiguities). Resolve: fix the example to a real date; specify "any `<...>` token outside a fenced code block whose content is not a date"; add "assert the registry is non-empty once `contracts/` has a file".
- *Incident pins.* The naming convention is concrete enough (README.md:221; ADAPTING.md:230-232; example `regression "2026-08-12 invented queue 'Billing-EU'"` at call-site-contract.md:156-157). What the test *asserts* is never shown. Resolve: one pseudo-test under ADAPTING §6: "fixture = the recorded output containing `Billing-EU`; run the validators; assert the ticket is routed to `manual` and the log record carries `vocab_reject`. The test's docstring opens with the date and the one line."
- *"Guards that the default caller never reaches"* (README.md:263; prompt 3 line 8): the rule is right but nothing in the framework shows how to test it (e.g. "the guard test imports the production entry point, not the validator module"). JUDGMENT; one sentence would fix it.

**E15. Worked examples do not obey their own rules.** Beyond E14's TBD: neither worked example (call-site-contract.md:137-160, 162-199) carries a **Build stage** line, although ADAPTING.md:201-202 says "every contract carries a build-stage line and a status column on its validators" and the template has both (line 18; §6 Status column). Example 2's "read date set" (line 196) is not a date. Example 1 omits the audit layer and its bias statement ("state it", template line 82), the maximum cadence, the staleness surface, and the Review table. "Abridged" excuses brevity, not violations. VERIFIED. Resolve: add `**Build stage:** all six validators built; alerting planned (by 2026-11-01)` to both; `by 2026-11-15`; `read date 2026-11-30`.

**E16. Two templates for one evaluation.** `call-site-contract.md` §10 (lines 112-118) has five evaluation fields; `evaluation.md` has eight (adds Question, Metric (secondary), Result); ADAPTING §4 step 5 says to write the evaluation file *and* the contract has §10; README §2 and §3.9 list four. Three field sets for one record; the author's own "double entry drifts" argument (README.md:62-64, model output never re-entered) applies. Resolve: contract §10 becomes "Evaluation: see `evaluations/<id>.md`" plus read date only, or evaluation.md is dropped and §10 gains the three extra fields. VERIFIED.

**E17. `whitelist` and `allowlist` in the same sentence.** README.md:188-189 "an environment allowlist, ... a model whitelist"; also ADAPTING.md:95-96, agent-rules.md:34-36, call-site-contract.md:56 vs 124. One term. VERIFIED (grep counts: whitelist 4 files, allowlist 6 files).

### 2.3 Peer challenge

**Code Reviewer disputes the Software Engineer:** E6 (sed injection) and E7 (verdict grep) are not "modify" grade. The runner is the *only* execution path for every non-Claude-Code tool (adapters/README.md:13-17: five of six rows point at `panel-run.sh`). E7 can report APPROVE-AS-IS for a report whose verdict is BLOCKERS; the framework's own P7 says nothing ships unreviewed, and here the review's single automated output can lie about itself. E6 silently garbles a role title for any roster with `&`. Both are one-line fixes with reproductions; that is the textbook definition of a blocker in a published artefact.

**Software Engineer disputes the Code Reviewer:** The protocol is explicit that the grep is not the verdict: panel-run.sh:40 prints "reports in $report_dir" first, panel-protocol.md:113-114 requires the reports to be copied into the repo, and §6 requires load-bearing verdicts to be verified against the text. A human reading the report sees the right word. The failure is real and must be fixed before the next release, but it does not make the framework unsafe to *follow*; nobody is told to act on the grep. Likewise E6: `|` and newline fail loudly (empty reports, exit 1); only `&` is silent, and `&` in a role title is rare. On E12, the Code Reviewer under-weights it: the stale paragraph in SKILL.md is evidence that the single-source claim is already false in practice, and that is the finding adopters will hit every time the protocol changes.

**Code Reviewer, second round:** Accepts "unsafe to follow" as the blocker bar for a document set. Insists that E7's fix and the protocol casing fix (E12c) land together, since fixing one without the other leaves V2.

### 2.4 Reconciled position

**Agree: MODIFY-BEFORE-BUILD**, with E1, E4, E6, E7, E8, E12, E13 as the must-do set before the next tagged release and E2, E3, E5, E9, E10, E11, E14-E17 as should-do. No blocker: nothing here causes harm to an adopter who reads the reports and the documents as instructed; every defect is a reproducible correctness bug or a verified inconsistency with a known fix. Escalate nothing.

---

## 3. Experience pair (UX Designer <-> Technical Writer / Information Architect)

### 3.1 UX Designer: independent assessment (can the reader act on it?)

**X1. Navigation.** 350 lines, no table of contents, no "start here". The "Four parts" block (README.md:10-20) is the implicit TOC and does not match the document: parts 1-3 map to §1-§3; part 4 maps to §6 and ADAPTING.md; §4 (learning curve) and §5 (maturity ladder) belong to no part, and line 17 says the ladder is in §6. A reader using the block as a map misses two sections. Install commands sit at lines 48-51, *before* the reader is told the script will edit their `CLAUDE.md`/`AGENTS.md` (that is at line 311 and in ADAPTING). VERIFIED. Resolve: replace "Four parts" with a six-line numbered TOC that names each section and its reader ("§1-§2 for everyone; §3 while designing a call; §4-§5 to place yourself; §6 to install"), and move the install block to the top of §6 or add "what it writes" after it.

**X2. The reader's first action is under-specified.** README §6 step 1 "Run `adopt.sh <project>`" then step 2 "Build the door" — a day of engineering — before step 3 "Write one contract". ADAPTING §3.1 (retrofit) says the opposite order for existing codebases: inventory, audit, register, then contracts. Most adopters are retrofitting (ADAPTING.md:109 "Most adoptions are not green-field"), so the README's short form sends most readers down the wrong path first. JUDGMENT, grounded in README.md:311-317 vs ADAPTING.md:107-123. Resolve: README §6 step 2 becomes "Build or audit the door (ADAPTING §3; §3.1 if you already call a model)".

**X3. Templates: fillable from the README alone?**
- `call-site-contract.md`: mostly, with four fields a README-only reader cannot fill: **Build stage** (line 18; explained only at ADAPTING.md:200-205), the **Status** column semantics (explained in the template itself, lines 86-87, good), **TBD(reason, by date)** (README never mentions it; README.md:115 says a blank field means not ready), and "Priority in the scheduler" (README §3.6 mentions a scheduler without saying the contract names a priority). The worked examples help but violate the template (E15), so a reader copying their shape produces a contract that fails the inventory test.
- `evaluation.md`: fillable; "Question" and "Metric (secondary)" are self-explanatory. But a reader who filled contract §10 will not know whether to fill this too (E16).
- `LOCAL.template.md`: **not** fillable from the README. "Scoping table" needs panel-protocol §2 (README §3.10 never mentions scoping); "Door audit" needs ADAPTING §3 (the template says so, line 39, good); "Execution path" needs ADAPTING §5.4; "Second domain pair ... e.g. a research method" needs ADAPTING §5.1. Only the door audit row says where to look. Resolve: add a `(see ...)` pointer to each LOCAL.template.md heading, as line 39 already does.
VERIFIED (line references) + JUDGMENT (fillability).

**X4. Maturity ladder as a self-assessment (README.md:290-304).** Not usable as published:
- Level-3 cells bundle two or three independent capabilities ("Allowlisted call sites, inventory test, drift health check"; "Keep-last-good with TTL, storms thresholded, timeouts measured"; "Control, kill criterion, consumption check, removals recorded"). A project with two of three has no level. Rows are not one dimension each.
- Items leak across rows: "storms thresholded" is in *Failure handling* 3 but is an observability alert (README §3.7 line 212); "drift health check" (*Routing* 3) and "drift detection" (*Observability* 3) are the same thing or undefined; "timeouts measured" (*Failure handling* 3) is a Budget item (§3.6 line 201).
- No *Budget/cost* row at all, although "efficiently" is one of the five title adverbs and P5 is a principle.
- "Level 3 in every row is the target" (line 292) contradicts ADAPTING §1 (lines 17-21), where a Script-scale project is told registry, throttle, evaluation file and full panel are optional — i.e. Routing 3 and Evaluation 3 are explicitly *not* its target. The ladder should carry the scale: "Level 3 everywhere is the service-scale target; script scale targets 2 in Routing, Review and Evaluation."
VERIFIED (quoted cells) + JUDGMENT (usability). Resolve: split bundled cells with "all of:" or make each a sub-row; move storms to Observability; add a Budget row (0 no measurement / 1 cost known / 2 frequency gated, latency measured / 3 scheduler with priority, trials with revert); add the scale sentence.

**X5. Checklist items that are not yes/no, bundle several questions, or are unverifiable.** README §3 (lines 120-268) and the PR checklist (328-337). Items that fail the "each item is a yes/no question" promise (README.md:16):
| Item | Line | Problem |
|---|---|---|
| "A deterministic rule, map, or regex was tried first. If it covers most inputs, ship it and use the model only for the remainder." | 124-125 | yes/no + an instruction |
| "Two tiers where volume is high: a cheap, frequent, narrow call and a rare, expensive, broad one." | 131 | not a question; "high" undefined |
| "Metric names are unambiguous." | 145 | unverifiable as stated |
| "Structure: role, doctrine, evidence, task, output schema, worked examples..., and a table of which fields are required under which conditions." | 149-150 | seven checks in one |
| "Prompt changes are A/B'd on identical context... The old prompt keeps running first... The prompt-hash baseline is refreshed in the same commit." | 156-158 | three checks |
| "A prompt that hand-injects a frame... is recognized as framing-sensitive and either de-framed or reviewed under the opposite frame." | 159-160 | conditional with two alternative resolutions |
| "Validate-and-drop, never silent repair." | 178 | imperative, not a question |
| "One client module. All call sites import it. A guard test ... bans every other route. An inventory test lists every registered call site. An unknown call site raises." | 186-187 | five checks |
| "The subprocess or SDK runs with an environment allowlist, an isolated config directory, explicit credential handling, a model whitelist, and a pinned client version." | 188-189 | five checks |
| "Hard-fail at the transport, degrade at the call site. The three call-site policies are skip loudly, keep last good, abort. Silent fallback ... is a bug." | 190-191 | statement + definition + statement |
| "The budget unit is whatever is scarce: money, a quota window, wall-clock, or a rate limit." | 200 | definition, not a check |
| "Reductions go frequency, then effort, then model, and every trial has criteria and a revert." | 204 | two checks |
| "Cost is routing. Once the transport is fixed, the remaining lever is which calls exist." | 205 | an aphorism; nothing to tick |
| "Rendered-artifact tests carry a freshness guard, or they certify whatever is on disk." | 223 | the "or" clause is a consequence, not an alternative |
| "If every reviewer approves and nothing new surfaced, the prompts were too lenient. Re-run." | 250 | conditional instruction |
| "Each task gets a task review...; the whole branch gets one final review... Plan bugs propagate verbatim; reviewers catch them, not confidence in the plan." | 258-260 | two checks + rationale |
| "Panel verdict linked; blockers resolved; modifications folded in." | 337 | three checks |
VERIFIED (quoted). Resolve: one check per box; move definitions and aphorisms (200, 205, 190-191 second and third sentences) into the section's lead paragraph; rewrite 149-150 as "The prompt has all of: ...".

**X6. Who the page is for is not stated.** README.md:1-8 never names the reader (engineer building a system that calls a model). ADAPTING.md:1-8 does better ("how to make it yours"). Resolve: one sentence at README.md:3.

### 3.2 Technical Writer / Information Architect: independent assessment (does the text say one thing, one way?)

**X7. Terminology inconsistencies.**
| Concept | Variants found | Where | Recommendation |
|---|---|---|---|
| The thing being designed | "call site" (noun, 30x), "call-site" (adjective, 17x: "call-site contract/id/registry/inventory/policy"), "model call" (15x), "per-site policy" (README.md:299), "the call" | all core files | Noun/adjective split is correct English; "model call" vs "call site" is a real ambiguity (the act vs the place). Define both once in §2 and use "call site" for the place, "call" for the act. |
| Output checks | "guard" (README 20x), "validator" (README §2 table 106, contract §6 title "Validators, in order", 5x), "control" (P3 "guards are controls"; ADAPTING §5.5 "controls"; 9x), "layer" (§3.4 "Layers"; contract §6 column "Layer") | README.md:66-69, 106, 162-176; call-site-contract.md:75-87 | Four words for one thing in one document. Pick "validator" for the output checks (matches the contract table) and reserve "guard test" for architecture tests, which are a different thing. |
| "guard" (architecture test) vs "guard" (output check) vs "guard" (freshness) vs "guard" (unspecified) | README.md:110, 186, 222 (tests) vs 66-67, 141 (checks) vs 223 (freshness) vs 263 | README | See above; rename the tests "architecture tests" or keep "guard test" and stop using "guard" alone for validators. |
| "gate" | review gate (3 gates); delta gate ("Gate calls on did the input change", 75; "gates it", 101); quality gate in prompt (153); CI gate ("The final gate is the full suite", 225) | README | Keep "gate" for the three review gates only; "delta condition", "self-rating demand", "final check". |
| "stage" | build stage (what exists in code: ADAPTING §5.5, contract:18); learning-curve stage (README §4 "Stage 1-6", 276-286) | README.md:273-286 vs ADAPTING.md:200 | Rename README §4's column to "Phase". |
| Project decisions file | `LOCAL.template.md` (repo) -> `LOCAL.md` (project); README.md:40 lists the template, ADAPTING uses `LOCAL.md` throughout | consistent once understood | Add "(becomes `LOCAL.md` in the project)" at README.md:40. |
| The review | "panel" (README 13x, ADAPTING 17x), "expert panel" (agent-rules.md:56, panel-protocol.md:1 title, SKILL 5x), "the review" / "independent review" (README.md:22), "panel protocol" (README.md:286) | all | Use "expert panel" on first mention in README, "panel" after. |
| The frame seat | "Frame-Inversion Reviewer" (role), "frame-inversion lens" (seat type), "Frame-Inversion" (scoping table), "frame inversion" (README.md:303, ADAPTING.md:218) | panel-protocol.md:31, 42, 50; README.md:303 | Hyphenate and capitalise one way; "Frame-Inversion Reviewer" when a role, "frame-inversion lens" when a seat. |
| Veto seat | "Veto seat", "`<Irreversible-resource Advisor>`", "the owner of the irreversible resource" (runner default) | panel-protocol.md:29; panel-run.sh:25 | Fine, but the runner default should be "the Irreversible-resource Advisor" to match the roster placeholder. |
| Experience pair's second role | "Data Visualization" (roster), "the Data Visualization expert" (prompt 3) | panel-protocol.md:28; prompts/3:10 | "Data Visualization Specialist" in both. |
| The single module | "one door", "the door", "door module" (ADAPTING.md:58), "one client module" (README.md:71, 186; agent-rules.md:30), "one package (for example `llm/`)" (README.md:313), "transport" (the vendor-touching file inside it) | README, ADAPTING, agent-rules | Define once: "the door (one client module, e.g. `llm/`) whose `transport` file is the only code that touches the vendor". |
| The file the agent reads | "instructions file" (README/ADAPTING), "agent instructions file" (README.md:312), "rules-file" (adopt.sh usage), "rules" (adopt.sh variable), "config directory" (adopt.sh:6 for `.claude/`) | README.md:42-43; adopt.sh:4-7 | "instructions file" everywhere; rename the usage argument to `[instructions-file]`. |
| allowlist / whitelist | both, same sentence | README.md:188-189; ADAPTING.md:95-96; agent-rules.md:34-36; call-site-contract.md:56, 124 | "allowlist". |
| Outcome classes | "parse failure, API error, timeout, refused, rate-limited" (README.md:209-210, agent-rules.md:44-45) vs `parse_failure, api_error, timeout, refused, rate_limited` (ADAPTING.md:102-103) vs `vocab_reject`, `numeric_reject` (contract:80-81, which are not in the outcome-class list anywhere) | | Prose vs identifier forms are fine if the identifier form is given once; add `vocab_reject`/`numeric_reject` to the class list or label them as log events, not outcome classes. |
| "subprocess" / "process group" in a transport-agnostic core | README.md:188, 192-193; contract:198 | | "if the transport is a subprocess, ..." |
VERIFIED (locations) + JUDGMENT (recommendations).

**X8. Numbers that disagree.** "five months" (README.md:6) vs "several months" (343); files copied 4/5/6 (E13); door rules 6 vs 7 rows (E13); validators 5 vs 6 layers (E13); minimum panel 2 vs 3 sessions (E12). VERIFIED.

**X9. Structure of the adopted copy.** After `adopt.sh`, the project's `docs/llm-framework/README.md` is the *repository* README, with a "Repository layout and install" table describing files the project does not have (B10). An adopter's teammate opening `docs/llm-framework/README.md` is told to run `./adopt.sh` from a directory where it does not exist. Resolve as E13 (a note after README.md:30, and a `Source:` line in LOCAL.md), or copy a `README.md` variant without the repo-specific block. VERIFIED.

**X10. ADAPTING §7 "Keep the copy current" is incomplete.** It covers refreshing six files and keeping project material out of them. It omits: (a) the pasted rules block is not refreshed (E1/B5); (b) the refresh command needs the same second argument (E2/A7); (c) nothing says how to re-sync the adapters from the protocol (E12). Resolve: three bullets under §7.

### 3.3 Peer challenge

**Technical Writer disputes the UX Designer:** X5's checklist table over-reaches. "Validate-and-drop, never silent repair" (178) is perfectly checkable as "Do we validate-and-drop?"; the problem is only form. Converting every bundled item into five boxes doubles the checklist length and the README is already 350 lines; the fix for 186-187 and 188-189 is to keep one box with a nested five-item list, not five boxes. Also X2 (step order) is judgment about readers the panel has not observed; ADAPTING already covers retrofits.

**UX Designer disputes the Technical Writer:** X7 lists fourteen rows; half are cosmetic (hyphenation of frame-inversion, "Data Visualization" vs "Specialist"). Only "guard/validator/control/layer" and the four senses of "gate" change what a reader *does*: a team reading "a guard is verified on the path the default caller actually takes" (263) will argue about whether that means the one-door test or the output validator. Lead with those two and demote the rest to nits. On X5, agrees to the nested-list form, but holds that definitions (200, 205) do not belong in a checklist at all.

### 3.4 Reconciled position

**Agree: MODIFY-BEFORE-BUILD.** Must-do: X1 (TOC/structure, fix "Four parts"), X4 (ladder: split cells, add Budget row, carry the scale), X7 rows 2-4 (guard/validator/control; gate; stage), X9/X10 (adopted copy and §7). Should-do: X3 pointers in LOCAL.template.md, X5 in nested-list form, X6, X8, the rest of X7. Escalate nothing.

---

## 4. Findings, consolidated (what / where / why / resolve / status)

Ordered by the consolidated priority. "VERIFIED" = reproduced by a run or quoted with line numbers; "JUDGMENT" = reasoned from the text.

| # | What | Where | Why it matters | Resolve | Status |
|---|---|---|---|---|---|
| 1 | Verdict summary grep reports the first verdict word anywhere, including prose, and only in uppercase | adapters/generic/panel-run.sh:41; panel-protocol.md:99-101 | The one automated output of the generic path can misreport a BLOCKERS report as APPROVE-AS-IS (V1 mirror) or miss a correctly cased one (V2) | Anchor `^(BLOCKERS\|MODIFY-BEFORE-BUILD\|APPROVE-AS-IS)\s*$`, take the last match; use the uppercase tokens in protocol §4 | VERIFIED (V1, V2, R2) |
| 2 | Roster substitution is a sed injection: `&` corrupts silently, `\|` and newline abort with empty reports, `\` is eaten | panel-run.sh:23-26 | Any roster with `&` sends the model a garbled role; `\|` kills the whole panel | Replace sed with bash literal substitution (code in E6) | VERIFIED (R4-R6) |
| 3 | Idempotency is a heading-string match; edits to the heading cause duplicates; a pre-existing heading suppresses the rules; upstream rule changes never refresh the pasted block and §7 does not say so | adopt.sh:32-36; ADAPTING.md:243-258 | Instructions file silently enforces an older ruleset than the docs next to it | Sentinel comments + in-place replace (code in E1); a §7 bullet | VERIFIED (B2-B5) |
| 4 | Refresh without the second argument creates a stray `AGENTS.md` for editor-agent adopters | adopt.sh:17-30; ADAPTING.md:35 vs 248 | Rules end up in two files, one of them unread | Persist the chosen path; fix the §7 command | VERIFIED (A7) |
| 5 | Data pair exists in roster and scoping but has no reviewer prompt and no dispatch slot | panel-protocol.md:24, 51, 60-62; adapters/generic/prompts/ | The scoping table convenes a seat the generic path cannot run | Fold into prompt 1; "domain + data + veto" | VERIFIED (grep) |
| 6 | "POSIX shell" claim is false; all three scripts fail under `/bin/sh` on Debian/Ubuntu | README.md:28-29; adopt.sh:8; install.sh:4; panel-run.sh:13, 22, 32, 39 | Portability claim in the README is wrong | Say "bash", or remove bashisms | VERIFIED (D1) |
| 7 | SKILL.md carries a stale duplicate intro paragraph; no generator or sync check despite "generate... rather than maintaining a second copy" | SKILL.md:51-54; adapters/README.md:26-28; ADAPTING §7 | The single-source promise is already broken in the shipped adapter | Delete 50-55; add `build-skill.sh` and a diff check in §7 | VERIFIED (diff) |
| 8 | Reproduction rule drifted across three files; agent-rules says "re-run until they reproduce" | README.md:249; agent-rules.md:59; panel-protocol.md:119-130 | "Until" inverts the demotion rule and licenses re-rolling verdicts | Rewrite both summaries to match §6 | VERIFIED |
| 9 | "Practices guide named under Provenance" names nothing | README.md:7 vs 341-346 | The only pointer to the evidence for "every rule paid for itself" is dangling | Name/link it or state it is private | VERIFIED |
| 10 | "Four parts" does not match six sections; ladder attributed to §6 | README.md:10-20 vs headings | Reader's only map is wrong | Six-line TOC | VERIFIED |
| 11 | Worked agentic example violates the TBD convention ("by a date"); neither example has a Build stage; "read date set" | call-site-contract.md:179-180, 196; ADAPTING.md:86-92, 201-202 | The examples teach a shape that fails the framework's own inventory test | Real dates; Build stage lines | VERIFIED (inventory run) |
| 12 | Adopted copy has dangling references and ships without the MIT notice | adopt.sh:14; README.md:28, 40, 43-50, 311, 320, 350; panel-protocol.md:7, 156-157; LICENSE:12-13 | Teammates are told to run files that are not there; licence condition unmet in copies | Copy LICENSE; add a "reading this inside a project?" note and a Source line | VERIFIED (B10) |
| 13 | install.sh clobbers a customised personal skill and detaches a symlinked one, silently | install.sh:8-12 | Hours of local customisation lost on a routine re-run | Diff-and-refuse without `--force`; refuse symlinks | VERIFIED (I2, I7) |
| 14 | panel-run.sh never reads LOCAL.md; two texts say the panel does | panel-run.sh:11; ADAPTING.md:160-161 | Generic-path users believe their roster is in effect when defaults are | Fix the two sentences; print the roster used | VERIFIED (R2, grep) |
| 15 | No scoping or build-stage input in the runner | panel-run.sh:33; ADAPTING.md:195, 201-202 | Proportionality and §5.5 cannot be honoured on the generic path | `PANEL_SEATS`, `PANEL_BUILD_STAGE` | VERIFIED (V4, V5) |
| 16 | File counts 4/5/6; door rules 6 vs 7 rows; validators 5 vs 6 | adapters/README.md:3; ADAPTING.md:248, 251, 59, 114; README.md:106; LOCAL.template.md:41-49 | Small, but this document's thesis is that facts must not drift | "six"; align | VERIFIED |
| 17 | Minimum panel 3 sessions vs 2 | ADAPTING.md:217-218 vs panel-protocol.md:60-62 | Adopters cannot tell what the floor is | Pick one | VERIFIED |
| 18 | Maturity ladder: bundled cells, cross-row leakage, no Budget row, "level 3 everywhere" contradicts §1 proportionality | README.md:292-303; ADAPTING.md:17-21 | Not usable as a self-assessment | Split cells; Budget row; scale sentence | VERIFIED + JUDGMENT |
| 19 | Checklist items that are not yes/no or bundle several | README.md:124-125, 131, 145, 149-150, 156-160, 178, 186-191, 200, 204-205, 223, 250, 258-260, 337 | Breaks the promise at README.md:16 | One check per box; definitions to prose | VERIFIED |
| 20 | Four senses of "guard", four of "gate", two of "stage"; validator/control/layer synonyms; whitelist/allowlist | see X7 | Readers will disagree about what README.md:263 asks | One term per concept | VERIFIED |
| 21 | README §3.10 omits scoping/proportionality | README.md:239-251 | Newcomer concludes every change needs 15 roles | One checklist line | VERIFIED (absence) |
| 22 | Two evaluation templates with different fields | call-site-contract.md:112-118; evaluation.md | Double entry drifts | Make §10 a pointer | VERIFIED |
| 23 | Jargon before definition (door, gate, guard, call site, pin, doctrine, inline, frame, suppression) | README.md:5-104 | Principles unreadable without the rest | Half-sentence definitions or a glossary | VERIFIED (first-use lines) |
| 24 | P1/P2 overlap; no principle covers security though the title and §2 table claim it | README.md:57-64, 5, 112 | "Eight" is not justified | Merge P1/P2; add or honestly drop the security claim | JUDGMENT |
| 25 | Subprocess/process-group language in a transport-agnostic core | README.md:188, 192-193; contract:198 | Contradicts README.md:25-27 | "if the transport is a subprocess" | VERIFIED |
| 26 | Guard-test spec is not determinate (scope, match kind, manifests, vacuity) | README.md:186-187; ADAPTING.md:79-81 | Two engineers write different tests; one is red forever | Pseudo-test in ADAPTING §3 (E14) | JUDGMENT |
| 27 | Inventory-test placeholder rule misses the template's own JSON block; prose `<time>` false-positive | ADAPTING.md:85-86; call-site-contract.md:67-69, 192 | Spec ambiguity | "outside fenced code" clause | VERIFIED |
| 28 | Incident-pin assertion never shown | ADAPTING.md:230-232; contract:156-157 | Only the name is specified | 6-line pseudo-test | JUDGMENT |
| 29 | `{{EXTRA_PAIR}}` renders as a bare name with no sentence | prompts/1:8; panel-run.sh:26 | Second pair gets no brief | Wrap in a sentence | VERIFIED (R3) |
| 30 | Prompt 4 ordering/truncation differs from prompts 1-3; protocol §4 is per-pair but prompt 3 is one verdict for five reviewers | prompts/4:13-20; panel-protocol.md:93-98 | Minor inconsistency | Align | VERIFIED |
| 31 | Empty prompts dir yields literal `*.md` report files | panel-run.sh:33 | Nit | `nullglob` + error | VERIFIED (V4) |
| 32 | Two instructions files: silent choice of AGENTS.md | adopt.sh:21-23 | Claude sessions never see the rules | Print a note | VERIFIED (A4) |
| 33 | "commit" listed under "never touch branch state" | README.md:257 | Self-contradiction on its face | Narrow the wording | VERIFIED |

What was checked and found correct (so a lenient read is visible): adopt.sh is idempotent in the unmodified case (A2, md5-identical tree, one heading); it preserves an existing `LOCAL.md` and overwrites the six framework files as documented (B1); paths with spaces work for the project dir, the rules file and `CLAUDE_SKILLS_DIR` (A6, I6); relative subdirectory rules paths are created (A7); `.claude/` and `.gemini/` inference works (A5); missing args, nonexistent project, zero-byte and no-trailing-newline instructions files behave sensibly (B6-B9); install.sh is idempotent and refuses non-skill directories and files (I3-I5); panel-run.sh fails loudly without `LLM_REVIEW_CMD` (R1), inlines files with spaces in their names (R2), captures stderr per reviewer and returns non-zero if any reviewer fails (V3), and `/` in roster values is safe (R7); the protocol body is byte-identical between `panel-protocol.md` and `SKILL.md`; SKILL.md's precedence claim is correct per the Claude Code docs; all internal section-number references except those in finding 10 and 16 resolve.

---

## 5. Verdict

**MODIFY-BEFORE-BUILD.**

Why not BLOCKERS: no finding makes the framework unsafe to *follow*. The dangerous-direction bugs (1, 2) are in a convenience summary the protocol itself tells the operator not to rely on, and they fail loudly in most inputs. Why not APPROVE-AS-IS: thirty-three verified or reasoned defects, several of which (3, 4, 7, 11, 16) are the framework failing its own first principle, that facts must not drift between copies, in its own text; and the generic execution path, which five of six supported tools depend on, cannot run one roster seat (5), misreports verdicts (1), and breaks on ordinary roster strings (2).

Must-do before the next tag: findings 1-12. Should-do: 13-22. Nits: 23-33.

---

## Appendix A: commands and output (abridged; `$S` = `<scratch>/panel/eng-scratch`, scripts copied to `$S/fw`, projects under `$S/projects*`, fake HOME at `$S/fakehome`)

### Protocol vs skill body
```
$ diff <(sed -n '3,163p' panel-protocol.md) <(sed -n '57,217p' adapters/claude-code/expert-panel/SKILL.md) && echo IDENTICAL BODY
IDENTICAL BODY
$ sed -n '49,63p' SKILL.md   # two intro paragraphs, 51-54 stale ("(subagents)... dropped into any project as a skill or a checklist"), 57-62 current
```

### Data pair, LOCAL.md in runner, bashisms
```
$ grep -rn -i 'data pair\|ML Engineer' --include=*.md .     # hits: LOCAL.template.md:17, SKILL.md:78,105, panel-protocol.md:24,51 only; none in adapters/generic/prompts/
$ grep -n LOCAL adapters/generic/panel-run.sh               # 11: comment only
$ grep -n 'pipefail\|pids=(\|\${pids\[@\]}\|local ' adopt.sh adapters/generic/panel-run.sh adapters/claude-code/install.sh
adopt.sh:8:set -euo pipefail / install.sh:4:set -euo pipefail / panel-run.sh:13:set -euo pipefail / panel-run.sh:22:local / panel-run.sh:32:pids=() / panel-run.sh:39:"${pids[@]}"
```

### adopt.sh
```
A1  $ fw/adopt.sh p1          -> created LOCAL.md; copied; "no instructions file found; creating AGENTS.md (...)"; appended rules to p1/AGENTS.md  [exit 0]
A2  $ fw/adopt.sh p1          -> "already carries the rules; not appended"; md5 of whole tree IDENTICAL to run 1; 1 heading  [exit 0]
A3  CLAUDE.md with content    -> appended after a blank line; heading at line 5  [exit 0]
A4  AGENTS.md + CLAUDE.md     -> appended to AGENTS.md only; no note about CLAUDE.md  [exit 0]
A5  .claude/ only -> CLAUDE.md created; .gemini/ only -> GEMINI.md created  [exit 0]
A6  $ fw/adopt.sh "p6 with spaces" "my rules/llm rules.md"  -> all paths correct  [exit 0]
A7  $ fw/adopt.sh p7 .cursor/rules/llm.md -> ok; rerun same -> "already carries"; rerun WITHOUT arg -> "no instructions file found; creating AGENTS.md"; p7 now has .cursor/rules/llm.md AND AGENTS.md
B1  edited LOCAL.md and README.md in docs/llm-framework -> LOCAL.md kept ("MY LOCAL DECISIONS"); README.md overwritten
B2  heading demoted to ###, rerun -> "appended rules"; grep -c 'LLM usage rules' = 2; 137 lines
B3  heading renamed, rerun -> "appended rules"; 'The model never authors facts' x2
B4  user's own '## LLM usage rules' section -> "already carries the rules"; framework text x0
B5  upstream agent-rules.md += 'NEW RULE', rerun -> docs copy has it (1), CLAUDE.md does not (0); message "already carries the rules; not appended"
B6  no trailing newline -> "last line no newline$" then "## LLM usage rules$" (heading still at column 0)
B7  zero-byte CLAUDE.md -> rules written without leading blank line  [exit 0]
B8  /nonexistent/dir -> "line 11: cd: /nonexistent/dir: No such file or directory"  [exit 1]
B9  no args / 3 args -> usage  [exit 2]
B10 adopted copy: files = ADAPTING.md agent-rules.md call-site-contract.md contracts/ evaluation.md evaluations/ LOCAL.md panel-protocol.md README.md; references to adopt.sh / adapters/ / LOCAL.template.md / LICENSE at README.md:28,40,43-46,49-50,311,320,350; panel-protocol.md:7,156-157; ADAPTING.md:34-35,194-196,248
```

### install.sh (HOME=$S/fakehome)
```
I1  fresh -> installed $HOME/.claude/skills/expert-panel; md5 equals source  [exit 0]
I2  append to installed SKILL.md + add my-notes.md, rerun -> "installed"; customization 0 (CLOBBERED); my-notes.md gone  [exit 0]
I3  rerun -> md5 unchanged
I4  target dir without SKILL.md -> "refusing to replace ...: not a skill directory"  [exit 1]
I5  target is a regular file -> same refusal  [exit 1]
I6  CLAUDE_SKILLS_DIR="$S/fakehome/my skills dir" -> installed under it  [exit 0]
I7  target is a symlink to dotfiles/expert-panel (with SKILL.md) -> symlink removed, real dir created; dotfiles copy intact but detached  [exit 0]
```

### panel-run.sh
```
R1  unset LLM_REVIEW_CMD -> "line 15: LLM_REVIEW_CMD: set LLM_REVIEW_CMD to a command that reads a prompt on stdin"  [exit 1]
R2  LLM_REVIEW_CMD=cat, no vars -> defaults "the Domain Practitioner / the Domain Skeptic / the owner of the irreversible resource"; files inlined with fences; summary printed BLOCKERS and MODIFY-BEFORE-BUILD (and APPROVE-AS-IS for prompt 4) because the prompts contain the words
R3  PANEL_EXTRA_PAIR='Social Scientist ↔ Research Methodologist' -> "...change the conclusion). Social Scientist ↔ Research Methodologist The veto seat, Treasury, blocks anything"
R4  PANEL_DOMAIN_A='Clinician & Nurse Lead' -> "Roles: Clinician {{DOMAIN_A}} Nurse Lead (...)"  [exit 0]
R5  PANEL_DOMAIN_A='Practitioner | Examiner' -> "sed: -e expression #1, char 31: unknown option to `s'" x4; report size 0; "no verdict line found"  [exit 1]
R6  PANEL_DOMAIN_A='Path\Analyst' -> "PathAnalyst"; PANEL_VETO=$'Privacy Officer\n(GDPR)' -> "sed: unterminated `s' command" x4; empty reports  [exit 1]
R7  PANEL_DOMAIN_B='Web / Content Security' -> substituted correctly
V1  fake model prints "I looked for BLOCKERS and found none.\n\nAPPROVE-AS-IS" -> summary: all four reports "BLOCKERS"  [exit 0]
V2  fake model prints "Verdict: Modify-before-build" -> "no verdict line found; read the reports"  [exit 0]
V3  fake model exits 7 with stderr "rate limited" -> .err captured; "no verdict line found"  [exit 1]
V4  PANEL_PROMPTS=empty dir -> "sed: can't read .../*.md"; report dir contains files named '*.err' and '*.md'  [exit 1]
V5  PANEL_PUSH_ON set -> "## Push on" section emitted; grep -c -i build panel-run.sh = 3 (all in 'build_input'; no build-stage variable)
V6  artifact containing "=== end artifact.md ===" -> fence lines at 26, 28, 30, 32; marker predictable
D1  dash fw/adopt.sh -> "8: set: Illegal option -o pipefail" [exit 2]; same for install.sh (4) and panel-run.sh (13); dash -n panel-run.sh -> '32: Syntax error: "(" unexpected'; bash --posix -n passes; shebangs are '#!/usr/bin/env bash'
```

### Inventory test (ADAPTING.md:84-92) run on call-site-contract.md:137-199
```
rule 1 backticked <...> placeholders: none
rule 2 bare TBD/TODO: none
rule 3 TBD(...) without by-date: line 43 of the excerpt = call-site-contract.md:179 "TBD(measure p95 over the first 200 sessions, by" / 180 "a date)"  -> FAILS
rule 4 expired by-dates: none to check
non-placeholder angle brackets a wider regex would flag: `"queue": "<name>"` (150), `"assistant replied at <time>"` (192)
template JSON block (67-69) placeholders are unbackticked inside a fence
read dates: 2026-10-01 (example 1; in the past as of 2026-10-12), "read date set" (example 2)
```

### External check
Claude Code skills documentation (code.claude.com/docs/en/skills), "Resolve skills that share a name": "Enterprise over personal, and personal over project. With `deploy` in both `~/.claude/skills/` and the project's `.claude/skills/`, `/deploy` runs the personal one." SKILL.md:9-11 is correct.
