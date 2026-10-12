# LLM Practice Framework

For engineers building software that calls a large language model. A project-independent framework
for using models **sufficiently** (no more and no less than the job needs), **critically** (never
trusting the output), **effectively** (prompts that work), **efficiently** (cost, time, throughput),
and **bounded** (what the model can reach and move is limited by code, not by the prompt). It was
distilled from five months of production use in one system. Most rules trace to a specific incident
or measurement there; the agentic rules, the TBD convention, the audit-bias rule, and the 2026
additions on caching, model lifecycle, and principal scope came from adoption feedback and review,
and are reasoned rather than paid for. The incident record is not public; where a rule seems
arbitrary, treat it as a hypothesis with a stated rationale, and this framework's own review record
is in `docs/reviews/`.

**Where it came from, and what that shaped.** The source was a scheduled, single-tenant
decision-support pipeline whose output was read by its own operator. The principles transfer. The
examples, the loss model (a false fact in prose), and the observability vocabulary (cadence,
staleness, keep-last-good) were shaped by that system and by a command-line transport. If your
consumer is a third party, if the model can read or move another person's data or money, or if every
turn feeds the next, the agentic worked example in `call-site-contract.md` is a floor, not a ceiling:
the principal, data-scope, aggregate-bound, harm-floor, and content-sample fields exist for you, and
you seat one veto per irreversible resource. `ADAPTING.md` section 1 says what to drop for other
shapes.

The framework is independent of the model, the vendor, the coding tool, and the programming
language: the one door, the guard tests, and the log record are specified by behavior, and the
contract is prose. The tool-specific pieces live under `adapters/` and are optional. The helper
scripts are bash (Linux, macOS, WSL, Git Bash); everything they do can be done by hand in a few
minutes, and `ADAPTING.md` says how. Reading this inside a project's `docs/llm-framework/`? The
scripts, the adapters, and the review record are in the upstream repository named in `.adopt` beside
this file.

## Map

| Section | What it is | Read it when |
|---|---|---|
| 1. Principles | Eight sentences. The essence. | Always |
| 2. The call-site contract | The unit of design; no model call exists without one (`call-site-contract.md`) | Before writing any call |
| 3. Lifecycle checklists | Decide, design inputs, prompt, validate, route, budget, observe, test, evaluate, review, agent workflow. Each box is one yes/no question. | While designing and reviewing a call |
| 4. The learning curve | The seven phases projects pass through, so a new one can start at phase three | To place a project |
| 5. Maturity ladder | Score a project per dimension | At a results gate |
| 6. Adopting it | The short form; `ADAPTING.md` is the full guide | When installing |

Companion files: `panel-protocol.md` (independent review), `agent-rules.md` (the rules as
instructions for whatever coding agent works in the project), `evaluation.md` and
`LOCAL.template.md` (templates).

**Terms.** A *call site* is one place in the code that asks the model something; a *call* is one
execution of it. The *door* is the one client module every call site imports; its *transport* file
is the only code that touches the vendor. A *validator* checks the model's output (section 3.4 has
six layers); a *guard test* checks the codebase's structure (one door, no secrets in logs). A *gate*
is one of the three review points; the delta condition that decides whether a call runs is a
trigger, not a gate. The *stated policy* is what the call is for, what it is not, and whose interests
it serves, written in the prompt so the model does not invent one. *Suppression* is code deciding
what reaches the consumer regardless of what the model said. An *incident pin* is a regression test
whose description opens with the dated incident it prevents. *Frame inversion* is reading an
artifact as if it had already shipped and failed. A call's *shape* is one of scheduled artifact,
request-response, conversation, or agentic session. `TBD(reason, by date)` marks a contract field
that cannot be known until the call has run; `n/a(reason)` marks one that does not apply to the shape.

## Repository layout and install

| Path | Purpose |
|---|---|
| `README.md` | This framework |
| `ADAPTING.md` | Step-by-step guide to adopting and tailoring it: scale and shape, one door, first contract, panel, sync |
| `call-site-contract.md` | Template to fill per model call, with two worked examples |
| `evaluation.md` | Template for a feature's pre-registered evaluation |
| `LOCAL.template.md` | Template for the project's own decisions (scale, roster, gates, door audit, backlog, framework read date) |
| `panel-protocol.md` | The review protocol, tool-agnostic |
| `agent-rules.md` | The rules as agent instructions for any instructions file (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, editor rules) |
| `adopt.sh <project> [instructions-file]` | Copies the six documents and the licence into `<project>/docs/llm-framework/` and keeps the rules in the project's instructions file between two markers |
| `adapters/README.md` | What a tool needs to run the framework, and the known tool-specific forms |
| `adapters/generic/` | A runner that executes the panel with any command-line model, plus the reviewer prompts |
| `adapters/claude-code/` | The protocol packaged as a skill, generated from `panel-protocol.md`, with an installer |
| `tests/run.sh` | Tests for the scripts and for drift between these documents |
| `docs/reviews/` | This framework's own panel reports |

```
./adopt.sh ~/some-project            # once per project; writes docs/llm-framework/ and a rules block
                                     # into AGENTS.md / CLAUDE.md / GEMINI.md (it says which)
adapters/claude-code/install.sh      # optional, once per machine, for that tool
```

---

## 1. Principles

**P1. Code owns facts; the model owns judgment.** Numbers, dates, identifiers, prices, sizes,
schedules are computed or retrieved by deterministic code and injected into the prompt, or are
present verbatim in evidence the code chose to show. The model copies them; it never computes,
recalls, or invents them. Code decides what evidence exists and shows it; the model judges only what
it is shown and cites what it used; code validates the judgment before anything acts on it. Model
output feeds another model call only labelled as a claim to be checked, never as a fact, and a
sub-agent's output inherits the trust level of the worst input that sub-agent read.

**P2. Bound what the model can do, not only what it says.** Every call site states what the model
could reach and move if every instruction to it were ignored: which tools, which records, whose data,
how much per action and per period. That ceiling is enforced by the tool server, the sandbox, and the
allowlist, never by the prompt, and every read and write is scoped to the acting principal by code,
not by the model's account of who is asking. An action that cannot be undone passes a human approval
step or a deterministic reversibility design.

**P3. Instructions are requests; guards are controls.** A rule the model "disobeyed" is not fixed by
another sentence in the prompt. It is fixed by a structural validator: schema validation, a closed
vocabulary, an audit whose bias matches the cost of its errors, a deterministic suppression layer,
or by removing the model's ability to do the thing at all.

**P4. One door.** Every call goes through one client module with an allowlist of registered call
sites and pinned model snapshots. An unregistered caller raises. The transport never falls back
silently; the call site decides how to degrade. Enforced by tests, not by convention. For a hosted
agent loop the door is the agent's resolved configuration (pinned model, tool and server allowlist,
permission mode, sandbox, turn and budget caps) in a human-only file, guarded by a test that diffs it.

**P5. Frequency before quality.** The first cost lever is how often you call, not which model. Gate
calls on "did the input change", deduplicate overlapping schedules, tie cadence to the consumer's
decision rhythm. The second lever is cache hit rate, for loops and conversations that resend a
growing prefix. Only then tune effort and model, and only with criteria and a revert plan.

**P6. Every call is observed; every artifact shows its age.** Log each call with its outcome class.
Derive liveness from real calls, never from a heartbeat. Put an "as of" on every model-produced
artifact where a person or a system reads it. Where the consumer is not the operator, a person reads
a sample of the output: the log measures the pipeline, not what it said. A green pipeline can be
doing nothing, or doing harm.

**P7. Nothing ships unreviewed.** Designs, specs, and results are reviewed by independent reviewers
in separate contexts, one of them reading the artifact as if it had already failed. The author never
reviews its own work in the session that wrote it. Tests are pinned to the incidents they prevent.

**P8. Nothing stays unevaluated.** Every model feature has a pre-registered read date, a metric, a
control, a kill criterion, and a harm floor. "No measurable value" is a normal outcome. Output nobody
consumes is removed, not maintained. A positive read is not a licence to remove the control that
produced the measurement.

---

## 2. The call-site contract

Every model call is designed once, as a contract, before it is written. The template is in
`call-site-contract.md`. The fields, and why each exists:

| Field | Question it answers | Principle |
|---|---|---|
| Shape | Scheduled artifact, request-response, conversation, or agentic session; which sections do not apply, with a reason each | all |
| Purpose and consumer | Who reads the output and what decision changes because of it | P8 |
| Trigger | What event, delta, or user turn runs it, and what deduplicates it | P5 |
| Injected facts | Every fact the output may contain, and its source of truth | P1 |
| Closed vocabularies | Every identifier the output may emit, the set it is validated against, and whose scope that set is | P1, P2, P3 |
| Stated policy | What the call is for, what it is not, whose interests it serves | P1 |
| Model and budget | Pinned snapshot and its retirement date, effort, max tokens, measured latency, timeout, tier, caps, resources the model can move and their bounds | P4, P5, P2 |
| Output schema | The structured shape asked for at generation time, whether the API enforces it, and the residual cases | P3 |
| Validators, in order | Schema, vocabulary, numeric copy, audit, suppression, structural | P3 |
| Failure policy | Skip loudly, deterministic default, keep last good with a TTL, or abort; retries; compensation for committed actions | P4 |
| Observability | Log fields, staleness surface, content sample, alert thresholds | P6 |
| Tests | Recorded and redacted fixtures, incident pins, guard tests | P7 |
| Evaluation | Pointer to the evaluation file and its read date | P8 |
| Security and data | Secrets, injection surface and the ceiling under it, acting principal, tools and irreversible actions, personal data and retention | P2 |
| Review | Gates passed and verdicts | P7 |

A call whose contract has a blank field is not ready. A field that cannot be known until the call
has run is `TBD(reason, by date)` and the inventory test lets it through until the date; a field that
does not apply to the shape is `n/a(reason)` and the reason is reviewed at the spec gate; a bare
`n/a` is a blank. A blank consumer field means the call should not exist.

---

## 3. Lifecycle checklists

### 3.1 Decide: should this be a model call at all? (sufficiently)

Where volume is high, two tiers (a cheap, frequent, narrow call and a rare, expensive, broad one) is
the usual shape.

- [ ] A deterministic rule, map, or regex was tried first, and the model handles only the inputs it
      does not cover.
- [ ] A named consumer exists and a named decision changes because of the output.
- [ ] The trigger is an event, a delta, or a user turn, not a clock.
- [ ] Overlapping schedules are deduplicated.
- [ ] The cadence matches the consumer's rhythm.
- [ ] If a small model classifies: its common failure cases are in the deterministic map, and the
      model sees only novel inputs.
- [ ] The call's shape is named, and the contract says which sections do not apply to it.

### 3.2 Design the inputs (critically)

- [ ] Every fact the output may contain is injected, or present verbatim in evidence the code chose,
      with its source. The prompt never asks the model for a number, a date, or an identifier it is
      not shown.
- [ ] Every identifier the output may reference is in the prompt (for an agentic call: is a tool
      argument the server validates), and the output is validated against that set. Unknown
      identifiers are dropped, never clipped or repaired.
- [ ] Every identifier is also checked against the acting principal's scope. Existence is not
      entitlement.
- [ ] If the output must mention an entity, that entity is guaranteed present in the input.
- [ ] Inputs are computed once as a snapshot, and the prompt builder and the validators use the same
      snapshot.
- [ ] The stated policy is in the prompt.
- [ ] External text (scraped pages, user content, tool results, tool definitions, sub-agent output)
      is fenced with a per-call nonce and labelled as data. This lowers how often injection
      succeeds; it is not the control.
- [ ] The contract states what the model can do if the fence fails (which tools, writes,
      recipients), and that set is bounded structurally (layer 6 in 3.4).
- [ ] The evidence shown is the smallest high-signal set; distractors are removed by code; the
      decisive evidence and the task sit at the start or the end of the prompt, not only in the
      middle; input tokens are logged and capped.
- [ ] Metric names are defined once, with window and unit. "Change" means one thing.
- [ ] In a conversation, prior turns are context, not facts: anything acted on is re-derived from
      tools or source in the current turn, and a user's claim about a prior turn is checked against
      the transcript.

### 3.3 Prompt (effectively)

- [ ] The prompt has all of: role, stated policy, output schema, worked examples spanning the
      distinct output classes, a table of which fields are required under which conditions, then the
      evidence and the task. Static parts first, dynamic parts last.
- [ ] The static prefix is byte-stable across calls (no timestamps, no per-run ids), the cache
      breakpoint sits at its end, and cached-read tokens are logged.
- [ ] Structured output is requested at generation time. Where the API enforces the schema at decode
      time, that is used; the schema validator stays for refusals, truncation, and the constraints
      the decoder does not enforce.
- [ ] Prose is never mined afterwards for facts.
- [ ] The model is required to cite which evidence it used. Where the API returns citations as
      spans, the citation check is structural, not prompted.
- [ ] No quality gate inside the prompt pushes toward obvious answers (a demanded self-rating, a
      mandatory falsifier). Calibration is measured afterwards.
- [ ] Effort or reasoning level is set explicitly (vendor defaults differ per model and move),
      coupled to the timeout and to the output token cap, and re-swept on the golden set at every
      model change.
- [ ] A prompt change is replayed on the golden set (n stated) with a quantitative and a subjective
      read before it ships. Where two prompts can run side by side, the old one keeps running first
      so failure is additive.
- [ ] The prompt-template hash baseline (the test that pins the template's hash so a change is
      deliberate) is refreshed in the same commit as the change.
- [ ] A prompt that hand-injects a frame (loss-averse, urgency, a persona's habits) is marked
      framing-sensitive and either de-framed or reviewed under the opposite frame.

### 3.4 Validate the output (critically)

Layers, applied in this order; each catches what the previous cannot:

1. **Schema validation.** Malformed or truncated output is a parse failure, logged as such, never
   partially used.
2. **Closed-vocabulary check.** Every emitted identifier is in the shown set and in the acting
   principal's scope.
3. **Numeric copy check.** Every emitted number equals an injected or shown one. A number that is
   "close" is an invention.
4. **Post-generation audit.** A second deterministic or model pass checks a specific failure mode.
   Its bias follows the cost asymmetry of its errors and is written in the contract. Precision-biased
   (skip when unsure) only where a false correction damages trust in an advisory its reader can
   ignore. Recall-biased (hold when unsure and route to a person) wherever a miss reaches a third
   party, moves money, or discloses personal data. A reply to a customer is always the second kind.
5. **Deterministic suppression.** Code decides what may reach the consumer regardless of what the
   model said.
6. **Structural impossibility.** The model has no way to do the forbidden thing: no tool, no field,
   no path, no record outside the principal's scope.

- [ ] Validate-and-drop; no silent repair.
- [ ] Validators run on the complete output. If output is streamed to a surface a person reads, it
      is buffered, validated, then rendered, or the residual is stated in the contract.
- [ ] Where an artifact persists between runs, the last good one is kept with a TTL, a timeout or
      parse failure never overwrites it, and the contract says what the consumer sees when the TTL
      expires.
- [ ] No model output is a control input without a deterministic check between them.
- [ ] A compaction summary, a sub-agent report, or a persisted note that re-enters the context is
      model output: the facts it carries are re-derived from source or dropped.
- [ ] If the model sees its own prior output, the loop is tested for drift and ratcheting.
- [ ] Model output is rendered as text or through a sanitiser; links and images point only to
      allowlisted hosts; nothing fetches a model-authored URL automatically; URLs and contact details
      in a reply to a person are in a closed vocabulary.

### 3.5 Route (one door, bounded)

- [ ] One client module, and every call site imports it:
      a guard test (a parser or grep over the source tree, with a fixture that makes it fail) bans
      every other route; an inventory test lists every registered call site; an unknown call site
      raises; a second vendor is a second transport behind the same door, never a second door.
- [ ] Model ids in the allowlist are pinned snapshots, never aliases that move. Each carries its
      vendor retirement date, and the inventory test fails 30 days before it. The log records the
      model id the vendor returned; a returned id outside the allowlist alerts.
- [ ] The transport runs with an environment allowlist, credentials handled in one place, and a
      pinned client version. If it is a subprocess, it has its own config directory and a process
      group that is killed on timeout, so no credentialed process is orphaned.
- [ ] Hard-fail at the transport, degrade at the call site. The four call-site policies are skip
      loudly, deterministic default, keep last good with a TTL, abort. Silent fallback to another
      model or route is a bug; a designed cascade (cheap model first, escalate on a deterministic
      condition) is a registered route of its own.
- [ ] Retries are bounded and on the same route: n attempts, backoff with jitter, `Retry-After`
      honoured, inside the call site's total timeout, each attempt a log record. A call that can
      cause a side effect carries an idempotency key, and the tool server rejects a repeat.
- [ ] Timeouts are measured (p95 with margin) and enforced.
- [ ] Secrets never appear in prompts, logs, or fixtures. Logs carry a hash of the prompt template,
      not the prompt.
- [ ] Agentic calls get an explicit tool allowlist; the tool server holds the credentials and
      validates every read and write against the acting principal's scope, never against the model's
      account of who is asking; the model process has a filesystem scope, a network-egress
      allowlist, and no credential of its own.
- [ ] Tool definitions and tool servers are external text: reviewed as such, pinned by version or
      hash in the registry; a changed definition fails the inventory test until re-approved.
- [ ] An action the model can cause that cannot be undone (send to a person outside the system, pay,
      delete, publish, change permissions) passes a human approval step or a deterministic
      reversibility design (draft-not-send, soft delete with a recovery window, hold queue), and the
      contract names which. A prompt instruction or a keyword audit is not one of the options.
- [ ] For a hosted agent loop, the door is the agent's configuration file (pinned model, tool and
      server allowlist, permission mode, sandbox, turn and budget caps), human-only, guarded by a
      test that diffs it.

### 3.6 Budget (efficiently)

The budget unit is whatever is scarce: money, a quota window, wall-clock, or a rate limit. Once the
transport is fixed, the remaining lever is which calls exist.

- [ ] Latencies are measured before caps are set.
- [ ] A scheduler owns concurrency and priority: cap, token bucket, slowdown and pause thresholds
      read from live utilization, cancellation-safe slots.
- [ ] Every call site has a hard cap on calls and spend per day, enforced in the door; every
      agentic session has a cap on turns, tool calls, tokens, and wall clock. Hitting a cap is
      outcome class `cap_hit` and triggers the failure policy.
- [ ] Resources the model can move through tools (money, messages, records) are bounded per action,
      per principal per period, and per day, with an alert at the bound and a reversal path.
- [ ] Reductions go frequency, cache hit rate, effort, model, then batch tier for non-interactive
      work. Every trial has criteria and a revert.
- [ ] Non-interactive work goes to the batch tier where one exists, and the contract names the tier.
- [ ] Effort is changed between workloads, not within a conversation, because a change invalidates
      the cache.

### 3.7 Observe

- [ ] Every call logs: timestamp, call site, session or trace id, parent call id for an agent step,
      requested and served model id, effort, duration, input, output, and cached-read tokens, stop
      reason, outcome class, prompt-template hash, output hash. Outcome classes: `ok`,
      `parse_failure`, `api_error`, `timeout`, `refused`, `rate_limited`, `truncated`, `cap_hit`,
      `cancelled`.
- [ ] Liveness is derived from real successful calls, never from a heartbeat artifact. For
      request-response and conversational shapes, a scheduled canary call through the door with a
      fixed input, counted separately from user traffic, is the real call.
- [ ] Error storms are thresholded on a rolling window; parse failures and API errors alert
      separately because they have different owners.
- [ ] Every model-produced artifact shows its age wherever it is read, and says that a model
      produced it.
- [ ] Output is counted, not only runs. A run that produced nothing is visible.
- [ ] Drift is detected and surfaced: a prompt-template hash that changed without a linked change,
      and an outcome-class or output-field distribution over the last N runs that differs from the
      fixture baseline by more than a stated amount.
- [ ] Where the consumer is not the operator, a person reads a sample of the output every day, and
      every finding has a path: an incident pin, a validator, or the harm-floor count.

### 3.8 Test

- [ ] No test calls the live model. Fixtures are recorded from real outputs, failures included.
- [ ] Fixtures and stored transcripts are redacted or synthesised before commit; nothing personal
      enters the repository; a guard test scans the fixtures directory for secrets and personal-data
      patterns.
- [ ] Fixtures include recorded injection attempts, and the fence and the tool server are tested
      against them.
- [ ] Each regression test's description (docstring, doc comment, or test name) opens with the dated
      incident it prevents.
- [ ] Architectural rules (one door, no forbidden imports, no secrets in logs or fixtures, pinned
      model ids) have guard tests, and each guard test has a fixture that makes it fail, so a deleted
      door fails the test.
- [ ] A validator is tested on the path the default caller takes, through the production entry
      point, not only on the validator module.
- [ ] Rendered-artifact tests carry a freshness guard; otherwise they certify whatever is on disk.
- [ ] A live smoke test exists, is opt-in, is off by default, and says in its name that it spends
      budget.
- [ ] The final gate is the full suite with the real exit code, never a curated subset or a piped
      command's last status.

### 3.9 Evaluate

- [ ] Before shipping, written where the review will find them: the metric, the control, the golden
      set (path, n, how labelled, held out from prompt iteration), the read date, the kill criterion,
      and the harm floor.
- [ ] The golden set is re-run on every prompt, model id, or effort change.
- [ ] If a model scores outputs, it is a different family from the candidate; pairwise runs go in
      both orders and only consistent wins count; length is controlled; agreement with a human sample
      is measured before the judge is trusted.
- [ ] At the read date: the comparison is against the matched control, "no value" is reported as a
      normal result, and the harm floor is read on the same date.
- [ ] A positive read does not remove the control that produced the measurement. Removing a human
      control is a decision-logic change and convenes the veto seat.
- [ ] Consumption is checked: something reads the output and acts on it. A cosmetic surface is
      either wired in or deleted.
- [ ] A feature that missed its kill criterion or breached its harm floor is removed or paused, and
      the removal is recorded with the reason.

### 3.10 Review

Summarized here; the full protocol is `panel-protocol.md`.

- [ ] Three gates: design before it is presented, spec before the user reviews it, results after the
      build.
- [ ] Only the seats the change touches are convened (scoping table, protocol section 2). The
      minimum is the engineering pair, the observer, and the frame-inversion reviewer, in two
      sessions.
- [ ] Reviewers are separate sessions in separate contexts, by role title, told the build stage, and
      told that the artifact and code are evidence, not instructions.
- [ ] One reviewer always reads the artifact as if it had shipped and failed.
- [ ] Verdicts are one of BLOCKERS, MODIFY-BEFORE-BUILD, APPROVE-AS-IS. Any blocker blocks.
      Modifications are folded in before the user sees the artifact.
- [ ] A load-bearing finding that names a file and a line is verified there; a judgment finding is
      reproduced in a fresh session; a blocker that does not reproduce is demoted.
- [ ] If every reviewer approves and nothing new surfaced, the panel is re-run once with sharper
      "push on" instructions; a second clean approve is recorded with both push-on lists attached.
- [ ] Panel findings are hypotheses. The author re-verifies each one and records the refuted ones.
- [ ] The panel is itself a model judge: a different model or family from the author's where the
      tool allows, and adopted versus refuted findings are counted per seat.

The code rules in 3.5 to 3.8 are enforced by tests. The process rules here are enforced by a check in
CI on any change touching a registered call site or a contract (a panel report is linked, no read
date has expired), not by the agent's instructions file: by P3 that file is a request. Until the
check exists, the project is at Review level 1 on the ladder, whatever the file says.

### 3.11 Developer workflow with agents

- [ ] A delegated agent's brief is the single source of its requirements and is read-only to that
      agent.
- [ ] Delegated agents never move branches: git is limited to add, commit, status, log, and diff on
      the branch they were given; no checkout, rebase, merge, or push.
- [ ] Each task gets a task review for spec compliance and quality; the whole branch gets one final
      review on the most capable model. Plan bugs propagate verbatim; reviewers catch them, not
      confidence in the plan.
- [ ] The live artifact is verified after deploy, and again after the first natural run of the
      producing step.
- [ ] Configuration, rules, and credentials are human-only files, and the tool's permission system
      (deny rules, hooks, sandbox) enforces it. The sentence in the instructions file is
      documentation.
- [ ] Numbers an agent asserts (dates, prices, schedules, rates) are fetched or computed with a read
      date. A number from memory is a hypothesis.

---

## 4. The learning curve, so you can skip it

Projects that use models tend to move through the same phases. The framework lets a new project
start at phase three.

| Phase | Question the project is answering | What gets built |
|---|---|---|
| 1. Works | Can the model do this at all? | Prompts, a client, prose parsing |
| 2. Cheap | Why is this costing so much? | Frequency cuts, delta gating, cache layout, model trials |
| 3. Honest | Why did it say something false? | Injected facts, closed vocabularies, validator layers, structured output |
| 4. Bounded | Why did it do an allowed thing to the wrong person, or too often? | Principal scope, action bounds, approval steps, harm floor |
| 5. Observed | Is it even running, and what is it saying? | Per-call logging, liveness from real calls, staleness surfaces, content sample |
| 6. Evaluated | Is it worth keeping? | Pre-registered read dates, controls, kill criteria, consumption checks |
| 7. Reviewed | How do we stop shipping the same mistake? | Independent panel at three gates, incident-pinned tests, guard tests |

Phases one and two are where most projects live. The contract (section 2) forces phases three to
six at design time, and the panel protocol adds phase seven.

---

## 5. Maturity ladder

Score per call site; a row's project level is its lowest call site. A reviewer scores it at the
results gate from the door audit and the contracts, not the author. Level 3 everywhere is the target
at Service scale and above; Script scale (`ADAPTING.md` section 1) targets level 2 in Routing,
Evaluation, and Review. Level 1 anywhere at Service scale is a known risk. A level-3 cell is met only
when all of its items are.

| Dimension | 0 | 1 | 2 | 3 (all of) |
|---|---|---|---|---|
| Routing | Calls scattered, any route | One client, used by convention | One client, enforced by a guard test | Allowlisted call sites; inventory test; pinned model snapshots with retirement dates |
| Inputs | Model asked for facts | Facts injected sometimes | All facts injected, stated policy | Closed vocabularies scoped to the principal; entity presence; snapshot consistency |
| Validators | Prompt instructions only | Schema validation | Vocabulary and numeric copy checks | Audit biased by cost asymmetry; suppression; structural ceiling stated |
| Actions | Model acts unbounded | Tool allowlist | Tool server validates writes against the principal | Bounds per action, principal, and day; approval or reversibility for irreversible actions; sandbox and egress allowlist |
| Failure handling | Silent fallback | Errors logged | Hard-fail at transport, per-site policy named | Bounded retries with idempotency keys; TTL semantics or deterministic default; caps with `cap_hit` |
| Budget | Cost unknown | Cost known | Frequency gated; latency measured; timeouts from p95 | Cache layout and hit rate tracked; scheduler with priority; trials with revert |
| Observability | Nothing | Success counter | Per-call log with outcome classes | Liveness from real calls; staleness surfaces; drift detection; content sample where the consumer is not the operator |
| Testing | Live model in tests | Recorded fixtures | Incident-pinned regressions; redacted fixtures | Guard tests with failing fixtures; adversarial fixtures; opt-in live smoke |
| Evaluation | Never asked | Anecdotal | Metric and read date | Golden set; control; kill criterion and harm floor; consumption check; removals recorded |
| Review | Author only | Author self-review | Independent reviewers at one gate | Scoped panel at three gates; frame inversion; verified or reproduced verdicts; verdict link required by CI |

---

## 6. Adopting it in a new project

The short form. `ADAPTING.md` has the full guide. Budget an afternoon to install and write the first
contract on a green-field project with one call site; a day to build the door and its two tests;
another half day for the first panel gate; and two weeks of production logging before the measured
fields (latency, cadence, alert thresholds) can be filled. A retrofit costs about a day per existing
call site, fixtures included; fund it as a project, not a side task. In this order:

1. **Run `adopt.sh <project>`**, which copies these documents in and puts `agent-rules.md` into the
   project's agent instructions file between two markers, so every future session works under the
   rules and a refresh updates them in place. Fill in `LOCAL.md`: scale, shape, roster.
2. **Build or audit the door** (`ADAPTING.md` section 3; section 3.1 if the project already calls a
   model). One package (for example `llm/`) with a transport, a `complete()` entry point and a
   `run()` entry point for loops, a call-site registry with pinned model snapshots, and a call log
   sink. Write the guard test that bans other routes and the inventory test that lists registered
   sites.
3. **Write one contract** for the call with the highest cost of being wrong, using
   `call-site-contract.md`. Implement its validators before its prompt. Record fixtures from the
   first real outputs and redact them.
4. **Add the surfaces.** Put the call log, outcome classes, and staleness "as of" on whatever admin
   or operations page exists. Derive liveness from the log. Decide who reads the daily content sample.
5. **Install the panel.** Pick the adapter for your tool (`adapters/README.md`), or use the generic
   runner with any command-line model. Adapt the domain pair; seat one veto per irreversible
   resource. Put the three gates into the project's workflow and the verdict-link check into CI.
6. **Set the first read date.** Metric, control, golden set, kill criterion, and harm floor for the
   first feature, written where the review will find them.

### Pull-request checklist for any change touching a model call

- [ ] Contract updated; no blank fields; every `n/a` has a reason.
- [ ] New or changed facts are injected, not requested.
- [ ] New identifiers are in a closed vocabulary with a validator scoped to the principal.
- [ ] Output schema changed at generation time, not parsed from prose.
- [ ] Failure policy named and tested with a recorded failure fixture.
- [ ] Timeout justified by a measurement.
- [ ] Model id is a pinned snapshot with its retirement date recorded.
- [ ] Static prompt prefix unchanged, or the cache-hit drop is noted.
- [ ] Any irreversible action the model can reach has its approval step or reversal path named.
- [ ] Fixtures added are redacted.
- [ ] Call log outcome classes cover the new failure modes.
- [ ] Regression test description names the incident, or the change is not a fix.
- [ ] Prompt-template hash baseline refreshed if the prompt changed; golden-set result linked.
- [ ] Panel report linked; blockers resolved; modifications folded in.

---

## Provenance and limits

Distilled from five months of running model-driven features in a live decision-support system: its
code, its design specs, and the incident record kept alongside them. The generic wording here
deliberately drops the domain and the incidents. The rules added since (agentic calls, the TBD
convention, audit bias by cost asymmetry, and the 2026 additions on model lifecycle, caching,
structured outputs, context, principal scope, harm floors, and data handling) came from adoption
feedback and from this framework's own panel review, whose reports are in `docs/reviews/`; they are
reasoned, and they will be marked paid for when an adopter's incident record says so.

This is an engineering practice. It does not substitute for a privacy impact assessment, legal
review, or a safety case; those enter through the veto seats, and the veto seats cannot be dropped
for a product that reaches a third party. The tool allowlist bounds what the model can do, not what
it can say: injection that steers a reply's content reaches the reader unless the reply is held for
a person or passes a recall-biased check. Scrubbing and fencing are hygiene, not controls (P3).

## License

MIT. See `LICENSE`.
