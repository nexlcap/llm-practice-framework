# Consolidated panel verdict: spec gate on branch panel-2026-10-12 (third run)

**Artifact:** the revision at b41ba8d (base 4c8d6ce): the second panel's findings folded in, plus the
Observer's README cuts and the pull-request checklist moved to ADAPTING 2.1.
**Review dates:** dispatched 2026-10-12, consolidated 2026-10-13. **Gate:** spec, before merge and
publish. **Scope:** two sessions, the protocol's minimum for a change to documents and scripts, chosen
because both earlier rounds' blockers came from the Frame-Inversion lens and from script text written
the same day; the Experience pair joined the engineering session because the README cut is a change
to a document people read.
**Roster:** Frame-Inversion Reviewer (session 2); Engineering pair, Experience pair adapted to
UX Designer ↔ Technical Writer, and the Common Sense Observer (session 1). Proposed, as in the earlier
runs: this repository is the framework, not an adopter, and has no `LOCAL.md`.
**Sessions:** two fresh subagents dispatched in parallel from the orchestrating session. Session 1 ran
with a shell on a scratch copy of the repository (the protocol's recorded exception for a script under
review); session 2 had read-only tools plus write access to its report file, and its Glob and Grep
tools were unavailable, so it read the prompts directory by the four names the tests reference.
Session 1 was cut off by a usage limit while writing its findings table and resumed once with its
context intact. Neither session saw the earlier rounds' reports before writing its independent
assessment; session 1 then read the second round's consolidated verdict to mark closure.
  1. Engineering + Experience + Observer → BLOCKERS (2 blockers, 18 modify) — `1-engineering-experience-observer.md`
  2. Frame-Inversion → BLOCKERS (1 blocker, 13 modify, 3 limitations) — `2-frame-inversion.md`

## Consolidated verdict

**BLOCKERS** (3 distinct), all folded in before presenting; about 40 modifications folded in; 3
limitations stated in README Provenance and limits.

Closure of the second panel (session 1, section 4): both blockers closed; "process-group stop",
"`.adopt` containment", "`shape` in one sense", and the `pgrep` test fix were partial, each with the
defect the fix introduced, and all are closed in this round.

## Blockers (all verified; the first by two independent lenses)

| # | Finding | Lenses | Resolution in this round |
|---|---|---|---|
| B1 | `panel-run.sh` reported the last token-alone line as the verdict; a reviewer that quotes the artifact's own verdict line under its verdict, as the prompts ask, flipped BLOCKERS to APPROVE-AS-IS with exit 0. The previous round's test pinned the defect. | engineering (F1, reproduced) and frame (F8) | A verdict is exactly one distinct token-alone line; none, or two different ones, is reported as `NO VERDICT LINE` or `CONFLICTING VERDICT LINES` and the runner exits 3; the same token twice is one verdict. Tests replaced. |
| B2 | `adopt.sh` wrote the framework checkout's origin URL verbatim into the adopter's committed `.adopt`, credentials included (reproduced with a stub git: `https://user:token@...`). Introduced by the first round's `.adopt` record. | engineering (F2, reproduced) | Userinfo stripped before recording; test with a stub git. |
| B3 | Nothing in the failure policy, the last-good store, the deterministic default, the deduplication key, the liveness window, the log record, or the content sample was keyed by the acting principal, and the entitlement test covered only the model path; a per-principal scheduled artifact built as the template words it serves one tenant's last-good artifact to another, with green liveness, a correct "last good shown" banner, no sample, and a log that cannot attribute the failure. The README named this vocabulary as single-tenant-shaped and did not turn the admission into a rule. | frame (F1, verified by quote at nine places) | README 3.2, 3.4, 3.5, 3.7 and the ladder; contract sections 2, 7, 8, 9; ADAPTING rule 8 and section 6 (tests, alerts); agent-rules (artifact) and Observability: stores, defaults, and the dedupe key keyed by (call site, acting principal); counts per principal; per-principal liveness for a scheduled artifact produced per principal; the acting principal in the log record; the entitlement test covers the failure path and the principal binding; the sample draws from what consumers received. |

## Modifications folded in (by group)

**Scripts (verified by execution, tests added; 177 → 249 checks):** every reviewer in its own process
group with or without `timeout`, so a stop reaches the reviewer's children (reproduced with a
`timeout` that makes no group: two children left alive before, none after); exit 3 on a missing or
conflicting verdict; `PANEL_TIMEOUT=0` refused; a report directory that already holds reports
refused; `PANEL_SEATS` accepts `name.md`; command and variable names printed; work directory removed on
any exit (a prompt unreadable mid-run leaked it); marker scan and rewrite as one awk pass each, with
CRLF and BOM kept and fenced marker lines treated as text (the rules had been written inside a user's
``` fence with success reported); rewrite computed in pre-flight so a failure changes nothing;
symlinked instructions file refused; deleted instructions directory recreated rather than reported as
"outside the project"; legacy detection by the first rule at line start, with the 4c8d6ce file as a
fixture; `reviews/` created; LOCAL.md sections the template gained are printed on refresh;
install.sh's shadowing comment corrected against the tool's documentation (personal over project,
checked 2026-10-13). Tests: the developer's `CLAUDE_SKILLS_DIR` and `PANEL_*` are unset (the suite
had written into a real skills directory; verified: with the variable set, 249 checks pass and the
directory stays empty); LOCAL.md and `contracts/` survive a refresh (a mutant that clobbered LOCAL.md
had passed); the SIGTERM test asserts the reviewer's child; `not_with 'end'` tightened; tool inference
tested; drift checks for README's six files, the 2.1 and Agent workflow pointers, the day counts, and
no fence in agent-rules.md; the door-rule count survives a tenth rule.

**Principal and entitlement (frame F2–F5):** approval surface shows the acting principal; binding test
named in the contract and ADAPTING; a sub-agent inherits the principal from the door, never from the
spawning call's arguments; operator-internal fields (internal notes, tags, margins) are an audit
class, with a "visible to the reader" column in the data-sources table; the first worked example's
`n/a(no per-customer reads)` replaced by the CRM-keyed entitlement test, its acting principal
restated as the operator with the service identity standing in only because the consumer is the
operator, and its harm floor stated (urgent tickets misrouted, measured deterministically).

**The panel's own gate (frame F6–F9, engineering Observer):** the CI check parses the verdict line
(present, not BLOCKERS); at Service scale and above a refuted or demoted blocker is recorded by a
second person who is not the author, as a moved by-date is; the tautological "unanimity" sentence
replaced by an operational rule (a blocker stands if any of K re-dispatches raises it; demoted only
when none of K ≥ 2 does); per-seat verdicts recorded beside the consolidated one (review log columns
in LOCAL.template.md and here); the coding-agent write restriction stated as a request unless a deny
rule enforces it; reviewers quote no credential, fixture record, or personal data (prompts, protocol,
skill header); `docs/llm-framework/reviews/` added to the secrets-and-personal-data guard; the
panel's vendor, account, model, and terms recorded in LOCAL.md; HOME reaching the reviewer command
stated in the runner header and adapters/README.

**Adoption path (frame F10–F13, engineering F8, F14, F15):** re-run the adapter installer after each
update (README, ADAPTING 7); scale decided by capability and audience, not size, with "no tool the
model can call" in the Script Mandatory cell and the agent-rules preamble; the scoping row for
removing a human control agrees across protocol, template, and README (Domain, Data, Veto).

**Reading (engineering Observer and Experience pair, frame F14–F17):** Terms gain consumer and
operator, entitlement, snapshot (two senses), budget unit, and scale; the jargon sentence before Terms
cut; the Install paragraph describes each of the six files and the no-coding-agent case; the
pull-request checklist pointer moved to the section it compresses; section 6 step 1 points at
Install; the P2 parenthetical and the P4 pointer cut; the Map row no longer promises a box in 3.11;
the read-only-brief rule restored in agent-rules.md and the review rule given an actor and "a session
that did not write it"; the "treat it as a hypothesis" sentence and the loss-model admission restored,
with "every rule here about another person's data, money, or messages is reasoned, not paid for"; the
opening's provenance claim weakened to groups of rules; `n/a` reasons named a review-only control, and
the evaluation template's example reason sharpened.

## Accepted limitations, stated in README Provenance and limits
- The ceiling bounds the model; the code around the call (failure policies, caches, last-good
  stores, logs) can disclose on its own, and the per-principal rules in 3.4, 3.5, and 3.7 are the
  only ones that address it.
- The content sample is a human-review processing activity; where agreements forbid it, the harm
  floor cannot be measured by sampling and only the deterministic checks remain.
- The panel's own calls go to a vendor under the reviewer command's account; the generic runner's
  allowlist bounds environment variables, not the files under HOME.

## Refuted, demoted, or declined (with evidence)
- Experience pair's remaining cut, "merge Where it came from into Provenance": declined. The
  Frame-Inversion Reviewer's section 2 item 3 and F17 want the single-tenant admission before the
  rules, where a multi-tenant adopter reads it; the paragraph now carries the loss-model sentence.
  The other four small cuts were taken. README is 602 lines (566 at dispatch): the round's additions
  are terms and rules the reviewers asked for. The Technical Writer's assessment stands: the README is
  an orientation and a reference in one file, and that split is a separate decision because it
  changes the six-file set the tests pin.
- Frame F7's preference for reviewers returning the report text rather than writing a file:
  partially taken. The restriction is now stated as a request unless a deny rule enforces it, and the
  reviews directory is scanned; the write-a-file pattern is kept because the report would otherwise
  pass through the orchestrator's context.
- Frame F11's "hash of the published block" for legacy detection: a hash would miss an edited block,
  which is the case the finding describes; detection by the first rule at line start was chosen, and
  the 4c8d6ce fixture pins it. The verbatim-fixture check passed before the change (it pins current
  behaviour); the edited-heading check failed before it and passes after.
- Engineering F11's "refuse a non-empty report directory": taken as stated rather than deleting the
  stale files, because deleting a user's files on a path argument is the riskier default.
- Engineering's grading dispute on B1 (a convenience line vs a structural parse): resolved for the
  structural reading by making the line structural and the exit code honest, which also answers the
  Observer's question of why a convenience was pinned by a test.
- Engineering F13's "hand both commands to the human": not taken literally; in a tool that
  delegates, the orchestrating session dispatches the reviewing session itself. The sentence now has
  an actor and the words "a session that did not write it".

## What the third panel checked and found sound
The second round's blockers closed at the lines given; adopt.sh pre-flight ordering, LOCAL.md and
`contracts/` never touched, candidate-file notes, paths with spaces; panel-run.sh pre-flight,
nonce fence, environment allowlist, seat selection, `timeout -k`, trap order; install.sh backup and
refusals; make-skill.sh `--check` and the generated file's section numbering; no dangling reference in
the README; the Map matching the headings; LOCAL.template.md pointers; the agentic worked example's
bounds; the rules that hold against the inverted frame (approval-rate measurement, recall-biased audit
for third parties, control retention, sized harm floor, redacted fixtures, pinned snapshots with
lifecycle dates, tool-list hash pinning, sub-agent output as external text, prior turns as context).
