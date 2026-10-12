# Adapting the framework to your project

This is the step-by-step guide. `README.md` says what the framework is; this file says how to make
it yours: which parts apply at your scale and shape, how to install the documents, how to build the
one door in your language, how to tailor the panel to your domain and your tool, and how to keep the
copy current. Budget an afternoon for steps 1 to 5 on a green-field project with one call site, an
hour per further call site for step 4, a day for the door and its tests, and another half day for
the first panel gate. A retrofit costs about a day per existing call site including fixtures, plus
the first gate, which on an existing codebase will find defects in code the artifact merely
describes; folding those in is part of adoption, not a detour from it. Fund a retrofit as a project,
not a side task. Fields that need production data (latency, cadence, alert thresholds) take two weeks
of logging to fill, however fast the rest goes.

---

## 1. Decide the scale and the shape first

The framework is proportionate by design. Pick the row that describes the project and adopt that
column; grow into the next row when the project does.

| Scale | What it looks like | Mandatory | Optional until it hurts |
|---|---|---|---|
| **Script** | One or two model calls, one person, output read by that person | Injected facts, structured output with schema validation, one function that makes the call, a log line per call, one recorded and redacted fixture, one separate reviewer session before relying on it | Registry, throttle, evaluation file, full panel |
| **Service** | Calls in production, other code or people depend on the output | Everything in the core: contract per call, one door with guard and inventory tests, validator layers, failure policy, per-call log with outcome classes, staleness surfaces, incident-pinned tests, pinned model snapshots, evaluation with a read date and a harm floor, panel at the three gates | Throttle with live utilization, drift detection |
| **Agentic product** | The model can act: call tools, write data, message people | Everything above, plus tool allowlists, a tool server that scopes every read and write to the acting principal, a sandbox with an egress allowlist, hard caps, a human approval step or reversibility design for every irreversible action, a nonce fence on all external text, redacted transcripts with a retention, a daily content sample, one veto seat per irreversible resource, and the security and systems pairs at every gate | Nothing; all of it applies |

Then name the shape of each call: scheduled artifact, request-response, conversation, or agentic
session. The vocabulary of cadence, delta gating, keep-last-good, and liveness-from-cadence comes
from the scheduled shape; for the other three, the contract marks those fields `n/a(reason)`, the
trigger is a request or a user turn, the budget unit is per user or per session, and liveness is a
scheduled canary call through the door. For a conversation, add the rule that prior turns are
context, not facts.

Write the chosen scale and shapes in `docs/llm-framework/LOCAL.md` (not inside the framework files,
which refreshes overwrite). Reviewers will hold you to them.

---

## 2. Install the documents

From the framework checkout:

```
./adopt.sh /path/to/project                        # detects AGENTS.md, CLAUDE.md, GEMINI.md
./adopt.sh /path/to/project .cursor/rules/llm.md   # or name the instructions file yourself
```

This copies `README.md`, `ADAPTING.md`, `call-site-contract.md`, `evaluation.md`,
`panel-protocol.md`, and `agent-rules.md` (the six framework files) and `LICENSE` into
`docs/llm-framework/`, creates `LOCAL.md` from a template if it does not exist, creates `contracts/`
and `evaluations/`, records the chosen instructions file and the framework version in
`docs/llm-framework/.adopt`, and puts `agent-rules.md` into the instructions file between two marker
comments. If no instructions file exists it infers the tool from its config directory and says
which file it chose; check that your tool actually reads that file. If several candidate files
exist it uses the first and names the others; a team whose tools read different files runs the
script once per file. Re-running is safe: it refreshes the six files and the marked block in place
and never touches `LOCAL.md`, `contracts/`, or `evaluations/`.

Without the script: copy the same files and paste `agent-rules.md` into whatever your coding agent
reads. If your team uses no coding agent, paste it into `CONTRIBUTING.md` and add the pull-request
checklist from `README.md` section 6 to the PR template. The rules are for people as much as for
agents.

The script creates:

```
docs/llm-framework/LOCAL.md       # scale, shapes, roster, scoping table, gates, door audit, backlog, review log
docs/llm-framework/.adopt         # instructions file, source repository, framework commit
docs/llm-framework/contracts/     # one call-site contract per model call
docs/llm-framework/evaluations/   # one pre-registration per model feature (copy evaluation.md)
```

If the project already has a door module, do the door audit in `LOCAL.md` before writing any
contract: one row per rule in section 3, met or not met and how. The gaps become the first backlog.

---

## 3. Build the one door

One module owns every model call. Its shape is the same in any language:

```
llm/
  transport     talks to the vendor (HTTP, SDK, or a command-line client); the ONLY file that
                imports the vendor library or names its endpoint; one transport per vendor, all
                behind the same door
  complete()    the entry point for one call: complete(call_site, prompt, schema, effort, timeout)
  run()         the entry point for a loop: run(call_site, messages, tools, effort, timeout, caps)
  registry      the allowlist: call-site id -> owner, contract path, pinned model snapshot and its
                retirement date, default effort, timeout, daily cap, tool allowlist with pinned
                tool-definition hashes
  log           writes one record per call, success or failure, before returning
  throttle      (service scale and up) priority, concurrency cap, pause on limit errors
```

Rules to enforce on day one, each with a test. The door audit in `LOCAL.md` has one row per rule:

1. **Only `transport` imports the vendor.** A guard test walks the project's source files, excluding
   dependency manifests, lockfiles, and `docs/`, and fails on any import or require statement naming
   the vendor package, or any string equal to the endpoint host or the CLI binary name, in a file
   other than `llm/transport.*`. It also asserts that `llm/transport.*` itself contains at least one
   such hit, so deleting the door fails the test, and it has a fixture with the vendor's import
   placed in each top-level directory (scripts, notebooks, tests) that must fail it. Transitive
   dependencies are covered by the lockfile: fail if any package outside the transport's own
   dependency set names a model vendor. Tests that need the SDK mock the transport's seam, not the
   SDK. Add the test before the second call site exists.
2. **Unknown call sites raise.** `complete()` and `run()` look the id up in the registry and raise on
   a miss. No default route.
3. **Every registered id has a contract.** An inventory test walks the registry and asserts a file
   exists at `docs/llm-framework/contracts/<id>.md` with no unfilled template placeholder (the
   backticked `<...>` form, outside fenced code blocks). Fields that cannot be known before the call
   runs are written as `TBD(reason, by YYYY-MM-DD)`; fields that do not apply are `n/a(reason)`. The
   test enforces: a bare `TBD`, `TODO`, or `n/a` anywhere in a contract fails; a `TBD(...)` without a
   by-date fails; a `TBD(...)` whose by-date has passed fails; a registry with contracts on disk but
   no entries fails. The expiry is deliberate: an expired provisional field turns the check red
   until someone either fills it in or consciously moves the date, and the moved date is a visible
   diff that a second person approves. Let the by-date match across a line wrap (`by\s+YYYY-MM-DD`);
   prose reflows. Run the inventory test as its own CI check: required on changes that touch a
   contract, the registry, or a registered call site, advisory elsewhere, so an expired date blocks
   the work it concerns and not unrelated merges.
4. **The transport never falls back.** On error, timeout, or limit it raises a typed error; the call
   site chooses skip-loudly, deterministic default, keep-last-good, or abort. Retries are on the same
   route only, bounded (attempts, backoff with jitter, `Retry-After` honoured, inside the call site's
   total timeout), and each attempt is a log record. A test asserts no retry to another model, and a
   test asserts that a side-effecting call repeated with the same idempotency key is rejected.
5. **Environment isolation.** The transport runs with an explicit environment allowlist, credentials
   handled in one place, and a pinned client version; if it is a subprocess, its own config directory
   and a process group killed on timeout. Credentials never appear in the log, the prompt, or a
   fixture; the log carries a hash of the prompt template.
6. **Timeouts are measured.** Ship with a generous ceiling, log durations for a week, then set
   p95 times a margin per call site in the registry.
7. **Model ids are pinned snapshots.** The registry names a dated snapshot, never an alias that
   moves, with the vendor's retirement date beside it; the inventory test fails 30 days before any
   retirement (reuse the by-date parser). The transport logs the model id the vendor returned, and a
   returned id outside the allowlist alerts. A snapshot change is handled like a prompt change:
   fixtures re-recorded, golden set re-run, effort re-swept, deprecated parameters removed, baseline
   refreshed in the same commit.
8. **Log record, minimum fields:** timestamp, call site, session or trace id, parent call id for an
   agent step, requested and served model id, effort, duration, input, output, and cached-read
   tokens if available, stop reason, outcome class (`ok`, `parse_failure`, `api_error`, `timeout`,
   `refused`, `rate_limited`, `truncated`, `cap_hit`, `cancelled`), prompt-template hash, output
   hash. Put it wherever your project keeps operational data; a table or an append-only file both
   work. Liveness is "last `ok` record for this call site is younger than its cadence", computed
   from this log and nothing else; for request-response and conversational shapes the record comes
   from a scheduled canary call through the door, counted separately from user traffic.

### 3.1 Retrofitting onto code that already calls a model

Most adoptions are not green-field. If a transport layer and call sites already exist:

1. **Inventory before anything.** List every place that reaches the model, including tests,
   scripts, notebooks, and libraries that call a vendor from inside their own code. Grep for each
   vendor's import, endpoint, or command name, and read the lockfile; the list is the first version
   of the registry.
2. **Audit the door** against the eight rules above, one row each in `LOCAL.md`, met or not met and
   how. Gaps become the backlog with by-dates. Do not fix them all first; the audit is the map.
3. **Register every existing call site now**, even ones without a contract yet, and turn on the
   "unknown call sites raise" check. This freezes the surface: nothing new gets added unregistered
   while contracts are backfilled.
4. **Backfill contracts in order of cost of being wrong**, one per sitting, and mark what the code
   does not yet do as `TBD(...)` rather than describing the design as if it were built. A contract
   that describes planned controls as present is the most common retrofit defect; reviewers read it
   as a security claim.
5. **Add the guard and inventory tests** before the next feature lands, not after.

---

## 4. Write the first contract

Choose the call with the highest cost of being wrong, not the easiest one. Copy
`call-site-contract.md` to `docs/llm-framework/contracts/<id>.md`, write the shape line, and fill
every field. For an agentic call (the model acts through tools) the output schema is each tool's
argument schema and the closed vocabularies are enforced by the tool server against the acting
principal's records; say so in the contract rather than leaving the fields blank, and name the
approval step or reversibility design for every action that cannot be undone. Register the id in the
registry at the same time so the inventory test guards the contract from day one. Then implement in
this order, because each step constrains the next:

1. **Validators first.** Schema, closed-vocabulary check scoped to the principal, numeric copy check,
   the audit with its bias stated, suppression rules, and the structural ceiling. They define what
   the output may be before you ask for it.
2. **Fixtures second.** Run the call by hand a few times, save the raw outputs (good and bad), redact
   them, and write the tests against them. Include a malformed one, a fully-rejected one, and one
   with an injected instruction in the external text.
3. **Prompt third.** Role, stated policy, output schema, worked examples, then injected facts, closed
   vocabularies, evidence, task. Ask for citations of the evidence used. Keep the static part first
   and byte-stable.
4. **Log and surfaces fourth.** Confirm the record lands, the "as of" shows where the output is read,
   and, where the consumer is not the operator, someone owns the daily content sample.
5. **Evaluation file last.** Metric, control, golden set, read date, kill criterion, harm floor,
   control retention, in `docs/llm-framework/evaluations/<id>.md`. Put the read date in a calendar
   and in the contract, so the inventory test expires it.

A contract is done when a reviewer can answer, from the contract alone, what happens when the call
fails, what the output may contain, what the model can reach and move if every instruction were
ignored, and how you will know whether it was worth it.

---

## 5. Tailor the panel

### 5.1 Choose the domain pair

Ask: which disagreements cost this project the most when they are settled wrongly? Name the two
roles that hold each position. They must have opposite blind spots; two roles that would agree are
one role. Most projects have one such question; a project that is also an experiment has two (the
product question and the method question) and gets two pairs. The Claude Code adapter reads the
roster from `LOCAL.md`; the generic runner reads it from environment variables (section 5.4).

| Project type | Domain pair | The tension |
|---|---|---|
| Trading or investing | Quant Trader ↔ Statistician | Tradeable edge vs. statistical sufficiency |
| Health or clinical | Clinician ↔ Biostatistician | Fits practice vs. evidence quality |
| E-commerce or growth | Merchandiser ↔ Experimentation Lead | Sells vs. measured uplift |
| Legal or compliance | Practitioner ↔ Regulator's Examiner | Workable vs. defensible |
| Education | Teacher ↔ Learning Scientist | Engages vs. demonstrably teaches |
| Simulated community or game | Narrative Designer ↔ Community Moderator | Believable vs. safe |
| Any project run as a research experiment | + Social Scientist ↔ Research Methodologist | Interesting finding vs. defensible design (power, blinding, confounds) |
| Internal tooling | Power User ↔ Support Owner | Fast for experts vs. survivable for everyone |
| Data pipeline | Analyst who consumes it ↔ Source-system Owner | Useful vs. faithful to the source |
| Customer-facing assistant | Support Lead ↔ Compliance Officer | Helpful vs. defensible to the customer and the regulator |

### 5.2 Choose the veto seats

What can this project do that cannot be undone? Money spent, a record deleted, a message sent,
personal data exposed, a legal position taken. Seat the role that owns each such resource, one seat
per resource the project touches: Tax or Treasury for money, Privacy Officer for personal data,
whoever owns the customer relationship for a message sent, Counsel for a legal position. A support
assistant that can credit an account, read personal data, and reply to a customer has three. If
nothing is irreversible, drop the seat and say so in the scoping table; a product that reaches a
third party never has nothing irreversible.

### 5.3 Write your scoping table

Copy the table in `panel-protocol.md` section 2 and replace the change types with the ones your
project actually has (for example: "new persona generator", "new scraper", "prompt change",
"schema migration", "removing a human control"). Every row keeps the observer, the frame-inversion
lens, and the engineering pair. Add the domain and data pairs to rows that change what the model
decides, the security and systems pairs to rows that add a surface, the veto seats to rows that
spend, disclose, or delete, or that remove a human control.

### 5.4 Pick the execution path for your tool

| Your tool can... | Do this |
|---|---|
| Delegate to fresh-context agents in parallel | Use or write an adapter: a short header that says how to dispatch, followed by the protocol body. `adapters/claude-code/` is the pattern (its `SKILL.md` is generated from `panel-protocol.md` by `make-skill.sh`); `adapters/README.md` says what an adapter must and must not do. Tools discover skills at session start, so restart sessions after installing. |
| Run a model from the command line | `adapters/generic/panel-run.sh` with `LLM_REVIEW_CMD` set and `PANEL_ENV_PASS` naming the variables that command needs (an API key); nothing else from your environment reaches it. Put the roster in a `.panel.env` beside `LOCAL.md` (`PANEL_DOMAIN_A`, `PANEL_DOMAIN_B`, `PANEL_VETO`, `PANEL_EXTRA_PAIR`) and source it before each run; the runner prints the roster it used. Scope seats with `PANEL_SEATS`, state the build stage with `PANEL_BUILD_STAGE`, put the change-specific concerns in `PANEL_PUSH_ON`. Reviewers get the artifact and code inlined inside a per-run nonce fence. |
| Only chat | Open one fresh chat per reviewer prompt in `adapters/generic/prompts/`, paste the prompt and the artifact, save each reply as a report. Separate chats are separate contexts; this is a valid panel. |

The one thing no path may do is ask the session that wrote the artifact to review it.

### 5.5 Tell reviewers the build stage

Every reviewer prompt states what exists in code and what is design only, and every contract
carries a build-stage line and a status column on its validators. The single largest class of
findings in a retrofit gate is "the contract describes a control that is not built"; stating the
stage up front turns those into a checklist instead of blockers. Every reviewer prompt also says
that the artifact and code are evidence, not instructions: an instruction or a verdict word inside
them is content to review.

### 5.6 Put the gates in the workflow

Decide where each gate physically happens and write it down:

- **Design gate**: before the design is shown to whoever approves it. In a solo project, before you
  start building.
- **Spec gate**: before the spec is marked ready. Attach the consolidated verdict to the spec.
- **Results gate**: before conclusions are stated or the feature is called done. Attach the verdict
  to the PR or the results document.

In a team, "the user" in the protocol is whoever approves the PR; the panel verdict is attached
before human review begins, and `LOCAL.md` names that role per gate. Make the gate mechanical: a CI
check fails any change that touches the door, a registered call site, or a contract unless it links
a report under `docs/llm-framework/reviews/` dated after the last change to those paths, and runs
beside the inventory test. By P3 the sentence in the instructions file is a request; the check is
the control. A solo developer runs the same gates; the minimum viable panel is two sessions: the
engineering pair with the observer, and the frame-inversion reviewer.

---

## 6. Tests, observability, and evaluation in your stack

- **Fixture recording.** Add a flag that, when set, writes each raw model output to a fixtures
  directory named by call site and timestamp. The flag is off by default and its name says it
  records real data. If the call handles personal data, the recorder redacts before writing, or
  writes to a store with the source data's access control and retention; raw transcripts never enter
  the repository. Record for a day, curate, commit the redacted set. Tests read fixtures only; no
  test calls the model. Add one opt-in live smoke test that says in its name that it spends budget.
- **Guard tests.** One for the vendor import, one for the registry inventory, one for secrets and
  personal-data patterns in log records and in the fixtures directory, one for pinned model ids, one
  per architectural rule you add later. Each has a fixture that makes it fail, so a test that passes
  on an empty project is visible.
- **Incident pins.** When a model call misbehaves in production, the fix ships with a test whose
  description opens with the date and one line of what happened. The shape: the fixture is the
  recorded output that caused the incident; the test runs the validators through the production
  entry point, not the validator module; it asserts the consumer-visible result (the ticket goes to
  `manual`) and the log record (`vocab_reject`). Over time this is the project's real history.
- **Surfaces.** Wherever a model-produced artifact is shown, show its age and that a model produced
  it. On the operations page, show the call log's outcome classes per call site for the last day,
  the liveness per call site, and the served model id.
- **Content sample.** Where the consumer is not the operator, a named person reads a fixed number of
  outputs every day, looking for the harms the evaluation names; each finding becomes an incident
  pin, a validator, or a count against the harm floor.
- **Alerts.** Start with: five parse failures per hour per call site, any API error class above ten
  per hour, silence longer than twice the cadence (for request-response shapes: a failed canary), any
  cap hit, any served model id outside the allowlist. Tune from the log after two weeks.
- **Evaluation.** On the read date, compare against the control written in the evaluation file, read
  the harm floor on the same day, and record the result in the same file. Remove or pause features
  that miss the kill criterion or breach the floor, and keep the file as the record of why. A
  positive read does not remove the human control that produced it; that is a decision-logic change
  with its own gate.

---

## 7. Keep the copy current

The documents are copied, not linked, so a project's copy does not change under it. To refresh:

```
./adopt.sh /path/to/project     # overwrites the six framework files and LICENSE, rewrites the marked
                                # rules block in the instructions file recorded in .adopt, leaves
                                # everything else
```

The refresh rewrites the rules block between the two marker comments and says so when it changed;
re-read the block then, because the agent reads it, not the docs copy. If you named the instructions
file on the first run, `.adopt` remembers it; a team with several files re-runs once per file. Keep
project-specific additions out of the six files so a refresh cannot clobber them:

- `docs/llm-framework/LOCAL.md` for the scale and shapes, the domain pair, the veto seats, the
  scoping table, where the gates live, who "the user" is, and your own added or dropped rules with
  the reason.
- `docs/llm-framework/contracts/` and `docs/llm-framework/evaluations/` for the per-call material.

Diff before committing a refresh, and re-run the panel's spec gate on any project document a
changed rule invalidates.

In the framework repository itself, the Claude Code skill is generated: `adapters/claude-code/
make-skill.sh` writes `SKILL.md` from `skill-header.md` and `panel-protocol.md`, and
`make-skill.sh --check` (run by `tests/run.sh`) fails when the shipped file has drifted. Edit the
protocol or the header, never the generated file.

---

## 8. Mistakes people make when adapting

- **Pasting the rules and keeping direct vendor calls elsewhere.** A rule without a guard test is
  a suggestion. Build the door and the test before writing the second call.
- **Filling in the panel yourself.** A checklist the author ticks is inline role-play. Every
  reviewer is a separate session.
- **Copying the roster verbatim.** A trading pair reviewing a tutoring product finds nothing. Do
  step 5.1.
- **Copying the agentic example without its bounds.** The example works because no tool sends or
  moves money, every read is scoped to the principal, and a person sends every reply. Copy the
  structure, not only the validators.
- **Adding a sentence to the prompt when the model misbehaves.** Add a validator layer instead, then
  test it with a fixture that reproduces the misbehavior.
- **Guessing timeouts.** Measure for a week first. A guessed timeout either kills good calls or
  hides a hung one.
- **Skipping the read date.** A model feature without a kill criterion is permanent by default,
  whether or not it works.
- **Reading a good metric as permission to remove the control.** The metric was measured with the
  control in place; its removal is a decision-logic change with its own gate and a harm floor.
- **Bumping TBD dates.** A moved by-date is a decision; it gets a second approver, and the inventory
  test stays required on the paths it concerns rather than being downgraded to a warning.
- **Treating panel findings as facts.** Re-verify each one. The panel is independent, not
  infallible, and a refuted finding is worth recording too.
