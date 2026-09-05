# LLM Practice Framework

A project-independent framework for using large language models **sufficiently** (no more and no
less than the job needs), **critically** (never trusting the output), **effectively** (prompts that
work), **efficiently** (cost, time, throughput), and **guardrailed** (isolation, failure handling,
security). It was distilled from five months of production use in one system, where every rule below paid
for itself at least once; the incident-level evidence is in the practices guide named under Provenance.
Nothing here depends on the domain, the model vendor, or the transport.

Four parts:

1. **Eight principles.** The essence. If you remember nothing else, remember these.
2. **The call-site contract.** The unit of design. No model call exists without one
   (`call-site-contract.md`).
3. **Lifecycle checklists.** Decide, design inputs, prompt, guard, route, budget, observe, test,
   evaluate, review, and the developer workflow. Each item is a yes/no question.
4. **Adoption.** How to install it in a project in an afternoon, a pull-request checklist, and a
   maturity ladder to see where a project stands.

Companion files: `panel-protocol.md` (independent review) and `CLAUDE.md.fragment` (rules for an
agent working in the project).

## Repository layout and install

| Path | Purpose |
|---|---|
| `README.md` | This framework |
| `call-site-contract.md` | Template to fill per model call |
| `panel-protocol.md` | The review protocol, tool-agnostic |
| `CLAUDE.md.fragment` | The rules as agent instructions |
| `skills/expert-panel/SKILL.md` | The protocol as a Claude Code skill (same text plus execution steps; edit both together) |
| `install.sh` | Installs the skill for every Claude Code project on this machine (`~/.claude/skills/expert-panel`) |
| `adopt.sh <project>` | Copies the documents into `<project>/docs/llm-framework/` and appends the fragment to its `CLAUDE.md` once |

```
./install.sh              # once per machine
./adopt.sh ~/some-project  # once per project
```

---

## 1. Principles

**P1. Code owns facts; the model owns judgment.** Numbers, dates, identifiers, prices, sizes,
schedules are computed or retrieved by deterministic code and injected into the prompt. The model
copies them; it never computes, recalls, or invents them. Every serious defect in the source corpus was
a fact carried by prose.

**P2. Server retrieves, model judges, code enforces.** Deterministic code decides what evidence exists
and shows it. The model judges only what it is shown and cites what it used. Code validates the
judgment before anything acts on it. Model output never feeds another model call as fact.

**P3. Instructions are requests; guards are controls.** A rule the model "disobeyed" is not fixed by
another sentence in the prompt. It is fixed by a structural guard: schema validation, a closed
vocabulary, a precision-biased audit, a deterministic suppression layer, or by removing the model's
ability to do the thing at all.

**P4. One door.** Every call goes through one client module with an allowlist of registered call
sites. An unregistered caller raises. The transport never falls back silently; the call site decides
how to degrade. Enforced by tests, not by convention.

**P5. Frequency before quality.** The first cost lever is how often you call, not which model. Gate
calls on "did the input change", deduplicate overlapping schedules, tie cadence to the consumer's
decision rhythm. Only then tune model and effort, and only with criteria and a revert plan.

**P6. Every call is observed; every artifact shows its age.** Log each call with its outcome class.
Derive liveness from real calls, never from a heartbeat. Put an "as of" on every model-produced
artifact where a person or a system reads it. A green pipeline can be doing nothing.

**P7. Nothing ships unreviewed.** Designs, specs, and results are reviewed by independent reviewers
in separate contexts, one of them reading the artifact as if it had already failed. The author never
reviews its own work inline. Tests are pinned to the incidents they prevent.

**P8. Nothing stays unevaluated.** Every model feature has a pre-registered read date, a metric, a
control, and a kill criterion. "No measurable value" is a normal outcome. Output nobody consumes is
removed, not maintained.

---

## 2. The call-site contract

Every model call is designed once, as a contract, before it is written. The template is in
`call-site-contract.md`. The fields, and why each exists:

| Field | Question it answers | Principle |
|---|---|---|
| Purpose and consumer | Who reads the output and what decision changes because of it | P8 |
| Trigger | What event runs it, what delta condition gates it, what deduplicates it | P5 |
| Injected facts | Every fact the output may contain, and its source of truth | P1 |
| Closed vocabularies | Every identifier the output may emit, and the set it is validated against | P1, P3 |
| Doctrine | The policy or intent stated in the prompt, so the model does not invent one | P2 |
| Output schema | The structured shape asked for at generation time | P3 |
| Validators, in order | Schema, vocabulary, numeric copy, audit, suppression | P3 |
| Failure policy | Skip loudly, keep last good with a TTL, or abort | P4 |
| Budget | Priority, effort, measured latency, timeout, expected calls per day | P5 |
| Observability | Log fields, staleness surface, alert thresholds | P6 |
| Tests | Recorded fixtures, incident pins, guard tests | P7 |
| Evaluation | Metric, control, read date, kill criterion | P8 |
| Security | Secrets, injection surface, tool allowlist | P4 |
| Review | Gates passed and verdicts | P7 |

A call whose contract has a blank field is not ready. A blank consumer field means the call should not
exist.

---

## 3. Lifecycle checklists

### 3.1 Decide: should this be a model call at all? (sufficiently)

- [ ] A deterministic rule, map, or regex was tried first. If it covers most inputs, ship it and use
      the model only for the remainder.
- [ ] A named consumer exists and a named decision changes because of the output.
- [ ] The trigger is an event or a delta, not a clock. Overlapping schedules are deduplicated.
- [ ] The cadence matches the consumer's rhythm. An advisory read once a day is called once a day.
- [ ] If a small model is proposed for classification: its common failure cases were added to the
      deterministic map, and the model handles only novel inputs.
- [ ] Two tiers where volume is high: a cheap, frequent, narrow call and a rare, expensive, broad one.

### 3.2 Design the inputs (critically)

- [ ] Every fact the output may contain is injected, with its source. The prompt never asks the model
      for a number, a date, or an identifier.
- [ ] Every identifier the output may reference is listed in the prompt. Output is validated against
      the shown set. Unknown identifiers are dropped, never clipped or repaired.
- [ ] If the output must mention an entity, that entity is guaranteed present in the input.
- [ ] Inputs are computed once as a snapshot and the same snapshot is passed to the prompt builder and
      to the guards, so a long call cannot straddle a change.
- [ ] The doctrine is stated: what the call is for, what it is not, whose interests it serves.
- [ ] External text (scraped pages, user content, tool results) is scrubbed of instruction-like
      content, fenced, and labeled as data.
- [ ] Metric names are unambiguous. "Change" means one thing, with its window and unit.

### 3.3 Prompt (effectively)

- [ ] Structure: role, doctrine, evidence, task, output schema, worked examples spanning the distinct
      output classes, and a table of which fields are required under which conditions.
- [ ] Structured output is requested at generation time. Prose is never mined afterwards for facts.
- [ ] The model is required to cite which evidence it used.
- [ ] No quality gate inside the prompt that pushes toward obvious answers (a demanded self-rating,
      a mandatory falsifier). Calibration is measured afterwards, not gated before.
- [ ] Effort or reasoning level is chosen per task and coupled to the timeout.
- [ ] Prompt changes are A/B'd on identical context with both a quantitative and a subjective read.
      The old prompt keeps running first so failure is additive. The prompt-hash baseline is refreshed
      in the same commit.
- [ ] A prompt that hand-injects a frame (loss-averse, urgency, a persona's habits) is recognized as
      framing-sensitive and either de-framed or reviewed under the opposite frame.

### 3.4 Guard the output (critically)

Layers, applied in this order; each catches what the previous cannot:

1. **Schema validation.** Malformed output is a parse failure, logged as such, never partially used.
2. **Closed-vocabulary check.** Every emitted identifier is in the shown set.
3. **Numeric copy check.** Every emitted number equals an injected one. A number that is "close" is
   an invention.
4. **Post-generation audit.** A second deterministic or model pass checks a specific failure mode.
   On a trust surface it is precision-biased: skip when unsure, because a false correction of a
   correct output destroys trust and a missed one only leaves prose unguarded.
5. **Deterministic suppression.** Code decides what may reach the consumer regardless of what the
   model said.
6. **Structural impossibility.** The model has no way to do the forbidden thing: no tool, no field,
   no path.

- [ ] Validate-and-drop, never silent repair.
- [ ] Keep the last good artifact with a TTL. A timeout or parse failure never clobbers it.
- [ ] No model output is a control input without a deterministic check between them.
- [ ] If the model can be asked again with its own prior output in context, the iteration loop is
      tested for drift and ratcheting.

### 3.5 Route (one door, guardrailed)

- [ ] One client module. All call sites import it. A guard test (AST or grep) bans every other
      route. An inventory test lists every registered call site. An unknown call site raises.
- [ ] The subprocess or SDK runs with an environment allowlist, an isolated config directory,
      explicit credential handling, a model whitelist, and a pinned client version.
- [ ] Hard-fail at the transport, degrade at the call site. The three call-site policies are skip
      loudly, keep last good, abort. Silent fallback to a different model or route is a bug.
- [ ] Timeouts are measured (p95 with margin), enforced on the process group, and never orphan a
      credentialed subprocess.
- [ ] Secrets never appear in prompts or logs. Logs carry a hash of the prompt, not the prompt.
- [ ] Agentic calls get an explicit tool allowlist, least privilege, and a tool server that validates
      every write as if it came from an untrusted client.

### 3.6 Budget (efficiently)

- [ ] The budget unit is whatever is scarce: money, a quota window, wall-clock, or a rate limit.
- [ ] Latencies are measured before caps are set. Caps are never guessed.
- [ ] A scheduler owns concurrency and priority: cap, token bucket, slowdown and pause thresholds read
      from live utilization, cancellation-safe slots.
- [ ] Reductions go frequency, then effort, then model, and every trial has criteria and a revert.
- [ ] Cost is routing. Once the transport is fixed, the remaining lever is which calls exist.

### 3.7 Observe

- [ ] Every call logs: timestamp, call site, model, effort, duration, tokens, outcome class (ok,
      parse failure, API error, timeout, refused, rate-limited), prompt hash, output hash.
- [ ] Liveness is derived from real successful calls, never from a heartbeat artifact.
- [ ] Error storms are thresholded on a rolling window, with parse failures and API errors alerting
      separately because they have different owners.
- [ ] Every model-produced artifact shows its age wherever it is read.
- [ ] Output is counted, not only runs. A run that produced nothing is visible.
- [ ] Prompt-hash and output-distribution drift is detected and surfaced.

### 3.8 Test

- [ ] No test calls the live model. Fixtures are recorded from real outputs, including failures.
- [ ] Each regression test's docstring opens with the dated incident it prevents.
- [ ] Architectural rules (one door, no forbidden imports, no secrets in logs) have guard tests.
- [ ] Rendered-artifact tests carry a freshness guard, or they certify whatever is on disk.
- [ ] A live smoke test exists, is opt-in, is off by default, and says that it spends budget.
- [ ] The final gate is the full suite with the real exit code, never a curated subset or a piped
      command's last status.

### 3.9 Evaluate

- [ ] Before shipping: the metric, the control, the read date, and the kill criterion are written
      down where the review will find them.
- [ ] At the read date: the comparison is against the matched control, and "no value" is reported as
      a normal result.
- [ ] Consumption is checked: something reads the output and acts on it. A cosmetic surface (prose
      that feeds nothing) is either wired in or deleted.
- [ ] A feature that missed its kill criterion is removed, and the removal is recorded with the
      reason.

### 3.10 Review

Summarized here; the full protocol is `panel-protocol.md`.

- [ ] Three gates: design before it is presented, spec before the user-review gate, results after
      the build. Every change, no exceptions for "quick" work.
- [ ] Reviewers are separate agents in separate contexts, by role title, scoped to the change.
- [ ] One reviewer always reads the artifact as if it had shipped and failed.
- [ ] Verdicts use one of three classes: blockers, modify-before-build, approve-as-is. Any blocker
      blocks. Modifications are folded in before the user sees the artifact.
- [ ] A load-bearing verdict is re-run and must reproduce.
- [ ] If every reviewer approves and nothing new surfaced, the prompts were too lenient. Re-run.
- [ ] Panel findings are hypotheses. The author re-verifies each one before adopting it.

### 3.11 Developer workflow with agents

- [ ] A subagent's brief is the single source of its requirements and is read-only to the subagent.
- [ ] Subagents never touch branch state. Git is limited to add, commit, status, log, diff.
- [ ] Each task gets a task review for spec compliance and quality; the whole branch gets one final
      review on the most capable model. Plan bugs propagate verbatim; reviewers catch them, not
      confidence in the plan.
- [ ] The live artifact is verified after deploy, and again after the first natural run of the
      producing step, not only after a manual smoke test.
- [ ] A guard is verified on the path the default caller actually takes.
- [ ] Configuration, rules, and credentials are human-only files. Agents hand the command to the
      human and never route around the block.
- [ ] Numbers an agent asserts (dates, prices, schedules, rates) are fetched or computed with a read
      date. A number from memory is a hypothesis.

---

## 4. The learning curve, so you can skip it

Projects that use models tend to move through the same stages. The framework lets a new project start
at stage three.

| Stage | Question the project is answering | What gets built |
|---|---|---|
| 1. Works | Can the model do this at all? | Prompts, a client, prose parsing |
| 2. Cheap | Why is this costing so much? | Frequency cuts, delta gating, model trials |
| 3. Honest | Why did it say something false? | Injected facts, closed vocabularies, guard layers, structured output |
| 4. Observed | Is it even running? | Per-call logging, liveness from real calls, staleness surfaces, error classes |
| 5. Evaluated | Is it worth keeping? | Pre-registered read dates, controls, kill criteria, consumption checks |
| 6. Reviewed | How do we stop shipping the same mistake? | Independent panel at three gates, incident-pinned tests, guard tests |

Stages one and two are where most projects live. The contract (section 2) forces stages three to five
at design time, and the panel protocol adds stage six.

---

## 5. Maturity ladder

Score a project by dimension. Level 3 in every row is the target; level 1 anywhere is a known risk.

| Dimension | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| Routing | Calls scattered, any route | One client, used by convention | One client, enforced by a guard test | Allowlisted call sites, inventory test, drift health check |
| Inputs | Model asked for facts | Facts injected sometimes | All facts injected, doctrine stated | Closed vocabularies, entity presence, snapshot consistency |
| Guards | Prompt instructions only | Schema validation | Vocabulary and numeric copy checks | Precision-biased audit, suppression, structural impossibility |
| Failure handling | Silent fallback | Errors logged | Hard-fail at transport, per-site policy | Keep-last-good with TTL, storms thresholded, timeouts measured |
| Observability | Nothing | Success counter | Per-call log with outcome classes | Liveness from real calls, staleness surfaces, drift detection |
| Testing | Live model in tests | Recorded fixtures | Incident-pinned regressions | Guard tests for architecture, opt-in live smoke |
| Evaluation | Never asked | Anecdotal | Metric and read date | Control, kill criterion, consumption check, removals recorded |
| Review | Author only | Author self-review | Independent reviewers at one gate | Scoped panel at three gates, frame inversion, reproduced verdicts |

---

## 6. Adopting it in a new project

An afternoon, in this order:

1. **Run `adopt.sh <project>`**, which copies these documents in and pastes `CLAUDE.md.fragment` into
   the project's agent instructions so every future session works under the rules.
2. **Build the door.** One package (for example `llm/`) with a transport, a `complete()` entry
   point, a call-site registry, and a call log sink. Write the guard test that bans other routes and
   the inventory test that lists registered sites. Pin the client version.
3. **Write one contract** for the first call site using `call-site-contract.md`. Implement its
   validators before its prompt. Record fixtures from the first real outputs.
4. **Add the surfaces.** Put the call log, outcome classes, and staleness "as of" on whatever admin
   or operations page exists. Derive liveness from the log.
5. **Install the panel.** Run `install.sh` once per machine so the `/expert-panel` skill exists in
   every project; add a project-local `.claude/skills/expert-panel/SKILL.md` with a domain roster when
   the generic pair is not enough (the global skill defers to it).
   Put the three gates into the project's workflow.
6. **Set the first read date.** Metric, control, and kill criterion for the first feature, written
   where the review will find them.

### Pull-request checklist for any change touching a model call

- [ ] Contract updated; no blank fields.
- [ ] New or changed facts are injected, not requested.
- [ ] New identifiers are in a closed vocabulary with a validator.
- [ ] Output schema changed at generation time, not parsed from prose.
- [ ] Failure policy named and tested with a recorded failure fixture.
- [ ] Timeout justified by a measurement.
- [ ] Call log outcome classes cover the new failure modes.
- [ ] Regression test docstring names the incident, or the change is not a fix.
- [ ] Prompt-hash baseline refreshed if the prompt changed; A/B result linked.
- [ ] Panel verdict linked; blockers resolved; modifications folded in.

---

## Provenance

Extracted from the incident-level practices guide kept in a private project's repository at
`docs/llm-practices/README.md` (with source extraction reports under `docs/llm-practices/sources/`),
itself distilled from an earlier private project. The generic wording here deliberately drops the domain;
where a rule seems arbitrary, the guide has the failure that produced it.
