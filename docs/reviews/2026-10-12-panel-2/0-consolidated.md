# Consolidated panel verdict: spec gate on branch panel-2026-10-12 (second run)

**Artifact:** the revision at f0c0a9b (base 4c8d6ce), which folded in the first panel's findings.
**Review date:** 2026-10-12. **Gate:** spec, before merge and publish.
**Roster:** proposed, as in the first run: LLM Production Engineer ↔ Methodology Skeptic; Data pair;
veto Adopter's Time and Credibility Advocate; Security, Systems, Engineering pairs; Experience pair
adapted to UX Designer ↔ Technical Writer; Common Sense Observer; Frame-Inversion Reviewer.
**Sessions:** four fresh subagents, dispatched in parallel, resumed once after a session limit cut
them off mid-report (their contexts were kept; nothing was re-read). Three did an independent
assessment first and only then opened the first panel's consolidated report to mark closure; the
Frame-Inversion Reviewer never saw the first panel's reports.
  1. Domain + Data + Veto → MODIFY-BEFORE-BUILD (21 findings) — `1-domain-data-veto.md`
  2. Security + Systems → MODIFY-BEFORE-BUILD (30 findings, 4 blocker-grade absorbed) — `2-security-systems.md`
  3. Engineering + Experience + Observer → MODIFY-BEFORE-BUILD (23 findings) — `3-engineering-experience-observer.md`
  4. Frame-Inversion → BLOCKERS (1 blocker, 14 modify, 3 limitations) — `4-frame-inversion.md`

## Consolidated verdict

**BLOCKERS** (2), folded in before presenting; about 60 modifications folded in; 3 limitations stated.

Closure of the first panel: all seven blockers closed (B2 partially: the agent-rules preamble
exempted only the panel at Script scale, now the whole Mandatory cell); of the engineering report's
33 findings 27 closed and 6 partial, all partials closed in this round; no first-panel finding left
open.

## Blockers (both verified; two independent lenses on the second)

| # | Finding | Lenses | Resolution in this round |
|---|---|---|---|
| R1 | The contract offered "a service identity" as the acting principal, and every scope rule reached tool reads and emitted identifiers but not the evidence code itself retrieves; a multi-tenant digest from a shared index passed P2 on paper. | frame (verified by quote) | P2 names the principal as the party whose entitlement bounds the output; 3.2 gains an entitlement item with a fixture test; the contract gains data sources read by code, evidence ownership, and a principal field whose service-identity option is narrowed to a consumer; layer 3 counts shown values only from evidence within the entitlement. |
| SYS-1 / N1 | `adopt.sh` deleted everything after the begin marker when the end marker was missing, and an indented marker corrupted the refresh while reporting success. | security and engineering, reproduced by both and by the consolidator | Markers validated before any write (one pair, column 1, begin before end); the script refuses and changes nothing otherwise; tests. |

## Modifications folded in (by group)

**Scripts (verified by execution, tests added):** `.adopt` path containment; incomplete upstream
copy refused; legacy-block detection requires the heading; instructions file under
`docs/llm-framework/` refused; `PANEL_SEATS` that selects nothing is an error, duplicates run once,
ambiguous numbers are refused; `timeout -k` with `PANEL_KILL_AFTER`; Ctrl-C and SIGTERM stop every
reviewer's process group; `PANEL_TIMEOUT`/`PANEL_MAX_BYTES`/`PANEL_ENV_PASS` validated; HOME passed
only when set; empty arrays safe under `set -u`; bash 4 required and said; single-pass placeholder
substitution; `make-skill.sh` refuses unknown arguments; relative `CLAUDE_SKILLS_DIR` refused.
Tests: the vacuous `*.md` check replaced; `not` paired with message greps; `md5sum`/`sed -i`
replaced; timing tests skip without `timeout`; drift checks compare the nine outcome classes, derive
the six files from `adopt.sh`, count door rules against audit rows, run the placeholder rule on the
examples, and warn when an example date passes.

**Vendor neutrality (verified against three vendors by session 1):** "cache breakpoint" → marker
where required, prefix kept first otherwise; "dated snapshot" → an id the vendor documents as fixed;
retirement date may be unpublished (lifecycle page checked, stale after 90 days; preview ids not
pinned); batch tier conditional on the deadline tolerating the window, expiry is `cancelled`;
effort/cache sentence softened.

**Over-correction:** agent-rules preamble exempts everything but the Script Mandatory cell;
`(scheduled)` tag; canary and content sample conditioned on Service scale; tool-list hash pinning
scoped to servers the project controls, version-with-review for third-party servers.

**Contradictions the first revision introduced:** ladder vs Script row; "Review level 1" → "at most
level 2"; P3 lists all six layers; "Eight sentences" → principles; "Each box is one yes/no question"
dropped; "gate" reserved for the review gates; `shape` used in one sense; ADAPTING's budget
sentence; "section 11 carries the bounds"; "six documents" row; "its two tests"; "veto seat"
singular; Title Case for the Frame-Inversion Reviewer.

**Evaluation (data pair):** dev set vs golden set; hash-baseline failure as the re-run trigger;
labels blind to the model; judge family vs data terms; harm floor sample sized by the rate it must
exclude; content sample random, stratified, including held and discarded outputs, read where the
data lives, each read logged, missing read alerts; drift baseline from production, not fixtures;
ladder scoring per call site only for per-call-site rows, cumulative all-of semantics.

**Security and systems (documents):** reviewers run with read-only tools (the panel's own ceiling);
agentic example's rule-of-two answer corrected (three yeses, covered by draft-not-send and
reversible state); reader/actor split passes only typed values; P1's trust sentence made operational
(a sub-agent that read external text is external text; `read_external` logged); acting-principal
binding specified (door binds from the authenticated request, never a tool argument); approval
surface shows deterministic arguments and approvals are measured; `timeout`/`cap_hit`/`cancelled`
defined; inventory test split into structural and calendar parts with read dates and `planned(by)`
expiring; retirement grammar; serving drift via canary vs fixture; idempotency key never includes
the attempt counter; deterministic default visibly a default, `default_served` counted; tagged
sections deleted rather than filled with `n/a`; canary against a synthetic principal; per-tool-call
timeout; content sample as a processing activity.

**Length and reading (observer, veto):** opening provenance cut to one sentence; "Where it came
from" moved after the Terms and written plainly; Terms as a definition list including the terms this
revision added (acting principal, fence, ceiling, harm floor, dev/golden set, veto seats,
deterministic default); P4 shortened; the hosted-loop sentence lives in 3.5; Bounded and Observed
phases swapped; the README's own time estimate is one line pointing to ADAPTING.

**Worked examples:** example 1's backticked `<name>` replaced by prose; blind-labelled golden set;
abridgement declared; example 2 gains a golden set (recorded sessions replayed over recorded tool
results), Iteration loop and Context lines, a correct idempotency key, a dated retirement, principal
binding, a weekly content sample with stated power, a canary against a synthetic customer.

## Accepted limitations, stated in README Provenance and limits
- A real-time surface to a third party cannot pass layers 1 to 5 before the person receives the
  output; the framework does not cover it.
- A product that is itself a coding agent needs its own branch-state and approval rules in LOCAL.md;
  a PR review is an approval step only if the approver did not issue the instruction.
- The rules block is read on every agent task; teams with path-scoped instruction files place it
  under the door and the contracts (ADAPTING section 2).

## Refuted, demoted, or declined (with evidence)
- Engineering finding "tests/run.sh:248 is vacuous" was confirmed; the consolidator's own
  `pgrep -f` test for the SIGTERM path was also vacuous (it matched its own shell) and was fixed with
  the bracket pattern before the script change was credited.
- Frame-inversion R12 proposed a new outcome class `drift`; declined in favour of an alert, to keep
  the nine-class list stable; the canary-vs-fixture comparison was adopted.
- Frame-inversion R18 asked for a third worked example (scheduled artifact); declined for length;
  ADAPTING section 1 now carries a per-shape table of which contract sections each shape keeps, and
  the scheduled shape's fields are tagged.
- Observer's cut to 450 lines: partially taken (provenance duplication, "Where it came from"
  rewritten, 3.11 kept because agent-rules.md is its summary by design, repository layout kept).
  README is 569 lines; the user decides whether to cut further.
- Security SYS-13's suggestion that the drift test assert `wc -w` of the file list in every document
  was replaced by a simpler check that each of the six names appears where the documents enumerate them.
- The domain veto's estimate (five to six hours per known contract) was adopted into ADAPTING.

## What the second panel checked and found sound
All first-panel blockers addressed at the lines given; structured-output residuals, effort defaults,
batch pricing, served-id logging, and effort/cache behaviour verified at two or three vendors;
outcome classes, failure policies, six files, eight rules, four shapes, two-session minimum,
reproduction rule, audit-bias rule consistent across files; the nonce fence, environment allowlist,
pre-flight, anchored verdict, literal roster substitution, backup-not-delete in install.sh, generated
SKILL.md; the agentic example's bounding design; the provenance wording.
