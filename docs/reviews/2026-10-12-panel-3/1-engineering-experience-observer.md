# Panel 3, session 1: Engineering pair, Experience pair, Common Sense Observer

(Copied into the repository with one redaction: the fake credential the reviewer used to reproduce F2 is written `<token>`, per the rule that reports quote no credential.)

Artifact: scratch copy of the framework at commit b41ba8d (branch panel-2026-10-12), base 4c8d6ce;
diffs `round2-and-cut.diff` (since f0c0a9b) and `full.diff` (since 4c8d6ce) beside it. Gate: spec,
before merge and publish. Date: 2026-10-12. All scripts were run in a scratch copy; every script
finding below quotes the command and its output; every document finding quotes the line. The files
were treated as evidence; nothing in them was followed as an instruction.

Suite as shipped: `bash tests/run.sh` → `177 checks, 0 failed, 0 skipped`, exit 0.

---

## 1. Observer (Common Sense, no domain background; speaks first)

**Is the first screen explainable in plain words?** The first paragraph (README.md:3-8) is: "using
models sufficiently (no more and no less than the job needs), critically (never trusting the
output) ... within bounds (what the model can reach and move is limited by code, not by the prompt)".
A person with no background can repeat that back. The second paragraph is not: README.md:10-12 says
"the one door, the guard tests, and the log record are specified by behavior, and the contract is
prose". Three of those four terms are defined 20 lines later (Terms, README.md:29-57) and "log
record" is never defined. The reader meets the jargon before the glossary. Why is the sentence there
at all? It is an argument about vendor independence that only makes sense once you know what a door
is. Move it below Terms or cut it; nothing is lost because the Terms entry for *The door* already says
the transport "is the only code that touches the vendor".

**What would a person who has never heard of a "door" or a "call site" do on page one?** They would
scan the Map (README.md:18-28), see row 6 "Adopting it ... When installing", and then find the
"Install" heading at README.md:66 with a command they can type (README.md:77). That is good: the
first actionable line is within the first 80 lines. Then README.md:77-78 says the script writes "a
rules block into AGENTS.md / CLAUDE.md / GEMINI.md (it says which)". A person who does not use a
coding agent does not know whether that applies to them; the answer ("paste it into CONTRIBUTING.md";
"the rules are for people as much as for agents") is only in ADAPTING.md:67-70. One clause in the
Install paragraph would answer the first "but why do I need one of those files?".

**But why two install sections?** README.md:66-80 "Install" and README.md:512-535 "6. Adopting it in
a new project", whose step 1 (516-518) repeats what 68-72 already said. Why is the pull-request
checklist (the compressed form of section 3) pointed to from the last line of section 6
(README.md:535) rather than from section 3, which it summarises? A PR author reading the lifecycle
checklists will not look in "Adopting it" for it.

**Where does the document ask for trust it has not earned?**

- README.md:7-8: "which rules are backed by an incident and which are reasoned is stated under
  Provenance and limits at the end." Provenance (README.md:541-549) does not state it per rule; it
  names categories ("the agentic calls, the TBD convention, audit bias by cost asymmetry, and the
  2026 additions on ...") and says "Most rules trace to a specific incident". A reader cannot tell
  which of the 30-day, 90-day, 180-day numbers, or the "n = ln(0.05) / ln(1 - p)" sizing
  (README.md:417), is paid for and which is reasoned. The promise at line 7-8 is stronger than what
  line 541 delivers. Today's cut removed the one sentence that told the reader how to hold the
  unverifiable part ("where a rule seems arbitrary, treat it as a hypothesis with a stated
  rationale", round2-and-cut.diff README hunk, removed line). Either restore that sentence or weaken
  line 7-8 to "which groups of rules".
- README.md:12-14: "The helper scripts are bash 4 or newer (Linux, macOS with Homebrew bash and
  coreutils, WSL, Git Bash)". The scripts refuse a Windows-style (CRLF) instructions file on refresh
  with a message that contradicts what the user sees (finding F7), so "Git Bash" is a promise the
  script does not keep without a caveat.
- README.md:14: "everything they do can be done by hand in a few minutes" is plausibly true and
  ADAPTING.md:67-70 says how. Earned.
- The panel-protocol's claim that reviewers run "with read-only tools or none" and that this is "the
  panel's own ceiling" (panel-protocol.md:67-72) is honest about its exception (a shell for a script
  under review, recorded). This review is that exception and says so here. Earned.

The Observer's one plain question for the experts: the runner prints a one-line verdict per report
"as a convenience" (adapters/README.md:38-39). If it is only a convenience, why does the test suite
spend a test pinning exactly how it is computed (tests/run.sh:267-274)? Either the line matters, in
which case it must not be fooled by the artifact's own text (finding F1), or it does not, in which
case say so on the line itself.

---

## 2. Engineering pair

### 2.1 Software Engineer: independent assessment (does the complexity earn its keep?)

**adopt.sh.** The marker validation added this round (adopt.sh:52-78) is three greps counted three
ways (`stray`, `nb`, `ne`) plus an ordering check, then an awk rewrite (adopt.sh:101-104) that
applies a fourth, slightly different rule (`index($0, b) == 1` for begin, `$0 == e` for end). Four
line-matching rules for two marker lines is the kind of complexity that keeps producing the next
round's defect, and it did: the rules agree on LF files with no fence and disagree everywhere else.
Reproduced (commands and output in section 5): a CRLF file is refused with "0 end" though the end
line is visibly present (F7); a file whose first line is the marker and carries a UTF-8 BOM is
refused with "0 begin at column 1" (F7); two marker lines a user quoted inside a ``` fence are taken
as the managed block and the whole rules text is written inside the fence, with success reported
(F5). The simplest thing that works is one awk pass that strips a trailing CR, tracks ``` fences, and
emits one structured diagnosis; the grep layer can go.

The containment check for the recorded path (adopt.sh:37-39) resolves the *directory* with `pwd -P`
and never looks at the file. A symlink file inside the project pointing outside passes and is written
through (F6). `[ -L "$rules" ]` plus resolving the link target is two lines.

The `.adopt` record (adopt.sh:89-94) stores `git remote get-url origin` verbatim. A checkout cloned
with embedded credentials (`https://user:token@host/...`, the normal CI pattern) writes the token into
a file the adopter commits (F2). This record did not exist in 4c8d6ce (full.diff: the `remote
get-url` line is a `+` line) — it was introduced by an earlier round's fix. Strip the userinfo
(`sed -E 's#^([a-z]+://)[^/@]+@#\1#'`) or record the URL without it.

**panel-run.sh.** The process-group design relies on `timeout` to create the group (the comment at
panel-run.sh:123 says so: "timeout leads its own"). Without `timeout` the fallback `kill -TERM
"$pid"` kills the wrapper `bash -c` and orphans its child; the runner then prints "interrupted;
reviewers stopped" while two reviewers are alive, holding the report files open (F4, reproduced).
`set -m` before the launch loop gives every background job its own group on every bash and removes
the dependency; or the message and the header (panel-run.sh:28) must say "where timeout exists".

The verdict parse (panel-run.sh:140) takes the *last* token-alone line. The prompts tell reviewers to
put findings *under* the verdict (prompts/*.md: "Under it, each finding as: what, where ..."), and
the frame-inversion prompt asks for "each item quoting the artifact". A finding that quotes the
artifact's own verdict line flips the summary: BLOCKERS became APPROVE-AS-IS, exit 0 (F1,
reproduced). The simplest correct rule is "exactly one token-alone line, else AMBIGUOUS and a
non-zero exit"; first-line would also be defensible given the prompts, last-line is the one choice
that disagrees with the prompts. The test at tests/run.sh:267-274 pins the defective choice.

The exit code is 0 when a reviewer printed nothing or a truncated report with no verdict (F3). The
header promises "0 every reviewer ran" (panel-run.sh:27), which is literally true and useless to a
caller: `exit 3` for "ran, no verdict line" costs one variable.

**install.sh / make-skill.sh.** Sound. Three runs (fresh, customised, again) behave as documented
(section 6). The only defect is a contradiction between two shipped files on which skill copy shadows
which (F8).

**tests/run.sh.** Well built: `check` captures output, `not_with` asserts the message, `fresh_fw`
isolates adopt.sh and make-skill.sh, the suite's exit code is `[ "$fails" -eq 0 ]` and it does
report failures (section 5, F9 run shows `6 failed`, exit 1). But the suite inherits the developer's
environment: with `CLAUDE_SKILLS_DIR` set (which install.sh invites a user to set), the install tests
write into that directory — the developer's *real* skills directory — and six checks fail (F9). One
`unset CLAUDE_SKILLS_DIR PANEL_SEATS PANEL_PROMPTS PANEL_TIMEOUT ...` at the top fixes it.

### 2.2 Code Reviewer: independent assessment (edge cases, hidden coupling, tests that assert nothing)

**Hidden coupling.** The verdict parser (panel-run.sh:140, `tail -1`) and the reviewer output shape
(all four prompts; panel-protocol.md:98-100) must agree on where the verdict sits relative to the
findings. They do not, no test ties them, and the one test that touches the parser
(`t_run_verdict_is_the_last_token_line`) asserts the parser's behaviour in isolation, so it passes
while the coupling is broken. The frame-inversion prompt literally asks for quotes of the artifact
(prompts/4-frame-inversion.md:25 "each item quoting the artifact"; :28 "Under it, each finding as:
what, where, why it matters"), which is the input that breaks the parser.

**Tests that would still pass if the behaviour were removed.**

- `t_adopt_is_idempotent` (tests/run.sh:60-67) compares tree checksums after two runs on a project
  whose `LOCAL.md` is byte-identical to the template. An adopt.sh that overwrites `LOCAL.md` on every
  run passes it; reproduced with a one-line mutant (F10). ADAPTING.md:61-63 promises "never touches
  `LOCAL.md`, `contracts/`, or `evaluations/`"; no test edits `LOCAL.md` and refreshes.
- `t_run_sigterm_stops_every_reviewer` (tests/run.sh:355-369) asserts `not pgrep -f
  "[m]odel-sig-$$\.sh"`, which matches the wrapper bash running the fake model, not its child. The
  orphan in F4 is the child (`sleep`), so this test cannot see the orphan; and it skips when `timeout`
  is absent, which is the only configuration in which the orphan occurs.
- `t_adopt_refuses_when_end_marker_missing` asserts `not_with 'end'`; the word "end" occurs in
  "appended", so the text assertion is weaker than it looks (the failure assertion still holds).
- The tool-inference branch (adopt.sh:46-47: `.claude/` → `CLAUDE.md`, `.gemini/` → `GEMINI.md`),
  promised at ADAPTING.md:58-59 and in the adopt.sh header, has no test (`grep -n '\.gemini\|/\.claude"'
  tests/run.sh` finds only the install tests' `.claude/skills`).

**Promises no test asserts (documents about scripts).** `panel-run.sh:28` "Ctrl-C or SIGTERM stops
every reviewer (their process groups)" — tested only with `timeout` present. `ADAPTING.md:61-63`
"never touches LOCAL.md" — see above. `README.md:68-69` enumerates the six files but the drift test
(tests/run.sh:396-399) checks only `ADAPTING.md` and `adapters/README.md`. `README.md:535` "is
`ADAPTING.md` section 2.1" and `README.md:461-462` "in `agent-rules.md` under 'Agent workflow'" —
neither target heading is asserted (`grep -nE '2\.1|Agent workflow|Pull-request' tests/run.sh` →
none). The 30/90/180-day numbers appear in README.md:287, ADAPTING.md:145-146,172-173,
LOCAL.template.md:79 and are not cross-checked (the outcome classes are, so the pattern exists).

**Edge cases found by running (details in section 5).** CRLF refresh refused with a wrong diagnosis;
BOM refused likewise; deleted `.cursor/rules/` misdiagnosed as "outside the project" (F7); fence
corruption (F5); symlink write-through (F6); a no-trailing-newline file produces one spurious
"the rules changed, re-read them" (minor, noted in section 6); `PANEL_SEATS=4-frame-inversion.md` is
refused by a message that says "name the file" (F11); `PANEL_TIMEOUT=0` passes the integer check and
disables the timeout (F11); a reused report directory keeps a stale report from an earlier seat
selection beside the new ones, and the summary lists only the new (F11).

**Latent, not graded.** tests/run.sh:402 counts door rules with `^[0-9]\. \*\*`, which stops
matching at rule 10. panel-run.sh:81-115: `set -e` failures between `mktemp -d` and the EXIT trap
(line 130) leak `$work` with a copy of the artifact in `$TMPDIR`.

### 2.3 Peer challenge

- SE on CR's grading of the verdict flip: adapters/README.md:38-39 says "A person reads the report;
  the verdict summary line is a convenience", so this is MODIFY. CR: panel-protocol.md:69-70 says "the
  orchestrator parses the verdict line structurally"; the summary and the exit code are what any
  script around the runner keys on; the flip is in the unsafe direction (block → approve) and is
  triggered by a reviewer following the prompt; and the previous round added the test that pins it.
  Reconciled: BLOCKER, because the fix is two lines, the test must change with it, and shipping a
  "structural" parse that the artifact's own text can flip contradicts P3 in the framework's own
  runner.
- CR on SE's grading of the fence case as MODIFY: the file is corrupted and the script says
  "appended". SE: the input needs both marker lines quoted at column 1 inside a fence; a team that
  documents the convention in its CLAUDE.md is the realistic case, and it is uncommon. Reconciled:
  MODIFY with a test, because the damage is contained to the instructions file and is visible in the
  diff the user is told to make (ADAPTING.md:408).
- SE on CR's orphan finding: README.md:13 already requires coreutils on macOS, so this is a
  documented environment. CR: the runner prints "reviewers stopped" while they run; a lying message
  is a defect regardless of environment, and `set -m` removes the dependency. Reconciled: MODIFY;
  fix the mechanism or the message, and make the sigterm test assert the child.
- Both: the credentialed URL in `.adopt` is a BLOCKER; one `sed`, one test.

### 2.4 Reconciled position

Agree. Two blockers (F1 verdict flip, F2 token in `.adopt`), both introduced by fixes since 4c8d6ce,
both reproduced, both two-line fixes with a test each. The adopt.sh marker logic should be rewritten
as one pass rather than patched a third time. The suite needs an environment scrub and two
behavioural tests (LOCAL.md survives a refresh; the sigterm test asserts the child process).

---

## 3. Experience pair

### 3.1 UX Designer: independent assessment (can a newcomer act on it?)

**From the README alone** (566 lines, read top to bottom as a newcomer):

- *How to install*: yes, README.md:66-80; the command is at line 77. The Map (README.md:20-27) does
  not list Install or Provenance, only the six numbered sections, so the Map does not match the
  headings; Install is findable because it is a heading, not because the Map points to it.
- *Which six documents exist*: the names, yes (README.md:68-69). What each is for: four of six.
  `ADAPTING.md` (14, 27), `call-site-contract.md` (23, 141), `panel-protocol.md` (430),
  `agent-rules.md` (461, 516) are each described somewhere. `evaluation.md` appears once, as a bare
  name in the list (README.md:69), and nothing in the README says it is the per-feature
  pre-registration template. The table that said so ("Template for a feature's pre-registered
  evaluation") was removed today (round2-and-cut.diff, README hunk, `-| evaluation.md | ...`). F12.
- *Where the pull-request checklist is*: README.md:535, the last line of section 6. Findable by
  searching, not by the Map.
- *What governs coding agents*: README.md:458-464 (3.11) points to `agent-rules.md` "under 'Agent
  workflow'", which exists as a bold label (agent-rules.md:102 `**Agent workflow**`). Clear.
- *Dangling references*: none to a missing section or file. Every "section N" and backticked file in
  the README resolves (checked: sections 1, 2, 2.1, 3, 3.1, 3.4, 3.5 of ADAPTING; `adapters/README.md`;
  `docs/reviews/`, which exists upstream and was removed from this copy on purpose). The only
  convention clash: README.md:73 and :547 say the framework's reports are in `docs/reviews/` while
  panel-protocol.md:130 and ADAPTING.md:332 tell adopters to use `docs/llm-framework/reviews/`; both
  are right for their repository, but `adopt.sh` creates `contracts/` and `evaluations/`
  (ADAPTING.md:74-79) and not `reviews/`, the one directory the CI gate in ADAPTING.md:330-333 reads
  (F14).

**Two install paths** (README.md:66-80 and 512-518) is one too many for a first screen.

### 3.2 Technical Writer: independent assessment (terms, the new sentence, the template, the cut)

**X2, Terms.** Every listed term is defined before the body uses it, because the list precedes the
body. The list is in "the order they are needed" (README.md:29), which holds. Undefined in the body:

- *entitlement*: used inside the Terms list itself (README.md:40-41, defining *Acting principal*) and
  ten times after (97-98, 188, 195-196 "Existence is not entitlement", 249, 252, 311-312); it is the
  load-bearing word of P2 and never defined.
- *consumer* / *operator*: the pair that decides audit bias, content sample, and the ladder
  (README.md:60, 123, 255-256, 373, 505): "Where the consumer is not the operator". Neither is in Terms.
- *Service scale* / *Script scale*: README.md:359, 493-495 use them; they are defined only in
  ADAPTING.md:17-26. README.md:493 points to ADAPTING section 1, so a reader can resolve it, but the
  ladder paragraph is where a newcomer scores themselves.
- *snapshot* in two senses: a pinned model id (README.md:111, 151, 285-286, 499) and the computed-once
  input set (README.md:198-199, 500 "snapshot consistency"). The Terms list has neither.
- *inventory test* (README.md:162, 282) and *content sample* (155, 373-379) are used as names of
  controls without a Terms entry; *guard test* has one.

**X3, the agent-rules sentence added this round** (agent-rules.md:105-107): "Each delegated task
gets a review for spec compliance and quality, and the whole branch one final review on the most
capable model: plan bugs propagate verbatim." The file is injected into every agent session,
including the delegated ones (agent-rules.md:3-4 "every agent session working on it"). Read by a
*delegated* agent, the sentence has no action: it cannot review its own task (P7, README.md:128) and
must not dispatch reviewers of its own (its git is limited to the branch it was given). Read by the
*orchestrating* agent, it is actionable only in a tool that lets it pick a model, and "the most
capable model" is an undated, vendor-relative claim that the same file forbids one line later
("Numbers you assert are fetched or computed with a read date; a number from memory is a
hypothesis", agent-rules.md:109-110). The sentence also does not say the review is a *separate
session*; an agent can satisfy it by re-reading its own diff, which is the inline role-play the
Review paragraph forbids for the panel. The colon clause ("plan bugs propagate verbatim") is a
rationale an agent cannot act on. Rewrite as an instruction with an actor: "Before a delegated task
is merged, a session that did not write it reviews the result against the brief; before the branch
is merged, one fresh session reviews the whole branch. Hand both commands to the human." F13.

**X4, LOCAL.template.md.** Every section an adopter must fill points to a source that exists and
says enough: Scale and shapes → ADAPTING §1 (table at ADAPTING.md:22-37); Instructions files →
ADAPTING §2; Roster → ADAPTING 5.1-5.2; Scoping → protocol §2 and ADAPTING 5.3; Gates → ADAPTING 5.6
(including "the user" per gate, execution path, CI check); Door audit → ADAPTING §3, eight rows for
eight rules (the drift test asserts the count). Two gaps: "Project-level controls referenced by every
contract" (LOCAL.template.md:62-67) has no pointer, and "Vendor terms relied on" has no guidance in
README or ADAPTING at all (only the contract template, call-site-contract.md:200-202, names the
classes). One inconsistency: LOCAL.template.md:37 "Removing a human control | + Domain pair, Veto
seats" versus panel-protocol.md:57 "removing a human control | + Veto seats" and :53 (decision logic
→ Domain, Data, Veto). README.md:421-422 calls it "a decision-logic change", which would seat all
three. Pick one (F15).

**X5, the cut and what it lost.** Today's cut lost one rule: the old 3.11 said the delegated agent's
brief "is read-only to that agent" (round2-and-cut.diff, README hunk, removed checkbox); the pointer
sentence (README.md:460-461) lists "the brief as single source", and agent-rules.md:103 says "single
source of its requirements" — neither says read-only. `grep -n 'read-only to' README.md
agent-rules.md` finds nothing (F16). It also lost "where a rule seems arbitrary, treat it as a
hypothesis with a stated rationale" (reader guidance, see Observer) and the per-file descriptions
(F12). Everything else cut was a duplicate or a rationale.

What I would still cut, by line, without losing a rule:

- README.md:59-64 ("Where it came from, and what that shaped") → merge into Provenance 541-549; the
  two paragraphs say the same thing twice, 60 lines apart. Saves 6.
- README.md:101-103, the parenthetical "(draft-not-send, soft delete with a recovery window, a hold
  queue a named person releases)" in P2 → it is repeated verbatim at 323-325 where the checkbox is.
  Saves 2.
- README.md:112-113, "For a hosted agent loop the door is the agent's configuration file (section
  3.5)" in P4 → the checkbox at 329-331 carries it. Saves 2.
- README.md:516-518, step 1 of section 6 → it repeats Install (68-72); replace with "1. Install
  (above). Fill in LOCAL.md: scale, shapes, roster." Saves 2.
- README.md:10-12, the "specified by behavior" sentence → see Observer. Saves 2.

What I would not cut, and why: the Terms list (29-57) is the only navigational aid a document this
size has; the contract table (143-159) is the one place that says *why* each field exists; the
checklists 3.1-3.9 are the rules themselves, and moving any of them to ADAPTING would make the README
a pointer to its own content; the ladder (485-508) is the scoring instrument; section 4 (468-481)
carries no rule but is the only explanation of why 3.1-3.9 are in that order. The honest answer on
length is that README.md is two documents, a 150-line orientation and a 350-line reference; that
split is the real cut and is out of scope at this gate because it changes the six-file set the tests
pin.

### 3.3 Peer challenge

- UX on TW's Terms additions: adding four terms makes the list longer, and the list is already the
  longest thing before Install. TW: the four are the words that decide every audit-bias and scoping
  question; a reader who does not know "consumer" cannot apply 3.4 layer 4 at all. Reconciled: add
  *entitlement*, *consumer/operator*, and a one-line disambiguation of *snapshot*; point *scale* to
  ADAPTING §1 in one clause instead of defining it.
- TW on UX's wish to merge the two install sections: section 6 is "the short form" of ADAPTING and
  needs a step 1. Reconciled: keep section 6, make step 1 a one-line pointer to Install.
- UX on TW's X3 rewrite: the human, not the agent, runs reviews, so the sentence belongs in LOCAL.md
  or ADAPTING, not in a file injected into every agent. TW: README.md:462 already says these rules
  "govern the coding agent, not the model call", and the orchestrating agent is the one that
  delegates; it just needs an actor and the words "separate session". Reconciled: rewrite in place.

### 3.4 Reconciled position

Agree. No blocker from this pair. Five modifications: restore the one-line description of
`evaluation.md` (F12); rewrite the new agent-rules sentence with an actor and "separate session"
(F13); add the missing Terms (F17); reconcile the scoping row (F15); restore "read-only to that
agent" in agent-rules.md (F16). The length cuts above are offered, not required.

---

## 4. Closure of the previous gate (docs/reviews/2026-10-12-panel-2/0-consolidated.md, read after sections 1-3 were written)

Marked at the lines verified in the b41ba8d copy. README went from 610 lines (11adcde) to 566
today (`git show 11adcde:README.md | wc -l` → 610; `wc -l README.md` → 566).

### Blockers

| # | Status | Verified at | Introduced by the fix |
|---|---|---|---|
| R1 (service identity as acting principal; evidence scope) | **closed** | README.md:98-101 (P2: "the party whose entitlement bounds the output, not the identity that runs the call; code binds it from the authenticated request"); README.md:188-191 (3.2 entitlement item with a fixture "owned by another principal"); README.md:250-252 (layer 3 counts a shown value only from evidence within the entitlement); call-site-contract.md:30, 50-54, 179-183 (evidence ownership, data sources read by code, principal field narrowed to "acting for <consumer>") | nothing found |
| SYS-1 / N1 (missing end marker deleted the tail; indented marker corrupted with success) | **closed** for the two reported inputs | adopt.sh:52-78 (pre-write validation: one pair, column 1, begin before end), adopt.sh:105-107 (post-rewrite check); tests `t_adopt_refuses_when_end_marker_missing`, `t_adopt_refuses_indented_or_duplicate_markers` pass; my CRLF and BOM runs are refused without writing | F5: two marker lines quoted at column 1 inside a ``` fence pass the new validation and the rules are written inside the fence with success reported; F7: CRLF and BOM files are refused with a diagnosis that contradicts what the user sees; a begin marker with trailing whitespace is accepted and the refresh says "the rules changed" when they did not |

### Modifications folded in: Scripts

| Item | Status | Verified at | Introduced |
|---|---|---|---|
| `.adopt` path containment | **partial** | adopt.sh:37-39 resolves the parent directory with `pwd -P`; `../` and absolute escapes refused (test passes) | F6: a file symlink inside the project passes and is written through to outside; F7: a deleted parent directory is reported as "outside the project" |
| incomplete upstream copy refused | closed | adopt.sh:27-29; test | — |
| legacy-block detection requires the heading | closed | adopt.sh:54 | — |
| instructions file under `docs/llm-framework/` refused | closed | adopt.sh:52; test | — |
| `PANEL_SEATS`: nothing selected is an error; duplicates once; ambiguous numbers refused | closed | panel-run.sh:59-71; tests `run_seats`, `run_seats_edge` | F11: the error says "name the file" but the file name with `.md` is refused |
| `timeout -k` with `PANEL_KILL_AFTER` | closed | panel-run.sh:76-77; test `run_timeout` | F11: `PANEL_TIMEOUT=0` passes the integer check and disables the timeout (GNU semantics) |
| Ctrl-C and SIGTERM stop every reviewer's process group | **partial** | panel-run.sh:123-129; with `timeout` present my control run left no child alive | F4: without a `timeout` binary the fallback kills the wrapper only, the child survives holding the report file, and the runner prints "interrupted; reviewers stopped" |
| `PANEL_TIMEOUT`/`PANEL_MAX_BYTES`/`PANEL_ENV_PASS` validated | closed | panel-run.sh:46, 51-55; test `run_preflight` | — |
| HOME passed only when set | closed | panel-run.sh:132 `${HOME+HOME="$HOME"}` | — |
| empty arrays safe under `set -u` | closed | panel-run.sh:62, 125-127, 132 | — |
| bash 4 required and said | closed | adopt.sh:13, panel-run.sh:30, install.sh:8 (make-skill.sh and tests/run.sh have no check and use nothing that needs one) | — |
| single-pass placeholder substitution | closed | panel-run.sh:83-98; test `run_substitution` | — |
| `make-skill.sh` refuses unknown arguments | closed | make-skill.sh:18-19; test | — |
| relative `CLAUDE_SKILLS_DIR` refused | closed | install.sh:15; test | F9 (not caused by this item, but adjacent): the suite honours a `CLAUDE_SKILLS_DIR` set in the developer's shell and writes there |
| Tests: vacuous `*.md` check replaced | closed | tests/run.sh:333 | — |
| Tests: `not` paired with message greps | closed | `not_with`, tests/run.sh:23-27 | `not_with 'end'` (tests/run.sh:99) matches "appended" |
| Tests: `md5sum`/`sed -i` replaced | closed | tests/run.sh:32-34 | — |
| Tests: timing tests skip without `timeout` | closed | tests/run.sh:347, 357 | F4 (test side): the only configuration that orphans is the one the test skips |
| Tests: drift checks (nine classes, six files from adopt.sh, door rules vs rows, placeholder rule on examples, example-date warning) | closed | tests/run.sh:394-418 | F18: the six-file check covers ADAPTING and adapters/README but not README.md:68-69; nothing covers README's new pointers (2.1, "Agent workflow") or the 30/90/180-day numbers |
| "the consolidator's own `pgrep -f` test ... fixed with the bracket pattern" | **partial** | tests/run.sh:363, 367: `pgrep -f "[m]odel-sig-$$\.sh"` no longer matches its own shell | it matches the wrapper bash, not the reviewer's child; the vacuity moved from the test's shell to the wrapper (F4) |

### Modifications folded in: Contradictions the first revision introduced

| Item | Status | Verified at |
|---|---|---|
| ladder vs Script row | closed | README.md:493-494 (Script: Routing 1, Review 2, Evaluation unscored) agrees with ADAPTING.md:24 (one function; one reviewer session; evaluation file optional) |
| "Review level 1" → "at most level 2" | closed | README.md:456 |
| P3 lists all six layers | closed | README.md:106-108 |
| "Eight sentences" → principles | closed | README.md:22 |
| "Each box is one yes/no question" dropped | closed | README.md:24 "Each box is one check" |
| "gate" reserved for review gates | closed | `grep -niE 'gat(e|ed|ing)' README.md ADAPTING.md` finds only review senses; README.md:473 "delta conditions", :504 "Frequency conditioned" |
| `shape` used in one sense | **partial** | ADAPTING.md:106 "One module owns every model call. Its shape is the same in any language:" uses shape for the module's layout; every other use is the call shape |
| ADAPTING's budget sentence | closed | ADAPTING.md:6-13; README.md:514 points to it |
| "section 11 carries the bounds" | closed | call-site-contract.md:11-12 ("section 4 carries the bounds, and section 11 the ceiling, the principal, and the approval step") matches §4 :87-91 and §11 |
| "six documents" row | closed | Map README.md:20-27 has none; README.md:68 "six framework documents" matches adopt.sh:21 |
| "its two tests" | closed | `grep -rn 'its two tests'` → none; README.md:522-523 names both tests |
| "veto seat" singular | closed | README.md:422, 552 plural; protocol uses "veto seat(s)"; prompts/1-domain-data-and-veto.md:11 is singular by design (one `PANEL_VETO`) |
| Title Case for the Frame-Inversion Reviewer | closed | `grep -rn 'frame-inversion reviewer'` → none |

### Modifications folded in: Length and reading

| Item | Status | Verified at | Note |
|---|---|---|---|
| opening provenance cut to one sentence | closed | README.md:6-8 | F19: the one sentence promises per-rule provenance that Provenance (541-549) gives only by group; the "treat it as a hypothesis" guidance was cut today |
| "Where it came from" moved after the Terms, plain | closed | README.md:59-64 | still duplicates Provenance; cut candidate (3.2) |
| Terms as a definition list including the added terms | closed as specified | README.md:29-57 has acting principal, fence, ceiling, harm floor, dev/golden set, veto seats, deterministic default | F17: entitlement, consumer/operator, scale, and the two senses of snapshot are still undefined |
| P4 shortened; hosted-loop sentence lives in 3.5 | closed | README.md:110-113; 329-331 | the pointer form remains in P4 (112-113); cut candidate |
| Bounded and Observed phases swapped | closed | README.md:475-476 | — |
| README's own time estimate is one line pointing to ADAPTING | closed | README.md:514 | — |
| Observer's cut (declined in part: "3.11 kept because agent-rules.md is its summary by design, repository layout kept") | **changed today** | 3.11 is now a pointer paragraph (README.md:458-464); the layout table is gone (Install paragraph, 66-74); the PR checklist moved to ADAPTING.md:84-100 | F16: the move dropped "read-only to that agent"; F12: the move dropped the only description of `evaluation.md`; the second panel's reason for keeping 3.11 ("agent-rules.md is its summary") is now inverted: agent-rules.md is the source and README the summary, and the summary lists five of the seven bullets |

---

## 5. Findings table

| id | what | where (file:line, quoted) | why it matters | what would resolve it | grade | evidence |
|---|---|---|---|---|---|---|
| F1 | The verdict summary takes the *last* token-alone line; a finding written under the verdict that quotes the artifact's own verdict line flips the result. Reproduced: reviewer output `BLOCKERS` + a finding quoting `APPROVE-AS-IS` from the artifact → summary `4-frame-inversion.md: APPROVE-AS-IS`, exit 0. | panel-run.sh:140 `v="$(grep -E '^(BLOCKERS\|MODIFY-BEFORE-BUILD\|APPROVE-AS-IS)[[:space:]]*$' "$report_dir/$name.md" \| tail -1 ...)"`; the prompts put findings under the verdict and ask for quotes: prompts/4-frame-inversion.md:25 "each item quoting the artifact", :28 "Under it, each finding as: what, where, why it matters"; panel-protocol.md:69-70 "the orchestrator parses the verdict line structurally". Command: `MODEL_OUTPUT='BLOCKERS\n\nFinding 1: ... quoted:\nAPPROVE-AS-IS\nwhy it matters: ...' PANEL_SEATS=4 panel-run.sh rH artifact.md` → `.../4-frame-inversion.md: APPROVE-AS-IS`, `exit=0`. | The artifact's own text decides the structural verdict, in the unsafe direction (block → approve). This is the input the fence was built to neutralise, reaching the one line a script around the runner reads. Introduced by the previous round's "last token line" fix; tests/run.sh:267-274 pins it. | Require exactly one token-alone line; on 0 or >1 print `AMBIGUOUS (n verdict lines); read the report` and exit non-zero. Change the test to assert that a quoted verdict word under the verdict does not change the summary. | BLOCKER | VERIFIED |
| F2 | `.adopt` records the framework checkout's `origin` URL verbatim, including embedded credentials, in a file the adopter commits. | adopt.sh:91 `src="$(git -C "$here" remote get-url origin 2>/dev/null \|\| echo "$here")"`; adopt.sh:94 `printf 'rules=%s\nsource=%s\ncommit=%s\n' ...  > "$state"`; ADAPTING.md:76 lists `.adopt` as a created project file. Command (stub `git` on PATH answering `remote get-url origin` with a token URL): `PATH="$W/stubgit:$PATH" fw-token/adopt.sh tokproj` → `.adopt` contains `source=https://user:<token>@github.com/org/llm-practice-framework.git`. | A token in a committed file, written by a framework whose rule 5 is "Credentials never appear in the log, the prompt, or a fixture" (ADAPTING.md:164). The `source=` record did not exist in 4c8d6ce (full.diff adopt.sh hunk: the `remote get-url` line is a `+` line). | Strip userinfo before recording (`sed -E 's#^([a-z]+://)[^/@]+@#\1#'`), or record only `commit=`. Add a test with a stub git. | BLOCKER | VERIFIED |
| F3 | Exit 0 when a reviewer printed nothing or a report with no verdict line. | panel-run.sh:27 "exit: 0 every reviewer ran"; :137 `wait "$pid" \|\| fail=1`; :140-141. Commands: `LLM_REVIEW_CMD=true PANEL_SEATS=4 panel-run.sh rI artifact.md` → `NO VERDICT LINE; read the report`, `exit=0`, report 0 bytes; `MODEL_OUTPUT='## Assessment\n\nhalf a report'` → same, `exit=0`. | A CI job gating on the exit code passes with no verdicts; the header's contract is true and useless. | `exit 3` when any selected report lacks exactly one verdict line; say so in the header. | MODIFY | VERIFIED |
| F4 | Without a `timeout` binary, SIGTERM/Ctrl-C kills the wrapper and orphans the reviewer's child, while the runner prints "reviewers stopped". The test cannot see it. | panel-run.sh:125 `kill -TERM -- "-$pid" 2>/dev/null \|\| kill -TERM "$pid"`; :28 "Ctrl-C or SIGTERM stops every reviewer (their process groups)"; :129 `echo "interrupted; reviewers stopped"`. Command (PATH without timeout, two seats, `kill -TERM $runner`): runner output `interrupted; reviewers stopped`; afterwards `wrappers=0` and two `sleep 40` processes with `ppid 4575`, `stdout -> .../r/3-engineering-experience-observer.md` and `.../4-frame-inversion.md`. Control with `timeout` on PATH: `wrappers=0 sleeps=0`. Test: tests/run.sh:357 skips without timeout; :367 `not pgrep -f "[m]odel-sig-$$\\.sh"` matches the wrapper, not the child. | A credentialed CLI keeps running after the operator stopped the run, and the message says otherwise; README.md:13 lists macOS, where `timeout` is absent without coreutils. | `set -m` before the launch loop (every background job gets its own group on every bash), or print "stopped where timeout exists" and refuse to claim otherwise; make the sigterm test assert the child (`pgrep -f '^sleep 30'`) and run a no-timeout variant with a PATH that hides it. | MODIFY | VERIFIED |
| F5 | Two marker lines a user quoted at column 1 inside a ``` fence pass validation and are treated as the managed block: the rules are written inside the fence, the user's example is replaced, nothing is written outside, success is reported. | adopt.sh:63-77 count markers without regard to fences; adopt.sh:101-104 awk rewrite. Command: AGENTS.md containing "```\n<!-- llm-framework:agent-rules begin ... -->\n<!-- llm-framework:agent-rules end -->\n```" → `exit=0`, "next: follow ..."; result: 118 lines, `fence lines: 2`, rules text between the fences, `is any rules text OUTSIDE the fence?` → 0. | The instructions file now carries the rules only as a code sample; the agent reads a quotation, not rules; every refresh preserves the state; the script said it succeeded. Exactly the class SYS-1/N1 was meant to close. | Track ``` fences in the validation and the awk pass; a marker inside a fence is neither counted nor rewritten; refuse if the only markers are fenced. Test. | MODIFY | VERIFIED |
| F6 | A recorded `rules=` path that is a file symlink to outside the project passes containment and is written through. | adopt.sh:37-39 `parent="$(cd -- "$(dirname -- "$rules")" ... && pwd -P ...)"; case "$parent/" in "$proj"/*) ;; *) ... exit 2`. Command: `ln -s $W/symout/outside/victim.md proj/rules-link.md; printf 'rules=rules-link.md\n' > .adopt; adopt.sh proj` → `appended the rules block to .../proj/rules-link.md`, `exit=0`; `begin markers in OUTSIDE file: 1`. | The comment at adopt.sh:37 ("the recorded path lives in the repository, so it is contained") is false for a symlink a cloned repository can carry. Harm is a rules block appended to a file the user can read (e.g. their global instructions file), so not a blocker. | Refuse when `[ -L "$rules" ]`, or resolve the link target and apply the same containment to it. Test. | MODIFY | VERIFIED |
| F7 | Wrong diagnoses on inputs README.md:13 says are supported: a CRLF file is refused with "0 end" though the end line is visible; a BOM-prefixed file with "0 begin at column 1"; a deleted recorded directory with "outside the project". | adopt.sh:65 `ne="$(grep -cF -x -- "$end" "$rules" ...)"`; :64 `nb="$(grep -c -- "^$begin_key" ...)"`; :39. Outputs: CRLF → `(found 1 begin at column 1, 1 begin anywhere, 0 end); fix the marker lines by hand`; BOM → `(found 0 begin at column 1, 1 begin anywhere, 1 end)`; after `rm -rf .cursor` → `.adopt names an instructions file outside the project (.cursor/rules/llm.md)`. Also: a begin marker with trailing spaces is accepted and the refresh prints "the rules changed, re-read them" when only the marker line changed. | Safe (nothing written) but the user is told to fix lines that look correct; Windows and Git Bash users hit the CRLF case on the first refresh after their editor or `autocrlf` normalises the file. | Strip a trailing CR and a leading BOM when matching (or say "line endings / BOM" in the message); distinguish "parent directory missing" from "outside the project". | MODIFY | VERIFIED |
| F8 | Two shipped files state opposite precedence rules for the skill copies. | adapters/claude-code/skill-header.md:9-11 "personal skills shadow project skills of the same name, so this file cannot rely on the project's copy loading by itself"; adapters/claude-code/install.sh:5-6 "Customisations belong in a project's .claude/skills/expert-panel/, which shadows this copy" (and :32). | Whichever is true, one file sends customisations to a copy the tool ignores; both are undated claims about a tool, which agent-rules.md:109-110 forbids for numbers and should forbid here. | Pick one, cite the tool's documentation with a checked date in the file, and make the other file agree. | MODIFY | VERIFIED |
| F9 | The suite honours a `CLAUDE_SKILLS_DIR` set in the developer's shell: install tests write to that directory and six checks fail; the header's "never touches ... your HOME" does not hold for the directory install.sh invites users to set. | tests/run.sh:2-4 "never touches the checkout, your HOME, or a real model"; :190 `env HOME="$h" "$fw/adapters/claude-code/install.sh"` passes the inherited environment. Command: `CLAUDE_SKILLS_DIR=$W/leak-skills bash tests/run.sh` → `FAIL [install_backup] fresh copy installed` ... `177 checks, 6 failed, 0 skipped`, exit 1; `find $W/leak-skills` → `leak-skills/expert-panel/SKILL.md` written. | With a customised real skill in that directory, `t_install_backs_up_a_customised_skill` would `mv` the user's real skill aside. The same holds for a sourced `.panel.env` (`PANEL_*`), which ADAPTING.md:304 recommends. | `unset CLAUDE_SKILLS_DIR PANEL_SEATS PANEL_PROMPTS PANEL_TIMEOUT PANEL_KILL_AFTER PANEL_MAX_BYTES PANEL_BUILD_STAGE PANEL_PUSH_ON PANEL_DOMAIN_A PANEL_DOMAIN_B PANEL_VETO PANEL_EXTRA_PAIR` at the top of tests/run.sh, or pass `CLAUDE_SKILLS_DIR` explicitly in every install test. | MODIFY | VERIFIED |
| F10 | `t_adopt_is_idempotent` cannot detect an adopt.sh that overwrites `LOCAL.md` on refresh; the promise has no test. | tests/run.sh:60-67 compares `tree_sum` after two runs on a project whose `LOCAL.md` equals the template; ADAPTING.md:61-63 "Re-running is safe: ... never touches `LOCAL.md`, `contracts/`, or `evaluations/`". Mutant: adopt.sh:84 `if [ ! -f "$dest/LOCAL.md" ]` → `if true`; two runs → `tree unchanged -> t_adopt_is_idempotent passes against the mutant`; after `echo "Scale: service" >> LOCAL.md` and a refresh → `user edit survived in LOCAL.md (0 = clobbered): 0`. | The one file the adopter writes by hand is the one whose survival is untested; a regression would pass the suite. | Add a test: edit `LOCAL.md`, add a file under `contracts/`, refresh, assert both survive. | MODIFY | VERIFIED |
| F11 | Runner usability, three small items: a reused report directory keeps a stale report from an earlier seat selection and the summary lists only the new ones; `PANEL_SEATS=4-frame-inversion.md` is refused by a message that says "name the file"; `PANEL_TIMEOUT=0` passes the integer check and disables the timeout. | panel-run.sh:118 `mkdir -p -- "$report_dir"`; :68 "...selects no prompt or is ambiguous; name the file"; :46 `case "$timeout_s$kill_after$max_bytes" in *[!0-9]*\|'')`. Outputs: run J → `ls rJ` shows `3-...md 4-...md` from two runs, summary lists only `3-...`; run K → `seat '4-frame-inversion.md' matches 0 prompts`; run L → `MODEL_SLEEP=3 PANEL_TIMEOUT=0` completes, `exit=0 elapsed=3s`. | A person reading the directory sees a verdict from a different run; the error message's advice fails; a typo disables the control. | Refuse a non-empty report dir or remove `*.md`/`*.err` for unselected seats; accept `name.md`; reject 0 for `PANEL_TIMEOUT`. | MODIFY | VERIFIED |
| F12 | The README no longer says what `evaluation.md` is; today's cut removed the only description. | README.md:68-69 "copies the six framework documents (this file, `ADAPTING.md`, `call-site-contract.md`, `evaluation.md`, `panel-protocol.md`, `agent-rules.md`)"; `grep -n evaluation.md README.md` → line 69 only; round2-and-cut.diff README hunk removed `| evaluation.md | Template for a feature's pre-registered evaluation |`. | A newcomer can name six files but not what the fifth is for; the other four are described elsewhere in the README (14, 23, 430, 461). | One clause in the Install paragraph: "`evaluation.md` (the per-feature pre-registration template)". | MODIFY | VERIFIED |
| F13 | The sentence added to agent-rules.md this round has no actor and is not actionable by the agent that reads it. | agent-rules.md:105-107 "Each delegated task gets a review for spec compliance and quality, and the whole branch one final review on the most capable model: plan bugs propagate verbatim."; agent-rules.md:3-4 "every agent session working on it"; :109-110 "a number from memory is a hypothesis". | A delegated agent cannot act on it (P7); an orchestrating agent can satisfy it by re-reading its own diff (the sentence does not say "separate session"); "the most capable model" is an undated vendor-relative claim in a file that forbids them. README.md:460-461 summarises it as "task and final reviews". | Rewrite with an actor and the words "a session that did not write it": "Before a delegated task is merged, a session that did not write it reviews the result against the brief; before the branch is merged, one fresh session reviews the whole branch. Hand both commands to the human." Drop the colon clause. | MODIFY | JUDGMENT |
| F14 | `adopt.sh` creates `contracts/` and `evaluations/` but not `reviews/`, the one directory the CI gate reads. | adopt.sh:81 `mkdir -p "$dest" "$dest/contracts" "$dest/evaluations"`; ADAPTING.md:74-79 "The script creates: ... contracts/ ... evaluations/"; ADAPTING.md:331-332 "a CI check fails any change ... unless it links a report under `docs/llm-framework/reviews/`"; panel-protocol.md:130 "Copy the reports into the repository (`docs/llm-framework/reviews/`)". | The adopter's first panel has nowhere designated to land; the gate's path exists only in prose. | `mkdir -p "$dest/reviews"` and list it at ADAPTING.md:74-79. | MODIFY | VERIFIED (quoted) |
| F15 | The template's scoping row for removing a human control disagrees with the protocol. | LOCAL.template.md:37 "\| Removing a human control \| + Domain pair, Veto seats \|"; panel-protocol.md:57 "\| Anything that spends, commits, discloses, or deletes; removing a human control \| + Veto seats \|"; :53 decision logic → "+ Domain pair, Data pair, Veto seats"; README.md:421-422 "Removing a human control is a decision-logic change and convenes the veto seats". | The adopter copies the template row and the protocol row and gets two different panels for the same change. | Make the three agree; the README's "decision-logic change" implies Domain + Data + Veto. | MODIFY | VERIFIED (quoted) |
| F16 | Today's cut lost one rule: the delegated agent's brief is read-only to that agent. | round2-and-cut.diff README hunk, removed: "- [ ] A delegated agent's brief is the single source of its requirements and is read-only to that agent."; agent-rules.md:103 "A delegated agent's brief is the single source of its requirements."; `grep -n 'read-only to' README.md agent-rules.md` → no match. | The pointer at README.md:460 ("the brief as single source") assumes agent-rules.md carries the rule; it carries half. | Add "and is read-only to that agent" at agent-rules.md:103. | MODIFY | VERIFIED |
| F17 | Terms used in the body without a definition: *entitlement* (10 uses, first inside the Terms list itself), *consumer*/*operator* (the pair that decides audit bias and the content sample), *Service*/*Script scale* (defined only in ADAPTING §1), and *snapshot* in two senses. | README.md:40-41 "whose entitlement bounds what the model may see and do"; :195-196 "Existence is not entitlement"; :123 "Where the consumer is not the operator"; :359 "at Service scale"; :493 "Script scale (`ADAPTING.md` section 1)"; :111 "pinned model snapshots" vs :198-199 "Inputs are computed once as a snapshot". | A reader who does not know "consumer" cannot apply layer 4 (README.md:253-257) or the ladder's Observability column. | Add three Terms entries (entitlement; consumer and operator; snapshot: model snapshot vs input snapshot) and one clause pointing *scale* to ADAPTING §1. | MODIFY | JUDGMENT |
| F18 | Drift the tests cannot catch after today's cut: README's six-file enumeration; the pointers to ADAPTING 2.1 and to agent-rules.md "Agent workflow"; the 30/90/180-day numbers that appear in four files. | tests/run.sh:396-399 checks `ADAPTING.md` and `adapters/README.md` only; `grep -nE '2\.1\|Agent workflow\|Pull-request' tests/run.sh` → none; README.md:287, ADAPTING.md:145-146, 172-174, LOCAL.template.md:79 carry the day counts; README.md:535 "is `ADAPTING.md` section 2.1"; README.md:461-462 "under 'Agent workflow'". | The round's own pattern: a pointer added by a cut has no test, so the next cut can break it silently. | Extend the six-file loop to README.md (skipping its self-reference); `has '### 2.1 Pull-request checklist' ADAPTING.md`; `has '**Agent workflow**' agent-rules.md`; grep the three day counts across the four files. | MODIFY | VERIFIED (grep) |
| F19 | The opening promises per-rule provenance that the Provenance section gives by group, and the reader guidance for the gap was cut today. | README.md:7-8 "which rules are backed by an incident and which are reasoned is stated under Provenance and limits at the end."; README.md:543-549 "Most rules trace to a specific incident ... The rules added since (agentic calls, the TBD convention, ...) ... are reasoned"; round2-and-cut.diff removed "where a rule seems arbitrary, treat it as a hypothesis with a stated rationale". | The first screen asks for trust the last section does not back per rule; the numbers (30/90/180 days, the sample-size formula) are not attributed either way. | Weaken 7-8 to "which groups of rules", or mark reasoned rules in place; restore the "treat it as a hypothesis" sentence in Provenance. | MODIFY | VERIFIED (quoted) |
| F20 | The skill header describes a tool restriction the dispatch cannot enforce. | adapters/claude-code/skill-header.md:31-32 "read-only tools (Read, Grep, Glob, and Write to its own report path only; never Bash or Edit ...)"; panel-protocol.md:71 "This is the panel's own ceiling." | A tool allowlist can include or exclude Write; it cannot scope Write to one path from the dispatch. By P3 the "only" is a request; calling it the ceiling overstates. | "Write, instructed to use it only for its report; the ceiling is no Bash and no Edit." | MODIFY | JUDGMENT |

---

## 6. What was checked and found sound

Scripts, by running them in the scratch copy:

- adopt.sh: nothing is written before the checks (bad arguments leave no `docs/`; verified by the
  suite and by the F7 runs, each of which left the file byte-identical); missing end marker,
  indented begin, duplicated block, legacy unmarked block, prose quoting the sentence, instructions
  file under `docs/llm-framework/`, `../` and absolute `.adopt` escapes, incomplete upstream copy:
  all refused with the documented message (suite, 177 checks). A re-run after the user edited inside
  the block replaces the block and keeps text before and after (suite `adopt_block_edit`). Two
  candidate files: the first is used and the other named on every run. Project paths with spaces, a
  trailing slash, and `.` all work; `pwd -P` canonicalises a symlinked project. `CLAUDE.md ->
  AGENTS.md` (one file, two names) works, with a redundant note (minor: the note says the other file
  "was not changed", which is false for a symlink; `-ef` would suppress it). The git check at
  adopt.sh:90 compares the toplevel to `$here`, so a framework copy under a temp directory that is
  inside some other repository records `source=<path>`, `commit=unknown` rather than that
  repository's values. A file whose last line lacks a newline produces one spurious "the rules
  changed, re-read them" on the next run and is stable afterwards (minor).
- panel-run.sh: pre-flight refuses every bad input before invoking the model (suite's
  `MODEL_CAPTURE` checks); the nonce differs per run and the artifact's fence-like line is delivered
  as content; `env -i` strips a secret and passes an allowlisted variable; a non-identifier in
  `PANEL_ENV_PASS` is refused, an unset name produces the documented note; seat selection cannot
  silently pick the wrong prompt (exact basename or exact leading number only; ambiguity, blank, and
  `*` refused; duplicates run once); `timeout -k` ends a reviewer that ignores SIGTERM within the
  bound; with `timeout` present a SIGTERM to the runner leaves no wrapper and no child (control run:
  `wrappers=0 sleeps=0`); the trap order (INT/TERM/HUP then EXIT) cleans `$work`; roster and seats
  are printed; `shopt -u patsub_replacement` and the single-pass `subst` keep `&`, `\`, `|` literal.
- install.sh: fresh install, customised copy moved to `expert-panel.bak.<timestamp>` with its extra
  file, third run "already current" (run under `CLAUDE_SKILLS_DIR` in eng-work); symlinked target,
  non-skill directory, relative `CLAUDE_SKILLS_DIR`, and unset HOME refused (suite). Nothing is lost
  on a second run; backups accumulate by design.
- make-skill.sh: `--check` passes; `SKILL.md` is byte-identical to header + protocol body (lines
  58-245 are panel-protocol.md:3-190); every "section N" in the header (2, 3, 4, 5, 6) resolves to the
  protocol's numbering; the header's tool wording (Read, Grep, Glob, Write own report; never Bash or
  Edit; a scratch copy and a shell for a script under review, recorded) agrees with
  panel-protocol.md:67-72.
- tests/run.sh: the exit code reflects failures (observed `6 failed` → exit 1 in the F9 run);
  `fresh_fw` isolates adopt.sh and make-skill.sh from the checkout; the drift tests that exist pass
  and assert what they claim (nine classes in three files, six names in two files, eight rules vs
  eight rows, no bare `n/a`, no placeholder in the examples, future example dates: 2026-11-15,
  2026-11-30, 2026-12-15 are all after today).

Documents, by reading:

- No dangling reference in README.md: every "section N" and backticked file resolves (ADAPTING 1,
  2, 2.1, 3, 3.1; README 3.4, 3.5; `adapters/README.md`; `docs/reviews/` exists upstream). The Map's
  six rows match the six numbered headings. ADAPTING.md:84 "### 2.1 Pull-request checklist for any
  change touching a model call" exists with 13 items; agent-rules.md:102 "**Agent workflow**" exists.
- LOCAL.template.md: every section with a pointer points to a section that exists and answers it;
  eight door-audit rows match eight rules by title; "Framework read date" 180 days matches ADAPTING
  rule 3.
- The Script row (ADAPTING.md:24) and the ladder (README.md:493-494) agree; "gate" has one sense;
  Title Case holds; the hosted-loop rule is in 3.5; outcome classes, failure policies, and the
  two-session minimum are consistent across README, ADAPTING, agent-rules, protocol.
- The agentic worked example's bounds (no tool sends or moves money, person sends every reply,
  principal bound at session start) still hold after this round's edits.

---

## 7. Verdict

Two blockers, both reproduced, both introduced by fixes made since 4c8d6ce, both two-line changes
with a test each: the runner's verdict summary can be flipped from BLOCKERS to APPROVE-AS-IS by a
reviewer quoting the artifact's own verdict line as the prompts instruct (F1), and `adopt.sh`
records a credentialed origin URL in a committed file (F2). Eighteen modifications, of which the
ones to fold in before publish are F3 (exit code), F4 (orphan and false "stopped" message), F5
(fence corruption), F9 (suite writes to the developer's skills directory), F10 (LOCAL.md survival
untested), F12 and F16 (what today's cut lost), F13 (the agent-rules sentence), F18 (drift tests for
the new pointers). The length cuts in 3.2 are offered, not required.

BLOCKERS
