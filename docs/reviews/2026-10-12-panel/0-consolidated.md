# Consolidated panel verdict: LLM Practice Framework

**Artifact:** <checkout> at 4c8d6ce (last edit 2026-09-05)
**Review date:** 2026-10-12
**Roster:** proposed, not confirmed (the repo is the framework, not an adopter; no LOCAL.md exists). Domain pair: LLM Production Engineer ↔ Methodology Skeptic. Veto: Adopter's Time and Credibility Advocate. Plus Security, Systems, Engineering, Experience (adapted to UX Designer ↔ Technical Writer), Observer, Frame-Inversion.
**Sessions:** 4 fresh-context subagents, dispatched in parallel.
  1. Domain + Veto → BLOCKERS (2 blockers, 15 modify, 8 latent) — `1-domain-veto.md`
  2. Security + Systems → MODIFY-BEFORE-BUILD (21 modify, 1 blocker-grade absorbed) — `2-security-systems.md`
  3. Engineering + Experience + Observer → MODIFY-BEFORE-BUILD (0 blockers, 21 modify, 12 nits) — `3-engineering-experience-observer.md`
  4. Frame-Inversion → BLOCKERS (6 blockers, 14 modify, 3 accepted limitations) — `4-frame-inversion.md`

## Consolidated verdict

**BLOCKERS** — 7 blockers (6 confirmed by quote; 1 of the frame-inversion blockers demoted to modify), ~45 modify grouped below, 3 accepted limitations to state in the text.

Reproduction (protocol §6): every blocker is a quoted sentence or a grep-verified absence, so none needed a re-run. Where it matters, two or more independent lenses reached the same finding in one round, which §6 counts as reproduction; the count is given per finding.

## Blockers

| # | Finding | Lenses | Verification |
|---|---|---|---|
| B1 | README:6-7 claims "every rule below paid for itself at least once; the incident-level evidence is in the practices guide named under Provenance". Provenance names no guide; the git log shows at least four rules added in same-day "adoption feedback rounds", not from incidents. | 4/4 | quote + git log |
| B2 | agent-rules.md (the only file adopt.sh writes into every adopter's instructions file) states shape- and scale-specific rules unconditionally: every identifier shown in the prompt (:12-13), keep last good artifact (:27), three-gate panel for everything (:56-60), contradicting ADAPTING §1's Script scale and breaking on chat, codegen, RAG. | domain, frame (S2-f) | quote |
| B3 | The agentic worked example (call-site-contract.md:162-199) teaches P3 violations: money guarded by a prompt sentence ("never promise a refund") plus a keyword audit on "refund"; vocabularies validated "against the database" (existence, not entitlement); ambiguous on whether replies are sent autonomously (:166/:192 vs :195). No checklist or contract field anywhere requires human approval or a reversibility path for irreversible actions (send, pay, delete). | security (SEC-2, SEC-8), frame (F2, F5), domain (M-5) | quote + grep (authoriz/entitle/principal = 0) |
| B4 | README §3.4 layer 4 hard-codes "On a trust surface it is precision-biased: skip when unsure ... a missed one only leaves prose unguarded". For a customer-facing reply, the miss is the incident. agent-rules.md:23-26 states the cost-asymmetry rule correctly, then instantiates it with the source system's asymmetry. | frame (F1); domain (I3) flags the wording drift | quote |
| B5 | ADAPTING §6 instructs "writes each raw model output to a fixtures directory ... Record for a day, curate, commit" and the example commits "40 recorded tickets". Zero mentions of retention, redaction, regulated data, vendor retention/training terms, or residency anywhere. For any system handling personal data this puts PII into git history. | frame (F4), security (SEC-4), domain (L-4) | quote + grep |
| B6 | evaluation.md has a kill criterion for lack of value and no harm floor; the example metric "share of replies not edited by a person before sending" rewards removing the human control; nothing says the control stays after a positive read. | frame (F3) | quote |
| B7 | The contract has no field for acting principal, data scope, personal data, or resources the model can move in aggregate, while README §2 says "A call whose contract has a blank field is not ready", certifying such a contract complete. Security field = "secrets, injection surface, tool allowlist" only; the one pre-filled field is the security claim "Secrets in prompt or logs: none". | frame (F5), security (SEC-1, SEC-5) | quote + grep |

Demoted: frame-inversion F6 ("process rules enforced by instruction; P3 says that is a request") → modify. Reasoning: a methodology cannot mechanically enforce all of its own process; the fix is to say which rules are controls and which are conventions, and to recommend a CI check for the verdict link. Security SYS-12 reached the same point independently, so it stays as a high modify.

## Modify-before-build

### A. Shipped scripts (all VERIFIED by execution in two independent sessions)
- panel-run.sh:23-26 — roster substitution via sed: `&` silently corrupts (exit 0); `|`, `\1`, newline break sed and all four reviewers run on EMPTY prompts, spending budget and printing verdicts (exit 1 the only signal); GNU sed `e` flag gives command execution with a custom prompt file. Fix: bash literal substitution, validate inputs, build input to a file before invoking the model.
- panel-run.sh:41 — verdict grep takes the first verdict word anywhere, so "I found no BLOCKERS ... APPROVE-AS-IS" reports BLOCKERS and the mirror case reports APPROVE-AS-IS; protocol §4's mixed-case tokens never match. Fix: anchored `^(BLOCKERS|MODIFY-BEFORE-BUILD|APPROVE-AS-IS)\s*$`, last match; use uppercase tokens in protocol §4.
- panel-run.sh:28-29 — fence `=== path ===` is forgeable by the artifact; one sentence is the only defence; SKILL.md has no untrusted-content statement at all. Fix: nonce fence; add the sentence to SKILL.md step 3 and protocol §3.
- panel-run.sh — no timeout, no size cap, full environment (secrets) reaches LLM_REVIEW_CMD; missing artifact file still triggers model runs; empty prompts dir yields a literal `*.md` report; no `PANEL_SEATS` (scoping impossible) and no `PANEL_BUILD_STAGE`; `{{EXTRA_PAIR}}` renders as a bare name; never reads LOCAL.md though ADAPTING:160-161 says the panel does.
- adopt.sh:32 — idempotency keyed on bare heading `^## LLM usage rules`: a user's own section of that name blocks installation while reporting success; a `###` heading causes a duplicate; a framework refresh updates docs/llm-framework/agent-rules.md but never the pasted block (silent drift, not mentioned in ADAPTING §7). Refresh without the second argument creates a stray AGENTS.md for editor-agent adopters. Two instructions files present → silent choice. `cd "$1"` without `--`. Fix: sentinel comments + in-place replace; persist the chosen rules path; print notes.
- install.sh:11 — `rm -rf`s a customised personal skill (any dir with SKILL.md) with no backup, exit 0; detaches a symlinked one. Fix: cmp and move to .bak, or require --force.
- Data pair (ML Engineer ↔ Data Engineer) is in the roster and scoping table but has no reviewer prompt and no dispatch slot; the generic path can never convene it. Fix: fold into prompt 1; "domain + data + veto".
- SKILL.md:51-55 is a stale duplicate intro above :57-62; adapters/README promises generation from the protocol but no generator exists. Fix: delete; add make-skill.sh + a diff check in ADAPTING §7.

### B. New knowledge to bake in (2026 practice; vendor docs fetched by reviewer 1, security sources by reviewer 2)
- Model lifecycle: whitelist entries are names, not snapshots; no deprecation/retirement/alias/migration anywhere (grep = 0). Add contract §4 cells (pinned id, retirement date, replacement, migration test), log the vendor-returned model id, inventory-test clause for retirement within 30 days.
- Prompt caching: zero mentions; the recommended prompt order (evidence before schema/examples) is cache-hostile. Add static-first layout, cache breakpoint, cached-read tokens in the log, "cache hit rate" as the second cost lever in P5/§3.6, prompt hash = template hash.
- Structured outputs / constrained decoding: P3 stands; add "enforced at generation: yes/no; residual: refusal, truncation, unenforced constraints"; add `truncated` outcome class and a max_tokens cell.
- Effort: set explicitly (vendor defaults differ per model), re-swept on model change, effort change invalidates the cache.
- Agentic: P4 clause for hosted loops (the door is the agent's resolved configuration: pinned model, tool/MCP allowlist, permission mode, sandbox, turn and budget caps); `run(...)` entry beside `complete(...)`; contract §11 cells for MCP servers, sandbox/egress, actions requiring human approval, idempotency key, server-side vendor tools; tool definitions are external text, pinned by hash; capability ceiling under injection stated; Rule-of-Two check.
- Context engineering: evidence is the smallest high-signal set; decisive evidence at start or end; input tokens logged and capped; compaction summaries / sub-agent reports re-entering context are model output.
- P2 refinement: "Model output may feed another model call only labelled as a claim, never injected as a fact; a sub-agent's output inherits the trust level of the worst input it read." (three lenses: domain O10, security SYS-13, frame F8). In a conversation, prior turns are context, not facts.
- Evaluation: golden set, re-run triggers (prompt/model/effort change), judge discipline (different family, both orders, length-controlled, human agreement first); panel-protocol §8 line acknowledging the panel is a model judge; count adopted vs refuted findings per seat.
- Cost: batch tier for non-interactive work; a designed cascade is a registered route, the bug is an unchosen route; reword README:205.
- Retry policy on the same route (bounded, backoff, Retry-After, inside total timeout, each attempt logged) and idempotency keys for side-effecting calls.
- Hard caps enforced in the door with `cap_hit` outcome class; TTL expiry semantics; streaming residual stated; output rendering/exfiltration bullet (sanitise, URL allowlist, no auto-fetch); URLs/contacts in customer replies vocabulary-closed.
- Observability: session/trace id and parent call id in the log record; served model id; stop reason; OTel GenAI noted as still in Development, not mandated.
- Failure policy vocabulary: add "deterministic default" (the ticket-triage example uses it); "keep last good" conditional on "where an artifact persists"; compensating action for committed tool actions on abort.
- Scope paragraph in README stating the source shape (scheduled, single-tenant, operator-read) and what to add when the consumer is a third party; one veto seat per irreversible resource; content sample read by a person where the consumer is not the operator; "Shape" line in the contract header with `n/a(reason)`.

### C. Self-consistency and text (VERIFIED by quote)
- Validator layers: 6 in §3.4/contract/ladder, 5 in README:106, 4 in ADAPTING:137.
- Files copied: six (adopt.sh, ADAPTING:38-39) vs "five" (ADAPTING:248, 251) vs four (adapters/README:3). Door rules "six" (ADAPTING:114) vs seven rows (LOCAL.template).
- "POSIX shell" (README:28) — all three scripts are bash and die under dash.
- "whitelist" ×4 vs "allowlist" ×13. "five months" (:6) vs "several months" (:343).
- "Four parts" does not match six sections; ladder attributed to §6, is §5.
- Reproduction rule: protocol §6 "verify first, demote if it fails" vs README:249 "re-run and must reproduce" vs agent-rules:59 "re-run until they reproduce" (inverts the demotion rule).
- Minimum panel: 3 sessions (ADAPTING:217) vs 2 (protocol §3 grouping). Verdict casing differs across protocol §4, prompts, README, SKILL header.
- Worked examples violate their own rules: agentic example `TBD(..., by a date)` fails inventory rule 3; neither has a Build stage line (§5.5 says every contract does); "read date set" is not a date; example 1's read date (2026-10-01) has passed.
- Adopted copy references adopt.sh/adapters/LICENSE that are not copied; MIT notice absent from copies.
- Evaluation fields exist in three places (README §2/§3.9, contract §10, evaluation.md) with different sets.
- README:257 "never touch branch state" lists "commit". Subprocess/process-group language in a transport-agnostic core. "arm" undefined in protocol §6.
- README §3.10 omits scoping, so a newcomer reads "15 roles for every change". 17 checklist items are not yes/no or bundle up to five checks. Maturity ladder: bundled L3 cells, cross-row leakage, no Budget row, "level 3 everywhere" contradicts ADAPTING §1 proportionality. "guard" has four senses, "gate" four, "stage" two. Jargon before definition (door, gate, guard, call site, pin, doctrine, inline, frame).
- "If every reviewer approves, re-run" has no terminating condition; propose "re-run once, record a second approve with both push-on lists".
- TBD expiry reds the whole suite on a calendar date and trains date-bumping; propose scoping the check to PRs touching contracts/registry/call sites, with a second approver for moved dates.
- Time estimate: README "an afternoon" vs ADAPTING's day for the door plus two weeks of logging; retrofits cost about a day per call site.

## Escalated to the author (panel cannot decide)
- Should the framework carry its own P7/P8 record: a review log for itself (this panel's reports), and a "framework read date" in LOCAL.md with metrics (contract currency, findings adopted vs refuted, incidents pinned) and per-practice kill criteria?
- Merge P1 and P2 (observer: heavy overlap) and add or drop the security claim the title line makes (no principle covers it; §2 maps Security to P4, whose text says nothing about secrets, injection, or tools)?
- Rename "doctrine"?

## Accepted limitations, to be stated in the text
- The tool allowlist bounds what the model can do, not what it can say; scrubbing is hygiene, not a guard (P3).
- The framework is an engineering practice, not a substitute for a privacy impact assessment, legal review, or safety case.
- Liveness, silence alerts, "as of", and keep-last-good are built for scheduled artifacts; request-response and conversational shapes use a scheduled canary call through the door and never keep-last-good.

## Refuted or corrected findings (recorded with evidence)
- "the user" occurs 22 times (frame S2-k): 10 in the five core files; the rest are in adapters. Point stands, count corrected.
- Frame F6 as BLOCKER: demoted to modify (see above).
- Veto seat's "afternoon estimate" as BLOCKER: majority modify; ADAPTING is honest, README should match.
- Security "install.sh handles a symlinked destination safely (I4)" vs engineering "I7: symlink detached": same behaviour, both true — the target is not deleted, the link is replaced silently.
- Domain I9 "generic runner lacks the Data pair the protocol mandates": confirmed, but the Claude Code adapter also has no dispatch slot for it (engineering E8), so the gap is protocol-wide, not runner-specific.

## What was checked and found sound (so leniency is visible)
Six-layer guard order and validate-and-drop; TBD(reason, by date) with bare/dateless/expired enforcement; build-stage line and validator status column; no live model in tests, failures in fixtures, opt-in smoke; pre-registered read date/control/kill/consumption; separate-context reviewers, frame-inversion lens, "findings are hypotheses"; scale table in ADAPTING §1; tool server holds credentials, process-group kill, typed transport errors, no silent fallback; adopt.sh idempotent in the unmodified case, preserves LOCAL.md, handles spaces; SKILL.md's personal-shadows-project claim verified against the Claude Code docs.
