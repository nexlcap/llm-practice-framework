# Panel report: domain pair + veto seat — LLM Practice Framework

**Artifact:** `<checkout>` (public, MIT, shipped; last edit 2026-09-05; all 14 commits dated 2026-09-05)
**Review date:** 2026-10-12
**Seats:** LLM Production Engineer (practitioner) ↔ Methodology Skeptic (evidence) ; Veto: Adopter's Time and Credibility Advocate
**Build stage:** the artifact is prose plus three bash scripts. Nothing in it is "code under test"; every rule is a claim about practice. The scripts were read and are treated as shipped.
**Read in full:** README.md, call-site-contract.md, ADAPTING.md, agent-rules.md, panel-protocol.md, evaluation.md, LOCAL.template.md, adapters/README.md. Skimmed: adopt.sh, adapters/generic/panel-run.sh, adapters/generic/prompts/*.md, adapters/claude-code/expert-panel/SKILL.md (header), install.sh. Read-only git log.

**Evidence labels used below:** `[VERIFIED: quote]` = text quoted from the repo or a fetched primary source; `[VERIFIED: grep]` = absence/presence confirmed by grep over the repo; `[JUDGMENT]` = the seat's reasoning, not independently checkable.

---

## VERDICT

**BLOCKERS** (2 blockers, 15 modify-before-build, 6 latent/noted)

The two blockers are both one-afternoon edits, but they are the two places where the artifact as published is false or cannot be defended, and this is a public repo whose entire pitch is "every rule paid for itself". Everything else is additive: contract fields and checklist lines, not new principles.

---

## PART 1 — Independent assessments

### 1.1 LLM Production Engineer

**Overall.** This is the best-structured short framework I have seen for the *pipeline* shape of LLM use: a scheduled job that produces an advisory artifact that a person reads. Eight principles, a 12-section contract, a six-layer guard order, a TBD-with-expiry convention enforced by a test, incident-pinned regressions, pre-registered kill criteria. All of it is right for that shape and most of it is right for classification. The problem is that the README's first paragraph claims "Nothing here depends on the domain, the model vendor, or the transport" (README.md:8), and about a third of the concrete rules depend on the *shape*: scheduled, artifact-producing, quota-bound, CLI-subprocess transport.

**What is right and should not be touched.** P3 "Instructions are requests; guards are controls" (README.md:66-69) is now vendor doctrine verbatim: Claude Code's own permissions doc says "Permission rules are enforced by Claude Code, not by the model. Instructions in your prompt or CLAUDE.md shape what Claude tries to do, but they don't change what Claude Code allows." `[VERIFIED: code.claude.com/docs/en/permissions]`. The TBD(reason, by date) convention with the three-way inventory test (ADAPTING.md:84-92) is the most useful single mechanism in the repo. The build-stage line and the validator status column (call-site-contract.md:18, 77-87) are exactly what a retrofit needs. The guard order (schema → vocabulary → numeric copy → audit → suppression → structural) is correct and I have nothing to add to the order itself.

**Over-fitting I would flag to a team adopting this for a chat assistant, an agentic coding tool, or RAG** (HALF A, Q1). Specific sentences and where they break:

| # | Sentence (file:line) | Breaks on | Why |
|---|---|---|---|
| O1 | "The prompt never asks the model for a number, a date, or an identifier." (README.md:135-136) and P1 "it never computes, recalls, or invents them" (README.md:57-60) | Document extraction / RAG / multimodal | The job *is* to pull a number or date out of the shown text or image. The number is not injectable; it is in the evidence. The numeric-copy layer still works if "injected" is read as "present verbatim in the fenced source", but the framework never says so, and layer 3 says "Every emitted number equals an injected one" (README.md:168). `[VERIFIED: quote]` |
| O2 | "Every identifier the output may reference is listed in the prompt." (README.md:137) and agent-rules.md:12-13 "Every identifier the model may emit is shown in the prompt as a closed vocabulary" | Agentic coding, free chat | Codegen creates identifiers. The contract preamble (call-site-contract.md:6-7) and the agentic worked example already relax this to "tool argument schemas", but agent-rules.md states it absolutely, and agent-rules.md is the file adopt.sh pastes into every CLAUDE.md/AGENTS.md. `[VERIFIED: quote; adopt.sh:35]` |
| O3 | "The trigger is an event or a delta, not a clock." (README.md:127); contract Trigger "Delta condition (runs only if)", "Expected cadence: `<n per day>`" (call-site-contract.md:30-32); README.md:108 Budget "expected calls per day" | Interactive chat, agents | The trigger is a user turn; delta gating and dedup keys are meaningless for a user asking the same thing twice; "calls per day" is not the budget unit (per-user rate, per-session token budget are). The agentic example (call-site-contract.md:169) has to fudge the trigger as "a ticket enters the queue". `[VERIFIED: quote]` |
| O4 | "Keep the last good artifact with a TTL. A timeout or parse failure never clobbers it." (README.md:179, stated as a checklist MUST) and agent-rules.md:27 (stated as a rule) | Chat, per-item classification | There is no persisted artifact. The framework's own ticket-triage example uses "any failure → manual queue" (call-site-contract.md:153), which is a *deterministic default*, a fourth failure policy the three-way list (skip loudly / keep last good / abort, README.md:190-191) does not name. `[VERIFIED: quote]` |
| O5 | "Derive liveness from real calls, never from a heartbeat." (README.md:80); ADAPTING.md:236 alert "silence longer than twice the cadence" | User-initiated systems | Silence at 03:00 is normal when there are no users. The rule pages the on-call every night. Liveness for bursty traffic is a synthetic canary *through the door*, which the framework half-forbids ("never from a heartbeat") and half-allows (opt-in live smoke, README.md:224). `[VERIFIED: quote; JUDGMENT on consequence]` |
| O6 | "The subprocess or SDK runs with an environment allowlist, an isolated config directory ... pinned client version" (README.md:188-189); "enforced on the process group, and never orphan a credentialed subprocess" (README.md:192-193) | HTTP SDK users, open-weight/on-device | "Isolated config directory" and "process group" have no referent for an HTTP SDK. For open-weight models the thing to pin is the weights hash and quantization, which is not mentioned. These are tells that the source transport was a CLI subprocess. `[VERIFIED: quote]` |
| O7 | "The old prompt keeps running first so failure is additive." (README.md:157) | Chat, anything user-facing | You cannot run two prompts for one user turn. The alternative (offline replay on a golden set, or traffic split) is not named; "golden" appears nowhere in the repo. `[VERIFIED: grep]` |
| O8 | "A scheduler owns concurrency and priority: cap, token bucket, slowdown and pause thresholds read from live utilization" (README.md:202-203); budget unit "a quota window" (README.md:200) | API-key users | "Live utilization" and "quota window" are subscription-plan concepts. API-key users have per-minute token limits and 429s; a scheduler is reasonable but the wording is source-specific. `[VERIFIED: quote; JUDGMENT]` |
| O9 | `complete(call_site, prompt, schema, effort, timeout)` (ADAPTING.md:70) | Any agent loop | The door's signature cannot carry `tools`, `messages`, or a turn budget. For a hosted agent loop (Claude Code, Agent SDK, vendor-managed agents, MCP servers) the loop and the tool execution happen outside the adopter's code, so "An unregistered caller raises" (README.md:72) has no enforcement point. The door for that shape is the agent *configuration* (model id, tool/MCP allowlist, permission mode, sandbox, max turns), and the framework does not say so. `[VERIFIED: quote; JUDGMENT]` |
| O10 | P2 "Model output never feeds another model call as fact." (README.md:64) | Multi-agent, compaction, LLM-as-judge, note-taking memory | As a slogan it is right; as a rule it has no operational form for the 2026 default where sub-agent summaries, compaction summaries, and persisted notes re-enter the context. Anthropic's own context-engineering guidance recommends exactly these (`[VERIFIED: anthropic.com/engineering/effective-context-engineering-for-ai-agents, 2025-09-29]`). The closest checklist item is the iteration-loop drift test (README.md:181-182). |

**Missing from the contract that I would need before writing the call** (HALF A, Q4). In order of how often it bites:

1. **Pinned model id + retirement date + replacement + migration test.** Contract has `Model: <name> (in whitelist: yes)` (call-site-contract.md:56). Nothing on deprecation anywhere `[VERIFIED: grep "deprecat|retire|alias" = 0 hits]`. See B7.
2. **max_tokens / truncation.** Timeout is there (call-site-contract.md:59); output-token ceiling is not; `truncated` is not an outcome class (README.md:209-210). Both Anthropic and OpenAI name truncation as the residual case where even schema-enforced output is not schema-valid. See B1.
3. **Retry policy on the same route.** The framework bans "Silent fallback to a different model or route" (README.md:191) and the example says "no retry storm" (call-site-contract.md:153), but never says what a *legitimate* retry is (same model, 429/5xx, bounded, logged). Adopters will read the ban as "no retries". `[VERIFIED: grep "retry" = 4 hits, none defining a policy]`
4. **Cache layout and cache-hit logging.** Zero mentions of caching `[VERIFIED: grep "cach" = 0 hits]`. See B2.
5. **Context ceiling and compaction policy.** Zero mentions `[VERIFIED: grep]`. See B5.
6. **Streaming.** If output is streamed to a person, when do the guards run? Zero mentions `[VERIFIED: grep]`.
7. **Idempotency of tool writes** and **which tool actions need human approval before execution.** The agentic example's refund guard is a keyword match on "refund" (call-site-contract.md:184-186) gating an irreversible send. Nothing says "send/pay/delete require approval or a deterministic precondition".
8. **Data classes in the prompt, vendor retention, region, user-facing disclosure.** Zero mentions outside the veto-seat role description `[VERIFIED: grep "PII|personal data|retention|GDPR|AI Act|residency|disclos"]`.
9. **Golden set / judge / re-run triggers** in Evaluation. See B6.
10. **Server-side vendor tools** (web search, code execution) fetch external text the adopter's scrubber never sees; 3.2 (README.md:143-144) assumes all external text passes through code.

**Fields nobody will fill honestly** (Q4b). "Doctrine ... whose interests it serves" gets boilerplate; "Contract last reviewed" rots because no test reads it (the inventory test checks placeholders and TBDs only, ADAPTING.md:84-92); validators row 4 "say what it does *not* catch" will be left as an empty cell, which the `<...>` placeholder check does not catch. Everything else is honest enough, and the TBD mechanism handles the pre-launch unknowns well.

### 1.2 Methodology Skeptic

**Overall.** I have watched frameworks like this die three ways: unadopted (too heavy), cargo-culted (adopted as ritual with the enforcement left out), or rotted (the world moved and the text did not). This one has a real defence against the second (the guard-test-or-it-is-a-suggestion stance, ADAPTING.md:264-265) and a partial defence against the first (the scale table, ADAPTING.md:17-21). It has no defence against the third, and it is already showing rot at thirteen months of age relative to the practices it omits (Part 4). My main concern, though, is that the framework does not meet its own evidentiary standard.

**Does every rule earn its place?** The README says "every rule below paid for itself at least once; the incident-level evidence is in the practices guide named under Provenance" (README.md:6-7). I checked:

- The Provenance section (README.md:341-346) names no guide. It says the wording "deliberately drops the domain and the incidents; where a rule seems arbitrary, assume it was paid for." So the reader is asked to assume what the header says is documented. `[VERIFIED: grep "practices guide|guide named|named under" → only line 7]`
- The git log shows rules added in "Adoption feedback round 1/2/3" (commits 998974d, 1ce8646, 7fe7a1f): the agentic contract note and worked example, the TBD convention, the audit-bias-by-cost-asymmetry rule, the build-stage line. Those are rules added by reasoning in response to feedback, not rules that "paid for themselves" in the five months of production. All three rounds are dated 2026-09-05, the same day as the initial commit. `[VERIFIED: git log --date=short]`
- "five months" (README.md:6) vs "several months" (README.md:343). Trivial, same file.

So the headline claim is (a) unverifiable because the cited evidence does not exist in the repo, and (b) contradicted by the repo's own history for at least four rules. For a framework whose agent rules say "a number from memory is a hypothesis" (agent-rules.md:67), this is the sentence a hostile reader quotes first.

**The framework does not apply P7 and P8 to itself.** P7 "Nothing ships unreviewed" (README.md:83-85): there is no review log, no LOCAL.md, no panel verdict for the framework itself anywhere in the repo. P8 "Nothing stays unevaluated ... Every model feature has a pre-registered read date, a metric, a control, and a kill criterion" (README.md:87-89): the framework has none for itself. Which rules get dropped if adopters do not use them? What is the metric for "the framework helped"? A methodology that demands kill criteria for every feature and has none for itself is the definition of a rule not earning its place. `[VERIFIED: no LOCAL.md, no evaluations/ in repo; JUDGMENT on significance]`

**The panel is an LLM-as-judge and is not treated as one.** panel-protocol.md:3 "Reviewers are separate model sessions". The protocol guards against *context* contamination ("Never use a fork", SKILL.md:30-31) but not against *model-family self-preference*: in the Claude Code adapter the author session and the reviewer sessions are the same vendor. Self-enhancement bias is one of the three named biases in Zheng et al. (NeurIPS 2023, arXiv 2306.05685) `[VERIFIED: abstract]`. The protocol's reproduction logic (panel-protocol.md:119-130, "K=3 convergence", "unanimity") re-samples the *same model with the same prompt*, which is not independent evidence in any statistical sense; correlated errors reproduce. The protocol records refuted findings (panel-protocol.md:111-112) but never says to *count* them per seat and drop or re-prompt a seat whose findings are mostly refuted. That is the P8 discipline applied to the panel, and it is missing. Also "arm" (panel-protocol.md:130) is undefined A/B jargon leaked from the source project.

**Internal inconsistencies** (HALF A, Q2), each verified by quote:

| # | Inconsistency | Where |
|---|---|---|
| I1 | Validator list has 6 layers in README 3.4, the contract, agent-rules and the ladder; 5 in the README §2 field table ("Schema, vocabulary, numeric copy, audit, suppression", README.md:106, omits structural); 4 in ADAPTING §4 step 1 ("Schema, closed-vocabulary check, numeric copy check, suppression rules", ADAPTING.md:137, omits audit and structural). | README.md:106, 164-176; ADAPTING.md:137; call-site-contract.md:77-84 |
| I2 | Failure policies are "skip loudly, keep last good, abort" everywhere, but 3.4 makes keep-last-good a MUST (README.md:179) and agent-rules.md:27 makes it a rule, and the worked example uses a fourth policy (deterministic default). | README.md:179, 190-191; agent-rules.md:27; call-site-contract.md:153 |
| I3 | Audit bias: 3.4 says "On a trust surface it is precision-biased" (README.md:171); agent-rules.md:23-26 and the contract say bias is chosen by cost asymmetry; the ladder says "Precision-biased audit" unconditionally (README.md:298). | README.md:171, 298; agent-rules.md:23-26 |
| I4 | Three gates "for every change, no exceptions for 'quick' work" (README.md:243-244; panel-protocol.md:134) and agent-rules.md:56-60 (unconditional) vs the Script scale which requires only "one separate reviewer session before relying on it" (ADAPTING.md:19). agent-rules.md has no scale conditional and adopt.sh pastes it regardless; ADAPTING.md:23-25 asks the human to write the scale "above the pasted rules" as an override. | agent-rules.md:56-60; ADAPTING.md:19, 23-25; adopt.sh:35 |
| I5 | adopt.sh copies six files (adopt.sh:14; ADAPTING.md:38-39) but ADAPTING §7 says "overwrites the five framework files" (ADAPTING.md:248, 251). | ADAPTING.md:248 |
| I6 | ADAPTING §3.1 "Audit the door against the six rules above" (ADAPTING.md:114); the LOCAL template's door audit has seven rows (LOCAL.template.md:43-49, adds "Log record minimum fields"). | ADAPTING.md:114; LOCAL.template.md:43-49 |
| I7 | "The three helper scripts are POSIX shell" (README.md:28-29). All three use `set -euo pipefail` (pipefail is not POSIX); panel-run.sh uses bash arrays (`pids=()`, `pids+=($!)`, panel-run.sh:32,36). They are bash scripts with `#!/usr/bin/env bash`. | README.md:28; adopt.sh:8; panel-run.sh:13,32,36; install.sh:4 |
| I8 | "whitelist" (README.md:189; ADAPTING.md:96; agent-rules.md:34; call-site-contract.md:56) vs "allowlist" (12 other places). `[VERIFIED: grep count]` | as listed |
| I9 | The Data pair (ML Engineer ↔ Data Engineer) is required for "Decision logic, model prompts, scoring, thresholds" (panel-protocol.md:51) but no generic reviewer prompt contains it (adapters/generic/prompts/ has domain+veto, security+systems, engineering+experience+observer, frame-inversion). The generic runner can never convene a seat the protocol mandates for prompt changes. | panel-protocol.md:51; adapters/generic/prompts/* |
| I10 | panel-run.sh runs every prompt file unconditionally (`for p in "$prompts"/*.md`, panel-run.sh:33); the protocol's scoping table (panel-protocol.md:48-56, "Pure refactor ... only") cannot be honoured by the runner without deleting files. | panel-run.sh:33 |
| I11 | "Cost is routing. Once the transport is fixed, the remaining lever is which calls exist." (README.md:205) uses "routing" to mean "which calls exist"; in 2026 "routing" means model routing/cascades, and 3.1's two-tier item (README.md:131) *is* a cascade while 3.5 bans "fallback to a different model" (README.md:191). The distinction between a designed, registered cascade and an undesigned fallback is never drawn. | README.md:131, 191, 205 |
| I12 | Stage "3" in §4 ("start at stage three", README.md:274) and Level "3" in §5 ("Level 3 in every row is the target", README.md:292) are different scales with the same number. Not a contradiction; a readability trap. | README.md:274, 292 |

**Measurability of the maturity ladder** (HALF A, Q3), row by row:

- **Routing**: L0-L2 scoreable from the source tree (one module? guard test present?). L3 "drift health check" is undefined anywhere operationally; 3.7 says "Prompt-hash and output-distribution drift is detected and surfaced" (README.md:216) but no file says what distribution, what baseline, what test. Not scoreable.
- **Inputs**: L2 "All facts injected" requires knowing the universe of facts in outputs; an outsider can only check for the presence of a numeric-copy validator as a proxy. L3 scoreable from code if you know what to grep.
- **Guards**: scoreable (presence of each layer in code).
- **Failure handling**: L3 bundles "Keep-last-good with TTL" (README.md:299). A perfectly guarded interactive assistant cannot reach L3 in this row because the concept does not apply. `[VERIFIED: quote; JUDGMENT]`
- **Observability**: L3 "drift detection" again undefined. Not scoreable.
- **Testing**: fully scoreable (fixture files, dated docstrings, guard tests, opt-in flag).
- **Evaluation**: scoreable from `evaluations/` files.
- **Review**: scoreable from the review log.
- **Missing scoring rule**: a project with five call sites at mixed levels — is the row scored per project or per call site? Unstated. "level 1 anywhere is a known risk" (README.md:292) suggests per call site but nothing says so.
- **Missing scorer**: P7 forbids self-review, but §5 is presented as self-assessment ("Score a project").

Five of eight rows are scoreable by an outsider; two (Routing L3, Observability L3) are not because "drift" is never operationalised; one (Failure handling L3) is unreachable for a whole shape of use.

### 1.3 Veto seat: Adopter's Time and Credibility Advocate

I own two irreversible resources: the adopting team's hours, and the author's public credibility (public MIT repo; the git history is public with it).

**Is "budget an afternoon" honest?** README.md:19-20: "Budget an afternoon for installation and the first contract, and another half day for the first panel gate". ADAPTING.md:6-8 is more honest: "Budget an afternoon for steps 1 to 5, an hour per model call for step 4, and another half day for the first panel gate: on an existing codebase it will find defects in code the artifact merely describes, and folding those in is part of adoption, not a detour from it." README §6 (README.md:309) repeats "An afternoon, in this order" and the list includes **step 2, "Build the door"**: a package with transport, `complete()`, registry, log sink, guard test, inventory test, pinned client. On a green-field project in a language with an existing SDK that is a day of work for one engineer, not part of an afternoon; on a retrofit (ADAPTING §3.1 says "Most adoptions are not green-field") it is an inventory plus a backlog, and the framework itself says the first gate "will find defects in code the artifact merely describes". Also: the timeout rule says "log durations for a week" (ADAPTING.md:98-99) and the alert tuning says "Tune from the log after two weeks" (ADAPTING.md:236), so the *elapsed* time to a complete contract is at least two weeks regardless of effort. **The README estimate is not honest for anything beyond the Script scale.** ADAPTING is closer; the README should match it or say "an afternoon to install and write the first contract; the door is a day; measured fields take two weeks of production data". `[VERIFIED: quotes; JUDGMENT on the day estimate]`

**What does partial adoption cost? What fails if a team adopts the checklists but not the one door?** ADAPTING.md:264-265 already says it: "Pasting the rules and keeping direct vendor calls elsewhere. A rule without a guard test is a suggestion." Concretely, without the door: the inventory test has nothing to walk, so the TBD-expiry mechanism (the one thing that makes contracts stay honest) never fires; "unknown call sites raise" cannot exist, so new calls appear unregistered and uncontracted; the per-call log has no single write point, so liveness and the outcome classes are per-caller best effort; the model allowlist is a comment. In short: every checklist item in 3.4-3.9 that says "logged", "tested", "measured" degrades to "intended". The framework's own answer is correct. What is *missing* is a statement of what partial adoption buys, because teams will do it anyway: the contract alone, with no door, still forces the consumer/decision question (P8) and the validators-before-prompt order (ADAPTING §4), which are the two highest-value, lowest-cost ideas here. The framework should say so, so that a team that cannot build the door this quarter does not conclude the whole thing is all-or-nothing and drop it. `[JUDGMENT]`

**Indefensible public claims** (each verified by quote):

1. **"every rule below paid for itself at least once; the incident-level evidence is in the practices guide named under Provenance"** (README.md:6-7). No guide is named. The public git log shows at least four rules added in same-day "adoption feedback rounds", not from incidents. This is the sentence that costs credibility, because it is checkable in two minutes and fails. **BLOCKER.**
2. **"The three helper scripts are POSIX shell"** (README.md:28). They are bash. Small, but it is a factual claim about the repo's own files, false, and the kind of thing an engineer notices on first `cat`. **Modify** (it is one word).
3. **"Nothing here depends on the domain, the model vendor, or the transport"** (README.md:8). The transport dependence is visible (O6, O8). Overclaim; soften to "the core is specified by behaviour; the examples and some wording come from a CLI-subprocess, scheduled pipeline".
4. **"Nothing ships unreviewed"** (P7) with no review record for the framework itself. Not false, but a visible gap a reviewer will name.

**Adopter's time at risk from agent-rules.md.** This is the one file that executes on every future session in the adopter's repo (adopt.sh:35 appends it to CLAUDE.md/AGENTS.md/GEMINI.md). It states as unconditional rules: every identifier shown in the prompt (agent-rules.md:12-13), keep the last good artifact (agent-rules.md:27), three-gate panel before the user sees anything (agent-rules.md:56-60). For a chat product, an agentic coding tool, or a Script-scale project, a coding agent following these literally will build the wrong thing or stall every change on a panel the scale table says is optional. The human override ("write the scale above the pasted rules", ADAPTING.md:23-25) depends on the human knowing the rules are shape-specific, which the rules do not say. Because the cost recurs every session and the file is the framework's only executable surface in the adopter's repo, I rate this a **BLOCKER**: add a four-line shape/scale preamble to agent-rules.md and mark the three rules "where an artifact persists / where the model emits ids from a known set / at Service scale and above".

---

## PART 2 — Peer challenges

**Skeptic → Engineer.** You list ten missing contract fields and ten over-fit sentences. Add them all and the contract is twenty sections and the README is 500 lines; the framework's stated value is "staying short" and you have just made it the kind of framework that goes unadopted. Which of your additions have you seen a team actually fill? Also, you accept the guard order "as correct" without asking whether anyone outside the source system has run all six layers; layer 4 (a model-based audit of a model's output) is itself an unevaluated model feature under P8.

**Engineer → Skeptic.** Your "does not apply P7/P8 to itself" point is clever but partly unfair: a document is not a model feature, and the author did ship an evaluation template rather than a metric for the framework. Your "the panel is an LLM-as-judge" point, however, is the sharpest in the room and I had missed it: the Claude Code adapter has the same vendor author and review, and the protocol's reproduction logic is K re-samples of one correlated judge. That is a method finding, not a nitpick. On length: I agree most additions should be contract *cells* and checklist *lines*, not sections; I withdraw the request for a new principle on caching and agents and accept one clarifying clause on P4 and P5 each.

**Veto → both.** You are both grading the framework against an ideal. I grade it against the adopter who has four hours and a public repo they will link to. The Engineer's O1-O10 list matters to the adopter only insofar as agent-rules.md, the one file that runs, encodes the over-fit; fix that file and the README's shape-specific wording becomes a documentation issue. The Skeptic's "paid for itself" finding matters more than either of you weight it: it is the first sentence of the README, it is false as stated, and it is the sentence a sceptical team lead quotes when deciding not to adopt. The afternoon estimate matters because a team that budgets an afternoon and spends a week concludes the framework lied, and never reads ADAPTING, which told the truth.

**Engineer → Veto.** Agreed on agent-rules.md as the lever. But do not undersell the lifecycle gap: a team that adopted this on 2025-09-05 and did exactly what the contract says (`Model: claude-sonnet-4-5 (in whitelist: yes)`) was on an alias that resolved to the 20250929 snapshot, which was deprecated on 2026-09-30 and retires 2026-11-30 `[VERIFIED: platform.claude.com/docs/en/about-claude/model-deprecations]`. The framework gave them no field, no test, and no outcome class for that. That is adopter time too; it just lands in November.

**Skeptic → Veto.** I accept that the credibility finding is a blocker. I dispute that the "afternoon" estimate is a blocker: ADAPTING.md gets it right; the fix is to make the README match. Modify.

---

## PART 3 — Reconciled positions

| Topic | Position | Reasoning |
|---|---|---|
| "every rule paid for itself" + dangling Provenance reference | **Agree: BLOCKER** | Checkable, false as stated, first paragraph of a public README. One-line fix. |
| agent-rules.md unconditional shape-specific rules | **Agree: BLOCKER** | Only executable surface in the adopter's repo; recurs every session; four-line fix. |
| Model lifecycle (pin, retirement, migration test) | **Agree: MODIFY (highest-value)** | Verified vendor timeline shows the gap already bit anyone who adopted at publication. Contract cells + one inventory-test clause. |
| Prompt caching | **Agree: MODIFY** | Zero mentions; the framework's recommended prompt structure (evidence before schema and examples) is cache-hostile; P5 wording stays, 3.3/3.6/3.7 gain lines. |
| Structured outputs / constrained decoding | **Agree: MODIFY** | P3 needs no change; 3.3/3.4 and contract §5 need "enforced at generation: yes/no; residual: refusal, truncation, unenforced constraints". Add `truncated` outcome class. |
| Agentic door / hosted loops / HITL / sandbox | **Agree: MODIFY** | One clause on P4; contract §11 cells; one checklist line. No new principle. |
| Context engineering | **Agree: MODIFY** | 3.2 and 3.4 lines; contract §4 "context ceiling" cell. |
| Evaluation (golden set, judge biases, re-run triggers) | **Agree: MODIFY** | evaluation.md fields + 3.9 lines; panel-protocol §8 one line acknowledging the panel is a model judge. |
| "POSIX shell" | **Agree: MODIFY** | One word. |
| "Afternoon" estimate | **Disagree-with-reasoning (Veto wanted BLOCKER; majority MODIFY)** | ADAPTING.md is honest; make README match it. Resolution recorded as MODIFY. |
| Framework has no evaluation of itself | **Escalate to author** | Panel cannot decide whether a methodology should carry its own read date; author decides. We note that a one-paragraph "how to tell if this framework is helping your project" would answer the Skeptic. |
| Observability standards (OTel GenAI) | **Agree: latent/noted, not modify** | Conventions verified as still in Development (not stable) as of 2026; add trace/session ids to the log record (real gap) but do not mandate OTel. |

---

## PART 4 — Findings

### BLOCKERS

**BL-1. The headline evidentiary claim is unverifiable and partly contradicted by the repo's own history.**
- *What:* "every rule below paid for itself at least once; the incident-level evidence is in the practices guide named under Provenance" (README.md:6-7).
- *Where:* README.md:6-7; README.md:341-346 (Provenance names no guide); git log 998974d, 1ce8646, 7fe7a1f ("Adoption feedback round 1/2/3", all 2026-09-05, adding the TBD convention, the agentic contract note and example, audit bias by cost asymmetry, build-stage line).
- *Why it matters:* It is the first paragraph of a public README, it is checkable in two minutes, and it fails the check. The framework's own agent rule is "a number from memory is a hypothesis" (agent-rules.md:67). `[VERIFIED: quote, grep, git log]`
- *Resolve:* Replace with: "It was distilled from five months of production use in one system. Most rules trace to a specific incident or measurement there; the agentic rules, the TBD convention, and the audit-bias rule were added from adoption feedback and are reasoned, not yet paid for. The incident record is not public; where a rule seems arbitrary, treat it as a hypothesis with a stated rationale." Delete "named under Provenance" or name the guide. Make line 343 say "five months" to match line 6.

**BL-2. agent-rules.md states shape- and scale-specific rules as unconditional, and it is the only file that executes in the adopter's repo.**
- *What:* "Every identifier the model may emit is shown in the prompt as a closed vocabulary" (agent-rules.md:12-13); "Keep the last good artifact with a TTL" (agent-rules.md:27); "Designs, specs, and results go to the expert panel ... before the user sees them" (agent-rules.md:56-60). No scale or shape conditional anywhere in the file.
- *Where:* agent-rules.md:12-13, 27, 56-60; adopt.sh:35 (appends unconditionally); ADAPTING.md:19 (Script scale: panel optional), ADAPTING.md:23-25 (human must write the override above the rules).
- *Why it matters:* A coding agent working in a chat, codegen, or Script-scale project will be instructed every session to do things that are wrong for that shape, or to stall each change on a panel the framework itself calls optional. The cost recurs per session and is invisible to the human who pasted the rules. `[VERIFIED: quote; JUDGMENT on recurrence]`
- *Resolve:* Add a preamble after agent-rules.md:5: "Scale and shape: read `LOCAL.md` first. At Script scale the panel is one separate reviewer session, not three gates. Rules marked (artifact) apply where a model-produced artifact persists between runs; rules marked (ids) apply where the output must reference identifiers from a known set; for agentic calls the tool argument schemas are the schema and the tool list is the vocabulary." Then tag line 12 "(ids)", line 27 "(artifact)", and change line 56 to "At Service scale and above, designs, specs, and results go to the expert panel ...". Have adopt.sh print the scale question once when it creates LOCAL.md (it already prints "fill it in", adopt.sh:15).

### MODIFY-BEFORE-BUILD

**M-1. Model lifecycle: pinning, retirement, migration.** (HALF B, lifecycle)
- *Framework says:* "a model whitelist, and a pinned client version" (README.md:189); contract "Model: `<name>` (in whitelist: yes)" (call-site-contract.md:56). No mention of deprecation, aliases, retirement, or migration testing `[VERIFIED: grep = 0]`.
- *Current practice:* Anthropic: "Anthropic notifies customers ... providing at least 60 days' notice before model retirement"; "Requests to retired models will fail"; pre-4.6 aliases "point to the most recent dated snapshot for that minor version" (i.e. they move); 4.6+ dateless IDs "map to a single, fixed model snapshot"; "serving infrastructure ... can change ... produce minor differences in observable behavior even when the model ID and weights have not changed"; `temperature`/`top_p`/`top_k` return 400 on 4.7+ models. `claude-sonnet-4-5-20250929` deprecated 2026-09-30, retires 2026-11-30. `[VERIFIED: platform.claude.com model-deprecations and model-ids-and-versions pages]`
- *Gap type:* contract field + checklist + inventory-test clause + outcome class.
- *Resolve:* Contract §4 add: "Model id: `<pinned snapshot id, never a moving alias>`; vendor retirement: `<date or 'not sooner than <date>'>`; replacement candidate: `<id>`; migration test: fixtures + golden set re-run, effort re-swept, deprecated parameters removed". ADAPTING §3 inventory test add: "fails 30 days before any registered model's retirement date (reuse the by-date parser)". 3.7 log: record the *served* model id from the response alongside the requested one. 3.5 add: "Model ids in the allowlist are pinned snapshots; a vendor alias that can move is not a pin."

**M-2. Prompt caching is absent, and the recommended prompt layout is cache-hostile.** (HALF B, caching)
- *Framework says:* P5 "The first cost lever is how often you call, not which model" (README.md:75-77); "Reductions go frequency, then effort, then model" (README.md:204); prompt structure "role, doctrine, evidence, task, output schema, worked examples ..." (README.md:149-150), i.e. dynamic evidence *before* static schema and examples; log fields "tokens" (README.md:209). Zero mentions of caching `[VERIFIED: grep]`.
- *Current practice:* "Prompt caching references the entire prompt: tools, system, and messages (in that order)"; "Place static content (tool definitions, system instructions, context, examples) at the beginning of your prompt"; a timestamp before the breakpoint means "no cache hit occurs"; cache reads 0.1x base input (0.025-0.05x on newest models), 5-minute writes 1.25x, 1-hour writes 2x; changing `output_config.effort` or thinking config invalidates the message cache; usage reports `cache_creation_input_tokens` / `cache_read_input_tokens`. `[VERIFIED: platform.claude.com prompt-caching, effort, models/overview]`. Secondary sources agree the same static-first rule holds for OpenAI (automatic caching, ~50% off cached input).
- *Gap type:* principle clause (P5) + checklist (3.3, 3.6, 3.7) + PR checklist line. Not a new principle.
- *Resolve:* P5 append: "For loops and conversations that resend a growing prefix, cache hit rate is the second lever, before effort and model." 3.3 structure item: "Static first (role, doctrine, output schema, worked examples), dynamic last (evidence, task); mark the cache breakpoint at the end of the static prefix; no timestamps or per-run ids in the prefix." 3.6: "Reductions go frequency, cache hit rate, effort, model, and batch tier for non-interactive work." 3.7 log add "cached-read tokens"; alert when hit rate drops after a prompt change. PR checklist: "Prompt change keeps the static prefix byte-stable, or the cache-hit drop is noted." Also clarify that "prompt hash" (README.md:194, 210) hashes the static template, not the rendered prompt, or it changes every call.

**M-3. Structured outputs / constrained decoding, and `truncated` as an outcome class.** (HALF B, structured outputs)
- *Framework says:* "Structured output is requested at generation time" (README.md:151); layer 1 "Schema validation. Malformed output is a parse failure" (README.md:166); contract §5 "Schema (requested at generation time)" (call-site-contract.md:65). Outcome classes: "ok, parse failure, API error, timeout, refused, rate-limited" (README.md:209-210); no truncation class.
- *Current practice:* Anthropic: "Structured outputs guarantee schema-compliant responses through constrained decoding" via `output_config.format` and `tools[].strict`; exceptions: refusals ("the refusal message takes precedence over schema constraints"), max_tokens ("The output may be incomplete and not match your schema"), enum casing not guaranteed; `minimum`/`maximum`/`minLength`/`maxLength`/recursive schemas unsupported (400). OpenAI: "ensures the model will always generate responses that adhere to your supplied JSON Schema", except refusals and "if ... you reach a max tokens limit and the response is incomplete". `[VERIFIED: both vendor docs]`
- *Gap type:* checklist + contract field + outcome class. **P3 does not need updating**: constrained decoding is layer 6 (structural impossibility) applied to format; the schema validator stays because refusal, truncation, and unenforced numeric/string constraints bypass the grammar.
- *Resolve:* 3.3 item: "Where the API enforces the schema at decode time (strict / constrained decoding), use it; the schema validator stays for refusals, truncation, and the constraints the decoder does not enforce." Contract §5 add: "Enforced at generation: yes (strict) / no; residual cases handled: refusal, truncation, `<constraints not enforced>`". Contract §4 add "max_tokens: `<n>` (hard output cap; thinking counts toward it)". Outcome classes add `truncated` everywhere the list appears (README.md:209-210, ADAPTING.md:102-103, agent-rules.md:44-45, contract §6 row 1).

**M-4. Effort as a budget knob: vendor defaults differ per model and the cache interaction is unstated.** (HALF B, effort)
- *Framework says:* "Effort or reasoning level is chosen per task and coupled to the timeout" (README.md:155); contract "Effort / reasoning level: `<level>`" (call-site-contract.md:57). Already better than most frameworks.
- *Current practice:* `output_config.effort` in low/medium/high/xhigh/max; "Effort is a behavioral signal, not a strict token budget"; "Lower effort also means fewer and terser tool calls"; defaults differ by model ("Set effort explicitly"); "Run an effort sweep on your own evals rather than carrying settings over from an earlier model"; changing top-level effort invalidates the prompt cache; `max_tokens` is "the enforced limit"; `budget_tokens` extended thinking "deprecated on Claude Opus 4.6 and Claude Sonnet 4.6 and not accepted on later models"; task budgets (beta) are "a soft hint, not a hard cap" for a whole agentic loop, minimum 20k, and a too-small budget "can cause refusal-like behavior". `[VERIFIED: platform.claude.com effort, task-budgets, models/overview]`
- *Gap type:* contract field + checklist line.
- *Resolve:* Contract §4: "Effort: `<level>`, set explicitly (the vendor default differs by model and moves across releases), re-swept on the golden set at every model change; max_tokens `<n>`; for a loop: turn cap and advisory loop budget `<n>`". 3.3 item append: "... coupled to the timeout and to max_tokens; never left at the vendor default." 3.6 note: "Effort changes invalidate the cache; change it between workloads, not within a conversation."

**M-5. One door for hosted agent loops; tool-level HITL, sandbox, MCP allowlist, idempotency.** (HALF B, agents)
- *Framework says:* P4 "Every call goes through one client module ... An unregistered caller raises" (README.md:71-73); door shape `complete(call_site, prompt, schema, effort, timeout)` (ADAPTING.md:70); "Agentic calls get an explicit tool allowlist, least privilege, and a tool server that validates every write" (README.md:195-196); contract §11 "Tools available to the model: `<none | allowlist>`; Writes the model can cause: `<none | via tool server, validated by <function>>`" (call-site-contract.md:124-125). The agentic example gates an irreversible customer-facing send on a keyword match for "refund" (call-site-contract.md:184-186).
- *Current practice:* Claude Code permission modes `default | acceptEdits | plan | auto | dontAsk | bypassPermissions`; allow/deny/ask rules; MCP allow globs must name a server (`mcp__<server>__*`), `mcp__*` deny removes all MCP tools; "bypassPermissions ... Only use this mode in isolated environments like containers or VMs"; Bash rules are "not a security boundary around the program ... use sandboxing" for enforcement independent of command text. `[VERIFIED: code.claude.com/docs/en/permissions]`. Google MCP security guidance: human-in-the-loop mode where "a human user must approve each action before the agent completes the action"; least-privilege agent identity. OWASP Top 10 for LLM Applications 2025 lists LLM01 Prompt Injection, LLM05 Improper Output Handling, LLM06 Excessive Agency, LLM10 Unbounded Consumption; OWASP Top 10 for Agentic Applications 2026 published 2025-12-09 (ASI01-ASI10). `[VERIFIED: search results; OWASP pages located, category text from secondary summaries]`
- *Gap type:* one clause on P4; contract §11 cells; one checklist line in 3.5. No new principle.
- *Resolve:* P4 append: "For a hosted agent loop the door is the agent's resolved configuration (pinned model id, tool and MCP-server allowlist, permission mode, sandbox, turn and budget caps) in a human-only file, guarded by a test that diffs it." ADAPTING §3 door shape add a `run(call_site, messages, tools, effort, timeout, turn_cap)` entry for loops. Contract §11 add: "MCP servers mounted: `<name@version | none>`; permission mode / sandbox: `<mode; filesystem and network allowlist>`; actions requiring human approval before execution: `<send, pay, delete, ...>`; irreversible writes are idempotent: key = `<...>`; server-side vendor tools (web search, code execution): `<off | listed>`, their results are external text the scrubber cannot reach". 3.5 add: "Irreversible tool actions have a deterministic precondition or a human approval step, never only a prompt instruction or a keyword audit." Fix the worked example accordingly (the "refund" keyword audit becomes "reply tool refuses `send` while `refund_mentioned && !escalation_filed`, evaluated on the structured reply, not on prose").

**M-6. Context engineering: ceiling, placement, compaction as model output.** (HALF B, context)
- *Framework says:* nothing on context length, compaction, or position `[VERIFIED: grep "context window|compaction|lost in the middle|truncat" = 0]`. Closest: snapshot consistency (README.md:140-141) and the iteration-loop drift test (README.md:181-182).
- *Current practice:* Chroma "Context Rot" (2025-07-14): 18 models; "model performance varies significantly as input length changes, even on simple tasks"; "Even a single distractor reduces performance relative to the baseline". Liu et al., "Lost in the Middle" (TACL 2023, arXiv 2307.03172): U-shaped accuracy by position of the relevant document. Anthropic (2025-09-29): "the smallest possible set of high-signal tokens"; compaction; tool-result clearing as "one of the safest lightest touch forms of compaction"; sub-agents return "a condensed, distilled summary"; just-in-time retrieval; server-side compaction exists on the API. `[VERIFIED: fetched]`
- *Gap type:* checklist (3.2, 3.4) + contract §4 cell.
- *Resolve:* 3.2 add: "The evidence shown is the smallest high-signal set; distractors are removed by code (retrieval precision is a guard, not a prompt problem); the decisive evidence and the task sit at the start or the end, never only in the middle; input tokens are logged and capped." 3.4 add: "A compaction summary, a sub-agent report, or a persisted note that re-enters the context is model output: the facts it carries are re-derived from source or dropped, and the loop has a drift fixture." Contract §4: "Context ceiling: `<tokens>`; what is dropped or compacted first: `<...>`; compaction tested by `<fixture>`".

**M-7. Evaluation: golden set, judge biases, re-run triggers.** (HALF B, evaluation)
- *Framework says:* evaluation.md has primary/secondary metric, control, read date, kill, consumption; 3.3 "Prompt changes are A/B'd on identical context with both a quantitative and a subjective read" (README.md:156); layer 4 allows "a second deterministic or model pass" (README.md:170). No golden set, no judge discipline, no re-run trigger on model change `[VERIFIED: grep "golden|judge|pairwise|human label" = 0 relevant hits]`.
- *Current practice:* Zheng et al. 2023 (NeurIPS) name position, verbosity, and self-enhancement bias; arXiv 2406.07791 finds strong judges still show position bias; standard mitigations are order-swapping with consistent-win counting, a different model family for judge and candidate, and calibration against a human sample. Anthropic's effort docs tell adopters to re-sweep on their own evals at every model change. `[VERIFIED: abstracts, vendor docs]`
- *Gap type:* evaluation.md fields + 3.9 lines + one panel-protocol §8 line.
- *Resolve:* evaluation.md add: "**Golden set.** `<path, n, how labeled, held out from prompt iteration, refresh cadence>`. **Re-run on:** prompt change, model id change, effort change. **Judge (if a model scores outputs).** different family from the candidate; pairwise runs in both orders and only consistent wins count; length controlled; agreement with a human sample of `<n>` measured before the judge is trusted." 3.9 add the same as one checklist line. 3.3 item 6: replace "A/B'd on identical context" with "replayed on the golden set (n stated), plus a subjective read". panel-protocol §8 add: "The panel is itself a model judge: prefer a different model or family from the author's where the tool allows; count adopted vs refuted findings per seat across gates and re-prompt or drop a seat whose findings are mostly refuted."

**M-8. Batch tier and designed cascades vs forbidden fallback.** (HALF B, cost)
- *Framework says:* "Two tiers where volume is high" (README.md:131); "Silent fallback to a different model or route is a bug" (README.md:191); "Cost is routing. Once the transport is fixed, the remaining lever is which calls exist." (README.md:205). No mention of batch APIs `[VERIFIED: grep "batch" = 0]`.
- *Current practice:* Message Batches API: "reducing costs by 50%"; "most batches finishing in less than 1 hour"; results within 24 hours or requests expire; up to 100,000 requests or 256 MB per batch; pair with the 1-hour cache for shared context. Routing/cascade literature (FrugalGPT, RouteLLM, 2026 survey arXiv 2603.04445) treats cheap-first-then-escalate as a designed route. `[VERIFIED: platform.claude.com batch-processing; search results]`. The framework's source shape (a daily advisory) is exactly what batch suits.
- *Gap type:* checklist + contract cell + one reworded sentence.
- *Resolve:* 3.6 add: "Non-interactive work goes to the batch tier (about half price, results within a day); the contract names the tier." Contract §4: "Tier: interactive | batch". README.md:205 reword: "Cost is which calls exist. Once frequency, cache, effort, and tier are fixed, the remaining lever is removing calls." 3.5 add after the fallback ban: "A cascade (cheap model first, escalate on a deterministic or scored condition) is a designed route, registered as its own call site and logged as such; the bug is a route the call site did not choose."

**M-9. Legitimate retry policy is undefined.**
- *What:* The ban on fallback (README.md:191) and "no retry storm" (call-site-contract.md:153) with no definition of an allowed retry. `[VERIFIED: grep "retry"]`
- *Resolve:* Contract §7 add: "Retry: `<none | n attempts, backoff, on which outcome classes (rate_limited, api_error 5xx), same model and route, each attempt logged>`". 3.5: "Bounded retries on the same route for transient errors are a failure policy, not a fallback; they are logged per attempt."

**M-10. Failure-policy vocabulary is incomplete and misapplied.** (I2)
- *Resolve:* Everywhere the three policies appear (README.md:107, 190-191; agent-rules.md:32-33; ADAPTING.md:94; call-site-contract.md:93): "skip loudly, deterministic default, keep last good with a TTL, abort". README.md:179 and agent-rules.md:27: prefix "Where an artifact persists between runs, ...".

**M-11. Validator-list drift.** (I1) README.md:106 add "structural"; ADAPTING.md:137 "Schema, closed-vocabulary check, numeric copy check, audit, suppression rules, and what the model structurally cannot do."

**M-12. Audit bias wording drift.** (I3) README.md:171 and ladder README.md:298: "audit biased by cost asymmetry (precision-biased on a trust surface)".

**M-13. Generic runner cannot honour the protocol.** (I9, I10) Add `adapters/generic/prompts/5-data-pair.md` (ML Engineer ↔ Data Engineer, push on: label/deployment mismatch, pipeline trustworthiness, feature leakage) and a `PANEL_SEATS` env var (comma-separated prompt names) in panel-run.sh so a refactor runs three prompts, not all.

**M-14. Public inaccuracies in the README.** (I7, I5, I6, I8, overclaim) README.md:28 "POSIX shell" → "bash". ADAPTING.md:248/251 "five" → "six". ADAPTING.md:114 "six rules" → "seven rows" or drop the log row from the template. "whitelist" → "allowlist" in four places. README.md:8 and 25: soften "Nothing here depends on ... the transport" to "the core is specified by behaviour; wording and examples come from a scheduled pipeline over a CLI transport, and ADAPTING §1 says what to drop for other shapes."

**M-15. "Afternoon" estimate in README does not match ADAPTING.**
- *What:* README.md:19-20 and 309 vs ADAPTING.md:6-8, 98-99, 236.
- *Resolve:* README.md:19-20: "Budget an afternoon to install and write the first contract; a day to build the door and its two tests; another half day for the first panel gate; and two weeks of production logging before the measured fields (latency, cadence, alert thresholds) can be filled."

### LATENT / NOTED (not blocking, recorded for the author)

**L-1. Maturity ladder scoring rule and scorer.** Add under README §5: "Score per call site; a row's project level is its lowest call site. Scored by a reviewer at the results gate from the door audit and the contracts, not by the author." Define "drift health check" / "drift detection" (README.md:216, 296, 300) or remove from L3: minimally "prompt-template hash changed without a PR link; output class distribution over the last N runs differs from the fixture baseline by more than X".

**L-2. Failure-handling L3 unreachable for interactive shapes.** README.md:299: replace "Keep-last-good with TTL" by "Named per-site degradation (default, last-good with TTL, or abort)".

**L-3. Observability: trace/session ids and OTel mapping.** The agentic example has "one call record per session; one event row per tool call" (call-site-contract.md:191-192) with no join key named. Add to the log record (README.md:209-210; ADAPTING.md:101-103): "session/trace id; parent call id for an agent step; stop reason; cached-read tokens; served model id". Note the OpenTelemetry GenAI semantic conventions as the export mapping *when they stabilise*: they moved to their own repository in June 2026 and are marked Development with no release as of the fetch `[VERIFIED: opentelemetry.io redirect notice; repo page shows no releases; status from secondary sources (TrueFoundry 2026-08, Greptime 2026-05)]`. Do not mandate them.

**L-4. Data protection and disclosure.** Contract §11 add: "Data classes in the prompt: `<none | PII | ...>`; vendor retention / ZDR: `<...>`; region: `<...>`; user-facing disclosure that a model produced the artifact: `<where>` (the 'as of' label is the natural place)". Context: EU AI Act GPAI obligations applied from 2025-08-02; Article 50 transparency obligations are scheduled for 2026-08-02; high-risk deployer dates may be deferred by the Digital Omnibus (provisional, not confirmed) `[VERIFIED: secondary sources only; dates conflict; flagged as unconfirmed]`. Even without the regulation, an EU team asks this on day one.

**L-5. Streaming.** 3.4 add: "If output is streamed to a person, the guards run before the first token is shown or the surface can retract; otherwise the output is buffered."

**L-6. Citations as a structural control for RAG.** 3.3 "The model is required to cite which evidence it used" (README.md:152) can now be API-enforced for document inputs (Anthropic Citations, GA; search-result content blocks for RAG) `[VERIFIED: launch post located; details from secondary sources]`. One clause: "where the API returns citations as spans, the citation check is structural, not prompted".

**L-7. Adversarial fixtures.** 3.8 add: "Fixtures include recorded injection attempts; the scrubber and the tool server are tested against them."

**L-8. "arm" in panel-protocol.md:130** is undefined; replace with "run".

---

## PART 5 — HALF B summary table

| Area | Framework today (file:line) | Current practice (source) | Gap type | Resolution |
|---|---|---|---|---|
| Structured outputs | "requested at generation time" README.md:151; layer 1 README.md:166 | Constrained decoding guarantees schema except refusal/truncation/unenforced constraints (Anthropic, OpenAI docs) | checklist + contract + outcome class | M-3 |
| Prompt caching | absent (grep) | static-first, breakpoint at end of prefix, 0.1x reads, effort change invalidates (Anthropic docs) | P5 clause + checklist + log field | M-2 |
| Effort / thinking | README.md:155; contract :57 | levels low..max; behavioral not a cap; defaults differ; re-sweep per model; task budgets advisory (Anthropic docs) | contract + checklist | M-4 |
| Agentic / MCP / HITL / sandbox | README.md:71-73, 195-196; contract §11; ADAPTING.md:70 | permission modes, MCP allow globs per server, sandbox for enforcement, HITL for irreversible actions, OWASP LLM 2025 and Agentic 2026 | P4 clause + contract + checklist | M-5 |
| Context engineering | absent (grep) | context rot (Chroma 2025), lost-in-the-middle (Liu 2023), compaction/tool-result clearing (Anthropic 2025) | checklist + contract cell | M-6 |
| Evaluation | evaluation.md; README.md:156 | judge biases (Zheng 2023; 2406.07791), golden sets, re-sweep on model change (vendor docs) | template fields + checklist + panel line | M-7 |
| Model lifecycle | README.md:189; contract :56 | 60-day notice, retired models fail, aliases move pre-4.6, pinned dateless ids 4.6+, param deprecations (Anthropic docs) | contract + inventory test + log field | M-1 |
| Observability | README.md:209-210 | OTel GenAI conventions in Development, no release (repo) | log fields now; mapping later | L-3 |
| Cost: batch / cascades | README.md:131, 191, 205 | batch 50% off, <1 h typical, 24 h expiry; cascades as designed routes (Anthropic docs; 2026 survey) | checklist + contract cell + reword | M-8 |
| Other: retry, streaming, data protection, citations, adversarial fixtures | absent (grep) | standard production practice; EU AI Act dates (unconfirmed) | contract + checklist | M-9, L-4, L-5, L-6, L-7 |

---

## PART 6 — What was checked and found sound (so a lenient read is visible)

- The six-layer guard order and the validate-and-drop stance: correct, consistent across four of five files, and now echoed by vendor permission docs.
- The TBD(reason, by date) convention with bare/dateless/expired enforcement: the best mechanism in the repo; nothing to add.
- Build-stage line and validator status column: exactly right for retrofits.
- "No test calls the live model; fixtures include failures; opt-in smoke that says it spends budget": sound and shape-independent.
- Pre-registered read date, control, kill criterion, consumption check: sound; only the golden-set and judge discipline are missing.
- Panel: the separate-context requirement, the frame-inversion lens, the "if everyone approves the prompts were too lenient" rule, and "findings are hypotheses" are all sound; the self-preference and seat-precision points are additions, not corrections.
- Scale table in ADAPTING §1: sound; the defect is that agent-rules.md does not read it.
- adopt.sh: idempotent, detects the instructions file, never touches LOCAL.md: as described. install.sh refuses to clobber a non-skill directory: good.
- No secrets, no vendor lock-in in the core files; adapters are genuinely optional.

---

## Sources (fetched or searched 2026-10-12)

Primary (fetched):
- https://platform.claude.com/docs/en/build-with-claude/structured-outputs
- https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- https://platform.claude.com/docs/en/build-with-claude/effort
- https://platform.claude.com/docs/en/build-with-claude/task-budgets
- https://platform.claude.com/docs/en/build-with-claude/batch-processing
- https://platform.claude.com/docs/en/about-claude/models/overview
- https://platform.claude.com/docs/en/about-claude/models/model-ids-and-versions
- https://platform.claude.com/docs/en/about-claude/model-deprecations
- https://code.claude.com/docs/en/permissions
- https://developers.openai.com/api/docs/guides/structured-outputs
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents (2025-09-29)
- https://www.trychroma.com/research/context-rot (2025-07-14)
- https://opentelemetry.io/docs/specs/semconv/gen-ai/ (moved notice) and https://github.com/open-telemetry/semantic-conventions-genai (no releases shown)

Searched (secondary; used only where marked):
- Zheng et al., "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena", arXiv 2306.05685 (NeurIPS 2023); "Judging the Judges" arXiv 2406.07791
- Liu et al., "Lost in the Middle", arXiv 2307.03172 (TACL 2023)
- OWASP Top 10 for LLM Applications 2025; OWASP Top 10 for Agentic Applications 2026 (genai.owasp.org, published 2025-12-09)
- Google Cloud MCP "AI security and safety" (HITL mode, least privilege)
- "Dynamic Model Routing and Cascading for Efficient LLM Inference: A Survey", arXiv 2603.04445
- TrueFoundry (2026-08) and Greptime (2026-05) on OTel GenAI status (Development)
- EU AI Act timelines: artificialintelligenceact.eu and consultancy summaries (dates conflict; treated as unconfirmed)
