# Panel report 3 (second panel, spec gate on the revision): Observer, Engineering pair, Experience pair

**Artifact:** `<checkout>`, branch `panel-2026-10-12`, HEAD f0c0a9b; base 4c8d6ce (the previously published version). The branch folds in the first panel's findings of the same day.
**Review date:** 2026-10-12.
**Seats in this session:** Common Sense Observer (first, cold read of README.md before any diff or prior report); Engineering pair (Software Engineer <-> Code Reviewer); Experience pair adapted to a documentation artifact (UX Designer <-> Technical Writer / Information Architect).
**Build stage:** documents plus four bash scripts with a test suite (`tests/run.sh`). Everything under review exists as text and code; where a document specifies a test an adopter must build (guard test, inventory test), it was reviewed as a specification.
**Method:** every listed file read in full (18 files, 2,592 lines). `tests/run.sh` run from the checkout (108 checks, 0 failed, 2.5 s). Scripts copied to `$S = <scratch>/panel2/eng-scratch/` and exercised against fake projects; the inventory-test logic from ADAPTING section 3 rule 3 was run mechanically against both worked examples. Read-only `git diff 4c8d6ce..HEAD` and `git show 4c8d6ce:<file>` were used to separate what the rewrite introduced from what it inherited. Nothing in the repository was modified; no state-changing git command was run. The prior reports (`docs/reviews/2026-10-12-panel/0-consolidated.md`, `3-engineering-experience-observer.md`) were opened only after sections 1 to 3 below were drafted. Commands are in Appendix A.

**VERDICT: MODIFY-BEFORE-BUILD** (0 blockers, 14 modify, 9 nits). Reasoning in section 6. Of the prior panel's 33 findings, 27 are CLOSED, 6 PARTIAL, 0 NOT CLOSED (section 5). The new findings below are not on the author's list (the commit messages and the first panel's reports); the three with reproductions (adopt.sh end-marker data loss, adopt.sh indented-marker silent no-op, worked example 1 failing its own inventory rule) are the ones the author should read first.

---

## 1. Common Sense Observer (first, unfiltered; written before any diff or prior report)

I read README.md top to bottom with no background, as someone handed the link and ten minutes.

### 1.1 Can I say in one sentence what this is and who it is for?

Yes, now, from the first sentence: "For engineers building software that calls a large language model." My sentence after line 6: *"Rules for engineers whose code calls an LLM, so the code stays cheap, honest, watched, and unable to do more than it should."* That is a real improvement over a version that (I am told, but did not see first) never named the reader. VERIFIED (README.md:3).

The paragraph then loses me by line 7. Lines 7 to 12 are about where the rules came from ("five months of production use", "the TBD convention, the audit-bias rule", "principal scope", "reasoned rather than paid for"). I do not know any of those words yet, and "reasoned rather than paid for" is an idiom nobody outside the author's head uses. The last sentence (lines 10-12) runs two unrelated clauses together with "and". Nearly all of this is repeated at lines 522-528 under Provenance. One of the two copies should go, and it should be the one in the opening. VERIFIED (README.md:7-12 vs 522-528).

Line 4-6 lists "sufficiently, critically, effectively, efficiently, and bounded". Four adverbs and an adjective. It reads like the fifth word was bolted on. "within bounds" would scan. JUDGMENT.

The second paragraph (lines 14-22) is the hardest in the document: "loss model (a false fact in prose)", "cadence, staleness, keep-last-good", "a floor, not a ceiling", "the principal, data-scope, aggregate-bound, harm-floor, and content-sample fields", "seat one veto per irreversible resource". Eleven terms, none defined yet; the Terms paragraph that defines some of them is 25 lines later. For a newcomer this paragraph says "if your situation is more serious than ours, there is more to fill in", which is one sentence. VERIFIED (README.md:14-22).

### 1.2 Did the Map and the Terms paragraph help?

**Map (lines 32-41): yes.** Six rows, each says what the section is and when to read it. It is the table of contents the document lacked. Two quibbles: line 36 says "Eight sentences. The essence." and the principles are each three to five sentences (P1 is five); and the row titles are shortened versions of the headings ("4. The learning curve" vs "4. The learning curve, so you can skip it"), which is fine. VERIFIED (README.md:36 vs 88-94).

**Terms (lines 47-58): half.** Defining words before using them is right, and these fourteen definitions are good ones ("A *call site* is one place in the code that asks the model something; a *call* is one execution of it" is exactly the sentence I wanted). But fourteen definitions in one twelve-line paragraph is a wall; I read it twice and still had to come back for *suppression* and *incident pin*. It is, as the question puts it, a second thing to read before the first. A definition list (one term per line) would cost eight lines and remove the re-reading. And the paragraph misses the words that actually stopped me later (section 1.3). JUDGMENT, with VERIFIED coverage below.

### 1.3 New sentences that are jargon

Checked each candidate against the README text:

| Term | Where used | Defined in README? | Observer's reaction |
|---|---|---|---|
| acting principal | 99, 191, 243, 293 | No. Never glossed; "principal" alone appears in 20, 254, 462, 505. | I guessed "the person the call is working for" from line 99 ("not by the model's account of who is asking"), which is the best context the document gives. One half-sentence at line 99 would settle it: "the acting principal (the person or system on whose behalf this call runs)". |
| capability ceiling | the phrase itself does not appear; "ceiling" at 19, 98, 156, 463; "Ceiling if the fence fails" in the contract | P2 line 96-98 defines it in effect ("what the model could reach and move if every instruction to it were ignored. That ceiling...") | Fine. P2 is the clearest paragraph in the document. |
| nonce fence / fence | 198, 200, 352 | No. "fenced with a per-call nonce and labelled as data" assumes I know what a nonce is and what fencing is. | A newcomer reads "nonce" as a typo. "wrapped in start and end markers that carry a random per-call token, so the model can tell where the untrusted text begins and ends" is what it means. Belongs in Terms. |
| rule-of-two | not in README; `call-site-contract.md:166` and :284 only | No, anywhere in README | The contract asks me to fill a "Rule-of-two check" that the README never mentions. The contract line itself explains it adequately (three yeses require the approval step or a split); the README should at least name it in 3.5 or Terms. |
| harm floor | 20, 130, 344, 371, 377, 382, 441, 469, 498 | No. Nine uses, zero definitions. `evaluation.md:24` defines it well. | A "floor" for harm sounds like the minimum harm you accept. It means the rate of a named bad outcome above which the feature is paused. The README should say that once, at P8. |
| golden set | 226, 228, 369-370, 372, 469, 515 | Partly: line 369-370 lists its attributes in parentheses, after two uses at 226 and 228. | "a fixed, labelled set of inputs kept out of prompt tuning, replayed before any change ships" at first use (226). |
| shape | Terms line 56-58 (call shape); but also 150 ("the structured shape asked for") and 171 ("is the usual shape") | Yes for the call-shape sense | Three senses survive: the call's shape (a defined term), the output schema's shape (150), and a design pattern (171). Rename the other two ("structure", "pattern"). VERIFIED. |
| deterministic default | 152, 283, 465 | No | Inferable ("a fixed fallback answer chosen by code") but never said. One parenthesis at 283. |
| cache breakpoint | 216 | No | Vendor-specific. "the point after which the prompt varies per call, which is where the cache ends" would do. |
| veto seat(s) | 21 ("seat one veto"), 379, 496, 531 | No; defined in panel-protocol.md only | "seat one veto per irreversible resource" at line 21 is a sentence I could not parse until panel-protocol.md:30. |
| TTL, p95, idempotency key, ratcheting, compaction summary, batch tier, canary call, cosmetic surface | 152, 259, 289, 265, 263, 319, 333, 380 | No | Engineering vocabulary; acceptable for the stated audience, but TTL and idempotency key are used in the ladder (465) where a manager may read. |

Pattern: the Terms paragraph defines the words the *first* panel complained about and none of the words the *rewrite* added. VERIFIED (table above; `grep` for defining sentences found none for harm floor, golden set, principal, nonce).

### 1.4 Is the new P2 understandable?

Mostly yes, and it is the best-written principle. "Every call site states what the model could reach and move if every instruction to it were ignored" is plain and frightening in the right way. "which tools, which records, whose data, how much per action and per period" is concrete. Two phrases need a gloss: "scoped to the acting principal" (above) and "a deterministic reversibility design" (line 101), which 3.5 line 300 later explains with examples ("draft-not-send, soft delete with a recovery window, hold queue") that P2 should borrow in a parenthesis. "tool server" (98) is inferable. JUDGMENT.

### 1.5 Does the "Bounded" phase make sense where it sits?

As a list of what gets built, yes: you cannot bound to a principal before you have closed vocabularies (phase 3). As a list of questions a project *asks*, no: the question in row 4 ("Why did it do an allowed thing to the wrong person, or too often?") can only be asked by a project that is already observing (phase 5). The table's column header is "Question the project is answering", so the row order contradicts the header for rows 4 and 5. Either swap rows 4 and 5, or change the header to "What the project learns it needs". The sentence at 446-447 ("The contract forces phases three to six at design time") is fine either way. JUDGMENT, grounded in README.md:436-444.

### 1.6 Other "but why?" items

- README.md:50-52 defines a *gate* as "one of the three review points" and says the delta condition "is a trigger, not a gate". Then P5 (line 114-115) says "Gate calls on 'did the input change'", line 439 says "delta gating", line 466 says "Frequency gated", line 223 says "No quality gate inside the prompt", line 364 says "The final gate is the full suite". The paragraph that was added to settle the word contradicts the body five times. VERIFIED.
- README.md:71 "Copies the six documents". The table above it lists seven `.md` files (64-70). I counted twice. `adopt.sh:19` copies six and makes `LOCAL.md` from the seventh; the README row does not say so. VERIFIED.
- README.md:391-393 "The minimum is the engineering pair, the observer, and the frame-inversion reviewer, in two sessions." Four roles, two sessions; which two go together is not said here (ADAPTING.md:276-277 says). One more clause.
- README.md:477 "a day to build the door and its two tests" vs ADAPTING.md:96 "Rules to enforce on day one, each with a test" (eight rules). Two or eight? VERIFIED.
- README.md:379 "convenes the veto seat"; everywhere else there are "veto seats", one per resource. VERIFIED.

### 1.7 What I would cut to get under 450 lines without losing a rule

538 lines; 89 to remove. By line number, in the order I would take them:

| Cut | Lines | Saved | Why it loses no rule |
|---|---|---|---|
| Opening provenance, replace with one sentence "Provenance and limits are at the end." | 7-12 | -5 | Repeated verbatim at 522-528 |
| "Where it came from" paragraph; fold its one new fact (the source shape) into Provenance | 14-22 | -6 net | Provenance already says the source was a decision-support system; the field list is in the contract |
| Companion-files sentence | 43-45 | -3 | The layout table (62-76) lists the same files |
| Repository layout table; keep the two-line install block and one sentence "`adopt.sh` copies the six framework documents and the licence into `docs/llm-framework/` and creates `LOCAL.md`" | 60-77 | -15 | ADAPTING.md section 2 is the full version; the Map already orients the reader |
| Lead sentences of 3.1 and 3.6 | 170-171, 308-309 | -4 | Definitions, not rules (3.6's lead is a definition the Experience pair below says belongs in Terms) |
| 3.11 Developer workflow with agents, replaced by one line pointing at `agent-rules.md` "Agent workflow" | 412-427 | -14 | `agent-rules.md:89-95` carries every one of these rules already; they are about the coding agent, not the model call |
| Section 4 prose; keep the table | 433-434, 446-447 | -4 | Not rules |
| Total | | **-51** → 487 | |

To reach 450 the next candidate is the section 2 field table (141-157, -17), which duplicates the headings of `call-site-contract.md`; but the Experience pair (section 3.1, X3) relies on exactly that table for README-only fillability, so I would keep it and accept ~487, or drop section 4 entirely (-18, no rules) to reach ~469. Under 450 "without losing a rule" is reachable only by also moving the PR checklist (501-516) into `ADAPTING.md` section 2 where it is already referenced (ADAPTING.md:60-61). JUDGMENT.

---

## 2. Engineering pair

### 2.1 Software Engineer: independent assessment

The shape is still right: prose is the source of truth, scripts are thin, SKILL.md is generated, and there is now a test suite that runs in 2.5 seconds against temp directories. The revision fixed every script defect the first panel reproduced (section 5). What follows are the defects the fixes introduced or left, found by reading the scripts for what the tests do not exercise.

**N1. `adopt.sh` deletes everything after the rules block when the end marker is missing, and reports success.** Mechanism: the awk program at `adopt.sh:72-75` sets `skip = 1` at the begin marker and clears it only at the end marker; with no end marker, every subsequent line is dropped. The branch is entered whenever the begin marker is present (`adopt.sh:70`), so no check that the end marker exists runs. Reproduced (`$S/pA`): a project `AGENTS.md` with the block and a trailing "AFTER THE BLOCK: user text", end-marker line removed, `adopt.sh` re-run: output "refreshed the rules block in .../AGENTS.md; the rules changed, re-read them"; the trailing text is gone (grep count 1 before, 0 after; 102 lines before, 101 after). VERIFIED. Why it matters: the instructions file is a human-only file by the framework's own rule (README.md:423-425), and the marker comment invites editing nearby ("edits here are overwritten"). A one-line slip (deleting a comment line) plus a routine refresh silently truncates the file. Resolve, before the awk at line 70:

```bash
if [ -f "$rules" ] && grep -qF -- "$begin_key" "$rules"; then
  grep -qF -- "$end" "$rules" || { echo "$rules has the begin marker but no end marker; restore the line
  $end
after the rules block, then re-run" >&2; exit 1; }
```

and add a test `t_adopt_refuses_when_end_marker_missing` asserting non-zero exit and that the file is byte-identical afterwards.

**N2. `adopt.sh` with an indented begin marker drops the end marker, never refreshes, and then reports "is current" forever.** Mechanism: `index($0, b) == 1` (`adopt.sh:73`) requires the marker at column 1, but the end-marker rule `index($0, e) == 1` on line 74 still fires and `next`s the line away. Reproduced (`$S/pB`): begin marker indented by two spaces (as happens when a user nests the block under a list item or quote), upstream `agent-rules.md` gains a rule, re-run: "refreshed the rules block ...; the rules changed, re-read them", new rule present 0 times, end marker gone; second re-run: "rules block in ... is current", new rule still absent. VERIFIED. Why it matters: this is the same silent-drift class as the first panel's finding 3 (instructions file enforcing an older ruleset than the docs beside it), reintroduced through the fix. Resolve: match the markers anywhere on the line (`index($0, b) > 0`), or trim leading whitespace before matching, and after the rewrite assert that the output contains exactly one begin and one end marker, else refuse and leave the file untouched. The test from N1 covers the missing-end case; add `t_adopt_indented_marker_still_refreshes`.

**N3. `panel-run.sh` `PANEL_SEATS` matches by leading number, and two prompts sharing a number silently select only the last.** Mechanism: `adapters/generic/panel-run.sh:49-52` loops over all prompts and overwrites `hit` on every match. Reproduced with a custom `PANEL_PROMPTS` holding `1-alpha.md` and `1-bravo.md`, `PANEL_SEATS=1`: "seats: 1-bravo", one report. Also `PANEL_SEATS='3 3'` on the shipped prompts runs the same seat twice, in parallel, writing the same `3-engineering-experience-observer.md` and `.err` (two concurrent writers to one file). VERIFIED. Why it matters: ADAPTING.md:248 tells chat-path users to keep their own prompt files; a project that adds `1-domain-and-safety.md` beside the shipped `1-domain-data-and-veto.md` loses one of them with no message. Resolve: error on an ambiguous number ("seat 1 matches 1-alpha and 1-bravo; name the file") and dedupe `selected`.

**N4. `panel-run.sh` will abort on stock macOS bash when no `timeout` is installed.** `timeout_cmd=()` stays empty when neither `timeout` nor `gtimeout` exists (`panel-run.sh:59-63`, the branch that prints "PANEL_TIMEOUT is not enforced"), and `envargs=()` stays empty when `PANEL_ENV_PASS` is unset; both are then expanded as `"${timeout_cmd[@]}"` / `"${envargs[@]}"` under `set -u` at line 100. In bash 3.2 (what macOS ships) and 4.0-4.3, expanding an empty array with `[@]` under `set -u` is "unbound variable" and the script exits; bash 4.4+ (this machine: 5.2.21) treats it as nothing. macOS without Homebrew coreutils is exactly the configuration that takes the no-timeout branch. README.md:27 promises macOS. JUDGMENT (not reproduced here; the behaviour is documented bash history and the test machine has 5.2 only). Resolve: `${timeout_cmd[@]+"${timeout_cmd[@]}"}` and `${envargs[@]+"${envargs[@]}"}` at line 100, or state "bash 4.4 or newer" in README.md:27 and `panel-run.sh:1`.

**N5. ADAPTING.md's timing sentence contradicts itself.** `ADAPTING.md:6-7`: "Budget an afternoon for steps 1 to 5 ... a day for the door and its tests". Step 3 (section 3) *is* the door. The base version said "an afternoon for steps 1 to 5" and the rewrite appended the day for the door into the same sentence. README.md:476-479 says it coherently ("an afternoon to install and write the first contract ...; a day to build the door"). VERIFIED (`git show 4c8d6ce:ADAPTING.md` line 6). Resolve: "an afternoon for steps 1, 2, and 4 on a green-field project with one call site; a day for step 3 (the door and its tests)".

**N6. `call-site-contract.md:8-9` points the agentic reader to the wrong section for bounds.** "section 11 carries the bounds": the per-action, per-principal, per-day bounds and the reversal path are in section 4 (`call-site-contract.md:77-79`); section 11 carries the ceiling, the principal, the tools, and the irreversible-action gate. VERIFIED. Resolve: "section 4 carries the bounds and section 11 the ceiling, the principal, and the approval step".

### 2.2 Code Reviewer: independent assessment

Contradictions the rewrite introduced between files, cross-references, the worked examples against the template's own test, and `tests/run.sh` as code.

**N7. The Terms paragraph's "trigger, not a gate" rule is contradicted by five uses of "gate" for the delta condition and two more senses.** README.md:50-52 (new in this revision) vs README.md:114-115 "Gate calls on 'did the input change'", :439 "delta gating", :466 "Frequency gated", agent-rules.md:60 "delta-gate on changed input", ADAPTING.md:28 "delta gating"; plus README.md:223 "quality gate inside the prompt", :364 and agent-rules.md:92 "The final gate is the full suite", call-site-contract.md:163 "gate: `<human approval ...>`". VERIFIED (grep). Before the revision "gate" was loose; the Terms paragraph has turned it into a stated rule the body breaks. Resolve either way: (a) keep the Terms rule and rewrite the seven uses ("Run calls only when the input changed", "delta condition", "frequency-conditioned", "no self-rating demand inside the prompt", "the final check is the full suite", "approval step:"), or (b) soften the Terms sentence to "the delta condition that decides whether a call runs is called a trigger here, though the body also says 'delta gating'". (a) is the one consistent with the document's own thesis.

**N8. The inventory test as specified does not expire the read date, although three files now say it does.** `call-site-contract.md:152` "Read date: `<YYYY-MM-DD>` (repeated here so the inventory test can expire it)", `evaluation.md:20` "put it in a calendar and in the contract, so the inventory test expires it", `ADAPTING.md:191-192` same. The test specification, `ADAPTING.md:109-120` rule 3, enumerates what the test enforces: a bare `TBD`/`TODO`/`n/a`; `TBD(...)` without a by-date; `TBD(...)` whose by-date has passed; an empty registry with contracts on disk. Rule 7 (:133-134) adds the retirement date ("reuse the by-date parser"). Nothing parses a `Read date:` line, and the read date is written as a bare date, not inside `TBD(... by ...)`. The same gap applies to `planned(by date)` in the validators' status column (`call-site-contract.md:102`) and in both examples' Build stage lines (:188, :229-230): a planned control whose date passes never turns the check red. VERIFIED (text; the "repeated here so the inventory test can expire it" clause is new in this revision per `git show 4c8d6ce:call-site-contract.md` line 116). Why it matters: an engineer building the inventory test from rule 3, as the document intends, produces a test that never expires an evaluation, and the double entry of the read date (the one thing the double entry is justified by) buys nothing. Resolve: add to rule 3: "a `Read date: YYYY-MM-DD` in section 10 that has passed while the evaluation file's Result is empty fails; a `planned(by YYYY-MM-DD)` whose date has passed fails, like a TBD."

**N9. Worked example 1 fails the template's own inventory rule.** Running rule 3's placeholder check ("the backticked `<...>` form, outside fenced code blocks", `ADAPTING.md:110-111`) on `call-site-contract.md:184-223`: line 203, `` `{ "queue": "<name>", "confidence": "high|low", "evidence_used": ["subject", "body"] }` ``, is a backticked span containing `<name>` outside any fence. Example 2 passes. Every `TBD(...)` in both examples has a by-date (:249), no bare `TBD`/`TODO`/`n/a` in either, all `n/a` carry a reason. VERIFIED (Appendix A, inventory run). Why it matters: the first panel's finding 11 was exactly "the examples teach a shape that fails the framework's own inventory test"; the author fixed the three named lines and the clarified rule now catches a fourth. Resolve: `"queue": "Billing"` (a real value from the 14), or move the schema into a fenced ```json block as the template does at :85-87.

**N10. Example 2 omits the two template fields that matter most for an agentic session.** The template's **Iteration loop** field (`call-site-contract.md:112-115`: "does the model ever see its own prior output? ... Drift and ratchet test: `<test name>`") and **Context** field (:58: ceiling, what is dropped or compacted first, how a compaction summary re-entering the context is treated) are absent from the agentic example (:224-287), which runs 12 tool calls, 600 s and 60k tokens per session and therefore sees its own prior output every turn. Both examples also omit Owner, Created, Contract last reviewed, Streaming, Priority, Tier (interactive|batch; example 1 says "small tier", a model tier), "thinking counts toward it", worked-examples count, live smoke flag, and the section 12 Review table; example 2 omits expected cadence/max per day, alert thresholds, incident pins, and gives "retirement recorded" without a date. "(abridged)" covers brevity; it does not cover modelling the "not ready" state README.md:159 forbids. VERIFIED (field-by-field, Appendix A). Resolve: add to example 2 one line "**Iteration loop:** every turn sees the transcript; no prior model statement is relied on (entitlements and ticket facts re-read through tools each turn); user claims about earlier turns are checked against the transcript; drift test `test_session_ratchet_2026_09_20`" and one line "**Context:** 60k tokens; oldest tool results compacted first; a compaction summary is labelled model output and no fact in it is acted on without a tool re-read"; and open each example with "(abridged: Owner, Created, Streaming, Priority, Review table omitted)" so the omission is declared rather than silent.

**N11. `tests/run.sh:248` is a vacuous check.** `check "no report named *.md" test ! -e "$tmp/r8b/*.md"`: the glob is inside double quotes, so `test` looks for a file literally named `*.md`, which never exists; the check passes whether or not the runner wrote literal `*.md` files. The first panel's V4 (empty prompts dir yields literal `*.md` reports) is therefore not actually tested; `panel-run.sh:42-44` does fix it, but the test would pass if the fix were reverted. VERIFIED (shell semantics; a `test ! -e "/x/*.md"` with an existing `/x/a.md` returns true). Resolve: `check "no report files written" bash -c '! ls "$1"/*.md 2>/dev/null | grep -q .' _ "$tmp/r8b"`, or simply `test ! -d "$tmp/r8b"` since the runner exits before `mkdir -p`.

**N12. The doc-drift checks are weaker than their names.** `tests/run.sh:289` "six framework files everywhere" greps for the absence of "(five|four) framework files|those five files"; it does not check that "six" appears, nor that the enumerated list in `ADAPTING.md:48-49` and `adapters/README.md:3-4` equals `files=` in `adopt.sh:19`. :293-295 "names the truncated and cap_hit outcome classes" checks two words, not that the three outcome-class lists (README.md:329-331, ADAPTING.md:140-141, agent-rules.md:65-66) are equal (they are, today; I compared them). Nothing tests: the door-audit row count in `LOCAL.template.md:52-59` against the numbered rules in `ADAPTING.md:98-145` (the first panel's 6-vs-7 mismatch, fixed by hand to 8/8, has no pin); the placeholder rule against the worked examples (would have caught N9); that example by-dates (2026-11-15, 2026-11-30, 2026-12-15) are in the future (on 2026-11-16 the examples will model expired TBDs and nothing will say so). VERIFIED (read). Resolve: four checks, each a few lines: extract and compare the three outcome-class lists; compare `files=` to the two prose lists; count `^[0-9]\. \*\*` in ADAPTING section 3 against `^\| ` rows in the door-audit table; run the N9 placeholder grep on `sed -n '/^## Worked example/,$p' call-site-contract.md`; compare example by-dates to `date +%F` and *warn* (not fail) when within 30 days.

**N13. `make-skill.sh --check` does catch an unregenerated header edit.** Appended a line to a copy of `skill-header.md` and ran `--check`: "SKILL.md differs from skill-header.md + panel-protocol.md; run ..." exit 1. VERIFIED (Appendix A). Sound. One brittleness: `tail -n +3` of `panel-protocol.md` assumes the title and one blank line; front matter or a second title line would be silently included or dropped, though `--check` would flag the resulting diff.

**N14. Cross-references, every one checked.** All section-number references resolve to a section that says what is claimed, with two exceptions already listed (N6; and README.md:49 "section 3.4 has six layers" resolves correctly). Specifically verified: README.md:21 → ADAPTING section 1 (:27-32 says what to mark n/a for other shapes); README.md:391 → protocol section 2; README.md:446 → README section 2; README.md:455, 485 → ADAPTING sections 1, 3, 3.1; ADAPTING.md:61 → README section 6 PR checklist (:501); ADAPTING.md:74 → section 3; :208 → 5.4; :235 → protocol section 2; ADAPTING.md:338-341 describes `make-skill.sh` correctly (writes from header + protocol; `--check` run by tests at `tests/run.sh:278`); `adapters/README.md:23` → ADAPTING 5.4; :27-30 → make-skill correct; :37-38 "passes only PATH, HOME, and PANEL_ENV_PASS" matches `panel-run.sh:100`; LOCAL.template.md:6, 12, 17, 31, 40, 48, 69 all resolve; skill-header.md:26, 35, 40, 41, 43 resolve inside SKILL.md; `panel-run.sh:14` → protocol section 2; contract :157 "see section 3" → :56. The README Map (32-41) matches the six numbered headings (86, 136, 166, 431, 451, 474) modulo shortened titles. Contract section 10's pointer (`evaluations/<id>.md`) is relative to `docs/llm-framework/`, not to the contract's own directory (`contracts/`); ADAPTING.md:191 gives the full path. Nit.

**N15. Terminology, revised text.** "guard test" is now used only for architecture tests and "validator" only for output checks (grep: no "validator" near import/door/route/secret; "guard" alone survives in P3's title "guards are controls", README.md:103, where it means any structural control including validators, and as a verb at :112, :303, ADAPTING.md:176). "stage" is now only build stage (section 4 says "Phase"). "whitelist" is gone (test). "veto seat" singular at README.md:379 where the document otherwise has one per resource. "Frame-Inversion Reviewer" (role, Title Case: protocol :32, :52, :58; LOCAL :29, :35, :38) vs "frame-inversion reviewer" (lower case: README.md:392, agent-rules.md:84, ADAPTING.md:277, protocol :78) vs "frame-inversion lens" (seat kind: protocol :44, :63; skill-header :52; ADAPTING :237) vs "frame inversion" (technique: README.md:55, :470): four forms, defensible as role / seat kind / technique, but the lower-case role title breaks the protocol's own "Role titles only" convention. "instructions file" is now uniform (README, ADAPTING, adapters/README, adopt.sh usage); the `.adopt` key is still `rules=` and ADAPTING.md:68 glosses it as "instructions file" (nit). "content sample" everywhere except agent-rules.md:69 "a daily sample of the output" (nit). Outcome classes identical in the three lists; `vocab_reject` / `numeric_reject` (contract :103-104, ADAPTING.md:297) are log events, not outcome classes, and are never labelled as such (nit carried from the first panel's X7, not in its numbered 33).

### 2.3 Peer challenge

**Code Reviewer disputes the Software Engineer:** N1 is a blocker by the first panel's own bar. The first panel demoted install.sh's clobbering of a customised skill to modify because "nobody is told to act on the grep" and the loss was a *skill copy*; N1 truncates the project's instructions file, the one file the framework calls human-only, on a routine refresh that ADAPTING.md:320 tells every adopter to run, and reports success. The precondition (a missing comment line) is a one-keystroke user slip in a file users edit by design.

**Software Engineer disputes the Code Reviewer:** The precondition is a user *deleting* a line that says "managed by adopt.sh" in the same comment; the file is in version control in every real project; `cmp -s` before writing (adopt.sh:76) means an unchanged upstream never triggers the write, so the loss needs a user slip *and* an upstream change *and* no diff before commit, which ADAPTING.md:335 tells them to do. That is three failures deep, with a one-line fix and a test. It is the highest-priority modify, not a blocker; "unsafe to follow" means an adopter following the documents is harmed, and the documents say diff before committing. On N4 the Code Reviewer should hold the line harder: README.md:27 promises macOS, and the no-`timeout` branch is the default macOS condition; the author wrote the branch and then broke it with the array expansion two lines later. That one is JUDGMENT only because no bash 3.2 is on this machine.

**Code Reviewer, second round:** Accepts modify for N1 on condition that N1 and N2 land with their tests, since both are in the one code path the first panel's finding 3 was about and the test suite currently passes with both defects present. Insists N8 is not a nit: it is the revision's new justification for a double entry, and the double entry is justified by a check the specification does not contain.

### 2.4 Reconciled position

**Agree: MODIFY-BEFORE-BUILD.** Must-do: N1, N2 (with tests), N7, N8, N9, N11. Should-do: N3, N4, N5, N6, N10, N12. Nits: N13 (brittleness note only), N14 (relative path), N15 (veto seat singular, lower-case role title, `.adopt` key gloss, "daily sample", `vocab_reject` label). Escalate nothing.

---

## 3. Experience pair (UX Designer <-> Technical Writer / Information Architect)

### 3.1 UX Designer: independent assessment (can the reader act on it?)

**X1. Are the checklist items one yes/no question each?** The Map now promises it (README.md:38 "Each box is one yes/no question"). Every item in 3.2, 3.5, 3.7 sampled:

3.2 (lines 185-208), 11 items, 5 bundle:
- 185-187: facts injected with source *and* prompt never asks for a number/date/identifier (2).
- 188-190: identifier in prompt, validated against the set, unknown dropped not repaired (3).
- 200-201: contract states the ceiling *and* the set is bounded structurally (2).
- 202-204: smallest high-signal set; distractors removed; decisive evidence at start or end; input tokens logged and capped (4).
- 206-208: re-derived from tools *and* user claims checked against transcript (2).
- One question each: 191-192, 193, 194-195, 196, 197-199, 205.

3.5 (lines 272-304), 11 items, 10 bundle:
- 272-275: one module imported everywhere; guard test with failing fixture; inventory test; unknown raises; second vendor behind the same door (5).
- 276-278: pinned snapshots; retirement date; inventory fails 30 days before; served id logged; out-of-allowlist id alerts (5).
- 279-281: environment allowlist; credentials in one place; pinned client version; own config dir; process group killed (5).
- 282-285: hard-fail at transport; four policies; silent fallback is a bug; cascade is a registered route (4).
- 286-288: n attempts; backoff with jitter; Retry-After; inside total timeout; each attempt logged; idempotency key; server rejects repeat (7).
- 290-291: no secrets in prompts/logs/fixtures *and* logs carry the template hash (2).
- 292-295: tool allowlist; server holds credentials; server validates against the principal; filesystem scope; egress allowlist; no credential (6).
- 296-297: reviewed as external text; pinned by version/hash; changed definition fails inventory (3).
- 298-301: approval or reversibility named in the contract *and* prompt/keyword audit is not an option (2).
- 302-304: config is the door; human-only; guarded by a diff test (3).
- One question: 289 (measured and enforced, arguably two).

3.7 (lines 327-344), 7 items, 5 bundle:
- 332-334: liveness from real calls *and* canary for request-response shapes (2).
- 335-336: storms thresholded on a window *and* parse/API alerts separate (2).
- 337-338: shows its age *and* says a model produced it (2).
- 340-342: template-hash drift *and* distribution drift (2).
- 343-344: daily sample read *and* every finding has a path (2).
- One question: 327-331 (one long conjunction, acceptable as "does every call log these fields"), 339.

VERIFIED (quoted). The first panel agreed with the author on a nested-list form for the long items (its 3.3 peer challenge); the revision moved the definitions out of the boxes (good: 170-171, 308-309 are now lead paragraphs) and rewrote 212-214 as "The prompt has all of:" (good), but did not apply the nested form to 3.5, and the Map now asserts a property that 20 of 29 sampled boxes lack. Resolve: either (a) drop the Map clause "Each box is one yes/no question", or (b) for the five 3.5 items with four or more checks, keep one box and indent the checks as a nested list ("- [ ] One door: / - a guard test ... / - an inventory test ... / - an unknown call site raises / - a second vendor is a second transport"), which adds about 25 lines and makes the promise true where it matters (the ladder's Routing row scores from exactly these items).

**X2. Is the maturity ladder usable now?** Yes, mostly. VERIFIED against README.md:451-470: one dimension per row (ten rows; Budget row added at :466; storms no longer in Failure handling; timeouts moved to Budget; drift only in Observability); "3 (all of)" in the header plus the sentence at :456-457; the scale sentence at :454-456 ("Level 3 everywhere is the target at Service scale and above; Script scale targets level 2 in Routing, Evaluation, and Review"); the scoring rule at :453 ("Score per call site; a row's project level is its lowest call site") and who scores (:453-454, a reviewer at the results gate). Two gaps remain. (a) Level-2 cells also bundle ("Vocabulary and numeric copy checks"; "Frequency gated; latency measured; timeouts from p95"; "Incident-pinned regressions; redacted fixtures") and the "all of" rule is stated only for level 3; a project with vocabulary checks but no numeric copy check has no level-2 score. (b) Cumulative semantics are unstated: Routing 3 ("Allowlisted call sites; inventory test; pinned snapshots") does not mention the guard test from level 2, so a project with an inventory test and no guard test can read itself as 3. JUDGMENT grounded in the quoted cells. Resolve: one sentence at :457: "Levels are cumulative and every cell is 'all of': a cell is met only when each item in it and in every cell to its left is."

**X3. Can `call-site-contract.md` be filled by someone who read only README.md?** Better than before: section 2's table (:141-157) now names Shape, Build stage, TBD and n/a, and 3.3 to 3.6 name cache breakpoint, batch tier, scheduler priority, idempotency key. Still unfillable from the README alone: **Rule-of-two check** (:166-168; the phrase is absent from the README), **Context** (:58; "compaction" appears in README 3.4 but "ceiling in tokens / dropped first" does not), **thinking counts toward it** (:68; not in README), **Server-side vendor tools** (:165; not in README), **vendor terms relied on** (:170; not in README), and the **Iteration loop** block (:112-115; README 3.4 :265 has one line). VERIFIED (grep). The new fields most adopters will leave as boilerplate or `n/a(reason)`: for a non-agentic call, Resources the model can move (:77-79), For a loop caps (:76), Committed tool actions (:127-128), one event row per tool call (:133), Tools / Reads / Writes / Irreversible / Sandbox / Server-side tools / Rule-of-two (:160-168); for a non-conversational call, Iteration loop (:112-115) and Context compaction (:58); for a non-UI call, Streaming (:96); for Script scale, Priority (:72), Tier (:69), Cache (:73). That is 17 fields, each needing a written `n/a(reason)` for a single-shot operator-read call, which trains the reflex the template exists to prevent (reasons become "n/a(not agentic)" seventeen times). JUDGMENT.

Resolve: make the fields optional *by shape* rather than by prose. Tag each shape-specific field in the template with its shape in brackets, e.g. "**Iteration loop** [conversation, agentic]", "Resources the model can move [agentic]", "Streaming [request-response, conversation]", "Last-good artifact [scheduled artifact]", and add to the header rule (:7-8): "A field tagged with a shape this call does not have may be deleted rather than marked n/a; the Shape line records which shapes were not present." The inventory test is unaffected. Merges to shorten honest filling: section 2 cadence/max per day (:36) duplicates section 4 "hard cap per day, enforced in the door" (:74-75), keep the section 4 one; section 3 "Ceiling if the fence fails" (:56) and section 11 "Injection surface ... ceiling if the fence fails: see section 3" (:157) are already one field with a pointer, drop the section 11 half-line; section 4 "Resources the model can move ... reversal path" (:77-79) overlaps section 11 "Writes" and "Irreversible actions ... gate" (:162-163), keep the bounds in 4 and the gate in 11 and say so (N6); section 9 "Guard tests touching this site" (:146), section 11 "Secrets ... verified by guard test" (:156), "Sandbox" (:164) and "vendor terms relied on" (:170) are project-level invariants identical in every contract and belong in `LOCAL.md` (door audit, a "Vendor terms" line), referenced from the contract by one line "Project-level controls: per LOCAL.md door audit of <date>". Net: about ten fewer fields per contract, none of them per-call facts.

**X4. Is the evaluation.md / contract section 10 double entry resolved?** Yes. Contract section 10 (:149-152) is now a pointer plus the read date; `evaluation.md` holds the fields; README section 2 (:155) says "Pointer to the evaluation file and its read date". The instruction "repeated here so the inventory test can expire it" is clear in intent and phrasing and is repeated consistently in three places (contract :152, evaluation.md:20, ADAPTING.md:191-192). What is not clear is *how*, because the test specification does not do it (Engineering N8). From the reader's side: a reader who builds the test from rule 3 and then reads :152 will assume they missed something; they did not. VERIFIED (text) and resolved by N8's one sentence in rule 3.

**X5. Navigation.** The Map works (Observer 1.2). The install block (:78-82) now follows the layout table and the README says what `adopt.sh` writes (:71, :482-484); the "reading this inside a project" note at :28-30 is present. README section 6 step 2 now says "Build or audit the door (... section 3.1 if the project already calls a model)" (:485-486), fixing the retrofit-first order. VERIFIED.

### 3.2 Technical Writer / Information Architect: independent assessment (does the text say one thing, one way?)

**X6. Terminology table for the revised text.**

| Concept | Forms found | Where | Status |
|---|---|---|---|
| gate | review gate (three); "Gate calls on did the input change"; "delta gating"; "Frequency gated"; "quality gate inside the prompt"; "final gate is the full suite"; "gate: human approval" | README.md:50-52 vs :114, :439, :466, :223, :364; agent-rules.md:60, :92; ADAPTING.md:28; call-site-contract.md:163 | **Not resolved; now a contradiction with the Terms rule** (N7) |
| guard | "guard test" (architecture test, uniform); "guards are controls" (P3 title, generic); "guarded by a test" (verb) | README.md:49-50, :103, :112, :303; ADAPTING.md:176 | Resolved for the noun; P3's title uses the generic sense once. Acceptable. |
| validator | output checks only | README.md:49, section 3.4, contract section 6 | Resolved |
| shape | call shape (defined); output "structured shape"; "the usual shape" (pattern) | README.md:56, :150, :171 | Two stray senses |
| stage | build stage only; learning curve says "Phase" | README.md:436; ADAPTING.md:252 | Resolved |
| veto seat / seats | "one veto per irreversible resource", "veto seats", "the veto seat" (singular where plural is meant) | README.md:21, :379, :496, :531 | One stray singular (:379) |
| Frame-Inversion Reviewer / frame-inversion reviewer / frame-inversion lens / frame inversion | role title (Title Case), role title (lower case), seat kind, technique | protocol :32, :44, :52, :58, :63, :78; README.md:55, :392, :470; agent-rules.md:84; ADAPTING.md:237, :277; skill-header :39, :52 | Role title should be Title Case wherever it names the seat (README.md:392, agent-rules.md:84, ADAPTING.md:277, protocol :78); "lens" and "frame inversion" are fine as seat kind and technique |
| Data Visualization Specialist | uniform | protocol :29; LOCAL.template :28; prompt 3 :10 | Resolved as a title. Whether it is the right second role for a documentation artifact: see X7 |
| instructions file | uniform in prose; `.adopt` key `rules=`; ADAPTING.md:68 glosses the key as "instructions file" | README, ADAPTING, adapters/README, adopt.sh:5 usage | Resolved; the key name is a nit |
| content sample / daily sample | "content sample" ×11; "a daily sample of the output" ×1 | agent-rules.md:69 | One stray; "daily content sample" |
| nonce fence / fence / per-call nonce / session nonce | "fence" is the noun throughout; "nonce" the mechanism; "per-call" (README, contract template) vs "per-run" (ADAPTING.md:247, the runner's nonce is per run) vs "session nonce" (contract :245) | README.md:198; contract :54, :245; ADAPTING.md:25, :247; panel-run.sh:3 | Consistent in meaning; "per-call" / "per-run" / "session" each correct for its context. Define "fence" once in Terms (Observer 1.3) |
| TBD(reason, by date) / planned(by date) | two provisional markers | contract :6, :102, :188, :229 | Only one is expired by the specified test (N8) |
| outcome classes | identical nine in three lists; `vocab_reject`, `numeric_reject` unlabelled log events | README.md:329-331; ADAPTING.md:140-141; agent-rules.md:65-66; contract :103-104 | Resolved; label the two events "(log event, not an outcome class)" |
| six framework files / six documents / eight rules / two tests vs each with a test | "six" uniform; "eight rules" = 8 door-audit rows; "its two tests" (README.md:477) vs "each with a test" (ADAPTING.md:96) | README.md:71, :477; ADAPTING.md:49, :56, :96, :155, :320, :328; adapters/README.md:3; LOCAL.template.md:52-59; adopt.sh:66 | Counts resolved except the test count |
| minimum panel | "two sessions" in all three places | README.md:391-393; ADAPTING.md:276-277; protocol :64 | Resolved |
| reproduction rule | verify a file:line finding directly; reproduce judgment findings; demote a blocker that does not reproduce | README.md:399-400; agent-rules.md:85-87; protocol :128-141; skill-header :43-45 | Resolved |
| audit bias | README: precision-biased "only where a false correction damages trust in an advisory its reader can ignore"; agent-rules and contract: "only where the reader is the operator and can ignore the output" | README.md:247-250; agent-rules.md:35-37; contract :105 | Same rule, two conditions worded differently (README omits "operator"); harmonise to the agent-rules wording |
| failure policies | skip loudly, deterministic default, keep last good (with TTL), abort; ADAPTING hyphenates | README.md:152, :282-283; ADAPTING.md:122; agent-rules.md:47-48; contract :119 | Resolved (hyphenation only) |

VERIFIED (locations) + JUDGMENT (recommendations).

**X7. The protocol says only the domain pair(s) and veto seat(s) need adapting, and this review had to adapt the Experience pair.** `panel-protocol.md:8` "Only the domain pair(s) and the veto seat(s) in the roster need adapting per project"; :29 fixes the Experience pair as "UX Designer ↔ Data Visualization Specialist"; :56 convenes it for "anything a person reads". A documentation framework is something a person reads with no display and no data; both panels on this repository seated a Technical Writer instead, outside the protocol's rule. JUDGMENT. Resolve: in the roster row, "UX Designer ↔ Data Visualization Specialist (for a display of numbers) or Technical Writer / Information Architect (for a document)", and in :8 "the domain pair(s), the veto seat(s), and the Experience pair's second role".

**X8. Numbers and claims that disagree in the revised text.** "Eight sentences" (README.md:36) vs three to five per principle; "six documents" (:71) vs seven listed (:64-70; `LOCAL.template.md` becomes `LOCAL.md`, unsaid in that row); "its two tests" (:477) vs eight rules each with a test (ADAPTING.md:96); "an afternoon for steps 1 to 5" vs "a day for the door" (ADAPTING.md:6-7, N5); "Each box is one yes/no question" (:38) vs X1. VERIFIED.

**X9. ADAPTING section 7 and adapters/README now describe the real mechanisms.** Refresh rewrites the marked block and says so when it changed (:325-326, matches adopt.sh:76-77); `.adopt` remembers a named file (:326-327, matches adopt.sh:30-31); `make-skill.sh` and `--check` (:338-341); the runner's environment rule (adapters/README.md:37-38). VERIFIED.

### 3.3 Peer challenge

**Technical Writer disputes the UX Designer:** X1 over-counts again. "Timeouts are measured (p95 with margin) and enforced" is one question to anyone who has set a timeout, and 327-331 is one question with a long object. The Map clause should simply go; nesting 3.5 adds 25 lines to a README the Observer wants 90 lines shorter, and the ladder scores from the contract and the door audit (:453-454), not from the boxes. X3's shape tags are the real win and are cheap.

**UX Designer disputes the Technical Writer:** X6 is a long table and twelve of its sixteen rows say "resolved"; lead with the two that change what a reader does (gate; TBD/planned not expired) and the one that changes what a reviewer does (X7). Dropping the Map clause is fine, but the 3.5 items at 272-275 and 292-295 are the two the door audit copies into `LOCAL.md` row by row (LOCAL.template.md:52-59 has one row per *rule*, and the rule at 272-275 is five rows' worth); those two should be nested regardless of the Map.

### 3.4 Reconciled position

**Agree: MODIFY-BEFORE-BUILD.** Must-do: X1 in the reduced form (drop the Map clause; nest 272-275 and 292-295 only), X4/N8 (one sentence in rule 3), X6 row 1 (gate, with N7). Should-do: X2 cumulative sentence, X3 shape tags and the LOCAL.md move, X7 roster row, X8 counts. Nits: the rest of X6. Escalate nothing.

---

## 4. Findings, consolidated (what / where / why / resolve / status)

"VERIFIED" = reproduced by a run or quoted with line numbers; "JUDGMENT" = reasoned from the text.

| # | What | Where | Why it matters | Resolve | Status |
|---|---|---|---|---|---|
| 1 | `adopt.sh` refresh deletes everything after the begin marker when the end marker is missing, reports "refreshed" | adopt.sh:70-78 | Silent truncation of the human-only instructions file on the routine refresh ADAPTING section 7 prescribes | Refuse when begin present and end absent (code in N1); test | VERIFIED ($S/pA) |
| 2 | Indented begin marker: end marker removed, rules not refreshed, every later run says "is current" | adopt.sh:73-74 | The first panel's finding 3 (instructions file drifts from docs) reintroduced via the fix | Match markers anywhere on the line; assert one begin and one end after rewrite; test | VERIFIED ($S/pB) |
| 3 | Terms paragraph rules "trigger, not a gate" while the body uses "gate" for the delta condition five times and in two more senses | README.md:50-52 vs :114, :223, :364, :439, :466; agent-rules.md:60, :92; ADAPTING.md:28; contract :163 | The sentence added to fix the word creates a contradiction | Rewrite the seven uses, or soften the Terms sentence (N7) | VERIFIED |
| 4 | Three files say the inventory test expires the read date; the test specification does not, nor `planned(by date)` | contract :152, :102, :188, :229; evaluation.md:20; ADAPTING.md:109-120, :191-192 | The justification for the one remaining double entry is a check nobody is told to build | Add read-date and planned(by) expiry to rule 3 (N8) | VERIFIED |
| 5 | Worked example 1 fails the template's own placeholder rule (backticked `<name>` outside a fence) | call-site-contract.md:203; ADAPTING.md:110-111 | Same class as the first panel's finding 11; the clarified rule catches a fourth line | Real value or fenced block (N9) | VERIFIED (inventory run) |
| 6 | Map claims "Each box is one yes/no question"; 20 of 29 boxes in 3.2/3.5/3.7 bundle 2-7 checks | README.md:38 vs :185-208, :272-304, :327-344 | A promise the text does not keep; 3.5's items are the door-audit rows | Drop the clause; nest 272-275 and 292-295 (X1) | VERIFIED |
| 7 | `tests/run.sh:248` tests for a file literally named `*.md`; always passes | tests/run.sh:248 | The first panel's V4 is not actually pinned; a revert of nullglob passes the suite | `! ls "$d"/*.md 2>/dev/null \| grep -q .` or `test ! -d` (N11) | VERIFIED |
| 8 | `PANEL_SEATS` numeric match silently takes the last of two prompts sharing a number; a repeated seat runs twice into one file | panel-run.sh:49-55 | Custom prompt dirs (ADAPTING.md:248) lose a seat without a message | Error on ambiguity; dedupe (N3) | VERIFIED |
| 9 | Example 2 omits Iteration loop and Context, the two agentic-specific fields; both examples silently omit a dozen template fields | call-site-contract.md:224-287 vs :58, :112-115 | The example teaches the "not ready" state README.md:159 forbids | Two lines; declare the abridgement (N10) | VERIFIED |
| 10 | Empty-array expansion under `set -u` aborts on bash < 4.4 (stock macOS) when no `timeout` is installed or `PANEL_ENV_PASS` is unset | panel-run.sh:59-65, :100; README.md:27 | macOS without coreutils is the exact case the no-timeout branch exists for | `${arr[@]+"${arr[@]}"}` or state bash ≥ 4.4 (N4) | JUDGMENT |
| 11 | Doc-drift tests weaker than their names; no test for the placeholder rule on the examples, door-rule count, list equality, example dates | tests/run.sh:289, :293-295 | The suite would not have caught findings 5 or the 8-vs-rows count | Four small checks (N12) | VERIFIED |
| 12 | New jargon undefined in README: acting principal, harm floor, golden set, nonce/fence, veto seat; rule-of-two absent from README but a contract field | README.md:20-21, :99, :130, :198, :226, :379; contract :166 | The Terms paragraph defines last panel's words, not this revision's | Half-sentence at first use or Terms rows (Observer 1.3) | VERIFIED |
| 13 | Opening paragraphs duplicate Provenance and front-load eleven undefined terms | README.md:7-22 vs :522-534 | Loses the newcomer the first sentence won | Fold into Provenance (Observer 1.1, 1.7) | VERIFIED |
| 14 | Seventeen contract fields are n/a for a single-shot operator-read call; project-level invariants repeated per contract | call-site-contract.md:58, :69-79, :96, :112-115, :127-128, :133, :146, :156, :160-170 | Trains "n/a(not agentic)" as a reflex; honest filling is long | Shape tags; move invariants to LOCAL.md (X3) | JUDGMENT |
| 15 | ADAPTING timing sentence contradicts itself (afternoon for steps 1-5 incl. the door; a day for the door) | ADAPTING.md:6-7 | Introduced by the rewrite | "steps 1, 2, and 4 ...; a day for step 3" (N5) | VERIFIED |
| 16 | "section 11 carries the bounds"; bounds are in section 4 | call-site-contract.md:8-9 vs :77-79 | Agentic reader sent to the wrong section | Reword (N6) | VERIFIED |
| 17 | Ladder: level-2 cells bundle without an all-of rule; cumulative semantics unstated | README.md:459-470 | Routing 3 without the level-2 guard test reads as 3 | One sentence at :457 (X2) | JUDGMENT |
| 18 | Protocol fixes the Experience pair's second role as Data Visualization Specialist and says only domain/veto adapt; both panels on this repo had to adapt it | panel-protocol.md:8, :29, :56 | A documentation artifact gets a numbers reviewer | Shape-dependent second role (X7) | JUDGMENT |
| 19 | "Eight sentences", "six documents" (seven listed), "its two tests" vs eight rules, "convenes the veto seat" | README.md:36, :71, :477, :379; ADAPTING.md:96 | Small facts that drift, in a document about facts not drifting | Fix each (X8) | VERIFIED |
| 20 | "shape" in three senses | README.md:56, :150, :171 | A defined term reused loosely | "structure", "pattern" | VERIFIED |
| 21 | Role title "frame-inversion reviewer" in lower case where it names the seat | README.md:392; agent-rules.md:84; ADAPTING.md:277; protocol :78 | Breaks "Role titles only" | Title Case | VERIFIED |
| 22 | "Bounded" phase asks a question only an observing project can ask, one row before "Observed" | README.md:441-442 | Row order contradicts the column header | Swap rows or rename the header (Observer 1.5) | JUDGMENT |
| 23 | Nits: `.adopt` key `rules=` glossed as "instructions file"; "daily sample" vs "content sample"; `vocab_reject`/`numeric_reject` unlabelled; audit-bias condition worded two ways; evaluations/ path relative to the wrong directory; `tail -n +3` brittleness | ADAPTING.md:68; agent-rules.md:69; contract :103-104, :151; README.md:247-250 vs agent-rules.md:35; make-skill.sh:9 | Polish | One-word fixes | VERIFIED |

---

## 5. Closure of the first panel's findings (opened after sections 1-3 were drafted)

Against `docs/reviews/2026-10-12-panel/3-engineering-experience-observer.md` section 4 (33 findings) and `0-consolidated.md` section C ("Self-consistency and text").

| # | First panel's finding (short) | Status | Evidence in the revised text |
|---|---|---|---|
| 1 | Verdict grep: first word anywhere, uppercase only | CLOSED | panel-run.sh:108 anchored `^(BLOCKERS\|MODIFY-BEFORE-BUILD\|APPROVE-AS-IS)[[:space:]]*$`, last match; panel-protocol.md:105-108 uppercase tokens; tests/run.sh:196-203 |
| 2 | sed injection in roster substitution | CLOSED | panel-run.sh:25, :72-76 bash literal substitution; tests/run.sh:189-194 (`R&D Lead \| Path\Analyst` verbatim) |
| 3 | adopt.sh heading-string idempotency; pasted block never refreshed; section 7 silent | CLOSED (new defects in the same path: findings 1, 2 above) | adopt.sh:20-22 markers, :70-78 in-place rewrite, :44-52 legacy detection; ADAPTING.md:325-326; tests/run.sh:56-93 |
| 4 | Refresh without the second argument creates a stray AGENTS.md | CLOSED | adopt.sh:30-31, :62-65 `.adopt` `rules=`; ADAPTING.md:320-327; tests/run.sh:104-111 |
| 5 | Data pair has no prompt and no dispatch slot | CLOSED | adapters/generic/prompts/1-domain-data-and-veto.md:8-11; panel-protocol.md:62-63 "domain + data + veto"; skill-header.md:33; tests/run.sh:299 |
| 6 | "POSIX shell" false | CLOSED | README.md:27 "bash (Linux, macOS, WSL, Git Bash)"; tests/run.sh:288. (New: finding 10, bash < 4.4.) |
| 7 | SKILL.md stale duplicate intro; no generator | CLOSED | adapters/claude-code/make-skill.sh; SKILL.md:54-59 single intro; tests/run.sh:276-280 (`--check` and intro-once); ADAPTING.md:338-341; adapters/README.md:27-30 |
| 8 | Reproduction rule drifted ("until they reproduce") | CLOSED | README.md:399-400; agent-rules.md:85-87; panel-protocol.md:128-141; skill-header.md:43-45, all "verified where it names a line; judgment reproduced; non-reproducing blocker demoted" |
| 9 | "Practices guide named under Provenance" dangling | CLOSED | README.md:7-12 says which rules are reasoned and that "The incident record is not public"; :522-528 |
| 10 | "Four parts" vs six sections; ladder attributed to section 6 | CLOSED | README.md:32-41 Map matches headings :86, :136, :166, :431, :451, :474 |
| 11 | Examples: TBD "by a date"; no Build stage; "read date set"; read date in the past | PARTIAL | Fixed: contract :249 `by 2026-11-15`; :188, :229-230 Build stage lines; :218 read date 2026-11-30, :277 2026-12-15, both future. Missing: example 1 line 203 now fails the clarified placeholder rule (finding 5); example 2 lacks Iteration loop and Context (finding 9) |
| 12 | Adopted copy: dangling references, no MIT notice | CLOSED | adopt.sh:57 copies LICENSE; :63-65 `.adopt` records `source=` and `commit=`; README.md:28-30 "Reading this inside a project's docs/llm-framework/? ..." |
| 13 | install.sh clobbers a customised skill; detaches a symlink | CLOSED | install.sh:15-18 refuses symlink; :23-30 moves a differing copy to `.bak.<timestamp>`; tests/run.sh:138-158 |
| 14 | panel-run.sh never reads LOCAL.md though two texts say so | CLOSED | panel-run.sh:17-20 "copied from LOCAL.md"; :95 prints the roster; ADAPTING.md:207-208 and :247 `.panel.env`; tests/run.sh:268-272 |
| 15 | No PANEL_SEATS / PANEL_BUILD_STAGE | CLOSED (new: finding 8, ambiguity) | panel-run.sh:13-15, :46-58, :79; tests/run.sh:217-231 |
| 16 | File counts 4/5/6; door rules 6 vs 7 rows; validators 5 vs 6 | CLOSED | "six" at ADAPTING.md:49, :56, :320, :328; adapters/README.md:3; README.md:71; adopt.sh:66. Eight rules (ADAPTING.md:98-145, :155) = eight rows (LOCAL.template.md:52-59). Six layers at README.md:49-50, :151, :240-254; contract :100-107. (New: "its two tests", finding 19.) |
| 17 | Minimum panel 3 vs 2 sessions | CLOSED | README.md:391-393; ADAPTING.md:276-277; panel-protocol.md:64 |
| 18 | Ladder: bundled L3 cells, cross-row leakage, no Budget row, level-3-everywhere vs proportionality | PARTIAL | Fixed: README.md:459 "3 (all of)" + :456-457; :466 Budget row; storms/timeouts/drift moved; :454-456 scale sentence. Missing: level-2 all-of and cumulative semantics (finding 17) |
| 19 | Checklist items not yes/no or bundled (17 named) | PARTIAL | Fixed: :170-171 and :308-309 definitions moved to lead paragraphs; :212-214 "The prompt has all of:"; :256 "Validate-and-drop; no silent repair"; :401-402 "re-run once". Missing: nested form not applied to 3.5 (:272-275, :276-278, :279-281, :286-288, :292-295), and the Map (:38) now asserts the property (finding 6) |
| 20 | guard ×4, gate ×4, stage ×2; validator/control/layer; whitelist | PARTIAL | Fixed: guard test / validator split (README.md:49-50; grep clean); "Phase" (:436); whitelist gone (tests/run.sh:287). Missing: "gate" (finding 3); "shape" gained a second and third sense (finding 20) |
| 21 | README 3.10 omits scoping | CLOSED | README.md:391-393 |
| 22 | Two evaluation templates with different fields | CLOSED (with finding 4 on the stated reason) | contract :149-152 pointer + read date; evaluation.md:20; README.md:155 |
| 23 | Jargon before definition (door, gate, guard, call site, pin, doctrine, inline, frame, suppression) | PARTIAL | Fixed: README.md:47-58 Terms defines all nine; "doctrine" → "stated policy"; "inline" → "in the session that wrote it" (:126-127). Missing: the revision's own new terms (finding 12) |
| 24 | P1/P2 overlap; no principle covers security | CLOSED | README.md:88-94 P1 absorbs the old P2; :96-101 new P2 bounds/security; :156 Security row maps to P2 |
| 25 | Subprocess language in a transport-agnostic core | CLOSED | README.md:280 "If it is a subprocess"; ADAPTING.md:127 same; the agentic example (:286) keeps it as an example fact |
| 26 | Guard-test spec indeterminate | CLOSED | ADAPTING.md:98-106: scope (excluding manifests, lockfiles, docs/), import-statement match, endpoint host / CLI name, transport must contain a hit, fixture per top-level dir, lockfile rule, mock the seam |
| 27 | Placeholder rule misses the fenced JSON; prose `<time>` false positive | CLOSED | ADAPTING.md:110-111 "outside fenced code blocks"; template schema fenced at contract :85-87. (Example 1 :203 now violates the clarified rule: finding 5.) |
| 28 | Incident-pin assertion never shown | CLOSED | ADAPTING.md:293-297 (fixture, production entry point, `manual`, `vocab_reject`) |
| 29 | `{{EXTRA_PAIR}}` bare name | CLOSED | panel-run.sh:36 sentence; tests/run.sh:233-240 |
| 30 | Prompt 4 ordering/truncation; one verdict for five reviewers vs per-pair | CLOSED | 4-frame-inversion.md:18-29 Build stage before Output shape, full text; panel-protocol.md:100 "Per session" |
| 31 | Empty prompts dir yields literal `*.md` | CLOSED (the test for it is vacuous: finding 7) | panel-run.sh:42-44 nullglob + error |
| 32 | Two instructions files: silent choice | CLOSED | adopt.sh:83-87 note; ADAPTING.md:54-56; tests/run.sh:95-102 |
| 33 | "commit" under "never touch branch state" | CLOSED | README.md:416-417 "never move branches ...; no checkout, rebase, merge, or push"; agent-rules.md:90-91 |

Consolidated report, section C "Self-consistency and text" (items not already covered above):

| Item | Status | Evidence |
|---|---|---|
| Validator layers 6/5/4 | CLOSED | six at README.md:49-50, :151, :240-254; contract :100-107; ADAPTING.md:179-180 lists six |
| Files 6/5/4; door rules 6 vs 7 rows | CLOSED | see 16 |
| "POSIX shell" | CLOSED | see 6 |
| whitelist; "five months" vs "several months" | CLOSED | tests/run.sh:287; README.md:7 and :522 both "five months" |
| "Four parts"; ladder in section 6 | CLOSED | see 10 |
| Reproduction rule | CLOSED | see 8 |
| Minimum panel; verdict casing | CLOSED | see 17; uppercase at panel-protocol.md:105-108, README.md:397, skill-header.md:3, all four prompts |
| Worked examples violate own rules | PARTIAL | see 11 |
| Adopted copy references; MIT notice | CLOSED | see 12 |
| Evaluation fields in three places | CLOSED | see 22 |
| "commit" under branch state; subprocess language; "arm" undefined in protocol section 6 | CLOSED | see 33, 25; panel-protocol.md:128-141 no longer uses "arm" |
| 3.10 scoping; 17 checklist items; ladder; guard/gate/stage senses; jargon | CLOSED / PARTIAL / PARTIAL / PARTIAL / PARTIAL | see 21, 19, 18, 20, 23 |
| "Re-run if every reviewer approves" has no terminating condition | CLOSED | README.md:401-402; panel-protocol.md:156-158 "Re-run once ... A second clean approve is recorded ... with both push-on lists attached" |
| TBD expiry reds the whole suite; trains date-bumping | CLOSED | ADAPTING.md:115-120 (second approver for a moved date; own CI check, required on contract/registry/call-site changes, advisory elsewhere); :364-365 |
| Time estimate README vs ADAPTING | PARTIAL | Both now say afternoon + a day for the door + half day + two weeks + a day per retrofitted call site (README.md:476-480; ADAPTING.md:6-12), but ADAPTING.md:6-7 contradicts itself (finding 15) and README.md:477 "its two tests" vs ADAPTING.md:96 (finding 19) |

Tally: 27 CLOSED, 6 PARTIAL (11, 18, 19, 20, 23, and the time estimate), 0 NOT CLOSED. Every PARTIAL has its missing piece named in column 3 and a resolving change in section 4.

---

## 6. What was checked and found sound (so a lenient read is visible)

`tests/run.sh`: 108 checks, 0 failed, 2.5 s, from the checkout, no files touched outside `mktemp`. `make-skill.sh --check` catches a header edit that was not regenerated (exit 1 with a message). `SKILL.md` body is byte-identical to `panel-protocol.md` from line 3 and has one intro. `adopt.sh`: idempotent on an unmodified project (tree md5-identical); remembers an absolute instructions path outside the project and reports "is current" on re-run; refuses a directory as the instructions file before writing; creates `contracts/`, `evaluations/`, `LOCAL.md` from the template and never overwrites `LOCAL.md`; writes `rules=`, `source=`, `commit=`. `panel-run.sh`: pre-flight before any model call (unreadable file, empty prompts dir, oversize input); nonce differs between runs and the artifact's forged fence line is delivered as content; `env -i` passes only PATH, HOME and the named variables; verdict summary takes the last own-line token; `PANEL_SEATS` by basename works. Cross-references: every section-number and file reference in the ten documents and two scripts resolves to a section that says what is claimed (two wording defects: findings 16 and 23). The three outcome-class lists are identical. Failure-policy vocabulary is identical in content in five places. "six framework files" matches `adopt.sh:19`; eight door rules match eight door-audit rows. Both examples: every `TBD(...)` has a by-date; no bare `TBD`, `TODO`, or `n/a`; every `n/a` has a reason; every date is coherent with 2026-10-12 (latency measured 2026-08-30, guard test 2026-09-01, incident 2026-08-12, replacement snapshot 2026-10-01 already released, read dates and planned dates in the future). The audit-bias rule is the same rule in all three statements. The reproduction rule, the minimum panel, the re-run-once rule, and the TBD second-approver rule agree across files. The Map matches the headings. The ladder has a Budget row, one dimension per row, a scale sentence, and a scoring rule. Section 6 step 2 sends retrofits to ADAPTING 3.1. README names its reader in sentence one.

---

## 7. Verdict

MODIFY-BEFORE-BUILD

Why not BLOCKERS: no finding makes the framework unsafe to *follow*. The two destructive script paths (findings 1, 2) need a user edit to a managed comment line plus an upstream change, and ADAPTING.md:335 says to diff before committing a refresh; each is a two-line fix with a test. Why not APPROVE-AS-IS: two reproduced silent-corruption paths in the one script every adopter runs; one worked example still failing the template's own test after the first panel named that exact class; a new justification (read-date expiry) for a check the specification does not contain; two contradictions the rewrite itself introduced (the Terms "gate" rule vs seven uses; the Map's yes/no claim vs twenty boxes); and a vacuous test standing in for a fixed defect. These are the revision's own additions, not leftovers, and the framework's P1 and P7 are about exactly this.

Must-do before merge and publish: findings 1, 2 (with tests), 3, 4, 5, 6 (drop the Map clause at minimum), 7. Should-do: 8-17. Nits: 18-23.

---

## Appendix A: commands and output (abridged; `$S` = `<scratch>/panel2/eng-scratch`)

```
$ bash tests/run.sh | tail -1                  -> 108 checks, 0 failed  (real 2.5 s)
$ git diff --stat 4c8d6ce..HEAD                -> 25 files, +3429 -679; README 350 -> 538 lines

# Inventory-test logic (ADAPTING section 3 rule 3) on each example separately
$ awk 'NR>=184 && NR<=223' call-site-contract.md > $S/ex1.md; awk 'NR>=224' call-site-contract.md > $S/ex2.md
$ awk '/^```/{f=!f; next} !f' $S/ex1.md | grep -n -oE '`[^`]*<[^`>]*>[^`]*`'
20:`{ "queue": "<name>", "confidence": "high|low", "evidence_used": ["subject", "body"] }`   # = contract :203  FAILS rule 3
$ (same on ex2)                                -> none
$ grep -nE '\bTBD([^(]|$)|\bTODO\b|n/a([^(]|$)' $S/ex[12].md   -> none
$ tr '\n' ' ' < $S/ex2.md | grep -oE 'TBD\([^)]*\)' | grep -vE 'by\s+[0-9]{4}-[0-9]{2}-[0-9]{2}'   -> none
$ markers: ex1 planned(by 2026-11-15); ex2 planned(by 2026-11-15), TBD(measure p95 over the first 200 sessions, by 2026-11-15)
$ dates: ex1 2026-06-01 2026-08-12 2026-08-30 2026-09-01 2026-10-01 2026-11-15 2026-11-30 2027-06-01; ex2 2026-07-15 2026-09-01 2026-11-15 2026-12-15

# adopt.sh: end marker missing (pA)
$ adopt.sh pA; echo 'AFTER THE BLOCK: user text' >> pA/AGENTS.md; grep -v 'agent-rules end' ... (remove end marker)
  before: grep -c 'AFTER THE BLOCK' = 1, 102 lines
$ adopt.sh pA   -> "refreshed the rules block in .../AGENTS.md; the rules changed, re-read them"
  after:  grep -c 'AFTER THE BLOCK' = 0, 101 lines, end markers = 1 (the one awk printed)

# adopt.sh: begin marker indented (pB), upstream agent-rules.md += "- NEW UPSTREAM RULE"
$ adopt.sh pB   -> "refreshed the rules block ...; the rules changed, re-read them"; NEW UPSTREAM RULE present: 0
$ grep -n 'llm-framework:agent-rules' pB/AGENTS.md   -> 3: "  <!-- ... begin ..." only; end marker gone
$ adopt.sh pB   -> "rules block in .../AGENTS.md is current"; NEW UPSTREAM RULE present: 0

# adopt.sh: absolute instructions path outside the project (pC)
$ adopt.sh pC $S/outside/RULES.md; head -1 pC/docs/llm-framework/.adopt   -> rules=/.../outside/RULES.md
$ adopt.sh pC   -> "rules block in .../outside/RULES.md is current"; one block   (sound)

# panel-run.sh: PANEL_SEATS ambiguity and duplication
$ PANEL_PROMPTS=$S/prompts2 (1-alpha.md, 1-bravo.md, 2-other.md) PANEL_SEATS=1 panel-run.sh rep1 art.md
  -> "seats: 1-bravo"; rep1/ = 1-bravo.md 1-bravo.err
$ PANEL_SEATS='3 3' panel-run.sh rep2 art.md (shipped prompts)
  -> "seats: 3-engineering-experience-observer 3-engineering-experience-observer"; both writers to rep2/3-engineering-experience-observer.md

# make-skill.sh --check with an unregenerated header edit
$ cp -r adapters panel-protocol.md $S/mk/; echo "extra header line" >> $S/mk/adapters/claude-code/skill-header.md
$ $S/mk/adapters/claude-code/make-skill.sh --check   -> "SKILL.md differs from skill-header.md + panel-protocol.md; run ..." exit=1   (sound)

# bash on this machine: GNU bash 5.2.21; `set -u; a=(); echo "[${a[@]}]"` -> ok (so finding 10 is not reproducible here)

# base-version comparisons
$ git show 4c8d6ce:README.md | grep -c 'trigger, not a gate|^## Map|Eight sentences|acting principal|harm floor|golden set'   -> 0 (all new)
$ git show 4c8d6ce:call-site-contract.md | grep -n 'Read date'   -> 116: "- Read date: `<YYYY-MM-DD>`"  (the "so the inventory test can expire it" clause is new)
$ git show 4c8d6ce:ADAPTING.md | sed -n 6p   -> "Budget an afternoon for steps 1 to 5, an hour per model call for step 4, and another half" (the "a day for the door" clause was appended by the rewrite)
$ git show 4c8d6ce:panel-protocol.md | grep -n 'Only the domain'   -> 7: "Only the domain pair in the roster needs adapting"

# greps behind the terminology table (section 3.2 X6) and the cross-reference list (N14) are reproducible with:
$ grep -n -i 'gate' README.md ADAPTING.md agent-rules.md call-site-contract.md | grep -v -i -E 'design gate|spec gate|results gate|three gates|...'
$ grep -n -o -E 'section [0-9]+(\.[0-9]+)?' README.md ADAPTING.md agent-rules.md call-site-contract.md panel-protocol.md LOCAL.template.md adapters/README.md adapters/claude-code/skill-header.md adapters/generic/panel-run.sh
```
