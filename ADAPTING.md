# Adapting the framework to your project

This is the step-by-step guide. `README.md` says what the framework is; this file says how to make
it yours: which parts apply at your scale and shape, how to install the documents, how to build the
one door in your language, how to tailor the panel to your domain and your tool, and how to keep the
copy current. Budget an afternoon for steps 1, 2, and 4 on a green-field project with one simple
call site; a day for step 3 (the door and its tests); half a day per further call site for step 4 (a
day for an agentic one; the template has about 120 fields and the honest figure for a known call is
five to six hours); and half a day for the first panel gate. A retrofit costs about a day per
existing call site including fixtures, plus the first gate, which on an existing codebase will find
defects in code the artifact merely describes; folding those in is part of adoption, not a detour
from it. Fund a retrofit as a project, not a side task. Fields that need production data (latency,
cadence, alert thresholds) take two weeks of logging to fill, however fast the rest goes.

---

## 1. Decide the scale and the shape first

The framework is proportionate by design. Pick the row that describes the project and adopt that
column; grow into the next row when the project does. Capability and audience decide the row, not
size: the moment the model can act through a tool, or the output reaches anyone but the person
running it, the project is Agentic or Service whatever its size.

| Scale | What it looks like | Mandatory | Optional until it hurts |
|---|---|---|---|
| **Script** | One or two model calls, one person, output read by that person | Injected facts, structured output with schema validation, one function that makes the call, a log line per call, one recorded and redacted fixture, one separate reviewer session before relying on it, and no tool the model can call (otherwise the Agentic row) | Registry, throttle, evaluation file, full panel |
| **Service** | Calls in production, other code or people depend on the output | Everything in the core: contract per call, one door with guard and inventory tests, validator layers, failure policy, per-call log with outcome classes, staleness surfaces, incident-pinned tests, pinned model snapshots, evaluation with a read date and a harm floor, panel at the three gates | Throttle with live utilization, drift detection |
| **Agentic product** | The model can act: call tools, write data, message people | Everything above, plus tool allowlists, a tool server that receives the acting principal from the door and scopes every read and write to that principal's entitlement, a sandbox with an egress allowlist, hard caps, a human approval step or reversibility design for every irreversible action, a nonce fence on all external text, redacted transcripts with a retention, a content sample drawn by code, one veto seat per irreversible resource, and the security and systems pairs at every gate | Nothing; all of it applies |

Then name the shape of each call: scheduled artifact, request-response, conversation, or agentic
session. The contract template tags the fields that belong to particular shapes; a call deletes the
tagged sections it does not use and names them on its Shape line. Which sections each shape keeps:

| Shape | Keeps | Deletes |
|---|---|---|
| Scheduled artifact | delta condition, cadence, last-good artifact with TTL, staleness surface, liveness from cadence | Context, Streaming, Iteration loop, loop caps, resources the model can move, committed tool actions, event rows, tools, reads, writes, irreversible actions, sandbox |
| Request-response | Streaming, canary liveness, per-user cadence | delta condition, last-good artifact, Context, Iteration loop, and the agentic fields above |
| Conversation | Streaming, Context, Iteration loop, canary liveness; prior turns are context, not facts | delta condition, last-good artifact, and the agentic fields unless the conversation has tools |
| Agentic session | Context, Iteration loop, loop caps, resources, committed actions, event rows, tools, reads, writes, irreversible actions, sandbox, rule of two | delta condition, Streaming, last-good artifact |

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
comments, which must stay at column 1 as one pair. If no instructions file exists it infers the tool
from its config directory and says which file it chose; check that your tool actually reads that
file. If several candidate files exist it uses the first and names the others; a team whose tools
read different files runs the script once per file. Re-running is safe: it checks everything before
writing anything, refreshes the six files and the marked block in place, never touches `LOCAL.md`,
`contracts/`, or `evaluations/`, and prints the section headings the current template has that
`LOCAL.md` lacks. The rules block is read by the agent on every task; a
team whose tool supports path-scoped instruction files places it so that it loads for the door and
the contracts.

Without the script: copy the same files and paste `agent-rules.md` into whatever your coding agent
reads. If your team uses no coding agent, paste it into `CONTRIBUTING.md` and add the pull-request
checklist below (2.1) to the PR template. The rules are for people as much as for
agents.

The script creates:

```
docs/llm-framework/LOCAL.md       # scale, shapes, roster, scoping table, gates, door audit, vendor terms, backlog, review log
docs/llm-framework/.adopt         # instructions file (contained to the project), source repository, framework commit
docs/llm-framework/contracts/     # one call-site contract per model call
docs/llm-framework/evaluations/   # one pre-registration per model feature (copy evaluation.md)
docs/llm-framework/reviews/       # panel reports, one directory per gate; the CI check reads this path
```

If the project already has a door module, do the door audit in `LOCAL.md` before writing any
contract: one row per rule in section 3, met or not met and how. The gaps become the first backlog.

### 2.1 Pull-request checklist for any change touching a model call

- [ ] Contract updated; no blank fields; every `n/a` has a reason; deleted sections are named on the
      Shape line.
- [ ] New or changed facts are injected, not requested.
- [ ] New identifiers are in a closed vocabulary with a validator scoped to the principal.
- [ ] Output schema changed at generation time, not parsed from prose.
- [ ] Failure policy named and tested with a recorded failure fixture.
- [ ] Timeout justified by a measurement.
- [ ] Model id is a pinned snapshot with its lifecycle date recorded.
- [ ] Any irreversible action the model can reach has its approval step or reversal path named.
- [ ] Fixtures added are redacted.
- [ ] Call log outcome classes cover the new failure modes.
- [ ] Regression test description names the incident, or the change is not a fix.
- [ ] Prompt-template hash baseline refreshed if the prompt changed; a changed static prefix notes
      the expected cache-hit drop; golden-set result linked.
- [ ] Panel report linked; blockers resolved; modifications folded in.

---

## 3. Build the one door

One module owns every model call. Its shape is the same in any language:

```
llm/
  transport     talks to the vendor (HTTP, SDK, or a command-line client); the ONLY file that
                imports the vendor library or names its endpoint; one transport per vendor, all
                behind the same door
  complete()    the entry point for one call: complete(call_site, prompt, schema, effort, timeout)
  run()         the entry point for a loop: run(call_site, principal, messages, tools, effort,
                timeout, caps); the principal comes from the authenticated request, never from the
                model
  registry      the allowlist: call-site id -> owner, contract path, pinned model snapshot and its
                lifecycle date, default effort, timeout, daily cap, tool allowlist with the hash of
                each controlled server's tool list
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
3. **Every registered id has a contract, and the contract is honest.** The inventory test has two
   parts. The structural part walks the registry and asserts a file exists at
   `docs/llm-framework/contracts/<id>.md` with no unfilled template placeholder (the backticked
   `<...>` form, outside fenced code blocks), no bare `TBD`, `TODO`, or `n/a`, no empty cell in the
   tables of sections 3 and 6, and a registry that is not empty when `contracts/` has files; it runs
   on every change and is required on changes that touch a contract, the registry, or a registered
   call site. The calendar part reads the dates: a `TBD(reason, by YYYY-MM-DD)` or a
   `planned(by YYYY-MM-DD)` whose date has passed fails; a section 10 read date that has passed while
   the evaluation file's Result is empty fails; a model lifecycle date within 30 days fails (rule 7);
   a "Contract last reviewed" older than 180 days warns. The calendar part fails only for entries
   whose contract or registry row is in the change under test, and a scheduled daily run evaluates
   it for all entries and opens one issue per expiry, so an expired date blocks the work it concerns
   and not unrelated merges. The expiry is deliberate: a provisional field turns red until someone
   either fills it in or consciously moves the date, and the moved date is a visible diff that a
   second person approves. Let the by-date match across a line wrap (`by\s+YYYY-MM-DD`); prose
   reflows. A section the Shape line lists as deleted is accepted as absent.
4. **The transport never falls back.** On error, timeout, or limit it raises a typed error; the call
   site chooses skip-loudly, deterministic default (visibly a default where it is read), keep-last-good,
   or abort. Retries are on the same route only, bounded (attempts, backoff with jitter,
   `Retry-After` honoured, inside the call site's total timeout), and each attempt is a log record.
   A side-effecting call carries an idempotency key minted by the door per logical operation,
   identical across retries, never including an attempt counter or a timestamp. A test asserts no
   retry to another model, and a test asserts that a repeat with the same key is rejected by the
   tool server.
5. **Environment isolation.** The transport runs with an explicit environment allowlist, credentials
   handled in one place, and a pinned client version; if it is a subprocess, its own config directory
   and a process group that receives SIGTERM on timeout and SIGKILL after a grace period, so no
   credentialed process is orphaned. Credentials never appear in the log, the prompt, or a fixture;
   the log carries a hash of the prompt template.
6. **Timeouts are measured.** Ship with a generous ceiling, log durations for a week, then set
   p95 times a margin per call site in the registry.
7. **Model ids are fixed snapshots with a lifecycle date.** The registry names an id the vendor
   documents as a fixed snapshot (dated where the vendor dates them), never one documented as
   moving (`-latest`, a bare family alias, a "stable" pointer the vendor may hot-swap). Beside it:
   `retires YYYY-MM-DD`, `retires not before YYYY-MM-DD`, or `no retirement published, lifecycle
   page checked YYYY-MM-DD`; the calendar check fails 30 days before either retirement form and
   when the checked date is older than 90 days, and the door audit names who watches the vendor's
   lifecycle page. A vendor notice shorter than 30 days is recorded the day it arrives. Preview or
   experimental ids are not pinned in production. The transport logs the model id the vendor
   returned, and a returned id outside the allowlist alerts. A pinned id is a promise about weights,
   not about serving: the liveness canary's output is compared with its recorded fixture and a
   difference beyond the stated tolerance alerts as drift. A snapshot change is handled like a prompt
   change: fixtures re-recorded, golden set re-run, effort re-swept, deprecated parameters removed,
   baseline refreshed in the same commit.
8. **Log record, minimum fields:** timestamp, call site, acting principal as an opaque id where the
   call runs for more than one, session or trace id, parent call id for an agent step, requested and served model id, effort, duration, input, output, and cached-read
   tokens if available, stop reason, whether external text was read (`read_external`), outcome class
   (`ok`, `parse_failure`, `api_error`, `timeout`, `refused`, `rate_limited`, `truncated`, `cap_hit`,
   `cancelled`; exactly one per call: `timeout` is the transport's time limit, `cap_hit` a
   door-enforced budget, `cancelled` an external decision before completion), prompt-template hash,
   output hash. Put it wherever your project keeps operational data; a table or an append-only file
   both work. Liveness is "last `ok` record for this call site is younger than its cadence",
   computed from this log and nothing else, per principal for a scheduled artifact produced per
   principal; for request-response and conversational shapes the
   record comes from a scheduled canary call through the door against a synthetic principal, counted
   separately from user traffic.

Tool servers the project controls are pinned in the registry by a hash over each server's tool list
in canonical form (name, description, input schema, keys sorted). The door fetches the list when it
connects, refuses to start the session on a mismatch (outcome `refused`, alert), and aborts a session
whose server announces a changed list. The inventory test compares the registry hash with a recorded
fixture of the list, so re-approval is a reviewed diff of that fixture in the same commit as the new
hash. Third-party servers are pinned by version with a review on each bump; the contract says which.

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
`call-site-contract.md` to `docs/llm-framework/contracts/<id>.md`, write the shape line, delete the
tagged sections the shape does not use, and fill every field that remains. For an agentic call (the
model acts through tools) the output schema is each tool's argument schema and the closed
vocabularies are enforced by the tool server against the consumer's entitlement; say so in the
contract rather than leaving the fields blank, and name the approval step or reversibility design for
every action that cannot be undone. Register the id in the registry at the same time so the
inventory test guards the contract from day one. Then implement in this order, because each step
constrains the next:

1. **Validators first.** Schema, closed-vocabulary check scoped to the entitlement, numeric copy
   check, the audit with its bias stated, suppression rules, and the structural ceiling. They define
   what the output may be before you ask for it.
2. **Fixtures second.** Run the call by hand a few times, save the raw outputs (good and bad), redact
   them, and write the tests against them. Include a malformed one, a fully-rejected one, one with
   an injected instruction in the external text, and one that reads a record owned by another
   principal.
3. **Prompt third.** Role, stated policy, output schema, worked examples, then injected facts, closed
   vocabularies, evidence, task. Ask for citations of the evidence used. Keep the static part first
   and byte-stable.
4. **Log and surfaces fourth.** Confirm the record lands, the "as of" shows where the output is read,
   and, where the consumer is not the operator, someone owns the content sample.
5. **Evaluation file last.** Metric, control, dev set, golden set, read date, kill criterion, harm
   floor sized to the rate it must exclude, control retention, in
   `docs/llm-framework/evaluations/<id>.md`. Put the read date in a calendar and in the contract, so
   the inventory test expires it.

A contract is done when a reviewer can answer, from the contract alone, what happens when the call
fails, what the output may contain, whose data the model can see and move if every instruction were
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
whoever owns the customer relationship for a message sent, Counsel for a legal position. If nothing
is irreversible, drop the seat and say so in the scoping table; a product that reaches a third party
never has nothing irreversible.

### 5.3 Write your scoping table

Copy the table in `panel-protocol.md` section 2 and replace the change types with the ones your
project actually has (for example: "new persona generator", "new scraper", "prompt change",
"schema migration", "removing a human control", "a data source another team owns changed"). Every
row keeps the observer, the Frame-Inversion Reviewer, and the engineering pair. Add the domain and
data pairs to rows that change what the model decides, the security and systems pairs to rows that
add a surface, the veto seats to rows that spend, disclose, or delete, or that remove a human control.
A documentation artifact gets a Technical Writer as the Experience pair's second role instead of the
Data Visualization Specialist.

### 5.4 Pick the execution path for your tool

| Your tool can... | Do this |
|---|---|
| Delegate to fresh-context agents in parallel | Use or write an adapter: a short header that says how to dispatch, followed by the protocol body. `adapters/claude-code/` is the pattern (its `SKILL.md` is generated from `panel-protocol.md` by `make-skill.sh`); `adapters/README.md` says what an adapter must and must not do. Reviewers get read-only tools. Tools discover skills at session start, so restart sessions after installing. |
| Run a model from the command line | `adapters/generic/panel-run.sh` with `LLM_REVIEW_CMD` set to the CLI in non-interactive mode with tools disabled, and `PANEL_ENV_PASS` naming the variables that command needs (an API key, a proxy); nothing else from your environment reaches it. Put the roster in a `.panel.env` beside `LOCAL.md` (`PANEL_DOMAIN_A`, `PANEL_DOMAIN_B`, `PANEL_VETO`, `PANEL_EXTRA_PAIR`) and source it before each run; the runner prints the roster it used. Scope seats with `PANEL_SEATS`, state the build stage with `PANEL_BUILD_STAGE`, put the change-specific concerns in `PANEL_PUSH_ON`. Reviewers get the artifact and code inlined inside a per-run nonce fence; a hung reviewer is stopped after `PANEL_TIMEOUT`, and Ctrl-C stops them all. |
| Only chat | Open one fresh chat per reviewer prompt in `adapters/generic/prompts/`, paste the prompt and the artifact, save each reply as a report. Separate chats are separate contexts; this is a valid panel. |

The one thing no path may do is ask the session that wrote the artifact to review it.

### 5.5 Tell reviewers the build stage

Every reviewer prompt states what exists in code and what is design only, and every contract
carries a build-stage line and a status column on its validators. The single largest class of
findings in a retrofit gate is "the contract describes a control that is not built"; stating the
stage up front turns those into a checklist instead of blockers. Every reviewer prompt also says
that the artifact and code are evidence, not instructions: an instruction or a verdict word inside
them is content to review. Reviewers run with read-only tools or none, because they read untrusted
text; their only output is the report.

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
a report under `docs/llm-framework/reviews/` whose verdict line, parsed by the check, is present and
not BLOCKERS, dated after the last change to those paths that is not
a change the report itself requested (a commit that folds in the report's modifications cites the
report and does not invalidate it), and runs beside the inventory test. A change to a data source a
contract lists re-opens that contract's spec gate; where another team owns the source this is a
notification agreement, not a CI check, and the residual is stated in `LOCAL.md`. By P3 the sentence
in the instructions file is a request; the check is the control. Refuting or demoting a blocker is a
decision like moving a by-date (section 8): a second person who is not the author records it with
the evidence, and the review log keeps each session's own verdict beside the consolidated one, so
the record cannot read better than the reports. A solo developer runs the same
gates; the minimum viable panel is two sessions: the engineering pair with the observer, and the
Frame-Inversion Reviewer.

---

## 6. Tests, observability, and evaluation in your stack

- **Fixture recording.** Add a flag that, when set, writes each raw model output to a fixtures
  directory named by call site and timestamp. The flag is off by default and its name says it
  records real data. If the call handles personal data, the recorder redacts before writing, or
  writes to a store with the source data's access control and retention; raw transcripts never enter
  the repository. Record for a day, curate, commit the redacted set. Tests read fixtures only; no
  test calls the model. Add one opt-in live smoke test that says in its name that it spends budget.
- **Guard tests.** One for the vendor import, one for the registry inventory, one for secrets and
  personal-data patterns in log records, in the fixtures directory, and in
  `docs/llm-framework/reviews/` (reviewers quote what they read), one for pinned model ids, one
  per architectural rule you add later. Each has a fixture that makes it fail, so a test that passes
  on an empty project is visible.
- **Entitlement tests.** For every call that shows the model evidence about a person or a tenant, a
  fixture record owned by another principal (and one with no owner) is never shown, emitted, or
  served, tested through the production entry point on the success path and on each failure-policy
  path (a failure for principal A after a success for principal B serves A nothing of B's); and a
  request authenticated as A cannot be bound to B.
- **Incident pins.** When a model call misbehaves in production, the fix ships with a test whose
  description opens with the date and one line of what happened. The shape: the fixture is the
  recorded output that caused the incident; the test runs the validators through the production
  entry point, not the validator module; it asserts the consumer-visible result (the ticket goes to
  `manual`) and the log record (`vocab_reject`). Over time this is the project's real history.
- **Surfaces.** Wherever a model-produced artifact is shown, show its age, whether a model produced
  it or a default was served, and the oldest evidence date where it rests on retrieved evidence. On
  the operations page, show the call log's outcome classes per call site for the last day, the
  liveness per call site, defaults served, and the served model id.
- **Content sample.** Where the consumer is not the operator, code draws a random sample across the
  period (including the outputs the audit held or the agent discarded), sized so the harm floor's
  rate would appear within a week; a named person who is not the approver reads it where the data
  already lives, under its access control; each read is logged and a period without a read alerts.
  A spreadsheet export is a second copy with its own retention; do not make one. Each finding
  becomes an incident pin, a validator, or a count against the harm floor. The sample's size and
  cadence are reviewed at the read date and never fall below the floor's detection requirement.
- **Alerts.** Start with: five parse failures per hour per call site, any API error class above ten
  per hour, silence longer than twice the cadence (for request-response shapes: a failed canary), any
  cap hit, any served model id outside the allowlist, a canary output that differs from its fixture,
  defaults or last-good artifacts served to one principal above a stated count per period. Tune from
  the log after two weeks.
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
re-read the block then, because the agent reads it, not the docs copy. It also prints the section
headings `LOCAL.template.md` has that your `LOCAL.md` lacks; add them, since contracts and reviewers
point at them. Re-run your tool's adapter installer (`adapters/claude-code/install.sh`) after each
update so the installed skill matches the protocol. If the markers are damaged
(indented, duplicated, one missing) the script refuses and changes nothing; fix the marker lines by
hand. Marker lines quoted inside a ``` fence are documentation and are left alone; CRLF line endings
and a leading BOM are kept; a symlinked instructions file is refused, pass its target. If you named the instructions file on the first run, `.adopt` remembers it; a team with
several files re-runs once per file. Keep project-specific additions out of the six files so a
refresh cannot clobber them:

- `docs/llm-framework/LOCAL.md` for the scale and shapes, the domain pair, the veto seats, the
  scoping table, where the gates live, who "the user" is, the vendor terms, and your own added or
  dropped rules with the reason.
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
  a suggestion. Build the door and the test before writing the second call. Without the door, the
  contract still forces the consumer question and the validators-before-prompt order; keep those two
  even if the door waits a quarter, and say so in `LOCAL.md`.
- **Filling in the panel yourself.** A checklist the author ticks is inline role-play. Every
  reviewer is a separate session.
- **Copying the roster verbatim.** A trading pair reviewing a tutoring product finds nothing. Do
  step 5.1.
- **Copying the agentic example without its bounds.** The example works because no tool sends or
  moves money, every read is scoped to the consumer's entitlement by a principal the door binds, and
  a person sends every reply. Copy the structure, not only the validators.
- **Letting a service identity be the acting principal.** The identity that runs the call is not
  the party whose entitlement bounds the output. Narrow every read and every piece of evidence to
  that party's entitlement, one consumer per call.
- **Adding a sentence to the prompt when the model misbehaves.** Add a validator layer instead, then
  test it with a fixture that reproduces the misbehavior.
- **Guessing timeouts.** Measure for a week first. A guessed timeout either kills good calls or
  hides a hung one.
- **Skipping the read date.** A model feature without a kill criterion is permanent by default,
  whether or not it works.
- **Reading a good metric as permission to remove the control.** The metric was measured with the
  control in place; its removal is a decision-logic change with its own gate and a harm floor.
- **Bumping TBD dates.** A moved by-date is a decision; it gets a second approver, and the calendar
  check stays required on the paths it concerns rather than being downgraded to a warning.
- **Filling the template with `n/a`.** A shape that needs seventeen `n/a` fields is using the wrong
  sections: delete the tagged sections it does not use and name them on the Shape line.
- **Treating panel findings as facts.** Re-verify each one. The panel is independent, not
  infallible, and a refuted finding is worth recording too.
